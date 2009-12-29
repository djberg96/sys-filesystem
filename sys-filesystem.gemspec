require 'rubygems'

spec = Gem::Specification.new do |gem|
   gem.name      = 'sys-filesystem'
   gem.version   = '0.3.1'
   gem.author    = 'Daniel J. Berger'
   gem.email     = 'djberg96@gmail.com'
   gem.homepage  = 'http://www.rubyforge.org/projects/sysutils'
   gem.platform  = Gem::Platform::RUBY
   gem.summary   = 'A Ruby interface for getting file system information.'
   gem.test_file = 'test/test_sys_filesystem.rb'
   gem.has_rdoc  = true
   gem.files     = Dir['**/*'].reject{ |f| f.include?('CVS') }
   gem.license   = 'Artistic 2.0'
   
   gem.extra_rdoc_files  = ['CHANGES', 'README', 'MANIFEST']
   gem.rubyforge_project = 'sysutils'
   
   gem.add_development_dependency('test-unit', '>= 2.0.3')

   gem.description = <<-EOF
      The sys-filesystem library provides an interface for gathering filesystem
      information, such as disk space and mount point data.
   EOF
end

if $PROGRAM_NAME == __FILE__
   if RUBY_PLATFORM.match('mswin')
      spec.required_ruby_version = '>= 1.8.2'
      spec.files -= Dir['ext/**/*']
      spec.platform = Gem::Platform::CURRENT
      spec.add_dependency('windows-pr', '>= 0.6.0')
   else
      spec.required_ruby_version = '>= 1.8.0'
      spec.extensions = ['ext/extconf.rb']
      spec.files -= Dir['lib/**/*']
      spec.extra_rdoc_files << 'ext/sys/filesystem.c'
   end

   Gem::Builder.new(spec).build
end
