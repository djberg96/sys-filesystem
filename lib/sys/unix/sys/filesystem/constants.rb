# frozen_string_literal: true

require 'rbconfig'

case RbConfig::CONFIG['host_os']
  when /linux/i
    require_relative 'constants/linux'
  when /freebsd/i
    require_relative 'constants/freebsd'
  when /darwin|osx|mach/i
    require_relative 'constants/darwin'
  when /dragonfly/i
    require_relative 'constants/dragonfly'
  else
    require_relative 'constants/generic'
end
