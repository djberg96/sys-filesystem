# frozen_string_literal: true

require 'rbconfig'

if File::ALT_SEPARATOR
  require_relative 'windows/sys/filesystem'
else
  require_relative 'unix/sys/filesystem'
end

# Methods and properties universal to all platforms

# The Sys module serves as a namespace only.
module Sys
  # The Filesystem class serves as an abstract base class. Its methods
  # return objects of other types. Do not instantiate.
  class Filesystem
    # The version of the sys-filesystem library
    VERSION = '1.5.5'

    # Stat objects are returned by the Sys::Filesystem.stat method. Here
    # we're adding universal methods.
    class Stat
      ZFS_PROPERTIES = {
        zfs_atime: 'atime',
        zfs_casesensitivity: 'casesensitivity',
        zfs_compression: 'compression',
        zfs_compressratio: 'compressratio',
        zfs_devices: 'devices',
        zfs_exec: 'exec',
        zfs_quota: 'quota',
        zfs_readonly: 'readonly',
        zfs_recordsize: 'recordsize',
        zfs_reservation: 'reservation',
        zfs_setuid: 'setuid'
      }.freeze

      # Returns true if the filesystem is case sensitive for the current path.
      # Typically this will be any path on MS Windows or Macs using HFS.
      #
      # For a root path (really any path without actual a-z characters) we
      # take a best guess based on the host operating system. However, as a
      # general rule, I do not recommend using this method for a root path.
      #
      def case_insensitive?
        if path =~ /\w+/
          File.identical?(path, path.swapcase)
        else
          zfs_case = zfs_case_insensitive?
          return zfs_case unless zfs_case.nil?

          if RbConfig::CONFIG['host_os'] =~ /darwin|mac|windows|mswin|mingw/i
            true # Assumes HFS/APFS on Mac
          else
            false
          end
        end
      end

      # Opposite of case_insensitive?
      #
      def case_sensitive?
        !case_insensitive?
      end

      # Returns a native ZFS property value for this path's dataset.
      # Returns nil if the path is not on ZFS or libzfs is unavailable.
      def zfs_property(property)
        return nil unless base_type == 'zfs'
        return nil unless Sys::Filesystem.respond_to?(:zfs_property, true)

        dataset = zfs_dataset
        return nil unless dataset

        Sys::Filesystem.send(:zfs_property, dataset, property.to_s)
      rescue SystemCallError
        nil
      end

      ZFS_PROPERTIES.each do |method_name, property|
        define_method(method_name) do
          zfs_property(property)
        end
      end

      private

      def zfs_case_insensitive?
        return nil unless base_type == 'zfs'

        value = zfs_property('casesensitivity')
        return nil unless value

        case value.strip
          when 'insensitive'
            true
          when 'sensitive'
            false
          else
            nil
        end
      rescue SystemCallError
        nil
      end

      def zfs_dataset
        return mount_source if respond_to?(:mount_source) && mount_source

        mount_point = Sys::Filesystem.mount_point(path)
        mount = Sys::Filesystem.mounts.find{ |mnt| mnt.mount_point == mount_point }

        mount&.name
      rescue SystemCallError
        nil
      end
    end
  end
end

# Reopen the Numeric class and add some convenient methods
# for converting bytes to kb, mb, and gb.
class Numeric
  # call-seq:
  #  <tt>num</tt>.to_kb
  #
  # Returns +num+ in terms of kilobytes.
  def to_kb
    self / 1024
  end

  # call-seq:
  #  <tt>num</tt>.to_mb
  #
  # Returns +num+ in terms of megabytes.
  def to_mb
    self / 1048576
  end

  # call-seq:
  #  <tt>num</tt>.to_gb
  #
  # Returns +num+ in terms of gigabytes.
  def to_gb
    self / 1073741824
  end

  # call-seq:
  #  <tt>num</tt>.to_gb
  #
  # Returns +num+ in terms of terabytes.
  def to_tb
    self / 1099511627776
  end
end
