require File.join(File.dirname(__FILE__), 'filesystem', 'constants')
require File.join(File.dirname(__FILE__), 'filesystem', 'functions')
require File.join(File.dirname(__FILE__), 'filesystem', 'helper')

require 'socket'
require 'win32ole'
require 'date'
require 'time'

# The Sys module serves as a namespace only.
module Sys

  # The Filesystem class encapsulates information about your filesystem.
  class Filesystem
    include Sys::Filesystem::Constants
    extend Sys::Filesystem::Functions

    # Error typically raised if any of the Sys::Filesystem methods fail.
    class Error < StandardError; end

    # The version of the sys-filesystem library.
    VERSION = '1.1.0'

    class Mount
      # The name of the volume. This is the device mapping.
      attr_reader :name

      # The last time the volume was mounted. For MS Windows this equates
      # to your system's boot time.
      attr_reader :mount_time

      # The type of mount, e.g. NTFS, UDF, etc.
      attr_reader :mount_type

      # The volume mount point, e.g. 'C:\'
      attr_reader :mount_point

      # Various comma separated options that reflect the volume's features
      attr_reader :options

      # Always nil on MS Windows. Provided for interface compatibility only.
      attr_reader :pass_number

      # Always nil on MS Windows. Provided for interface compatibility only.
      attr_reader :frequency

      alias fsname name
      alias dir mount_point
      alias opts options
      alias passno pass_number
      alias freq frequency
    end

    class Stat
      # The path of the file system.
      attr_reader :path

      # The file system block size.  MS Windows typically defaults to 4096.
      attr_reader :block_size

      # Fragment size. Meaningless at the moment.
      attr_reader :fragment_size

      # The total number of blocks available (used or unused) on the file
      # system.
      attr_reader :blocks

      # The total number of unused blocks.
      attr_reader :blocks_free

      # The total number of unused blocks available to unprivileged
      # processes. Identical to +blocks+ at the moment.
      attr_reader :blocks_available

      # Total number of files/inodes that can be created on the file system.
      # This attribute is always nil on MS Windows.
      attr_reader :files

      # Total number of free files/inodes that can be created on the file
      # system.  This attribute is always nil on MS Windows.
      attr_reader :files_free

      # Total number of available files/inodes for unprivileged processes
      # that can be created on the file system. This attribute is always
      # nil on MS Windows.
      attr_reader :files_available

      # The file system volume id.
      attr_reader :filesystem_id

      # A bit mask of file system flags.
      attr_reader :flags

      # The maximum length of a file name permitted on the file system.
      attr_reader :name_max

      # The file system type, e.g. NTFS, FAT, etc.
      attr_reader :base_type

      alias inodes files
      alias inodes_free files_free
      alias inodes_available files_available
    end

    # Yields a Filesystem::Mount object for each volume on your system in
    # block form. Returns an array of Filesystem::Mount objects in non-block
    # form.
    #
    # Example:
    #
    #    Sys::Filesystem.mounts{ |mount|
    #       p mt.name        # => \\Device\\HarddiskVolume1
    #       p mt.mount_point # => C:\
    #       p mt.mount_time  # => Thu Dec 18 20:12:08 -0700 2008
    #       p mt.mount_type  # => NTFS
    #       p mt.options     # => casepres,casesens,ro,unicode
    #       p mt.pass_number # => nil
    #       p mt.dump_freq   # => nil
    #    }
    #
    # This method is a bit of a fudge for MS Windows in the name of interface
    # compatibility because this method deals with volumes, not actual mount
    # points. But, I believe it provides the sort of information many users
    # want at a glance.
    #
    # The possible values for the +options+ and their meanings are as follows:
    #
    # casepres     => The filesystem preserves the case of file names when it places a name on disk.
    # casesens     => The filesystem supports case-sensitive file names.
    # compression  => The filesystem supports file-based compression.
    # namedstreams => The filesystem supports named streams.
    # pacls        => The filesystem preserves and enforces access control lists.
    # ro           => The filesystem is read-only.
    # encryption   => The filesystem supports the Encrypted File System (EFS).
    # objids       => The filesystem supports object identifiers.
    # rpoints      => The filesystem supports reparse points.
    # sparse       => The filesystem supports sparse files.
    # unicode      => The filesystem supports Unicode in file names as they appear on disk.
    # compressed   => The filesystem is compressed.
    #
    def self.mounts
      buffer = FFI::MemoryPointer.new(:char, MAXPATH)
      length = GetLogicalDriveStrings(buffer.size, buffer)

      if length == 0
        raise SystemCallError.new('GetLogicalDriveStrings', FFI.errno)
      end

      mounts = block_given? ? nil : []

      # Try again if it fails because the buffer is too small
      if length > buffer.size
        buffer = FFI::MemoryPointer.new(:char, length)
        if GetLogicalDriveStrings(buffer.size, buffer) == 0
          raise SystemCallError.new('GetLogicalDriveStrings', FFI.errno)
        end
      end

      boot_time = get_boot_time

      drives = buffer.strip.split("\0")

      drives.each{ |drive|
        mount  = Mount.new
        volume = FFI::MemoryPointer.new(:char, MAXPATH)
        fsname = FFI::MemoryPointer.new(:char, MAXPATH)

        mount.instance_variable_set(:@mount_point, drive)
        mount.instance_variable_set(:@mount_time, boot_time)

        volume_serial_number = FFI::MemoryPointer.new(:ulong)
        max_component_length = FFI::MemoryPointer.new(:ulong)
        filesystem_flags     = FFI::MemoryPointer.new(:ulong)

        bool = GetVolumeInformation(
           drive,
           volume,
           volume.size,
           volume_serial_number,
           max_component_length,
           filesystem_flags,
           fsname,
           fsname.size
        )

        # Skip unmounted floppies or cd-roms
        unless bool
          errnum = GetLastError()
          if errnum == ERROR_NOT_READY
            next
          else
            raise Error, get_last_error(errnum)
          end
        end

        filesystem_flags = filesystem_flags.unpack('L')[0]

        name = 0.chr * MAXPATH

        if QueryDosDevice(drive[0,2], name, name.size) == 0
          raise Error, get_last_error
        end

        mount.instance_variable_set(:@name, name.strip)
        mount.instance_variable_set(:@mount_type, fsname.strip)
        mount.instance_variable_set(:@options, get_options(filesystem_flags))

        if block_given?
          yield mount
        else
          mounts << mount
        end
      }

      mounts # Nil if the block form was used.
    end

    # Returns the mount point for the given +file+. For MS Windows this
    # means the root of the path.
    #
    # Example:
    #
    #    File.mount_point("C:\\Documents and Settings") # => "C:\\'
    #
    def self.mount_point(file)
      wfile = FFI::MemoryPointer.from_string(file.wincode)

      if PathStripToRootW(wfile)
        wfile.read_string(wfile.size).split("\000\000").first.tr(0.chr, '')
      else
        nil
      end
    end

    # Returns a Filesystem::Stat object that contains information about the
    # +path+ file system.
    #
    # Examples:
    #
    #    File.stat("C:\\")
    #    File.stat("C:\\Documents and Settings\\some_user")
    #
    def self.stat(path)
      bytes_avail = FFI::MemoryPointer.new(:ulong_long)
      bytes_free  = FFI::MemoryPointer.new(:ulong_long)
      total_bytes = FFI::MemoryPointer.new(:ulong_long)

      wpath = path.wincode

      unless GetDiskFreeSpaceExW(wpath, bytes_avail, total_bytes, bytes_free)
        raise SystemCallError.new('GetDiskFreeSpaceEx', FFI.errno)
      end

      bytes_avail = bytes_avail.read_ulong_long
      bytes_free  = bytes_free.read_ulong_long
      total_bytes = total_bytes.read_ulong_long

      sectors = FFI::MemoryPointer.new(:ulong_long)
      bytes   = FFI::MemoryPointer.new(:ulong_long)
      free    = FFI::MemoryPointer.new(:ulong_long)
      total   = FFI::MemoryPointer.new(:ulong_long)

      unless GetDiskFreeSpaceW(wpath, sectors, bytes, free, total)
        raise SystemCallError.new('GetDiskFreeSpace', FFI.errno)
      end

      sectors = sectors.read_ulong_long
      bytes   = bytes.read_ulong_long
      free    = free.read_ulong_long
      total   = total.read_ulong_long

      block_size   = sectors * bytes
      blocks_avail = total_bytes / block_size
      blocks_free  = bytes_free / block_size

      vol_name   = FFI::MemoryPointer.new(:char, MAXPATH)
      base_type  = FFI::MemoryPointer.new(:char, MAXPATH)
      vol_serial = FFI::MemoryPointer.new(:ulong)
      name_max   = FFI::MemoryPointer.new(:ulong)
      flags      = FFI::MemoryPointer.new(:ulong)

      bool = GetVolumeInformationW(
        wpath,
        vol_name,
        vol_name.size,
        vol_serial,
        name_max,
        flags,
        base_type,
        base_type.size
      )

      unless bool
        raise SystemCallError.new('GetVolumInformation', FFI.errno)
      end

      vol_serial = vol_serial.read_ulong
      name_max   = name_max.read_ulong
      flags      = flags.read_ulong
      base_type  = base_type.read_string(base_type.size).tr(0.chr, '')

      stat_obj = Stat.new
      stat_obj.instance_variable_set(:@path, path)
      stat_obj.instance_variable_set(:@block_size, block_size)
      stat_obj.instance_variable_set(:@blocks, blocks_avail)
      stat_obj.instance_variable_set(:@blocks_available, blocks_avail)
      stat_obj.instance_variable_set(:@blocks_free, blocks_free)
      stat_obj.instance_variable_set(:@name_max, name_max)
      stat_obj.instance_variable_set(:@base_type, base_type)
      stat_obj.instance_variable_set(:@flags, flags)
      stat_obj.instance_variable_set(:@filesystem_id, vol_serial)

      stat_obj.freeze # Read-only object
    end

    private

    # This method is used to get the boot time of the system, which is used
    # for the mount_time attribute within the File.mounts method.
    #
    def self.get_boot_time
      host = Socket.gethostname
      cs = "winmgmts://#{host}/root/cimv2"
      begin
        wmi = WIN32OLE.connect(cs)
      rescue WIN32OLERuntimeError => e
        raise Error, e
      else
        query = 'select LastBootupTime from Win32_OperatingSystem'
        results = wmi.ExecQuery(query)
        results.each{ |ole|
          time_array = Time.parse(ole.LastBootupTime.split('.').first)
          return Time.mktime(*time_array)
        }
      end
    end

    # Private method that converts filesystem flags into a comma separated
    # list of strings. The presentation is meant as a rough analogue to the
    # way options are presented for Unix filesystems.
    #
    def self.get_options(flags)
       str = ""
       str << " casepres" if CASE_PRESERVED_NAMES & flags > 0
       str << " casesens" if CASE_SENSITIVE_SEARCH & flags > 0
       str << " compression" if FILE_COMPRESSION & flags > 0
       str << " namedstreams" if NAMED_STREAMS & flags > 0
       str << " pacls" if PERSISTENT_ACLS & flags > 0
       str << " ro" if READ_ONLY_VOLUME & flags > 0
       str << " encryption" if SUPPORTS_ENCRYPTION & flags > 0
       str << " objids" if SUPPORTS_OBJECT_IDS & flags > 0
       str << " rpoints" if SUPPORTS_REPARSE_POINTS & flags > 0
       str << " sparse" if SUPPORTS_SPARSE_FILES & flags > 0
       str << " unicode" if UNICODE_ON_DISK & flags > 0
       str << " compressed" if VOLUME_IS_COMPRESSED & flags > 0

       str.tr!(' ', ',')
       str = str[1..-1] # Ignore the first comma
       str
    end
  end
end

# Some convenient methods for converting bytes to kb, mb, and gb.
#
class Fixnum
  # call-seq:
  #  <tt>fix</tt>.to_kb
  #
  # Returns +fix+ in terms of kilobytes.
  def to_kb
    self / 1024
  end

  # call-seq:
  #  <tt>fix</tt>.to_mb
  #
  # Returns +fix+ in terms of megabytes.
  def to_mb
    self / 1048576
  end

  # call-seq:
  #  <tt>fix</tt>.to_gb
  #
  # Returns +fix+ in terms of gigabytes.
  def to_gb
    self / 1073741824
  end
end

p Sys::Filesystem.mount_point("C:/Users/djberge")
