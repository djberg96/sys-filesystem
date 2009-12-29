require 'rake'
require 'rake/clean'
require 'rake/testtask'
include Config

desc "Clean the build files for the sys-filesystem source for UNIX systems"
task :clean do
   Dir.chdir('examples') do
      FileUtils.rm_rf('sys') if File.exists?('sys')
   end

   unless CONFIG['host_os'].match('mswin')
      file = 'sys/filesystem.' + CONFIG['DLEXT']
      Dir.chdir('ext') do
         sh 'make distclean' rescue nil
         rm file if File.exists?(file)
      end
   end
end

desc "Build the sys-filesystem library on UNIX systems (but don't install it)"
task :build => [:clean] do
   unless CONFIG['host_os'].match('mswin')
      file = 'filesystem.' + CONFIG['DLEXT']
      Dir.chdir('ext') do
         ruby 'extconf.rb'
         sh 'make'
         mv file, 'sys'
      end
   end
end

if CONFIG['host_os'].match('mswin')
   desc "Install the sys-filesystem library"
   task :install do
      install_dir = File.join(CONFIG['sitelibdir'], 'sys')
      Dir.mkdir(install_dir) unless File.exists?(install_dir)
      FileUtils.cp('lib/sys/filesystem.rb', install_dir, :verbose => true)
   end
else
   desc "Install the sys-filesystem library"
   task :install => [:build] do
      Dir.chdir('ext') do
         sh 'make install'
      end
   end
end

desc "Run the test suite"
Rake::TestTask.new("test") do |t|
   unless CONFIG['host_os'].match('mswin')
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
