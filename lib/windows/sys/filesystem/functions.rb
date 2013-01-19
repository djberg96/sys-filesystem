require 'ffi'

module Sys
  class Filesystem
    module Functions
      extend FFI::Library
      ffi_lib :kernel32

      attach_function :GetDiskFreeSpaceW, [:buffer_in, :pointer, :pointer, :pointer, :pointer], :bool
      attach_function :GetDiskFreeSpaceExW, [:buffer_in, :pointer, :pointer, :pointer], :bool
      attach_function :GetLogicalDriveStringsA, [:ulong, :pointer], :ulong

      attach_function :GetVolumeInformationA,
        [:buffer_in, :pointer, :ulong, :pointer, :pointer, :pointer, :pointer, :ulong],
        :bool

      attach_function :GetVolumeInformationW,
        [:buffer_in, :pointer, :ulong, :pointer, :pointer, :pointer, :pointer, :ulong],
        :bool

      attach_function :QueryDosDeviceA, [:buffer_in, :buffer_out, :ulong], :ulong

      ffi_lib :shlwapi

      attach_function :PathStripToRootW, [:pointer], :bool
    end
  end
end
