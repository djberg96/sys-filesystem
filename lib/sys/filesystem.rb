if File::ALT_SEPARATOR
  require 'windows/sys/filesystem'
else
  require 'unix/sys/filesystem'
end
