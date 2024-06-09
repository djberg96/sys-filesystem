# frozen_string_literal: true

require 'rspec'
require 'sys_filesystem_shared'

RSpec.configure do |config|
  config.include_context(Sys::Filesystem)
  config.filter_run_excluding(:windows) unless Gem.win_platform?
  config.filter_run_excluding(:unix) if Gem.win_platform?
  config.filter_run_excluding(:dragonfly) unless RbConfig::CONFIG['host_os'] =~ /dragonfly/i
end
