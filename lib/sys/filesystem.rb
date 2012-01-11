require 'rbconfig'

case RbConfig::CONFIG['host_os']
  when /windows|mswin|mingw|win32|dos/i
    require 'windows/sys/filesystem'
  when /bsd/i
    require 'bsd/sys/filesystem'
  when /darwin|osx|mach/i
    require 'darwin/sys/filesystem'
  when /sunos|solaris/i
    require 'sunos/sys/filesystem'
  else
    require 'unix/sys/filesystem'
end
