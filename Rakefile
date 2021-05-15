require 'rake'
require 'rake/clean'
require 'rspec/core/rake_task'

CLEAN.include('**/*.gem', '**/*.rbc', '**/*.rbx', '**/*.lock')

namespace :gem do
  desc "Build the sys-filesystem gem"
  task :create => [:clean] do
    require 'rubygems/package'
    spec = Gem::Specification.load('sys-filesystem.gemspec')
    spec.signing_key = File.join(Dir.home, '.ssh', 'gem-private_key.pem')
    Gem::Package.build(spec)
  end

  desc "Install the sys-filesystem gem"
  task :install => [:create] do
    file = Dir['*.gem'].first
    sh "gem install -l #{file}"
  end
end

desc "Run the example program"
task :example do
  sh "ruby -Ilib -Ilib/unix -Ilib/windows examples/example_stat.rb"
end

desc "Run the test suite"
RSpec::Core::RakeTask.new(:spec)

task :default => :spec
