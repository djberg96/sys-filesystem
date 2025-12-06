require 'rubygems'

Gem::Specification.new do |spec|
  spec.name       = 'sys-filesystem'
  spec.version    = '1.5.5'
  spec.author     = 'Daniel J. Berger'
  spec.email      = 'djberg96@gmail.com'
  spec.homepage   = 'https://github.com/djberg96/sys-filesystem'
  spec.summary    = 'A Ruby interface for getting file system information.'
  spec.license    = 'Apache-2.0'
  spec.test_files = Dir['spec/*_spec.rb']
  spec.files      = Dir['**/*'].reject{ |f| f.include?('git') }
  spec.cert_chain = Dir['certs/*']
   
  spec.add_dependency('ffi', '~> 1.1')
  spec.add_development_dependency('mkmf-lite', '~> 0.7') unless Gem.win_platform?
  spec.add_development_dependency('rake')
  spec.add_development_dependency('rspec', '~> 3.9')
  spec.add_development_dependency('rubocop')
  spec.add_development_dependency('rubocop-rspec')

  if RUBY_PLATFORM == 'java' && Gem.win_platform?
    spec.add_dependency('jruby-win32ole')
  end

  spec.metadata = {
    'homepage_uri'          => 'https://github.com/djberg96/sys-filesystem',
    'bug_tracker_uri'       => 'https://github.com/djberg96/sys-filesystem/issues',
    'changelog_uri'         => 'https://github.com/djberg96/sys-filesystem/blob/main/CHANGES.md',
    'documentation_uri'     => 'https://github.com/djberg96/sys-filesystem/wiki',
    'source_code_uri'       => 'https://github.com/djberg96/sys-filesystem',
    'wiki_uri'              => 'https://github.com/djberg96/sys-filesystem/wiki',
    'rubygems_mfa_required' => 'true',
    'github_repo'           => 'https://github.com/djberg96/sys-filesystem',
    'funding_uri'           => 'https://github.com/sponsors/djberg96'
  }

  spec.description = <<-EOF
    The sys-filesystem library provides a cross-platform interface for
    gathering filesystem information, such as disk space and mount point data.
  EOF
end
