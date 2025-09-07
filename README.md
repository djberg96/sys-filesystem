[![Ruby](https://github.com/djberg96/sys-filesystem/actions/workflows/ruby.yml/badge.svg)](https://github.com/djberg96/sys-filesystem/actions/workflows/ruby.yml)

## Description

A cross platform Ruby interface for getting file system information.

## Installation

`gem install sys-filesystem`

## Adding the trusted cert
`gem cert --add <(curl -Ls https://raw.githubusercontent.com/djberg96/sys-filesystem/main/certs/djberg96_pub.pem)`

## Synopsis

```ruby
require 'sys/filesystem'
include Sys
   
# Display information about a particular filesystem.
p Filesystem.stat('/')

# Sample output

#<Sys::Filesystem::Stat:0x517440
  @base_type = "ufs",
  @flags = 4,
  @files_available = 3817457,
  @block_size = 8192,
  @blocks_available = 19957633,
  @blocks = 34349612,
  @name_max = 255,
  @path = "/",
  @filesystem_id = 35651592,
  @files = 4135040,
  @fragment_size = 1024,
  @files_free = 3817457,
  @blocks_free = 20301129
>
   
# Describe all mount points on the system
Filesystem.mounts{ |mount| p mount }
   
# Find the mount point of any particular file
puts Filesystem.mount_point('/home/djberge/some_file.txt') => '/home'
```

## Notes

This is a pure Ruby implementation that uses FFI. This means it should work
with JRuby, too.

## Sample code

Run 'rake example' if you want to see a basic sample run. The actual code
is 'example_stat.rb' in the 'examples' directory. Modify it as you see fit.

## Known Issues

Currently this may not work if you're running a 32-bit system with 64-bit offsets:

  https://github.com/djberg96/sys-filesystem/issues/71

Please report any other issues on the project home page at:

  https://github.com/djberg96/sys-filesystem

## Future Plans

* Suggestions welcome.

## Acknowledgements

* Mike Hall, for ideas and code that I borrowed from his 'filesystem' library.
* Park Heesob, for implementation and API ideas for the MS Windows version.
* Nobuyoshi Miyokawa, for adding the original FreeBSD and OS X support.
   
## License

Apache-2.0

## Copyright

(C) 2003-2025 Daniel J. Berger
All Rights Reserved

## Warranty

This library is provided "as is" and without any express or
implied warranties, including, without limitation, the implied
warranties of merchantability and fitness for a particular purpose.

## Author

Daniel J. Berger
