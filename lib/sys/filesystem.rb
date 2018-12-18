module Sys
  class Filesystem
    # The version of the sys-filesystem library
    VERSION = '1.1.10'.freeze
  end
end

require 'rbconfig'

if File::ALT_SEPARATOR
  require_relative 'windows/sys/filesystem'
else
  require_relative 'unix/sys/filesystem'
end

# Methods universal to all platforms

module Sys
  class Filesystem
    class Stat
      # Returns true if the filesystem is case sensitive for the current path.
      # Typically this will be any path on MS Windows or Macs using HFS.
      #
      # For a root path (really any path without actual a-z characters) we
      # take a best guess based on the host operating system. However, as a
      # general rule, I do not recommend using this method for a root path.
      #
      def case_insensitive?
        if path !~ /\w+/
          if RbConfig::CONFIG['host_os'] =~ /darwin|mac|windows|mswin|mingw/i
            true # Assumes HFS
          else
            false
          end
        else
          File.identical?(path, path.swapcase)
        end
      end
    end
  end
end
