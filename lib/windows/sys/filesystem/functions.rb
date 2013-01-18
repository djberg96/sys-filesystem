require 'ffi'

module Sys
  class Filesystem
    module Functions
      extend FFI::Library
      ffi_lib :kernel32

      attach_function :GetDiskFreeSpaceW, [:buffer_in, :pointer, :pointer, :pointer, :pointer], :bool
      attach_function :GetDiskFreeSpaceExW, [:buffer_in, :pointer, :pointer, :pointer], :bool
      attach_function :GetLogicalDriveStringsW, [:ulong, :pointer], :ulong

      attach_function :GetVolumeInformationW,
        [:buffer_in, :pointer, :ulong, :pointer, :pointer, :pointer, :pointer, :ulong],
        :bool

      attach_function :QueryDosDeviceW, [:buffer_in, :pointer, :ulong], :ulong

      ffi_lib :shlwapi

      attach_function :PathStripToRootW, [:buffer_in], :bool
    end
  end
end
