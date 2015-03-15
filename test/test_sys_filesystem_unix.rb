####################################################################
# test_sys_filesystem_unix.rb
#
# Test case for the Sys::Filesystem.stat method and related stuff.
# This test suite should be run via the 'rake test' task.
####################################################################
require 'test-unit'
require 'sys/filesystem'
include Sys

class TC_Sys_Filesystem_Unix < Test::Unit::TestCase
  def self.startup
    @@solaris = RbConfig::CONFIG['host_os'] =~ /solaris/i
    @@linux   = RbConfig::CONFIG['host_os'] =~ /linux/i
    @@freebsd = RbConfig::CONFIG['host_os'] =~ /freebsd/i
    @@darwin  = RbConfig::CONFIG['host_os'] =~ /darwin/i
  end

  def setup
    @dir   = "/"
    @stat  = Filesystem.stat(@dir)
    @mnt   = Filesystem.mounts[0]
    @size  = 58720256
    @array = []
  end

  def test_version
    assert_equal('1.1.4', Filesystem::VERSION)
  end

  def test_stat_path
    assert_respond_to(@stat, :path)
    assert_equal("/", @stat.path)
  end

  def test_stat_block_size
    assert_respond_to(@stat, :block_size)
    assert_kind_of(Fixnum, @stat.block_size)
  end

  def test_block_size_is_a_plausible_value
    assert_true(@stat.block_size >= 1024)
    assert_true(@stat.block_size <= 16384)
  end

  def test_stat_fragment_size
    assert_respond_to(@stat, :fragment_size)
    assert_kind_of(Fixnum, @stat.fragment_size)
  end

  def test_stat_blocks
    assert_respond_to(@stat, :blocks)
    assert_kind_of(Fixnum, @stat.blocks)
  end

  def test_stat_blocks_free
    assert_respond_to(@stat, :blocks_free)
    assert_kind_of(Fixnum, @stat.blocks_free)
  end

  def test_stat_blocks_available
    assert_respond_to(@stat, :blocks_available)
    assert_kind_of(Fixnum, @stat.blocks_available)
  end

  def test_stat_files
    assert_respond_to(@stat, :files)
    assert_kind_of(Fixnum, @stat.files)
  end

  def test_inodes_alias
    assert_respond_to(@stat, :inodes)
    assert_true(@stat.method(:inodes) == @stat.method(:files))
  end

  def test_stat_files_free
    assert_respond_to(@stat, :files_free)
    assert_kind_of(Fixnum, @stat.files_free)
  end

  def test_stat_inodes_free_alias
    assert_respond_to(@stat, :inodes_free)
    assert_true(@stat.method(:inodes_free) == @stat.method(:files_free))
  end

  def test_stat_files_available
    assert_respond_to(@stat, :files_available)
    assert_kind_of(Fixnum, @stat.files_available)
  end

  def test_stat_inodes_available_alias
    assert_respond_to(@stat, :inodes_available)
    assert_true(@stat.method(:inodes_available) == @stat.method(:files_available))
  end

  def test_stat_filesystem_id
    assert_respond_to(@stat, :filesystem_id)
    assert_kind_of(Integer, @stat.filesystem_id)
  end

  def test_stat_flags
    assert_respond_to(@stat, :flags)
    assert_kind_of(Fixnum, @stat.flags)
  end

  def test_stat_name_max
    assert_respond_to(@stat, :name_max)
    assert_kind_of(Fixnum, @stat.name_max)
  end

  def test_stat_base_type
    omit_unless(@@solaris, "base_type test skipped except on Solaris")

    assert_respond_to(@stat, :base_type)
    assert_kind_of(String, @stat.base_type)
  end

  def test_stat_constants
    assert_not_nil(Filesystem::Stat::RDONLY)
    assert_not_nil(Filesystem::Stat::NOSUID)

    omit_unless(@@solaris, "NOTRUNC test skipped except on Solaris")

    assert_not_nil(Filesystem::Stat::NOTRUNC)
  end

  def test_stat_bytes_total
    assert_respond_to(@stat, :bytes_total)
    assert_kind_of(Numeric, @stat.bytes_total)
  end

  def test_stat_bytes_free
    assert_respond_to(@stat, :bytes_free)
    assert_kind_of(Numeric, @stat.bytes_free)
  end

  def test_stat_bytes_used
    assert_respond_to(@stat, :bytes_used)
    assert_kind_of(Numeric, @stat.bytes_used)
  end

  def test_stat_percent_used
    assert_respond_to(@stat, :percent_used)
    assert_kind_of(Float, @stat.percent_used)
  end

  def test_stat_expected_errors
    assert_raises(ArgumentError){ Filesystem.stat }
  end

  def test_numeric_methods_basic
    assert_respond_to(@size, :to_kb)
    assert_respond_to(@size, :to_mb)
    assert_respond_to(@size, :to_gb)
    assert_respond_to(@size, :to_tb)
  end

  def test_to_kb
    assert_equal(57344, @size.to_kb)
  end

  def test_to_mb
    assert_equal(56, @size.to_mb)
  end

  def test_to_gb
    assert_equal(0, @size.to_gb)
  end

  # Filesystem::Mount tests

  def test_mounts_with_no_block
    assert_nothing_raised{ @array = Filesystem.mounts }
    assert_kind_of(Filesystem::Mount, @array[0])
  end

  def test_mounts_with_block
    assert_nothing_raised{ Filesystem.mounts{ |m| @array << m } }
    assert_kind_of(Filesystem::Mount, @array[0])
  end

  def test_mounts_high_iteration
    assert_nothing_raised{ 1000.times{ @array = Filesystem.mounts } }
  end

  def test_mount_name
    assert_respond_to(@mnt, :name)
    assert_kind_of(String, @mnt.name)
  end

  def test_fsname_alias
    assert_respond_to(@mnt, :fsname)
    assert_true(@mnt.method(:fsname) == @mnt.method(:name))
  end

  def test_mount_point
    assert_respond_to(@mnt, :mount_point)
    assert_kind_of(String, @mnt.mount_point)
  end

  def test_dir_alias
    assert_respond_to(@mnt, :dir)
    assert_true(@mnt.method(:dir) == @mnt.method(:mount_point))
  end

  def test_mount_type
    assert_respond_to(@mnt, :mount_type)
    assert_kind_of(String, @mnt.mount_type)
  end

  def test_mount_options
    assert_respond_to(@mnt, :options)
    assert_kind_of(String, @mnt.options)
  end

  def test_opts_alias
    assert_respond_to(@mnt, :opts)
    assert_true(@mnt.method(:opts) == @mnt.method(:options))
  end

  def test_mount_time
    assert_respond_to(@mnt, :mount_time)

    if @@solaris
      assert_kind_of(Time, @mnt.mount_time)
    else
      assert_nil(@mnt.mount_time)
    end
  end

  def test_mount_dump_frequency
    msg = 'dump_frequency test skipped on this platform'
    omit_if(@@solaris || @@freebsd || @@darwin, msg)
    assert_respond_to(@mnt, :dump_frequency)
    assert_kind_of(Fixnum, @mnt.dump_frequency)
  end

  def test_freq_alias
    assert_respond_to(@mnt, :freq)
    assert_true(@mnt.method(:freq) == @mnt.method(:dump_frequency))
  end

  def test_mount_pass_number
    msg = 'pass_number test skipped on this platform'
    omit_if(@@solaris || @@freebsd || @@darwin, msg)
    assert_respond_to(@mnt, :pass_number)
    assert_kind_of(Fixnum, @mnt.pass_number)
  end

  def test_passno_alias
    assert_respond_to(@mnt, :passno)
    assert_true(@mnt.method(:passno) == @mnt.method(:pass_number))
  end

  def test_mount_point_singleton
    assert_respond_to(Filesystem, :mount_point)
    assert_nothing_raised{ Filesystem.mount_point(Dir.pwd) }
    assert_kind_of(String, Filesystem.mount_point(Dir.pwd))
  end

  def test_ffi_functions_are_private
    assert_false(Filesystem.methods.include?('statvfs'))
    assert_false(Filesystem.methods.include?('strerror'))
  end

  def teardown
    @dir   = nil
    @stat  = nil
    @array = nil
  end

  def self.shutdown
    @@solaris = nil
    @@linux   = nil
    @@freebsd = nil
    @@darwin  = nil
  end
end
