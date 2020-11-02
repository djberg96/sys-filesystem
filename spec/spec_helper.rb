require 'rspec'

RSpec.configure do |config|
  config.filter_run_excluding(:windows) unless Gem.win_platform?
  config.filter_run_excluding(:unix) if Gem.win_platform?
end
