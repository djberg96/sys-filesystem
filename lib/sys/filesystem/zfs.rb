# frozen_string_literal: true

module Sys
  class Filesystem
    # Public libzfs-backed helpers for ZFS datasets.
    class ZFS
      ZFS_TYPE_FILESYSTEM = 1
      DEFAULT_BUFFER_SIZE = 8192

      PROPERTIES = {
        atime: 'atime',
        casesensitivity: 'casesensitivity',
        compression: 'compression',
        compressratio: 'compressratio',
        devices: 'devices',
        exec: 'exec',
        quota: 'quota',
        readonly: 'readonly',
        recordsize: 'recordsize',
        reservation: 'reservation',
        setuid: 'setuid'
      }.freeze

      private_constant :ZFS_TYPE_FILESYSTEM, :DEFAULT_BUFFER_SIZE

      private_class_method :new

      # Represents a ZFS filesystem dataset.
      class Dataset
        attr_reader :name

        def initialize(name)
          @name = name.to_s
        end

        def property(property)
          ZFS.property(name, property)
        end

        PROPERTIES.each do |method_name, property_name|
          define_method(method_name) do
            property(property_name)
          end
        end
      end

      def self.available?
        return false unless Filesystem.respond_to?(:libzfs_init, true)

        handle = Filesystem.send(:libzfs_init)
        return false if handle.null?

        true
      rescue FFI::NotFoundError, SystemCallError
        false
      ensure
        Filesystem.send(:libzfs_fini, handle) if handle && !handle.null?
      end

      def self.open(dataset)
        return nil unless Filesystem.respond_to?(:libzfs_init, true)

        dataset_name = dataset.to_s
        opened = false

        with_handle do |handle|
          with_dataset(handle, dataset_name) do |_zfs_handle|
            opened = true
          end
        end

        return nil unless opened

        dataset = Dataset.new(dataset_name)

        if block_given?
          yield dataset
        else
          dataset
        end
      end

      def self.property(dataset, property)
        return nil unless Filesystem.respond_to?(:libzfs_init, true)

        property = property.to_s
        cache = property_cache if property == 'casesensitivity'
        key = [dataset.to_s, property]

        return cache[key] if cache&.key?(key)

        value = nil

        with_handle do |handle|
          with_dataset(handle, dataset.to_s) do |zfs_handle|
            prop = Filesystem.send(:zfs_name_to_prop, property)
            return nil if prop < 0

            buffer = FFI::MemoryPointer.new(:char, DEFAULT_BUFFER_SIZE)

            if Filesystem.send(:zfs_prop_get, zfs_handle, prop, buffer, buffer.size, nil, nil, 0, 0).zero?
              value = buffer.read_string
            end
          end
        end

        cache[key] = value if cache && value
        value
      rescue FFI::NotFoundError, SystemCallError
        nil
      end

      def self.properties(dataset, *properties)
        properties.flatten.to_h do |property|
          [property.to_s, self.property(dataset, property)]
        end
      end

      PROPERTIES.each do |method_name, property_name|
        define_singleton_method(method_name) do |dataset|
          property(dataset, property_name)
        end
      end

      def self.property_cache
        @property_cache ||= {}
      end

      private_class_method :property_cache

      def self.with_handle
        handle = Filesystem.send(:libzfs_init)
        return nil if handle.null?

        yield handle
      ensure
        Filesystem.send(:libzfs_fini, handle) if handle && !handle.null?
      end

      private_class_method :with_handle

      def self.with_dataset(handle, dataset)
        zfs_handle = Filesystem.send(:zfs_open, handle, dataset, ZFS_TYPE_FILESYSTEM)
        return nil if zfs_handle.null?

        yield zfs_handle
      ensure
        Filesystem.send(:zfs_close, zfs_handle) if zfs_handle && !zfs_handle.null?
      end

      private_class_method :with_dataset
    end
  end
end
