require 'ffi'

module Sys
  class Filesystem
    extend FFI::Library
    ffi_lib(FFI::Library::LIBC)

    attach_function(:statvfs, [:string, :pointer], :int)
    attach_function(:strerror, [:int], :string)

    class Error < StandardError; end

    class Statvfs < FFI::Struct
      layout(
        :f_bsize, :ulong,
        :f_frsize, :ulong,
        :f_blocks, :ulong,
        :f_bfree, :ulong,
        :f_bavail, :ulong,
        :f_files, :ulong,
        :f_ffree, :ulong,
        :f_favail, :ulong,
        :f_fsid, :ulong,
        :f_flag, :ulong,
        :f_namemax, :ulong,
        :f_ftype, :ulong,
        :f_basetype, [:char, 16],
        :f_str, [:char, 16]
      )
    end

    attr_accessor :block_size
    attr_accessor :fragment_size
    attr_accessor :blocks
    attr_accessor :blocks_free
    attr_accessor :blocks_available
    attr_accessor :files
    attr_accessor :files_free
    attr_accessor :files_available
    attr_accessor :filesystem_id
    attr_accessor :flags
    attr_accessor :name_max
    attr_accessor :base_type

    def initialize
      @block_size       = nil
      @fragment_size    = nil
      @blocks           = nil
      @blocks_free      = nil
      @blocks_available = nil
      @files            = nil
      @files_free       = nil
      @files_available  = nil
      @filesystem_id    = nil
      @flags            = nil
      @name_max         = nil
      @base_type        = nil
    end

    def self.stat(path)
      fs = Statvfs.new

      if statvfs(path, fs) < 0
        raise Error, 'statvfs() function failed: ' + strerror(FFI.errno)
      end

      obj = self.new
      obj.block_size = fs[:f_bsize]
      obj.fragment_size = fs[:f_frsize]
      obj.blocks = fs[:f_blocks]
      obj.blocks_free = fs[:f_bfree]
      obj.blocks_available = fs[:f_bavail]
      obj.files = fs[:f_files]
      obj.files_free = fs[:f_ffree]
      obj.files_available = fs[:f_favail]
      obj.filesystem_id = fs[:f_fsid]
      obj.flags = fs[:f_flag]
      obj.name_max = fs[:f_namemax]
      obj.base_type = fs[:f_basetype]

      obj.freeze
    end
  end
end
