# frozen_string_literal: true

####################################################################
# sys_filesystem_windows_spec.rb
#
# Specs for the Sys::Filesystem.stat method and related stuff.
# This should be run via the 'rake spec' task.
####################################################################
require 'spec_helper'
require 'sys/filesystem'
require 'pathname'

RSpec.describe Sys::Filesystem, :windows do
  let(:root) { 'C:/' }

  before do
    @stat  = described_class.stat(root)
    @size  = 58720256
  end

  example 'stat path works as expected' do
    expect(@stat).to respond_to(:path)
    expect(@stat.path).to eq(root)
  end

  example 'stat block_size works as expected' do
    expect(@stat).to respond_to(:block_size)
    expect(@stat.block_size).to be_a(Numeric)
  end

  example 'stat works with or without trailing slash on standard paths' do
    expect(described_class.stat('C:/').path).to eq('C:/')
    expect(described_class.stat('C:/Users').path).to eq('C:/Users')
    expect(described_class.stat('C:/Users/').path).to eq('C:/Users/')
    expect(described_class.stat('C:/Users/').path).to eq('C:/Users/')
  end

  example 'stat works with or without trailing slash on UNC paths' do
    expect(described_class.stat('//127.0.0.1/C$').path).to eq('//127.0.0.1/C$')
    expect(described_class.stat('//127.0.0.1/C$/').path).to eq('//127.0.0.1/C$/')
    expect(described_class.stat('\\\\127.0.0.1\\C$').path).to eq('\\\\127.0.0.1\\C$')
    expect(described_class.stat('\\\\127.0.0.1\\C$\\').path).to eq('\\\\127.0.0.1\\C$\\')
  end

  example 'stat fragment_size works as expected' do
    expect(@stat).to respond_to(:fragment_size)
    expect(@stat.fragment_size).to be_nil
  end

  example 'stat blocks works as expected' do
    expect(@stat).to respond_to(:blocks)
    expect(@stat.blocks).to be_a(Numeric)
  end

  example 'stat blocks_free works as expected' do
    expect(@stat).to respond_to(:blocks_free)
    expect(@stat.blocks_free).to be_a(Numeric)
  end

  example 'stat blocks_available works as expected' do
    expect(@stat).to respond_to(:blocks_available)
    expect(@stat.blocks_available).to be_a(Numeric)
  end

  example 'block stats return expected relative values' do
    expect(@stat.blocks >= @stat.blocks_free).to be true
    expect(@stat.blocks_free >= @stat.blocks_available).to be true
  end

  example 'stat files works as expected' do
    expect(@stat).to respond_to(:files)
    expect(@stat.files).to be_nil
  end

  example 'stat inodes is an alias for files' do
    expect(@stat.method(:inodes)).to eq(@stat.method(:files))
  end

  example 'stat files_free works as expected' do
    expect(@stat).to respond_to(:files_free)
    expect(@stat.files_free).to be_nil
  end

  example 'stat inodes_free is an alias for files_free' do
    expect(@stat).to respond_to(:inodes_free)
  end

  example 'stat files available works as expected' do
    expect(@stat).to respond_to(:files_available)
    expect(@stat.files_available).to be_nil
  end

  example 'stat inodes_available is an alias for files_available' do
    expect(@stat.method(:inodes_available)).to eq(@stat.method(:files_available))
  end

  example 'stat filesystem_id works as expected' do
    expect(@stat).to respond_to(:filesystem_id)
    expect(@stat.filesystem_id).to be_a(Integer)
  end

  example 'stat flags works as expected' do
    expect(@stat).to respond_to(:flags)
    expect(@stat.flags).to be_a(Numeric)
  end

  example 'stat name_max works as expected' do
    expect(@stat).to respond_to(:name_max)
    expect(@stat.name_max).to be_a(Numeric)
  end

  example 'stat base_type works as expected' do
    expect(@stat).to respond_to(:base_type)
    expect(@stat.base_type).to be_a(String)
  end

  example 'stat bytes_total basic functionality' do
    expect(@stat).to respond_to(:bytes_total)
    expect(@stat.bytes_total).to be_a(Numeric)
  end

  example 'stat bytes_free basic functionality' do
    expect(@stat).to respond_to(:bytes_free)
    expect(@stat.bytes_free).to be_a(Numeric)
    expect(@stat.blocks_free * @stat.block_size).to eq(@stat.bytes_free)
  end

  example 'stat bytes_available basic functionality' do
    expect(@stat).to respond_to(:bytes_available)
    expect(@stat.bytes_available).to be_a(Numeric)
    expect(@stat.blocks_available * @stat.block_size).to eq(@stat.bytes_available)
  end

  example 'stat bytes_used basic functionality' do
    expect(@stat).to respond_to(:bytes_used)
    expect(@stat.bytes_used).to be_a(Numeric)
  end

  example 'stat percent_used basic functionality' do
    expect(@stat).to respond_to(:percent_used)
    expect(@stat.percent_used).to be_a(Float)
  end

  example 'case_insensitive returns expected result' do
    expect(@stat).to respond_to(:case_insensitive?)
    expect(@stat.case_insensitive?).to be(true)
  end

  context 'Filesystem.stat(Pathname)' do
    before do
      @stat_pathname = described_class.stat(Pathname.new(root))
    end

    example 'class returns expected value with pathname argument' do
      expect(@stat_pathname.class).to eq(@stat.class)
    end

    example 'path returns expected value with pathname argument' do
      expect(@stat_pathname.path).to eq(@stat.path)
    end

    example 'block_size returns expected value with pathname argument' do
      expect(@stat_pathname.block_size).to eq(@stat.block_size)
    end

    example 'fragment_size returns expected value with pathname argument' do
      expect(@stat_pathname.fragment_size).to eq(@stat.fragment_size)
    end

    example 'blocks returns expected value with pathname argument' do
      expect(@stat_pathname.blocks).to eq(@stat.blocks)
    end

    example 'blocks_free returns expected value with pathname argument' do
      expect(@stat_pathname.blocks_free).to eq(@stat.blocks_free)
    end

    example 'blocks_available returns expected value with pathname argument' do
      expect(@stat_pathname.blocks_available).to eq(@stat.blocks_available)
    end

    example 'files returns expected value with pathname argument' do
      expect(@stat_pathname.files).to eq(@stat.files)
    end

    example 'files_free returns expected value with pathname argument' do
      expect(@stat_pathname.files_free).to eq(@stat.files_free)
    end

    example 'files_available returns expected value with pathname argument' do
      expect(@stat_pathname.files_available).to eq(@stat.files_available)
    end

    example 'filesystem_id returns expected value with pathname argument' do
      expect(@stat_pathname.filesystem_id).to eq(@stat.filesystem_id)
    end

    example 'flags returns expected value with pathname argument' do
      expect(@stat_pathname.flags).to eq(@stat.flags)
    end

    example 'name_max returns expected value with pathname argument' do
      expect(@stat_pathname.name_max).to eq(@stat.name_max)
    end

    example 'base_type returns expected value with pathname argument' do
      expect(@stat_pathname.base_type).to eq(@stat.base_type)
    end
  end

  context 'Filesystem.stat(Dir)' do
    before do
      @stat_dir = Dir.open(root){ |dir| described_class.stat(dir) }
    end

    example 'stat class with Dir argument works as expected' do
      expect(@stat_dir.class).to eq(@stat.class)
    end

    example 'stat path with Dir argument works as expected' do
      expect(@stat_dir.path).to eq(@stat.path)
    end

    example 'stat block_size with Dir argument works as expected' do
      expect(@stat_dir.block_size).to eq(@stat.block_size)
    end

    example 'stat fragment_size with Dir argument works as expected' do
      expect(@stat_dir.fragment_size).to eq(@stat.fragment_size)
    end

    example 'stat blocks with Dir argument works as expected' do
      expect(@stat_dir.blocks).to eq(@stat.blocks)
    end

    example 'stat blocks_free with Dir argument works as expected' do
      expect(@stat_dir.blocks_free).to eq(@stat.blocks_free)
    end

    example 'stat blocks_available with Dir argument works as expected' do
      expect(@stat_dir.blocks_available).to eq(@stat.blocks_available)
    end

    example 'stat files with Dir argument works as expected' do
      expect(@stat_dir.files).to eq(@stat.files)
    end

    example 'stat files_free with Dir argument works as expected' do
      expect(@stat_dir.files_free).to eq(@stat.files_free)
    end

    example 'stat files_available with Dir argument works as expected' do
      expect(@stat_dir.files_available).to eq(@stat.files_available)
    end

    example 'stat filesystem_id with Dir argument works as expected' do
      expect(@stat_dir.filesystem_id).to eq(@stat.filesystem_id)
    end

    example 'stat flags with Dir argument works as expected' do
      expect(@stat_dir.flags).to eq(@stat.flags)
    end

    example 'stat name_max with Dir argument works as expected' do
      expect(@stat_dir.name_max).to eq(@stat.name_max)
    end

    example 'stat base_type with Dir argument works as expected' do
      expect(@stat_dir.base_type).to eq(@stat.base_type)
    end
  end

  context 'mount_point' do
    example 'mount_point singleton method basic functionality' do
      expect(described_class).to respond_to(:mount_point)
      expect{ described_class.mount_point(Dir.pwd) }.not_to raise_error
      expect(described_class.mount_point(Dir.pwd)).to be_a(String)
    end

    example 'mount_point singleton method returns expected value' do
      expect(described_class.mount_point('C:\\Users\\foo')).to eq('C:\\')
      expect(described_class.mount_point('//foo/bar/baz')).to eq('\\\\foo\\bar')
    end

    example 'mount_point works with Pathname object' do
      expect{ described_class.mount_point(Pathname.new('C:/Users/foo')) }.not_to raise_error
      expect(described_class.mount_point('C:\\Users\\foo')).to eq('C:\\')
      expect(described_class.mount_point('//foo/bar/baz')).to eq('\\\\foo\\bar')
    end
  end

  context 'filesystem constants are defined' do
    example 'CASE_SENSITIVE_SEARCH' do
      expect(Sys::Filesystem::CASE_SENSITIVE_SEARCH).not_to be_nil
    end

    example 'CASE_PRESERVED_NAMES' do
      expect(Sys::Filesystem::CASE_PRESERVED_NAMES).not_to be_nil
    end

    example 'UNICODE_ON_DISK' do
      expect(Sys::Filesystem::UNICODE_ON_DISK).not_to be_nil
    end

    example 'PERSISTENT_ACLS' do
      expect(Sys::Filesystem::PERSISTENT_ACLS).not_to be_nil
    end

    example 'FILE_COMPRESSION' do
      expect(Sys::Filesystem::FILE_COMPRESSION).not_to be_nil
    end

    example 'VOLUME_QUOTAS' do
      expect(Sys::Filesystem::VOLUME_QUOTAS).not_to be_nil
    end

    example 'SUPPORTS_SPARSE_FILES' do
      expect(Sys::Filesystem::SUPPORTS_SPARSE_FILES).not_to be_nil
    end

    example 'SUPPORTS_REPARSE_POINTS' do
      expect(Sys::Filesystem::SUPPORTS_REPARSE_POINTS).not_to be_nil
    end

    example 'SUPPORTS_REMOTE_STORAGE' do
      expect(Sys::Filesystem::SUPPORTS_REMOTE_STORAGE).not_to be_nil
    end

    example 'VOLUME_IS_COMPRESSED' do
      expect(Sys::Filesystem::VOLUME_IS_COMPRESSED).not_to be_nil
    end

    example 'SUPPORTS_OBJECT_IDS' do
      expect(Sys::Filesystem::SUPPORTS_OBJECT_IDS).not_to be_nil
    end

    example 'SUPPORTS_ENCRYPTION' do
      expect(Sys::Filesystem::SUPPORTS_ENCRYPTION).not_to be_nil
    end

    example 'NAMED_STREAMS' do
      expect(Sys::Filesystem::NAMED_STREAMS).not_to be_nil
    end

    example 'READ_ONLY_VOLUME' do
      expect(Sys::Filesystem::READ_ONLY_VOLUME).not_to be_nil
    end
  end

  example 'stat singleton method defaults to root path if proviced' do
    expect{ described_class.stat('C://Program Files') }.not_to raise_error
  end

  example 'stat singleton method accepts a Pathname object' do
    expect{ described_class.stat(Pathname.new('C://Program Files')) }.not_to raise_error
  end

  example 'stat singleton method requires a single argument' do
    expect{ described_class.stat }.to raise_error(ArgumentError)
    expect{ described_class.stat(Dir.pwd, Dir.pwd) }.to raise_error(ArgumentError)
  end

  example 'stat singleton method raises an error if path is not found' do
    expect{ described_class.stat('C://Bogus//Dir') }.to raise_error(Errno::ESRCH)
  end

  context 'Filesystem::Mount' do
    let(:mount){ described_class.mounts[0] }

    before do
      @array = []
    end

    example 'mount singleton method exists' do
      expect(described_class).to respond_to(:mount)
    end

    example 'umount singleton method exists' do
      expect(described_class).to respond_to(:umount)
    end

    example 'mounts singleton method basic functionality' do
      expect(described_class).to respond_to(:mounts)
      expect{ described_class.mounts }.not_to raise_error
      expect{ described_class.mounts{} }.not_to raise_error
    end

    example 'mounts singleton method returns the expected value' do
      expect(described_class.mounts).to be_a(Array)
      expect(described_class.mounts[0]).to be_a(Sys::Filesystem::Mount)
    end

    example 'mounts singleton method works as expected when a block is provided' do
      expect(described_class.mounts{}).to be_nil
      expect{ described_class.mounts{ |mt| @array << mt } }.not_to raise_error
      expect(@array[0]).to be_a(Sys::Filesystem::Mount)
    end

    example 'mount name works as expected' do
      expect(mount).to respond_to(:name)
      expect(mount.name).to be_a(String)
    end

    example 'mount_time works as expected' do
      expect(mount).to respond_to(:mount_time)
      expect(mount.mount_time).to be_a(Time)
    end

    example 'mount type works as expected' do
      expect(mount).to respond_to(:mount_type)
      expect(mount.mount_type).to be_a(String)
    end

    example 'mount point works as expected' do
      expect(mount).to respond_to(:mount_point)
      expect(mount.mount_point).to be_a(String)
    end

    example 'mount options works as expected' do
      expect(mount).to respond_to(:options)
      expect(mount.options).to be_a(String)
    end

    example 'mount pass_number works as expected' do
      expect(mount).to respond_to(:pass_number)
      expect(mount.pass_number).to be_nil
    end

    example 'mount frequency works as expected' do
      expect(mount).to respond_to(:frequency)
      expect(mount.frequency).to be_nil
    end

    example 'mounts singleton method does not accept any arguments' do
      expect{ described_class.mounts('C:\\') }.to raise_error(ArgumentError)
    end
  end

  example 'custom Numeric#to_kb method works as expected' do
    expect(@size).to respond_to(:to_kb)
    expect(@size.to_kb).to eq(57344)
  end

  example 'custom Numeric#to_mb method works as expected' do
    expect(@size).to respond_to(:to_mb)
    expect(@size.to_mb).to eq(56)
  end

  example 'custom Numeric#to_gb method works as expected' do
    expect(@size).to respond_to(:to_gb)
    expect(@size.to_gb).to eq(0)
  end

  context 'FFI' do
    example 'internal ffi functions are not public' do
      expect(described_class.methods.include?(:GetVolumeInformationA)).to be(false)
      expect(described_class.instance_methods.include?(:GetVolumeInformationA)).to be(false)
    end
  end
end
