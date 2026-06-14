# frozen_string_literal: true

require 'ffi'

module Sys
  class Filesystem
    # A scoped module for internal FFI functions to be used by the main code.
    module Functions
      extend FFI::Library

      ffi_lib FFI::Library::LIBC

      def self.linux64?
        if RUBY_PLATFORM == 'java'
          RbConfig::CONFIG['host_os'] =~ /linux/i &&
            ENV_JAVA['sun.arch.data.model'].to_i == 64
        else
          RbConfig::CONFIG['host_os'] =~ /linux/i &&
            (RbConfig::CONFIG['arch'] =~ /64/ || RbConfig::CONFIG['DEFS'] =~ /64/ || [nil].pack('P').size == 8)
        end
      end

      def self.zfs_supported?
        !!(RbConfig::CONFIG['host_os'] =~ /freebsd|linux/i)
      end

      private_class_method :linux64?
      private_class_method :zfs_supported?

      if linux64?
        begin
          attach_function(:statvfs, :statvfs64, %i[string pointer], :int)
        rescue FFI::NotFoundError # Not every Linux distro has an alias
          attach_function(:statvfs, %i[string pointer], :int)
        end
      else
        attach_function(:statvfs, %i[string pointer], :int)
      end

      if RbConfig::CONFIG['host_os'] =~ /darwin|osx|mach|bsd|dragonfly/i
        attach_function(:statfs, %i[string pointer], :int)
      end

      attach_function(:strerror, [:int], :string)

      if RbConfig::CONFIG['host_os'] =~ /linux/i
        attach_function(:mount_c, :mount, %i[string string string ulong string], :int)
      else
        attach_function(:mount_c, :mount, %i[string string int pointer], :int)
      end

      if RbConfig::CONFIG['host_os'] =~ /freebsd/i
        attach_function(:nmount_c, :nmount, %i[pointer uint int], :int)
      end

      if zfs_supported?
        begin
          ffi_lib FFI::Library::LIBC, 'zfs'

          attach_function(:libzfs_init, [], :pointer)
          attach_function(:libzfs_fini, [:pointer], :void)
          attach_function(:zfs_open, %i[pointer string int], :pointer)
          attach_function(:zfs_close, [:pointer], :void)
          attach_function(:zfs_name_to_prop, [:string], :int)
          attach_function(
            :zfs_prop_get,
            %i[pointer int pointer size_t pointer pointer size_t int],
            :int
          )
        rescue FFI::NotFoundError, LoadError
          # libzfs is optional. ZFS-specific helpers fall back when unavailable.
        end
      end

      if RbConfig::CONFIG['host_os'] =~ /darwin|osx|mach|bsd|dragonfly/i
        attach_function(:umount_c, :unmount, %i[string int], :int)
      else
        attach_function(:umount_c, :umount2, %i[string int], :int)
      end

      private_class_method :statvfs, :strerror, :mount_c, :umount_c
      private_class_method :statfs if method_defined?(:statfs)
      private_class_method :nmount_c if method_defined?(:nmount_c)
      if method_defined?(:libzfs_init)
        private_class_method(
          :libzfs_init,
          :libzfs_fini,
          :zfs_open,
          :zfs_close,
          :zfs_name_to_prop,
          :zfs_prop_get
        )
      end

      begin
        attach_function(:getmntent, [:pointer], :pointer)
        attach_function(:setmntent, %i[string string], :pointer)
        attach_function(:endmntent, [:pointer], :int)
        private_class_method :getmntent, :setmntent, :endmntent
      rescue FFI::NotFoundError
        if RbConfig::CONFIG['host_os'] =~ /darwin|osx|mach/i
          begin
            attach_function(:getmntinfo, :getmntinfo64, %i[pointer int], :int)
          rescue FFI::NotFoundError
            attach_function(:getmntinfo, %i[pointer int], :int) # Big Sur and later
          end
        else
          attach_function(:getmntinfo, %i[pointer int], :int)
        end
        private_class_method :getmntinfo
      end
    end
  end
end
