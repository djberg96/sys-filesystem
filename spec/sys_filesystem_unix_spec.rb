# frozen_string_literal: true

####################################################################
# sys_filesystem_unix_spec.rb
#
# Specs for the Sys::Filesystem.stat method and related stuff.
# This test suite should be run via the 'rake spec' task.
####################################################################
require 'spec_helper'
require 'sys-filesystem'
require 'pathname'

RSpec.describe Sys::Filesystem, :unix do
  let(:linux)   { RbConfig::CONFIG['host_os'] =~ /linux/i }
  let(:bsd)     { RbConfig::CONFIG['host_os'] =~ /bsd|dragonfly/i }
  let(:darwin)  { RbConfig::CONFIG['host_os'] =~ /mac|darwin/i }
  let(:root)    { '/' }

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

  example 'stat fragment_size works as expected' do
    expect(@stat).to respond_to(:fragment_size)
    expect(@stat.fragment_size).to be_a(Numeric)
  end

  example 'stat fragment_size is a plausible value' do
    expect(@stat.fragment_size).to be >= 512
    expect(@stat.fragment_size).to be <= 2**16
    expect(@stat.fragment_size).to be <= @stat.block_size
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

  example 'stat files works as expected' do
    expect(@stat).to respond_to(:files)
    expect(@stat.files).to be_a(Numeric)
  end

  example 'stat inodes is an alias for files' do
    expect(@stat).to respond_to(:inodes)
    expect(@stat.method(:inodes)).to eq(@stat.method(:files))
  end

  example 'stat files tree works as expected' do
    expect(@stat).to respond_to(:files_free)
    expect(@stat.files_free).to be_a(Numeric)
  end

  example 'stat inodes_free is an alias for files_free' do
    expect(@stat).to respond_to(:inodes_free)
    expect(@stat.method(:inodes_free)).to eq(@stat.method(:files_free))
  end

  example 'stat files_available works as expected' do
    expect(@stat).to respond_to(:files_available)
    expect(@stat.files_available).to be_a(Numeric)
  end

  example 'stat inodes_available is an alias for files_available' do
    expect(@stat).to respond_to(:inodes_available)
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

  context 'dragonfly', :dragonfly do
    example 'owner works as expected' do
      expect(@stat).to respond_to(:owner)
      expect(@stat.owner).to be_a(Numeric)
    end

    example 'filesystem_type works as expected' do
      expect(@stat).to respond_to(:filesystem_type)
      expect(@stat.filesystem_type).to be_a(Numeric)
    end

    example 'sync_reads works as expected' do
      expect(@stat).to respond_to(:sync_reads)
      expect(@stat.sync_reads).to be_a(Numeric)
    end

    example 'async_reads works as expected' do
      expect(@stat).to respond_to(:async_reads)
      expect(@stat.async_reads).to be_a(Numeric)
    end

    example 'sync_writes works as expected' do
      expect(@stat).to respond_to(:sync_writes)
      expect(@stat.sync_writes).to be_a(Numeric)
    end

    example 'async_writes works as expected' do
      expect(@stat).to respond_to(:async_writes)
      expect(@stat.async_writes).to be_a(Numeric)
    end
  end

  example 'stat constants are defined' do
    expect(Sys::Filesystem::Stat::RDONLY).not_to be_nil
    expect(Sys::Filesystem::Stat::NOSUID).not_to be_nil
  end

  example 'stat bytes_total works as expected' do
    expect(@stat).to respond_to(:bytes_total)
    expect(@stat.bytes_total).to be_a(Numeric)
  end

  example 'stat bytes_free works as expected' do
    expect(@stat).to respond_to(:bytes_free)
    expect(@stat.bytes_free).to be_a(Numeric)
    expect(@stat.blocks_free * @stat.fragment_size).to eq(@stat.bytes_free)
  end

  example 'stat bytes_available works as expected' do
    expect(@stat).to respond_to(:bytes_available)
    expect(@stat.bytes_available).to be_a(Numeric)
    expect(@stat.blocks_available * @stat.fragment_size).to eq(@stat.bytes_available)
  end

  example 'stat bytes works as expected' do
    expect(@stat).to respond_to(:bytes_used)
    expect(@stat.bytes_used).to be_a(Numeric)
  end

  example 'stat percent_used works as expected' do
    expect(@stat).to respond_to(:percent_used)
    expect(@stat.percent_used).to be_a(Float)
  end

  example 'stat singleton method requires an argument' do
    expect{ described_class.stat }.to raise_error(ArgumentError)
  end

  example 'stat case_insensitive method works as expected' do
    expected = darwin ? true : false
    expect(@stat.case_insensitive?).to eq(expected)
    expect(described_class.stat(Dir.home).case_insensitive?).to eq(expected)
  end

  example 'stat case_sensitive method works as expected' do
    expected = darwin ? false : true
    expect(@stat.case_sensitive?).to eq(expected)
    expect(described_class.stat(Dir.home).case_sensitive?).to eq(expected)
  end

  example 'numeric helper methods are defined' do
    expect(@size).to respond_to(:to_kb)
    expect(@size).to respond_to(:to_mb)
    expect(@size).to respond_to(:to_gb)
    expect(@size).to respond_to(:to_tb)
  end

  example 'to_kb works as expected' do
    expect(@size.to_kb).to eq(57344)
  end

  example 'to_mb works as expected' do
    expect(@size.to_mb).to eq(56)
  end

  example 'to_gb works as expected' do
    expect(@size.to_gb).to eq(0)
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

  context 'Filesystem.stat(File)' do
    before do
      @stat_file = File.open(root){ |file| described_class.stat(file) }
    end

    example 'class returns expected value with file argument' do
      expect(@stat_file.class).to eq(@stat.class)
    end

    example 'path returns expected value with file argument' do
      expect(@stat_file.path).to eq(@stat.path)
    end

    example 'block_size returns expected value with file argument' do
      expect(@stat_file.block_size).to eq(@stat.block_size)
    end

    example 'fragment_size returns expected value with file argument' do
      expect(@stat_file.fragment_size).to eq(@stat.fragment_size)
    end

    example 'blocks returns expected value with file argument' do
      expect(@stat_file.blocks).to eq(@stat.blocks)
    end

    example 'blocks_free returns expected value with file argument' do
      expect(@stat_file.blocks_free).to eq(@stat.blocks_free)
    end

    example 'blocks_available returns expected value with file argument' do
      expect(@stat_file.blocks_available).to eq(@stat.blocks_available)
    end

    example 'files returns expected value with file argument' do
      expect(@stat_file.files).to eq(@stat.files)
    end

    example 'files_free returns expected value with file argument' do
      expect(@stat_file.files_free).to eq(@stat.files_free)
    end

    example 'files_available returns expected value with file argument' do
      expect(@stat_file.files_available).to eq(@stat.files_available)
    end

    example 'filesystem_id returns expected value with file argument' do
      expect(@stat_file.filesystem_id).to eq(@stat.filesystem_id)
    end

    example 'flags returns expected value with file argument' do
      expect(@stat_file.flags).to eq(@stat.flags)
    end

    example 'name_max returns expected value with file argument' do
      expect(@stat_file.name_max).to eq(@stat.name_max)
    end

    example 'base_type returns expected value with file argument' do
      expect(@stat_file.base_type).to eq(@stat.base_type)
    end
  end

  context 'Filesystem.stat(Dir)' do
    before do
      @stat_dir = Dir.open(root){ |dir| described_class.stat(dir) }
    end

    example 'class returns expected value with Dir argument' do
      expect(@stat_dir.class).to eq(@stat.class)
    end

    example 'path returns expected value with Dir argument' do
      expect(@stat_dir.path).to eq(@stat.path)
    end

    example 'block_size returns expected value with Dir argument' do
      expect(@stat_dir.block_size).to eq(@stat.block_size)
    end

    example 'fragment_size returns expected value with Dir argument' do
      expect(@stat_dir.fragment_size).to eq(@stat.fragment_size)
    end

    example 'blocks returns expected value with Dir argument' do
      expect(@stat_dir.blocks).to eq(@stat.blocks)
    end

    example 'blocks_free returns expected value with Dir argument' do
      expect(@stat_dir.blocks_free).to eq(@stat.blocks_free)
    end

    example 'blocks_available returns expected value with Dir argument' do
      expect(@stat_dir.blocks_available).to eq(@stat.blocks_available)
    end

    example 'files returns expected value with Dir argument' do
      expect(@stat_dir.files).to eq(@stat.files)
    end

    example 'files_free returns expected value with Dir argument' do
      expect(@stat_dir.files_free).to eq(@stat.files_free)
    end

    example 'files_available returns expected value with Dir argument' do
      expect(@stat_dir.files_available).to eq(@stat.files_available)
    end

    example 'filesystem_id returns expected value with Dir argument' do
      expect(@stat_dir.filesystem_id).to eq(@stat.filesystem_id)
    end

    example 'flags returns expected value with Dir argument' do
      expect(@stat_dir.flags).to eq(@stat.flags)
    end

    example 'name_max returns expected value with Dir argument' do
      expect(@stat_dir.name_max).to eq(@stat.name_max)
    end

    example 'base_type returns expected value with Dir argument' do
      expect(@stat_dir.base_type).to eq(@stat.base_type)
    end
  end

  context 'Filesystem::Mount' do
    let(:mount){ described_class.mounts[0] }

    before do
      @array = []
    end

    example 'mounts singleton method works as expected without a block' do
      expect{ @array = described_class.mounts }.not_to raise_error
      expect(@array[0]).to be_a(Sys::Filesystem::Mount)
    end

    example 'mounts singleton method works as expected with a block' do
      expect{ described_class.mounts{ |m| @array << m } }.not_to raise_error
      expect(@array[0]).to be_a(Sys::Filesystem::Mount)
    end

    example 'calling the mounts singleton method a large number of times does not cause issues' do
      expect{ 1000.times{ @array = described_class.mounts } }.not_to raise_error
    end

    example 'mount name method works as expected' do
      expect(mount).to respond_to(:name)
      expect(mount.name).to be_a(String)
    end

    example 'mount fsname is an alias for name' do
      expect(mount).to respond_to(:fsname)
      expect(mount.method(:fsname)).to eq(mount.method(:name))
    end

    example 'mount point method works as expected' do
      expect(mount).to respond_to(:mount_point)
      expect(mount.mount_point).to be_a(String)
    end

    example 'mount dir is an alias for mount_point' do
      expect(mount).to respond_to(:dir)
      expect(mount.method(:dir)).to eq(mount.method(:mount_point))
    end

    example 'mount mount_type works as expected' do
      expect(mount).to respond_to(:mount_type)
      expect(mount.mount_type).to be_a(String)
    end

    example 'mount options works as expected' do
      expect(mount).to respond_to(:options)
      expect(mount.options).to be_a(String)
    end

    example 'mount opts is an alias for options' do
      expect(mount).to respond_to(:opts)
      expect(mount.method(:opts)).to eq(mount.method(:options))
    end

    # This method may be removed
    example 'mount time works as expected' do
      expect(mount).to respond_to(:mount_time)
      expect(mount.mount_time).to be_nil
    end

    example 'mount dump_frequency works as expected' do
      msg = 'dump_frequency test skipped on this platform'
      skip msg if bsd || darwin
      expect(mount).to respond_to(:dump_frequency)
      expect(mount.dump_frequency).to be_a(Numeric)
    end

    example 'mount freq is an alias for dump_frequency' do
      expect(mount).to respond_to(:freq)
      expect(mount.method(:freq)).to eq(mount.method(:dump_frequency))
    end

    example 'mount pass_number works as expected' do
      msg = 'pass_number test skipped on this platform'
      skip msg if bsd || darwin
      expect(mount).to respond_to(:pass_number)
      expect(mount.pass_number).to be_a(Numeric)
    end

    example 'mount passno is an alias for pass_number' do
      expect(mount).to respond_to(:passno)
      expect(mount.method(:passno)).to eq(mount.method(:pass_number))
    end

    example 'mount_point singleton method works as expected' do
      expect(described_class).to respond_to(:mount_point)
      expect{ described_class.mount_point(Dir.pwd) }.not_to raise_error
      expect(described_class.mount_point(Dir.pwd)).to be_a(String)
    end

    example 'mount singleton method is defined' do
      expect(described_class).to respond_to(:mount)
    end

    example 'umount singleton method is defined' do
      expect(described_class).to respond_to(:umount)
    end
  end

  context 'FFI' do
    before(:context) do
      require 'mkmf-lite'
    end

    let(:dummy) { Class.new { extend Mkmf::Lite } }

    example 'ffi functions are private' do
      expect(described_class.methods.include?('statvfs')).to be false
      expect(described_class.methods.include?('strerror')).to be false
    end

    example 'statfs struct is expected size' do
      header = bsd || darwin ? 'sys/mount.h' : 'sys/statfs.h'
      expect(Sys::Filesystem::Structs::Statfs.size).to eq(dummy.check_sizeof('struct statfs', header))
    end

    example 'statvfs struct is expected size' do
      expect(Sys::Filesystem::Structs::Statvfs.size).to eq(dummy.check_sizeof('struct statvfs', 'sys/statvfs.h'))
    end

    example 'mntent struct is expected size' do
      skip 'mnttab test skipped except on Linux' unless linux
      expect(Sys::Filesystem::Structs::Mntent.size).to eq(dummy.check_sizeof('struct mntent', 'mntent.h'))
    end

    example 'a failed statvfs call behaves as expected' do
      msg = 'statvfs() function failed: No such file or directory'
      expect{ described_class.stat('/whatever') }.to raise_error(Sys::Filesystem::Error, msg)
    end

    example 'statvfs alias is used for statvfs64' do
      expect(Sys::Filesystem::Functions.attached_functions[:statvfs]).to be_a(FFI::Function)
      expect(Sys::Filesystem::Functions.attached_functions[:statvfs64]).to be_nil
    end
  end

  describe 'linux64? method' do
    let(:functions_class) { Sys::Filesystem::Functions }

    # Helper method to test linux64? with mocked config
    def test_linux64_with_config(host_os, pointer_size, ruby_platform = nil, java_arch = nil)
      # Mock RbConfig::CONFIG
      allow(RbConfig::CONFIG).to receive(:[]).and_call_original
      allow(RbConfig::CONFIG).to receive(:[]).with('host_os').and_return(host_os)

      # When running under JRuby, we need to handle it differently
      if RUBY_PLATFORM == 'java'
        # Under JRuby, always mock ENV_JAVA since that's the path the code will take
        if java_arch
          # This is a JRuby-specific test
          allow(ENV_JAVA).to receive(:[]).with('sun.arch.data.model').and_return(java_arch.to_s)
        else
          # This is meant to test regular Ruby logic, but under JRuby we need to mock ENV_JAVA
          # to make it take the "regular Ruby" path by returning nil/empty
          expected_arch = pointer_size == 8 ? '64' : '32'
          allow(ENV_JAVA).to receive(:[]).with('sun.arch.data.model').and_return(expected_arch)
        end
      else
        # Running under regular Ruby
        # Determine arch and DEFS based on host_os for the new multi-check approach
        if pointer_size == 8
          # For 64-bit systems, make arch contain "64"
          arch_value = host_os.include?('64') ? host_os : host_os + '64'
          defs_value = '-DSOMETHING=1'
        else
          # For 32-bit systems, ensure neither arch nor DEFS contain "64"
          arch_value = host_os.gsub(/64/, '32')
          defs_value = '-DSOMETHING=1'
        end

        allow(RbConfig::CONFIG).to receive(:[]).with('arch').and_return(arch_value)
        allow(RbConfig::CONFIG).to receive(:[]).with('DEFS').and_return(defs_value)

        if ruby_platform == 'java'
          # Mock RUBY_PLATFORM for JRuby tests
          stub_const('RUBY_PLATFORM', 'java')

          # Mock ENV_JAVA for JRuby
          env_java_mock = double('ENV_JAVA')
          allow(env_java_mock).to receive(:[]).with('sun.arch.data.model').and_return(java_arch.to_s)
          stub_const('ENV_JAVA', env_java_mock)
        else
          # Mock the pack method for regular Ruby (last resort check)
          packed_data = 'x' * pointer_size
          allow_any_instance_of(Array).to receive(:pack).with('P').and_return(packed_data)
        end
      end

      functions_class.send(:linux64?)
    end

    context 'with different Linux distributions on 64-bit architectures' do
      let(:linux_distros) do
        {
          'x86_64-linux-gnu' => 'Ubuntu/Debian x86_64',
          'x86_64-pc-linux-gnu' => 'Generic x86_64 Linux',
          'aarch64-linux-gnu' => 'ARM64 (Raspberry Pi 4, AWS Graviton)',
          's390x-linux-gnu' => 'IBM Z mainframe',
          'powerpc64le-linux-gnu' => 'POWER8/9 little-endian',
          'powerpc64-linux-gnu' => 'POWER8/9 big-endian',
          'mips64el-linux-gnuabi64' => 'MIPS64 little-endian',
          'alpha-linux-gnu' => 'DEC Alpha',
          'sparc64-linux-gnu' => 'SPARC64',
          'riscv64-linux-gnu' => 'RISC-V 64-bit'
        }
      end

      it 'returns true for 64-bit Linux systems' do
        linux_distros.each do |host_os, description|
          result = test_linux64_with_config(host_os, 8)
          expect(result).to be_truthy, "Expected linux64? to return true for #{host_os} (#{description})"
        end
      end
    end

    context 'with different Linux distributions on 32-bit architectures' do
      let(:linux_32bit_distros) do
        {
          'i386-linux-gnu' => '32-bit x86',
          'i486-linux-gnu' => '32-bit x86',
          'i586-linux-gnu' => '32-bit x86',
          'i686-linux-gnu' => '32-bit x86',
          'arm-linux-gnueabihf' => 'ARM 32-bit hard-float',
          'armv7l-linux-gnueabihf' => 'ARMv7 32-bit',
          'mips-linux-gnu' => 'MIPS 32-bit',
          'mipsel-linux-gnu' => 'MIPS 32-bit little-endian',
          'powerpc-linux-gnu' => 'PowerPC 32-bit',
          's390-linux-gnu' => 'IBM S/390 32-bit'
        }
      end

      it 'returns false for 32-bit Linux systems' do
        linux_32bit_distros.each do |host_os, description|
          result = test_linux64_with_config(host_os, 4)
          expect(result).to be_falsey, "Expected linux64? to return false for #{host_os} (#{description})"
        end
      end
    end

    context 'with non-Linux operating systems' do
      let(:non_linux_os) do
        {
          'darwin21.6.0' => 'macOS',
          'freebsd13.1' => 'FreeBSD',
          'openbsd7.2' => 'OpenBSD',
          'netbsd9.3' => 'NetBSD',
          'dragonfly6.4' => 'DragonFlyBSD',
          'solaris2.11' => 'Solaris',
          'aix7.2.0.0' => 'AIX',
          'mingw32' => 'Windows MSYS2',
          'cygwin' => 'Cygwin'
        }
      end

      it 'returns false for non-Linux systems regardless of architecture' do
        non_linux_os.each do |host_os, description|
          # Test both 32-bit and 64-bit scenarios
          [4, 8].each do |pointer_size|
            result = test_linux64_with_config(host_os, pointer_size)
            expect(result).to be_falsey,
              "Expected linux64? to return false for #{host_os} (#{description}) with #{pointer_size * 8}-bit pointers"
          end
        end
      end
    end

    context 'with JRuby on different platforms' do
      it 'returns true for 64-bit Linux on JRuby' do
        result = test_linux64_with_config('x86_64-linux-gnu', nil, 'java', 64)
        expect(result).to be_truthy
      end

      it 'returns false for 32-bit Linux on JRuby' do
        result = test_linux64_with_config('i386-linux-gnu', nil, 'java', 32)
        expect(result).to be_falsey
      end

      it 'returns false for non-Linux systems on JRuby' do
        result = test_linux64_with_config('darwin21.6.0', nil, 'java', 64)
        expect(result).to be_falsey
      end
    end

    context 'edge cases' do
      it 'handles case-insensitive Linux detection' do
        ['LINUX-gnu', 'Linux-gnu', 'linux-GNU'].each do |host_os|
          result = test_linux64_with_config(host_os, 8)
          expect(result).to be_truthy, "Expected linux64? to handle case-insensitive matching for #{host_os}"
        end
      end

      it 'handles partial Linux matches in host_os string' do
        ['some-linux-variant', 'embedded-linux-system', 'custom-linux-build'].each do |host_os|
          result = test_linux64_with_config(host_os, 8)
          expect(result).to be_truthy, "Expected linux64? to match partial Linux strings for #{host_os}"
        end
      end
    end

    context 'multi-check priority order', unless: RUBY_PLATFORM == 'java' do
      it 'uses arch check first when arch contains 64' do
        allow(RbConfig::CONFIG).to receive(:[]).and_call_original
        allow(RbConfig::CONFIG).to receive(:[]).with('host_os').and_return('x86_64-linux-gnu')
        allow(RbConfig::CONFIG).to receive(:[]).with('arch').and_return('x86_64-linux')
        allow(RbConfig::CONFIG).to receive(:[]).with('DEFS').and_return('')

        # Should not need to call pack method since arch check succeeds
        expect_any_instance_of(Array).not_to receive(:pack)

        expect(functions_class.send(:linux64?)).to be_truthy
      end

      it 'uses DEFS check when arch does not contain 64 but DEFS does' do
        allow(RbConfig::CONFIG).to receive(:[]).and_call_original
        allow(RbConfig::CONFIG).to receive(:[]).with('host_os').and_return('special-linux-gnu')
        allow(RbConfig::CONFIG).to receive(:[]).with('arch').and_return('special-linux')
        allow(RbConfig::CONFIG).to receive(:[]).with('DEFS').and_return('-D__LP64__=1')

        # Should not need to call pack method since DEFS check succeeds
        expect_any_instance_of(Array).not_to receive(:pack)

        expect(functions_class.send(:linux64?)).to be_truthy
      end

      it 'falls back to pack method when neither arch nor DEFS contain 64' do
        allow(RbConfig::CONFIG).to receive(:[]).and_call_original
        allow(RbConfig::CONFIG).to receive(:[]).with('host_os').and_return('custom-linux-gnu')
        allow(RbConfig::CONFIG).to receive(:[]).with('arch').and_return('custom-linux')
        allow(RbConfig::CONFIG).to receive(:[]).with('DEFS').and_return('-DSOMETHING=1')

        # Should call pack method as last resort
        allow_any_instance_of(Array).to receive(:pack).with('P').and_return('12345678')

        expect(functions_class.send(:linux64?)).to be_truthy
      end

      it 'returns false when all checks fail on 32-bit' do
        allow(RbConfig::CONFIG).to receive(:[]).and_call_original
        allow(RbConfig::CONFIG).to receive(:[]).with('host_os').and_return('custom-linux-gnu')
        allow(RbConfig::CONFIG).to receive(:[]).with('arch').and_return('custom-linux')
        allow(RbConfig::CONFIG).to receive(:[]).with('DEFS').and_return('-DSOMETHING=1')

        # Pack method returns 4 bytes (32-bit)
        allow_any_instance_of(Array).to receive(:pack).with('P').and_return('1234')

        expect(functions_class.send(:linux64?)).to be_falsey
      end
    end
  end
end
