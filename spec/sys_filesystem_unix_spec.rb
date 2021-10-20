####################################################################
# sys_filesystem_unix_spec.rb
#
# Specs for the Sys::Filesystem.stat method and related stuff.
# This test suite should be run via the 'rake spec' task.
####################################################################
require 'spec_helper'
require 'sys-filesystem'
require 'pathname'

RSpec.describe Sys::Filesystem, :unix => true do
  let(:solaris) { RbConfig::CONFIG['host_os'] =~ /sunos|solaris/i }
  let(:linux)   { RbConfig::CONFIG['host_os'] =~ /linux/i }
  let(:bsd)     { RbConfig::CONFIG['host_os'] =~ /bsd/i }
  let(:darwin)  { RbConfig::CONFIG['host_os'] =~ /mac|darwin/i }
  let(:root)    { '/' }

  before do
    @stat  = Sys::Filesystem.stat(root)
    @size  = 58720256
  end

  example "version number is set to the expected value" do
    expect(Sys::Filesystem::VERSION).to eq('1.4.3')
    expect(Sys::Filesystem::VERSION).to be_frozen
  end

  example "you cannot instantiate an instance" do
    expect{ described_class.new }.to raise_error(NoMethodError)
  end

  example "stat path works as expected" do
    expect(@stat).to respond_to(:path)
    expect(@stat.path).to eq(root)
  end

  example "stat block_size works as expected" do
    expect(@stat).to respond_to(:block_size)
    expect(@stat.block_size).to be_kind_of(Numeric)
  end

  example "stat fragment_size works as expected" do
    expect(@stat).to respond_to(:fragment_size)
    expect(@stat.fragment_size).to be_kind_of(Numeric)
  end

  example "stat fragment_size is a plausible value" do
    expect(@stat.fragment_size).to be >= 512
    expect(@stat.fragment_size).to be <= 16384
  end

  example "stat blocks works as expected" do
    expect(@stat).to respond_to(:blocks)
    expect(@stat.blocks).to be_kind_of(Numeric)
  end

  example "stat blocks_free works as expected" do
    expect(@stat).to respond_to(:blocks_free)
    expect(@stat.blocks_free).to be_kind_of(Numeric)
  end

  example "stat blocks_available works as expected" do
    expect(@stat).to respond_to(:blocks_available)
    expect(@stat.blocks_available).to be_kind_of(Numeric)
  end

  example "stat files works as expected" do
    expect(@stat).to respond_to(:files)
    expect(@stat.files).to be_kind_of(Numeric)
  end

  example "stat inodes is an alias for files" do
    expect(@stat).to respond_to(:inodes)
    expect(@stat.method(:inodes)).to eq(@stat.method(:files))
  end

  example "stat files tree works as expected" do
    expect(@stat).to respond_to(:files_free)
    expect(@stat.files_free).to be_kind_of(Numeric)
  end

  example "stat inodes_free is an alias for files_free" do
    expect(@stat).to respond_to(:inodes_free)
    expect(@stat.method(:inodes_free)).to eq(@stat.method(:files_free))
  end

  example "stat files_available works as expected" do
    expect(@stat).to respond_to(:files_available)
    expect(@stat.files_available).to be_kind_of(Numeric)
  end

  example "stat inodes_available is an alias for files_available" do
    expect(@stat).to respond_to(:inodes_available)
    expect(@stat.method(:inodes_available)).to eq(@stat.method(:files_available))
  end

  example "stat filesystem_id works as expected" do
    expect(@stat).to respond_to(:filesystem_id)
    expect(@stat.filesystem_id).to be_kind_of(Integer)
  end

  example "stat flags works as expected" do
    expect(@stat).to respond_to(:flags)
    expect(@stat.flags).to be_kind_of(Numeric)
  end

  example "stat name_max works as expected" do
    expect(@stat).to respond_to(:name_max)
    expect(@stat.name_max).to be_kind_of(Numeric)
  end

  example "stat base_type works as expected" do
    skip "base_type test skipped except on Solaris" unless solaris

    expect(@stat).to respond_to(:base_type)
    expect(@stat.base_type).to be_kind_of(String)
  end

  example "stat constants are defined" do
    expect(Sys::Filesystem::Stat::RDONLY).not_to be_nil
    expect(Sys::Filesystem::Stat::NOSUID).not_to be_nil
  end

  example "stat constants for solaris are defined" do
    skip "NOTRUNC test skipped except on Solaris" unless solaris
    expect(Sys::Filesystem::Stat::NOTRUNC).not_to be_nil
  end

  example "stat bytes_total works as expected" do
    expect(@stat).to respond_to(:bytes_total)
    expect(@stat.bytes_total).to be_kind_of(Numeric)
  end

  example "stat bytes_free works as expected" do
    expect(@stat).to respond_to(:bytes_free)
    expect(@stat.bytes_free).to be_kind_of(Numeric)
    expect(@stat.blocks_free * @stat.fragment_size).to eq(@stat.bytes_free)
  end

  example "stat bytes_available works as expected" do
    expect(@stat).to respond_to(:bytes_available)
    expect(@stat.bytes_available).to be_kind_of(Numeric)
    expect(@stat.blocks_available * @stat.fragment_size).to eq(@stat.bytes_available)
  end

  example "stat bytes works as expected" do
    expect(@stat).to respond_to(:bytes_used)
    expect(@stat.bytes_used).to be_kind_of(Numeric)
  end

  example "stat percent_used works as expected" do
    expect(@stat).to respond_to(:percent_used)
    expect(@stat.percent_used).to be_kind_of(Float)
  end

  example "stat singleton method requires an argument" do
    expect{ Sys::Filesystem.stat }.to raise_error(ArgumentError)
  end

  example "stat case_insensitive method works as expected" do
    expected = darwin ? true : false
    expect(@stat.case_insensitive?).to eq(expected)
    expect(Sys::Filesystem.stat(Dir.home).case_insensitive?).to eq(expected)
  end

  example "stat case_sensitive method works as expected" do
    expected = darwin ? false : true
    expect(@stat.case_sensitive?).to eq(expected)
    expect(Sys::Filesystem.stat(Dir.home).case_sensitive?).to eq(expected)
  end

  example "numeric helper methods are defined" do
    expect(@size).to respond_to(:to_kb)
    expect(@size).to respond_to(:to_mb)
    expect(@size).to respond_to(:to_gb)
    expect(@size).to respond_to(:to_tb)
  end

  example "to_kb works as expected" do
    expect(@size.to_kb).to eq(57344)
  end

  example "to_mb works as expected" do
    expect(@size.to_mb).to eq(56)
  end

  example "to_gb works as expected" do
    expect(@size.to_gb).to eq(0)
  end

  context "Filesystem.stat(Pathname)" do
    before do
      @stat_pathname = Sys::Filesystem.stat(Pathname.new(root))
    end

    example "stat with Pathname argument works as expected" do
      expect(@stat_pathname.class).to eq(@stat.class)
      expect(@stat_pathname.path).to eq(@stat.path)
      expect(@stat_pathname.block_size).to eq(@stat.block_size)
      expect(@stat_pathname.fragment_size).to eq(@stat.fragment_size)
      expect(@stat_pathname.blocks).to eq(@stat.blocks)
      expect(@stat_pathname.blocks_free).to eq(@stat.blocks_free)
      expect(@stat_pathname.blocks_available).to eq(@stat.blocks_available)
      expect(@stat_pathname.files).to eq(@stat.files)
      expect(@stat_pathname.files_free).to eq(@stat.files_free)
      expect(@stat_pathname.files_available).to eq(@stat.files_available)
      expect(@stat_pathname.filesystem_id).to eq(@stat.filesystem_id)
      expect(@stat_pathname.flags).to eq(@stat.flags)
      expect(@stat_pathname.name_max).to eq(@stat.name_max)
      expect(@stat_pathname.base_type).to eq(@stat.base_type)
    end
  end

  context "Filesystem.stat(File)" do
    before do
      @stat_file = File.open(root){ |file| Sys::Filesystem.stat(file) }
    end

    example "stat with File argument works as expected" do
      expect(@stat_file.class).to eq(@stat.class)
      expect(@stat_file.path).to eq(@stat.path)
      expect(@stat_file.block_size).to eq(@stat.block_size)
      expect(@stat_file.fragment_size).to eq(@stat.fragment_size)
      expect(@stat_file.blocks).to eq(@stat.blocks)
      expect(@stat_file.blocks_free).to eq(@stat.blocks_free)
      expect(@stat_file.blocks_available).to eq(@stat.blocks_available)
      expect(@stat_file.files).to eq(@stat.files)
      expect(@stat_file.files_free).to eq(@stat.files_free)
      expect(@stat_file.files_available).to eq(@stat.files_available)
      expect(@stat_file.filesystem_id).to eq(@stat.filesystem_id)
      expect(@stat_file.flags).to eq(@stat.flags)
      expect(@stat_file.name_max).to eq(@stat.name_max)
      expect(@stat_file.base_type).to eq(@stat.base_type)
    end
  end

  context "Filesystem.stat(Dir)" do
    before do
      @stat_dir = Dir.open(root){ |dir| Sys::Filesystem.stat(dir) }
    end

    example "stat with Dir argument works as expected" do
      expect(@stat_dir.class).to eq(@stat.class)
      expect(@stat_dir.path).to eq(@stat.path)
      expect(@stat_dir.block_size).to eq(@stat.block_size)
      expect(@stat_dir.fragment_size).to eq(@stat.fragment_size)
      expect(@stat_dir.blocks).to eq(@stat.blocks)
      expect(@stat_dir.blocks_free).to eq(@stat.blocks_free)
      expect(@stat_dir.blocks_available).to eq(@stat.blocks_available)
      expect(@stat_dir.files).to eq(@stat.files)
      expect(@stat_dir.files_free).to eq(@stat.files_free)
      expect(@stat_dir.files_available).to eq(@stat.files_available)
      expect(@stat_dir.filesystem_id).to eq(@stat.filesystem_id)
      expect(@stat_dir.flags).to eq(@stat.flags)
      expect(@stat_dir.name_max).to eq(@stat.name_max)
      expect(@stat_dir.base_type).to eq(@stat.base_type)
    end
  end

  context "Filesystem::Mount" do
    let(:mount){ Sys::Filesystem.mounts[0] }

    before do
      @array = []
    end

    example "mounts singleton method works as expected without a block" do
      expect{ @array = Sys::Filesystem.mounts }.not_to raise_error
      expect(@array[0]).to be_kind_of(Sys::Filesystem::Mount)
    end

    example "mounts singleton method works as expected with a block" do
      expect{ Sys::Filesystem.mounts{ |m| @array << m } }.not_to raise_error
      expect(@array[0]).to be_kind_of(Sys::Filesystem::Mount)
    end

    example "calling the mounts singleton method a large number of times does not cause issues" do
      expect{ 1000.times{ @array = Sys::Filesystem.mounts } }.not_to raise_error
    end

    example "mount name method works as expected" do
      expect(mount).to respond_to(:name)
      expect(mount.name).to be_kind_of(String)
    end

    example "mount fsname is an alias for name" do
      expect(mount).to respond_to(:fsname)
      expect(mount.method(:fsname)).to eq(mount.method(:name))
    end

    example "mount point method works as expected" do
      expect(mount).to respond_to(:mount_point)
      expect(mount.mount_point).to be_kind_of(String)
    end

    example "mount dir is an alias for mount_point" do
      expect(mount).to respond_to(:dir)
      expect(mount.method(:dir)).to eq(mount.method(:mount_point))
    end

    example "mount mount_type works as expected" do
      expect(mount).to respond_to(:mount_type)
      expect(mount.mount_type).to be_kind_of(String)
    end

    example "mount options works as expected" do
      expect(mount).to respond_to(:options)
      expect(mount.options).to be_kind_of(String)
    end

    example "mount opts is an alias for options" do
      expect(mount).to respond_to(:opts)
      expect(mount.method(:opts)).to eq(mount.method(:options))
    end

    example "mount time works as expected" do
      expect(mount).to respond_to(:mount_time)

      if solaris
        expect(mount.mount_time).to be_kind_of(Time)
      else
        expect(mount.mount_time).to be_nil
      end
    end

    example "mount dump_frequency works as expected" do
      msg = 'dump_frequency test skipped on this platform'
      skip msg if solaris || bsd || darwin
      expect(mount).to respond_to(:dump_frequency)
      expect(mount.dump_frequency).to be_kind_of(Numeric)
    end

    example "mount freq is an alias for dump_frequency" do
      expect(mount).to respond_to(:freq)
      expect(mount.method(:freq)).to eq(mount.method(:dump_frequency))
    end

    example "mount pass_number works as expected" do
      msg = 'pass_number test skipped on this platform'
      skip msg if solaris || bsd || darwin
      expect(mount).to respond_to(:pass_number)
      expect(mount.pass_number).to be_kind_of(Numeric)
    end

    example "mount passno is an alias for pass_number" do
      expect(mount).to respond_to(:passno)
      expect(mount.method(:passno)).to eq(mount.method(:pass_number))
    end

    example "mount_point singleton method works as expected" do
      expect(Sys::Filesystem).to respond_to(:mount_point)
      expect{ Sys::Filesystem.mount_point(Dir.pwd) }.not_to raise_error
      expect(Sys::Filesystem.mount_point(Dir.pwd)).to be_kind_of(String)
    end

    example "mount singleton method is defined" do
      expect(Sys::Filesystem).to respond_to(:mount)
    end

    example "umount singleton method is defined" do
      expect(Sys::Filesystem).to respond_to(:umount)
    end
  end

  context "FFI" do
    before(:context) do
      require 'mkmf-lite'
    end

    let(:dummy) { Class.new { extend Mkmf::Lite } }

    example "ffi functions are private" do
      expect(Sys::Filesystem.methods.include?('statvfs')).to be false
      expect(Sys::Filesystem.methods.include?('strerror')).to be false
    end

    example "statfs struct is expected size" do
      header = bsd || darwin ? 'sys/mount.h' : 'sys/statfs.h'
      expect(Sys::Filesystem::Structs::Statfs.size).to eq(dummy.check_sizeof('struct statfs', header))
    end

    example "statvfs struct is expected size" do
      expect(Sys::Filesystem::Structs::Statvfs.size).to eq(dummy.check_sizeof('struct statvfs', 'sys/statvfs.h'))
    end

    example "mnttab struct is expected size" do
      skip "mnttab test skipped except on Solaris" unless solaris
      expect(Sys::Filesystem::Structs::Mnttab.size).to eq(dummy.check_sizeof('struct mnttab', 'sys/mnttab.h'))
    end

    example "mntent struct is expected size" do
      skip "mnttab test skipped except on Linux" unless linux
      expect(Sys::Filesystem::Structs::Mntent.size).to eq(dummy.check_sizeof('struct mntent', 'mntent.h'))
    end
  end
end
