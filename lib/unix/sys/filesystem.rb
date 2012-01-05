require 'ffi'

module Sys
  class Filesystem
    extend FFI::Library
    ffi_lib(FFI::Library::LIBC)

    VERSION = '1.0.0'

    private

    attach_function(:statvfs, [:string, :pointer], :int)
    attach_function(:strerror, [:int], :string)

    begin
      attach_function(:setmntent, [:string, :string], :pointer)
      attach_function(:endmntent, [:pointer], :int)
      attach_function(:getmntent, [:pointer], :pointer)
    rescue FFI::NotFoundError
      attach_function(:getmntinfo, [:pointer, :int], :int)
    end

    if File.exists?('/etc/mtab')
      MOUNT_FILE = '/etc/mtab'
    elsif File.exists?('/etc/mnttab')
      MOUNT_FILE = '/etc/mnttab'
    else
      MOUNT_FILE = 'getmntinfo'
    end

    class Statfs < FFI::Struct
      layout(
        :f_bsize, :uint32,
        :f_iosize, :int32,
        :f_blocks, :uint64,
        :f_bfree, :uint64,
        :f_bavail, :uint64,
        :f_files, :uint64,
        :f_ffree, :uint64,
        :f_fsid, [:int32, 2],
        :f_owner, :int32,
        :f_type, :uint32,
        :f_flags, :uint32,
        :f_fssubtype, :uint32,
        :f_fstypename, [:char, 16],
        :f_mntonname, [:char, 1024],
        :f_mntfromname, [:char, 1024],
        :f_reserved, [:uint32, 8]
      )
    end

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

    class Mntent < FFI::Struct
      layout(
        :mnt_fsname, :string,
        :mnt_dir, :string,
        :mnt_type, :string,
        :mnt_opts, :string,
        :mnt_freq, :int,
        :mnt_passno, :int
      )
    end

    public

    class Error < StandardError; end

    class Stat
      RDONLY  = 1
      NOSUID  = 2
      NOTRUNC = 3

      attr_accessor :path
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

      alias inodes files
      alias inodes_free files_free
      alias inodes_available files_available

      def initialize
        @path             = nil
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
    end

    class Mount
      attr_accessor :name
      attr_accessor :mount_point
      attr_accessor :mount_type
      attr_accessor :options
      attr_accessor :mount_time
      attr_accessor :dump_frequency
      attr_accessor :pass_number

      alias fsname name
      alias dir mount_point
      alias opts options
      alias passno pass_number
      alias freq dump_frequency

      def initialize
        @name = nil
        @mount_point = nil
        @mount_type = nil
        @options = nil
        @mount_time = nil
        @dump_frequency = nil
        @pass_number = nil
      end
    end

    def self.stat(path)
      fs = Statvfs.new

      if statvfs(path, fs) < 0
        raise Error, 'statvfs() function failed: ' + strerror(FFI.errno)
      end

      obj = Sys::Filesystem::Stat.new
      obj.path = path
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

    def self.mounts
      array = block_given? ? nil : []

      begin
        fp = setmntent(MOUNT_FILE, 'r')

        while ptr = getmntent(fp)
          break if ptr.null?
          mt = Mntent.new(ptr)

          obj = Sys::Filesystem::Mount.new
          obj.name = mt[:mnt_fsname]
          obj.mount_point = mt[:mnt_dir]
          obj.mount_type = mt[:mnt_type]
          obj.options = mt[:mnt_opts]
          obj.mount_time = nil
          obj.dump_frequency = mt[:mnt_freq]
          obj.pass_number = mt[:mnt_passno]

          if block_given?
            yield obj.freeze
          else
            array << obj.freeze
          end
        end
      ensure
        endmntent(fp) if fp && !fp.null?
      end

      array
    end

    def self.mount_point(file)
      dev = File.stat(file).dev
      val = file

      self.mounts.each{ |mnt|
        mp = mnt.mount_point
        if File.stat(mp).dev == dev
          val = mp
          break
        end
      }

      val
    end
  end
end

class Fixnum
  def to_kb
    self / 1024
  end

  def to_mb
    self / 1048576
  end

  def to_gb
    self / 1073741824
  end
end
