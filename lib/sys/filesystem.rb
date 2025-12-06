# frozen_string_literal: true

require 'rbconfig'

if File::ALT_SEPARATOR
  require_relative 'windows/sys/filesystem'
else
  require_relative 'unix/sys/filesystem'
end

# Methods and properties universal to all platforms

# The Sys module serves as a namespace only.
module Sys
  # The Filesystem class serves as an abstract base class. Its methods
  # return objects of other types. Do not instantiate.
  class Filesystem
    # The version of the sys-filesystem library
    VERSION = '1.5.5'

    # Stat objects are returned by the Sys::Filesystem.stat method. Here
    # we're adding universal methods.
    class Stat
      # Returns true if the filesystem is case sensitive for the current path.
      # Typically this will be any path on MS Windows or Macs using HFS.
      #
      # For a root path (really any path without actual a-z characters) we
      # take a best guess based on the host operating system. However, as a
      # general rule, I do not recommend using this method for a root path.
      #
      def case_insensitive?
        if path =~ /\w+/
          File.identical?(path, path.swapcase)
        elsif RbConfig::CONFIG['host_os'] =~ /darwin|mac|windows|mswin|mingw/i
          true # Assumes HFS/APFS on Mac
        else
          false
        end
      end

      # Opposite of case_insensitive?
      #
      def case_sensitive?
        !case_insensitive?
      end
    end
  end
end

# Reopen the Numeric class and add some convenient methods
# for converting bytes to kb, mb, and gb.
class Numeric
  # call-seq:
  #  <tt>num</tt>.to_kb
  #
  # Returns +num+ in terms of kilobytes.
  def to_kb
    self / 1024
  end

  # call-seq:
  #  <tt>num</tt>.to_mb
  #
  # Returns +num+ in terms of megabytes.
  def to_mb
    self / 1048576
  end

  # call-seq:
  #  <tt>num</tt>.to_gb
  #
  # Returns +num+ in terms of gigabytes.
  def to_gb
    self / 1073741824
  end

  # call-seq:
  #  <tt>num</tt>.to_gb
  #
  # Returns +num+ in terms of terabytes.
  def to_tb
    self / 1099511627776
  end
end
