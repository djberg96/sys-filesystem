require 'rake'
require 'rake/clean'
require 'rake/testtask'
include Config

desc "Clean the build files for the sys-filesystem source for UNIX systems"
task :clean do |task|
  Dir.chdir('examples') do
    FileUtils.rm_rf('sys') if File.exists?('sys')
  end

  unless Config::CONFIG['host_os'] =~ /mswin32|mingw|cygwin|windows|dos/i
    file = 'sys/filesystem.' + CONFIG['DLEXT']
    Dir.chdir('ext') do
      sh 'make distclean' rescue nil
      rm file if File.exists?(file)
      rm_rf 'conftest.dSYM' if File.exists?('conftest.dSYM') # OS X weirdness
    end
  end
end

desc "Build the sys-filesystem library on UNIX systems (but don't install it)"
task :build => [:clean] do
  unless Config::CONFIG['host_os'] =~ /mswin32|mingw|cygwin|windows|dos/i
    file = 'filesystem.' + CONFIG['DLEXT']
    Dir.chdir('ext') do
      ruby 'extconf.rb'
      sh 'make'
      mv file, 'sys'
    end
  end
end

desc "Install the sys-filesystem library"
task :install do
  unless Config::CONFIG['host_os'] =~ /mswin32|mingw|cygwin|windows|dos/i
    install_dir = File.join(CONFIG['sitelibdir'], 'sys')
    Dir.mkdir(install_dir) unless File.exists?(install_dir)
    FileUtils.cp('lib/sys/filesystem.rb', install_dir, :verbose => true)
  else
    task :install => :build
    Dir.chdir('ext') do
      sh 'make install'
    end
  end
end

desc "Run the test suite"
Rake::TestTask.new("test") do |t|
  unless Config::CONFIG['host_os'] =~ /mswin32|mingw|cygwin|windows|dos/i
    task :test => :build
    t.libs << 'ext'
    t.libs.delete('lib')
  end

  t.warning = true
  t.verbose = true
  t.test_files = FileList['test/test_sys_filesystem.rb']
end

task :test do
  Rake.application[:clean].execute
end

desc "Run the example program"
task :example => [:build] do |t|
  Dir.chdir('examples') do
    Dir.mkdir('sys') unless File.exists?('sys')
  end

  FileUtils.cp('ext/sys/filesystem.' + Config::CONFIG['DLEXT'], 'examples/sys')

  Dir.chdir('examples') do
    ruby 'example_stat.rb'
  end
end

desc "Build a gem"
task :gem => [:clean] do |t|
  spec = eval(IO.read('sys-filesystem.gemspec'))

  if Config::CONFIG['host_os'] =~ /mswin32|mingw|cygwin|windows|dos/i
    spec.required_ruby_version = '>= 1.8.2'
    spec.files -= Dir['ext/**/*']
    spec.platform = Gem::Platform::CURRENT
    spec.add_dependency('windows-pr', '>= 1.0.5')
  else
    spec.required_ruby_version = '>= 1.8.0'
    spec.extensions = ['ext/extconf.rb']
    spec.files -= Dir['lib/**/*']
    spec.extra_rdoc_files << 'ext/sys/filesystem.c'
  end

  Gem::Builder.new(spec).build
end
