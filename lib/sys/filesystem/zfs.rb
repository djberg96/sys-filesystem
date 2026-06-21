# frozen_string_literal: true

module Sys
  class Filesystem
    # Public libzfs-backed helpers for ZFS datasets.
    class ZFS
      ZFS_TYPE_INVALID = 0
      ZFS_TYPE_FILESYSTEM = 1
      ZFS_TYPE_SNAPSHOT = 2
      ZFS_TYPE_VOLUME = 4
      ZFS_TYPE_BOOKMARK = 8
      ZFS_TYPE_POOL = 16
      ZFS_TYPE_DATASET = ZFS_TYPE_FILESYSTEM | ZFS_TYPE_SNAPSHOT | ZFS_TYPE_VOLUME | ZFS_TYPE_BOOKMARK
      DEFAULT_BUFFER_SIZE = 8192

      TYPES = {
        filesystem: ZFS_TYPE_FILESYSTEM,
        snapshot: ZFS_TYPE_SNAPSHOT,
        volume: ZFS_TYPE_VOLUME,
        bookmark: ZFS_TYPE_BOOKMARK,
        pool: ZFS_TYPE_POOL,
        dataset: ZFS_TYPE_DATASET,
        all: ZFS_TYPE_DATASET
      }.freeze

      TYPE_NAMES = TYPES.invert.merge(
        ZFS_TYPE_INVALID => :invalid,
        ZFS_TYPE_DATASET => :dataset
      ).freeze

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

      private_constant :DEFAULT_BUFFER_SIZE

      private_class_method :new

      # Represents a ZFS filesystem dataset.
      class Dataset
        attr_reader :name, :type

        def initialize(name, type = nil)
          @name = name.to_s
          @type = type
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

      def self.list(type: :dataset)
        return [] unless zfs_functions?(:zfs_iter_root, :zfs_get_name, :zfs_get_type)

        datasets = []
        desired_type = zfs_type(type)

        with_handle do |handle|
          callback = iterator_callback(datasets, desired_type)
          return [] if Filesystem.send(:zfs_iter_root, handle, callback, nil).negative?
        end

        datasets
      rescue FFI::NotFoundError, SystemCallError
        []
      end

      def self.children(dataset, type: :dataset)
        return [] unless zfs_functions?(:zfs_iter_children, :zfs_get_name, :zfs_get_type)

        datasets = []
        desired_type = zfs_type(type)

        with_handle do |handle|
          with_dataset(handle, dataset.to_s, ZFS_TYPE_DATASET) do |zfs_handle|
            callback = iterator_callback(datasets, desired_type)
            return [] if Filesystem.send(:zfs_iter_children, zfs_handle, callback, nil).negative?
          end
        end

        datasets
      rescue FFI::NotFoundError, SystemCallError
        []
      end

      def self.exists?(dataset, type: :dataset)
        return false unless zfs_functions?(:zfs_dataset_exists)

        with_handle do |handle|
          return Filesystem.send(:zfs_dataset_exists, handle, dataset.to_s, zfs_type(type)) == 1
        end

        false
      rescue FFI::NotFoundError, SystemCallError
        false
      end

      def self.create(dataset, type: :filesystem, parents: false)
        return false unless zfs_functions?(:zfs_create)

        with_handle do |handle|
          return false if parents &&
                          (!zfs_functions?(:zfs_create_ancestors) ||
                           !Filesystem.send(:zfs_create_ancestors, handle, dataset.to_s).zero?)

          return Filesystem.send(:zfs_create, handle, dataset.to_s, zfs_type(type), nil).zero?
        end

        false
      rescue FFI::NotFoundError, SystemCallError
        false
      end

      def self.destroy(dataset, defer_destroy: false, type: :dataset)
        return false unless zfs_functions?(:zfs_destroy)

        with_handle do |handle|
          with_dataset(handle, dataset.to_s, zfs_type(type)) do |zfs_handle|
            return Filesystem.send(:zfs_destroy, zfs_handle, boolean(defer_destroy)).zero?
          end
        end

        false
      rescue FFI::NotFoundError, SystemCallError
        false
      end

      def self.snapshot(snapshot, recursive: false)
        return false unless zfs_functions?(:zfs_snapshot)

        with_handle do |handle|
          return Filesystem.send(:zfs_snapshot, handle, snapshot.to_s, boolean(recursive), nil).zero?
        end

        false
      rescue FFI::NotFoundError, SystemCallError
        false
      end

      def self.mount(dataset, options: nil, flags: 0)
        return false unless zfs_functions?(:zfs_mount)

        with_handle do |handle|
          with_dataset(handle, dataset.to_s) do |zfs_handle|
            return Filesystem.send(:zfs_mount, zfs_handle, options, flags.to_i).zero?
          end
        end

        false
      rescue FFI::NotFoundError, SystemCallError
        false
      end

      def self.unmount(dataset, mountpoint: nil, flags: 0)
        return false unless zfs_functions?(:zfs_unmount)

        with_handle do |handle|
          with_dataset(handle, dataset.to_s) do |zfs_handle|
            return Filesystem.send(:zfs_unmount, zfs_handle, mountpoint, flags.to_i).zero?
          end
        end

        false
      rescue FFI::NotFoundError, SystemCallError
        false
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

      def self.open(dataset, type: :filesystem)
        return nil unless Filesystem.respond_to?(:libzfs_init, true)

        dataset_name = dataset.to_s
        desired_type = zfs_type(type)
        opened = false
        actual_type = nil

        with_handle do |handle|
          with_dataset(handle, dataset_name, desired_type) do |zfs_handle|
            opened = true
            actual_type = dataset_type(zfs_handle) if zfs_functions?(:zfs_get_type)
          end
        end

        return nil unless opened

        dataset = Dataset.new(dataset_name, type_name(actual_type || desired_type))

        if block_given?
          yield dataset
        else
          dataset
        end
      end

      def self.property(dataset, property)
        return nil unless zfs_functions?(:zfs_name_to_prop, :zfs_prop_get)

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

      def self.zfs_functions?(*function_names)
        function_names.all?{ |function_name| Filesystem.respond_to?(function_name, true) }
      end

      private_class_method :zfs_functions?

      def self.zfs_type(type)
        return type if type.is_a?(Integer)

        TYPES.fetch(type.to_sym)
      rescue KeyError, NoMethodError
        raise ArgumentError, "invalid ZFS type: #{type.inspect}"
      end

      private_class_method :zfs_type

      def self.type_name(type)
        TYPE_NAMES[type]
      end

      private_class_method :type_name

      def self.boolean(value)
        value ? 1 : 0
      end

      private_class_method :boolean

      def self.dataset_type(zfs_handle)
        Filesystem.send(:zfs_get_type, zfs_handle)
      end

      private_class_method :dataset_type

      def self.dataset_matches_type?(actual_type, desired_type)
        actual_type.anybits?(desired_type)
      end

      private_class_method :dataset_matches_type?

      def self.iterator_callback(datasets, desired_type)
        proc do |zfs_handle, _data|
          begin
            actual_type = dataset_type(zfs_handle)
            if dataset_matches_type?(actual_type, desired_type)
              datasets << Dataset.new(Filesystem.send(:zfs_get_name, zfs_handle), type_name(actual_type))
            end
          ensure
            Filesystem.send(:zfs_close, zfs_handle) if zfs_handle && !zfs_handle.null?
          end

          0
        end
      end

      private_class_method :iterator_callback

      def self.with_handle
        handle = Filesystem.send(:libzfs_init)
        return nil if handle.null?

        yield handle
      ensure
        Filesystem.send(:libzfs_fini, handle) if handle && !handle.null?
      end

      private_class_method :with_handle

      def self.with_dataset(handle, dataset, type = ZFS_TYPE_FILESYSTEM)
        zfs_handle = Filesystem.send(:zfs_open, handle, dataset, type)
        return nil if zfs_handle.null?

        yield zfs_handle
      ensure
        Filesystem.send(:zfs_close, zfs_handle) if zfs_handle && !zfs_handle.null?
      end

      private_class_method :with_dataset
    end
  end
end
