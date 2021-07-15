require 'ffi'

module Sys
  class Filesystem
    module Functions
      extend FFI::Library

      ffi_lib FFI::Library::LIBC

      if RbConfig::CONFIG['host_os'] =~ /sunos|solaris|x86_64.*linux/i
        attach_function(:statvfs, :statvfs64, %i[string pointer], :int)
      else
        attach_function(:statvfs, %i[string pointer], :int)
      end

      attach_function(:strerror, [:int], :string)
      attach_function(:mount_c, :mount, %i[string string string ulong string], :int)

      begin
        attach_function(:umount_c, :umount, [:string], :int)
      rescue FFI::NotFoundError
        if RbConfig::CONFIG['host_os'] =~ /darwin|osx|mach|bsd/i
          attach_function(:umount_c, :unmount, [:string], :int)
        end
      end

      private_class_method :statvfs, :strerror, :mount_c, :umount_c

      begin
        if RbConfig::CONFIG['host_os'] =~ /sunos|solaris/i
          attach_function(:fopen, %i[string string], :pointer)
          attach_function(:fclose, [:pointer], :int)
          attach_function(:getmntent, %i[pointer pointer], :int)
          private_class_method :fopen, :fclose, :getmntent
        else
          attach_function(:getmntent, [:pointer], :pointer)
          attach_function(:setmntent, %i[string string], :pointer)
          attach_function(:endmntent, [:pointer], :int)
          attach_function(:umount2, %i[string int], :int)
          private_class_method :getmntent, :setmntent, :endmntent, :umount2
        end
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
