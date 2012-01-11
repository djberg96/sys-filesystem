require 'ffi'
require 'rbconfig'

# The Sys module serves as a namespace only.
module Sys
  # The Filesystem class serves as an abstract base class. Its methods
  # return objects of other types. Do not instantiate.
  class Filesystem
    extend FFI::Library
    ffi_lib(FFI::Library::LIBC)

    # The version of the sys-filesystem library.
    VERSION = '1.0.0'

    private

    attach_function(:statvfs, [:string, :pointer], :int)
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

    MNT_RDONLY      = 0x00000001 # read only filesystem
    MNT_SYNCHRONOUS = 0x00000002 # file system written synchronously
    MNT_NOEXEC      = 0x00000004 # can't exec from filesystem
    MNT_NOSUID      = 0x00000008 # don't honor setuid bits on fs
    MNT_NODEV       = 0x00000010 # don't interpret special files
    MNT_UNION       = 0x00000020 # union with underlying filesystem
    MNT_ASYNC       = 0x00000040 # file system written asynchronously
    MNT_CPROTECT    = 0x00000080 # file system supports content protection
    MNT_EXPORTED    = 0x00000100 # file system is exported
    MNT_QUARANTINE  = 0x00000400 # file system is quarantined
    MNT_LOCAL       = 0x00001000 # filesystem is stored locally
    MNT_QUOTA       = 0x00002000 # quotas are enabled on filesystem
    MNT_ROOTFS      = 0x00004000 # identifies the root filesystem
    MNT_DOVOLFS     = 0x00008000 # FS supports volfs (deprecated)
    MNT_DONTBROWSE  = 0x00100000 # FS is not appropriate path to user data
    MNT_IGNORE_OWNERSHIP = 0x00200000 # VFS will ignore ownership info on FS objects
    MNT_AUTOMOUNTED = 0x00400000 # filesystem was mounted by automounter
    MNT_JOURNALED   = 0x00800000 # filesystem is journaled
    MNT_NOUSERXATTR = 0x01000000 # Don't allow user extended attributes
    MNT_DEFWRITE    = 0x02000000 # filesystem should defer writes
    MNT_MULTILABEL  = 0x04000000 # MAC support for individual labels
    MNT_NOATIME     = 0x10000000 # disable update of file access time

    MNT_VISFLAGMASK = (
      MNT_RDONLY | MNT_SYNCHRONOUS | MNT_NOEXEC |
      MNT_NOSUID | MNT_NODEV | MNT_UNION |
      MNT_ASYNC  | MNT_EXPORTED | MNT_QUARANTINE |
      MNT_LOCAL  | MNT_QUOTA |
      MNT_ROOTFS | MNT_DOVOLFS | MNT_DONTBROWSE |
      MNT_IGNORE_OWNERSHIP | MNT_AUTOMOUNTED | MNT_JOURNALED |
      MNT_NOUSERXATTR | MNT_DEFWRITE  | MNT_MULTILABEL |
      MNT_NOATIME | MNT_CPROTECT
    )

    @@opt_names = {
      MNT_RDONLY           => 'read-only',
      MNT_SYNCHRONOUS      => 'synchronous',
      MNT_NOEXEC           => 'noexec',
      MNT_NOSUID           => 'nosuid',
      MNT_NODEV            => 'nodev',
      MNT_UNION            => 'union',
      MNT_ASYNC            => 'asynchronous',
      MNT_CPROTECT         => 'content-protection',
      MNT_EXPORTED         => 'exported',
      MNT_QUARANTINE       => 'quarantined',
      MNT_LOCAL            => 'local',
      MNT_QUOTA            => 'quotas',
      MNT_ROOTFS           => 'rootfs',
      MNT_DONTBROWSE       => 'nobrowse',
      MNT_IGNORE_OWNERSHIP => 'noowners',
      MNT_AUTOMOUNTED      => 'automounted',
      MNT_JOURNALED        => 'journaled',
      MNT_NOUSERXATTR      => 'nouserxattr',
      MNT_DEFWRITE         => 'defwrite',
      MNT_NOATIME          => 'noatime'
    }

    # File used to read mount informtion from.
    if File.exists?('/etc/mtab')
      MOUNT_FILE = '/etc/mtab'
    elsif File.exists?('/etc/mnttab')
      MOUNT_FILE = '/etc/mnttab'
    else
      MOUNT_FILE = 'getmntinfo'
    end

    class Statfs < FFI::Struct
      if RbConfig::CONFIG['host_os'] =~ /bsd/i
        layout(
          :f_version, :uint32,
          :f_type, :uint32,
          :f_flags, :uint64,
          :f_bsize, :uint64,
          :f_iosize, :int64,
          :f_blocks, :uint64,
          :f_bfree, :uint64,
          :f_bavail, :int64,
          :f_files, :uint64,
          :f_ffree, :uint64,
          :f_syncwrites, :uint64,
          :f_asyncwrites, :uint64,
          :f_syncreads, :uint64,
          :f_asyncreads, :uint64,
          :f_spare, [:uint64, 10],
          :f_namemax, :uint32,
          :f_owner, :int32,
          :f_fsid,  [:int32, 2],
          :f_charspare, [:char, 80],
          :f_fstypename, [:char, 16],
          :f_mntfromname, [:char, 88],
          :f_mntonname, [:char, 88]
        )
      else
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
    end

    # The Statvfs struct represents struct statvfs from sys/statvfs.h.
    class Statvfs < FFI::Struct
      if RbConfig::CONFIG['host_os'] =~ /darwin|osx|mach/i
        layout(
          :f_bsize, :ulong,
          :f_frsize, :ulong,
          :f_blocks, :uint,
          :f_bfree, :uint,
          :f_bavail, :uint,
          :f_files, :uint,
          :f_ffree, :uint,
          :f_favail, :uint,
          :f_fsid, :ulong,
          :f_flag, :ulong,
          :f_namemax, :ulong
        )
      elsif RbConfig::CONFIG['host'] =~ /bsd/i
        layout(
          :f_bavail, :uint64,
          :f_bfree, :uint64,
          :f_blocks, :uint64,
          :f_favail, :uint64,
          :f_ffree, :uint64,
          :f_files, :uint64,
          :f_bsize, :ulong,
          :f_flag, :ulong,
          :f_frsize, :ulong,
          :f_fsid, :ulong,
          :f_namemax, :ulong
        )
      elsif RbConfig::CONFIG['host'] =~ /sunos|solaris/i
        layout(
          :f_bsize, :ulong,
          :f_frsize, :ulong,
          :f_blocks, :ulong_t,
          :f_bfree, :ulong_t,
          :f_bavail, :ulong_t,
          :f_files, :ulong_t,
          :f_ffree, :ulong_t,
          :f_favail, :ulong_t,
          :f_fsid, :ulong,
          :f_basetype, [:char, 16],
          :f_flag, :uint32,
          :f_namemax, :uint32,
          :f_fstr, [:char, 32],
          :f_filler, [:uint32, 16]
        )
      else
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
    end

    # The Mnttab struct represents struct mnnttab from sys/mnttab.h on Solaris.
    class Mnttab < FFI::Struct
      layout(
        :mnt_special, :string,
        :mnt_mountp, :string,
        :mnt_fstype, :string,
        :mnt_mntopts, :string,
        :mnt_time, :string
      )
    end

    # The Mntent struct represents struct mntent from sys/mount.h on Unix.
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

    # The error raised if any of the Filesystem methods fail.
    class Error < StandardError; end

    # Stat objects are returned by the Sys::Filesystem.stat method.
    class Stat
      # Read-only filesystem
      RDONLY  = 1

      # Filesystem does not support suid or sgid semantics.
      NOSUID  = 2

      # Filesystem does not truncate file names longer than +name_max+.
      NOTRUNC = 3

      # The path of the filesystem.
      attr_accessor :path

      # The preferred system block size.
      attr_accessor :block_size

      # The fragment size, i.e. fundamental filesystem block size.
      attr_accessor :fragment_size

      # The total number of +fragment_size+ blocks in the filesystem.
      attr_accessor :blocks

      # The total number of free blocks in the filesystem.
      attr_accessor :blocks_free

      # The number of free blocks available to unprivileged processes.
      attr_accessor :blocks_available

      # The total number of files/inodes that can be created.
      attr_accessor :files

      # The total number of files/inodes on the filesystem.
      attr_accessor :files_free

      # The number of free files/inodes available to unprivileged processes.
      attr_accessor :files_available

      # The filesystem identifier.
      attr_accessor :filesystem_id

      # A bit mask of flags.
      attr_accessor :flags

      # The maximum length of a file name permitted on the filesystem.
      attr_accessor :name_max

      # The filesystem type, e.g. UFS.
      attr_accessor :base_type

      alias inodes files
      alias inodes_free files_free
      alias inodes_available files_available

      # Creates a new Sys::Filesystem::Stat object. This is meant for
      # internal use only. Do not instantiate directly.
      #
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

    # Mount objects are returned by the Sys::Filesystem.mounts method.
    class Mount
      # The name of the mounted resource.
      attr_accessor :name

      # The mount point/directory.
      attr_accessor :mount_point

      # The type of filesystem mount, e.g. ufs, nfs, etc.
      attr_accessor :mount_type

      # A list of comma separated options for the mount, e.g. nosuid, etc.
      attr_accessor :options

      # The time the filesystem was mounted. May be nil.
      attr_accessor :mount_time

      # The dump frequency in days. May be nil.
      attr_accessor :dump_frequency

      # The pass number of the filessytem check. May be nil.
      attr_accessor :pass_number

      alias fsname name
      alias dir mount_point
      alias opts options
      alias passno pass_number
      alias freq dump_frequency

      # Creates a Sys::Filesystem::Mount object. This is meant for internal
      # use only. Do no instantiate directly.
      #
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

    # Returns a Sys::Filesystem::Stat object containing information about the
    # +path+ on the filesystem.
    #
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

      # OSX does things a little differently
      if RbConfig::CONFIG['host_os'] =~ /darwin|osx|mach/i
        obj.block_size /= 256
      end

      if fs.members.include?(:f_basetype)
        obj.base_type = fs[:f_basetype].to_s
      end

      obj.freeze
    end

    # In block form, yields a Sys::Filesystem::Mount object for each mounted
    # filesytem on the host. Otherwise it returns an array of Mount objects.
    #
    # Example:
    #
    # Sys::Filesystem.mounts{ |fs|
    #   p fs.name        # => '/dev/dsk/c0t0d0s0'
    #   p fs.mount_time  # => Thu Dec 11 15:07:23 -0700 2008
    #   p fs.mount_type  # => 'ufs'
    #   p fs.mount_point # => '/'
    #   p fs.options     # => local, noowner, nosuid
    # }
    #
    def self.mounts
      array = block_given? ? nil : []

      if method_defined?(:getmntinfo)
        buf = FFI::MemoryPointer.new(:pointer)

        num = getmntinfo(buf, 2)

        if num == 0
          raise Error, 'getmntinfo() function failed: ' + strerror(FFI.errno)
        end

        ptr = buf.get_pointer(0)

        num.times{ |i|
          mnt = Statfs.new(ptr)
          obj = Sys::Filesystem::Mount.new
          obj.name = mnt[:f_mntfromname].to_s
          obj.mount_point = mnt[:f_mntonname].to_s
          obj.mount_type = mnt[:f_fstypename].to_s

          string = ""
          flags = mnt[:f_flags] & MNT_VISFLAGMASK

          @@opt_names.each{ |key,val|
            if flags & key > 0
              if string.empty?
                string << val
              else
                string << ", #{val}"
              end
            end
            flags &= ~key
          }

          obj.options = string

          if block_given?
            yield obj.freeze
          else
            array << obj.freeze
          end

          ptr += Statfs.size
        }
      else
        begin
          if method_defined?(:setmntent)
            fp = setmntent(MOUNT_FILE, 'r')
          else
            fp = fopen(MOUNT_FILE, 'r')
          end

          if RbConfig::CONFIG['host_os'] =~ /sunos|solaris/i
            mt = Mnttab.new
            while getmntent(fp, mt) == 0
              obj = Sys::Filesystem::Mount.new
              obj.name = mt[:mnt_special].to_s
              obj.mount_point = mt[:mnt_mountp].to_s
              obj.mount_type = mt[:mnt_fstype].to_s
              obj.options = mt[:mnt_mntopts].to_s
              obj.mount_time = Time.at(Integer(mt[:mnt_time]))

              if block_given?
                yield obj.freeze
              else
                array << obj.freeze
              end
            end
          else
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
          end
        ensure
          if fp && !fp.null?
            if method_defined?(:endmntent)
              endmntent(fp)
            else
              fclose(fp)
            end
          end
        end
      end

      array
    end

    # Returns the mount point of the given +file+, or itself if it cannot
    # be found.
    #
    # Example:
    #
    #  Sys::Filesystem.mount_point('/home/some_user') # => /home
    #
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
  # Converts a number to kilobytes.
  def to_kb
    self / 1024
  end

  # Converts a number to megabytes.
  def to_mb
    self / 1048576
  end

  # Converts a number to gigabytes.
  def to_gb
    self / 1073741824
  end
end
