require 'ffi'

module Sys
  class Filesystem
    # Wrapper module for Windows related FFI functions.
    module Functions
      extend FFI::Library
      ffi_lib :kernel32

      # Make FFI functions private
      module FFI::Library
        def attach_pfunc(*args)
          attach_function(*args)
          private args[0]
        end
      end

      attach_pfunc :DeleteVolumeMountPointA, [:string], :bool
      attach_pfunc :GetDiskFreeSpaceW, %i[buffer_in pointer pointer pointer pointer], :bool
      attach_pfunc :GetDiskFreeSpaceExW, %i[buffer_in pointer pointer pointer], :bool
      attach_pfunc :GetLogicalDriveStringsA, %i[ulong pointer], :ulong

      attach_pfunc :GetVolumeInformationA,
                   %i[buffer_in pointer ulong pointer pointer pointer pointer ulong],
                   :bool

      attach_pfunc :GetVolumeInformationW,
                   %i[buffer_in pointer ulong pointer pointer pointer pointer ulong],
                   :bool

      attach_pfunc :GetVolumeNameForVolumeMountPointW, %i[buffer_in buffer_in ulong], :bool
      attach_pfunc :QueryDosDeviceA, %i[buffer_in buffer_out ulong], :ulong
      attach_pfunc :SetVolumeMountPointW, %i[buffer_in buffer_in], :bool

      ffi_lib :shlwapi

      attach_pfunc :PathStripToRootW, [:pointer], :bool
    end
  end
end
