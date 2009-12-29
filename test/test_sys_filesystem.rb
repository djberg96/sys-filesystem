$LOAD_PATH.unshift File.dirname(File.expand_path(__FILE__))
   
require 'rbconfig'

if Config::CONFIG['host_os'].match('mswin')
   require 'test_sys_filesystem_windows'
else
   require 'test_sys_filesystem_unix'
end
