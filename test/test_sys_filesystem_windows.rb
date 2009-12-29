####################################################################
# test_sys_filesystem_windows.rb
#
# Test case for the Sys::Filesystem.stat method and related stuff.
# This should be run via the 'rake test' task.
####################################################################
require 'rubygems'
gem 'test-unit'

require 'test/unit'
require 'sys/filesystem'
require 'rbconfig'
include Sys

class TC_Sys_Filesystem_Windows < Test::Unit::TestCase
   def setup
      @dir   = '/'
      @stat  = Filesystem.stat(@dir)
      @mount = Filesystem.mounts[0]
      @size  = 58720256
      @array = []
   end

   def test_version
      assert_equal('0.3.2', Filesystem::VERSION)
   end

   def test_stat_path
      assert_respond_to(@stat, :path)
      assert_equal("/", @stat.path)
   end

   def test_stat_block_size
      assert_respond_to(@stat, :block_size)
      assert_kind_of(Fixnum, @stat.block_size)
   end

   def test_stat_fragment_size
      assert_respond_to(@stat, :fragment_size)
      assert_nil(@stat.fragment_size)
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
      assert_respond_to(@stat, :inodes)            # Alias
      assert_nil(@stat.files)
   end

   def test_stat_files_free
      assert_respond_to(@stat, :files_free)
      assert_respond_to(@stat, :inodes_free)       # Alias
      assert_nil(@stat.files_free)
   end

   def test_stat_files_available
      assert_respond_to(@stat, :files_available)
      assert_respond_to(@stat, :inodes_available)  # Alias
      assert_nil(@stat.files_available)
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
      assert_respond_to(@stat, :base_type)
      assert_kind_of(String, @stat.base_type)
   end

   def test_mount_point_singleton
      assert_respond_to(Filesystem, :mount_point)
      assert_nothing_raised{ Filesystem.mount_point(Dir.pwd) }
      assert_kind_of(String, Filesystem.mount_point(Dir.pwd))
   end

   def test_constants
      assert_not_nil(Filesystem::CASE_SENSITIVE_SEARCH)
      assert_not_nil(Filesystem::CASE_PRESERVED_NAMES)
      assert_not_nil(Filesystem::UNICODE_ON_DISK)
      assert_not_nil(Filesystem::PERSISTENT_ACLS)
      assert_not_nil(Filesystem::FILE_COMPRESSION)
      assert_not_nil(Filesystem::VOLUME_QUOTAS)
      assert_not_nil(Filesystem::SUPPORTS_SPARSE_FILES)
      assert_not_nil(Filesystem::SUPPORTS_REPARSE_POINTS)
      assert_not_nil(Filesystem::SUPPORTS_REMOTE_STORAGE)
      assert_not_nil(Filesystem::VOLUME_IS_COMPRESSED)
      assert_not_nil(Filesystem::SUPPORTS_OBJECT_IDS)
      assert_not_nil(Filesystem::SUPPORTS_ENCRYPTION)
      assert_not_nil(Filesystem::NAMED_STREAMS)
      assert_not_nil(Filesystem::READ_ONLY_VOLUME)
   end

   def test_stat_expected_errors
      assert_raises(ArgumentError){ Filesystem.stat }
   end

   # Filesystem.mounts

   def test_mounts_constructor_basic
      assert_respond_to(Filesystem, :mounts)
      assert_nothing_raised{ Filesystem.mounts }
      assert_nothing_raised{ Filesystem.mounts{} }
   end

   def test_mounts
      assert_kind_of(Array, Filesystem.mounts)
      assert_kind_of(Filesystem::Mount, Filesystem.mounts[0])
   end
 
   def test_mounts_block_form
      assert_nil(Filesystem.mounts{})
      assert_nothing_raised{ Filesystem.mounts{ |mt| @array << mt }}
      assert_kind_of(Filesystem::Mount, @array[0])
   end

   def test_mount_name
      assert_respond_to(@mount, :name)
      assert_kind_of(String, @mount.name)
   end

   def test_mount_time
      assert_respond_to(@mount, :mount_time)
      assert_kind_of(Time, @mount.mount_time)
   end

   def test_mount_type
      assert_respond_to(@mount, :mount_type)
      assert_kind_of(String, @mount.mount_type)
   end

   def test_mount_point
      assert_respond_to(@mount, :mount_point)
      assert_kind_of(String, @mount.mount_point)
   end

   def test_mount_options
      assert_respond_to(@mount, :options)
      assert_kind_of(String, @mount.options)
   end

   def test_pass_number
      assert_respond_to(@mount, :pass_number)
      assert_nil(@mount.pass_number)
   end

   def test_frequency
      assert_respond_to(@mount, :frequency)
      assert_nil(@mount.frequency)
   end

   def test_mounts_expected_errors
      assert_raise(ArgumentError){ Filesystem.mounts("C:\\") }
   end

   def test_fixnum_methods
      assert_respond_to(@size, :to_kb)
      assert_respond_to(@size, :to_mb)
      assert_respond_to(@size, :to_gb)

      assert_equal(57344, @size.to_kb)
      assert_equal(56, @size.to_mb)
      assert_equal(0, @size.to_gb)
   end

   def teardown
      @array = nil
      @dir   = nil
      @stat  = nil
      @size  = nil
      @mount = nil
   end
end
