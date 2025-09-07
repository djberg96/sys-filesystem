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

      private_class_method :linux64?

      if linux64?
        begin
          attach_function(:statvfs, :statvfs64, %i[string pointer], :int)
        rescue FFI::NotFoundError # Not every Linux distro has an alias
          attach_function(:statvfs, %i[string pointer], :int)
        end
      else
        attach_function(:statvfs, %i[string pointer], :int)
      end

      attach_function(:strerror, [:int], :string)
      attach_function(:mount_c, :mount, %i[string string string ulong string], :int)

      if RbConfig::CONFIG['host_os'] =~ /darwin|osx|mach|bsd|dragonfly/i
        attach_function(:umount_c, :unmount, %i[string int], :int)
      else
        attach_function(:umount_c, :umount2, %i[string int], :int)
      end

      private_class_method :statvfs, :strerror, :mount_c, :umount_c

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
