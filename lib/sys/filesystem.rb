module Sys
  class Filesystem
    # The version of the sys-filesystem library
    VERSION = '1.1.5'
  end
end

if File::ALT_SEPARATOR
  require_relative 'windows/sys/filesystem'
else
  require_relative 'unix/sys/filesystem'
end
