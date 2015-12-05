require 'ffi'

module Sys
  class Filesystem
    module Functions
      extend FFI::Library

      ffi_lib FFI::Library::LIBC

      if RbConfig::CONFIG['host_os'] =~ /sunos|solaris/i
        attach_function(:statvfs, :statvfs64, [:string, :pointer], :int)
      else
        attach_function(:statvfs, [:string, :pointer], :int)
      end

      attach_function(:strerror, [:int], :string)

      private_class_method :statvfs, :strerror

      begin
        if RbConfig::CONFIG['host_os'] =~ /sunos|solaris/i
          attach_function(:fopen, [:string, :string], :pointer)
          attach_function(:fclose, [:pointer], :int)
          attach_function(:getmntent, [:pointer, :pointer], :int)
          private_class_method :fopen, :fclose, :getmntent
        else
          attach_function(:getmntent, [:pointer], :pointer)
          attach_function(:setmntent, [:string, :string], :pointer)
          attach_function(:endmntent, [:pointer], :int)
          private_class_method :getmntent, :setmntent, :endmntent
        end
      rescue FFI::NotFoundError
        if RbConfig::CONFIG['host_os'] =~ /darwin|osx|mach/i
          attach_function(:getmntinfo, :getmntinfo64, [:pointer, :int], :int)
        else
          attach_function(:getmntinfo, [:pointer, :int], :int)
        end
        private_class_method :getmntinfo
      end
    end
  end
end
