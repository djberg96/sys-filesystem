## 1.5.5 - 6-Dec-2025
* Replaced string concatenation operators with addition assignment operators
  since the current code generates a frozen string warning with Ruby 3.4 and
  later.
* Updated Rakefile to run specs with warnings enabled.

## 1.5.4 - 7-Sep-2025
* Added a fallback check for 64-bit Linux in case the config info doesn't
  include "64" anywhere in it. Thanks go to Chris Hofstaedtler for the
  report.

## 1.5.3 - 3-Oct-2024
* Decided to unroll the changes in 1.5.2 because doing runtime compiler
  checks was making more people unhappy than happy, and I already had
  some misgivings about it.
* Updated the README.md to note the issues with running 32-bit Ruby with
  64-bit offsets. At the moment I think this mainly only affects arch Linux.

## 1.5.2 - 30-Sep-2024
* Forgot to switch mkmf-lite from a dev dependency to a runtime dependency.
  Thanks go to Thomas Langé for the spot and patch.

## 1.5.1 - 29-Sep-2024
* Add the f_type struct member to the Statvfs struct for Linux. This was added
  at some point in the Linux lifecycle, though may still be blank depending on
  your platform. Thanks go to Tasos Sahanidis for the patch.
* Added padding on 32-bit Statvfs struct with 64-bit offsets for Linux. Thanks
  go Tasos Sahanidis again for this update.
* Bumped mkmf-lite dependency since the changes were needed to support the above.

## 1.5.0 - 8-Jun-2024
* Add support for DragonFlyBSD.
* Remove Solaris support. It's dead, Jim.
* Now assumes umount2 function is present on Linux systems, and some
  corresponding refactoring of the umount method.

## 1.4.5 - 22-May-2024
* Handle the possibility that a statvs64 alias may not exist on some Linux
  platforms. Thanks go to Antoine Martin for the report.

## 1.4.4 - 12-Sep-2023
* Yet another fix for 32-bit vs 64-bit linux, specifically for the Statvfs
  struct. Thanks go to Josh Cooper for the spot and the patch.

## 1.4.3 - 20-Oct-2021
* Another fix for 32-bit vs 64-bit Linux since it was realized we cannot always
  rely on the host architecture information. Handling for JRuby was improved
  as well. Thanks go to Scott Bradnick for the spot. 
* The constructor is now explicitly private. This class was never meant to
  actually be instantiated.
* Updated the MANIFEST.md file.

## 1.4.2 - 22-Jul-2021
* Fixed support for 32-bit Linux. Thanks go to ciprianbadescu for the spot.

## 1.4.1 - 30-Dec-2020
* Fix an FFI function declaration bug for Big Sur and later on Mac. Thanks go
  to Roman Gaufman for the spot and Martins Polakovs for testing.
* Fixed the changelog metadata URI.
* Added a .gitignore file.

## 1.4.0 - 6-Sep-2020
* The Sys::Filesystem.stat method now accepts a Pathname and Dir object as
  an argument. On most platforms it will also accept a File object. Thanks
  go to hirura for the patch.
* Fixed the statvfs struct layout on i686 platforms. Thanks go to
  Filipovici-Andrei for the patch.
* Switched from test-unit to rspec, and updated the tests.

## 1.3.4 - 17-Mar-2020
* Properly include a LICENSE file as per the Apache-2.0 license.

## 1.3.3 - 18-Feb-2020
* Linux now uses statvfs64 under the hood. This fixes a potential issue with
  32 bit systems. Thanks go to Tom Smyth for the spot.

## 1.3.2 - 8-Dec-2019
* Renamed various text files to include .rdoc extension so that github renders
  them nicely.

## 1.3.1 - 15-Oct-2019
* Fixed a bug where the Statvfs and Statfs structs were not allocated properly
  on Linux, which could cause issues. Thanks go to Daniele Orlandi for the spot.
* Added specs to ensure that the FFI struct size matches the C struct size.
  This required adding mkmf-lite as a development dependency.
* Added a slightly more pessimistic version requirement for test-unit.

## 1.3.0 - 3-Oct-2019
* Added the mount and umount singleton methods.
* Changed an internal class variable to a frozen constant.

## 1.2.0 - 1-Jan-2019
* Changed the license to Apache-2.0.
* Added the case_sensitive? and case_insensitive? instance methods to the
  Filesystem::Stat class.
* Refactored the Numeric helper methods into a single location.
* Fixed the deprecation warnings when running the tests on Windows.
* Added metadata to the gemspec.

## 1.1.9 - 26-Jan-2018
* The bytes_free and bytes_total methods were updated to use the fragment size
  instead of the block size. This fixes Macs using APFS, as well as Solaris 10.
  Thanks go to Mikhail Vasin for the spot.
* Removed the code specific to FreeBSD 10, which was ultimately an attempt
  to address the issue now resolved by the above change.
* Updated the cert again.

## 1.1.8 - 2-Sep-2017
* The stat and mount_point methods now call to_s on the string argument
  explicitly so that Pathname objects will now work with String#wincode.
* Updated some tests to avoid Fixnum warnings for Ruby 2.4.
* Updated the cert.

## 1.1.7 - 1-Aug-2016
* Fixed an issue in the stat method for MS Windows where the blocks_avail
  value was not correct. Thanks go to Maxime Lapointe for the spot.

## 1.1.6 - 17-May-2016
* On versions that use setmntent or fopen, explicitly raise an error if
  either of those calls return a null value.

## 1.1.5 - 5-Dec-2015
* This gem is now signed.
* The gem related tasks in the Rakefile now assume Rubygems 2.x.
* Updates to the gemspec, added cert_chain, removed rubyforge_project.
* Internal reorganization, and use of relative_require as appropriate.
* Added a sys-filesystem.rb file for convenience.

## 1.1.4 - 15-Mar-2015
* The File.mounts method no longer raises an error if a mount point
  is not accessible. Thanks go to Michael Pope for the patch.
* Some internal code reorganization.

## 1.1.3 - 1-Oct-2014
* Now ignores EPERM errors when trying to find the mount point for a path.
  Thanks go to petersen for the patch.
* The Filesystem.stat method now defaults to using the root path on Windows
  for volume information.

## 1.1.2 - 9-May-2014
* Added the percent_used, bytes_total, bytes_free and bytes_used methods
  to the Filesystem::Stat class. Thanks go to xanview for the suggestion.
* Changed File.exists? to File.exist? to avoid warnings in Ruby 2.1.x.
* The convenience methods to_mb, to_gb, etc, are now defined in Numeric
  instead of Fixnum.
* Added the to_tb method for terabytes.
* Minor updates to the gem:create and gem:install Rake tasks.

## 1.1.1 - 3-Oct-2013
* Solaris now always uses statvfs64 on Solaris for better 64-bit support.
  Thanks go to Jeff Shantz for the spot.

## 1.1.0 - 19-Jan-2013
* Converted the Windows source code to use FFI. Consequently, there is now
  a single gem rather than separate gems for Windows and Unix.
* Revamped the Windows tests.

## 1.0.0 - 11-Jan-2012
* Converted everything from C to FFI for the Unix flavors. The Windows
  source code remains untouched.

## 0.3.4 - 19-Nov-2010
* Fixed a bug where negative block counts were happening on very large
  hard drives. Thanks go to Jonas Pfenniger for the spot.
* Refactored the clean task in the Rakefile.
* Some cosmetic source code changes.

## 0.3.3 - 21-May-2010
* Added a workaround for the Sys::Filesystem#block_size member to deal with
  a bug in OS X. Thanks go to Josh Pasqualetto for the spot.

## 0.3.2 - 29-Dec-2009
* Source has been moved to github.
* Added the 'gem' task and removed build logic from the gemspec.
* Updated the install task.
* Minor correction to the manifest.
* Removed some junk build files that were inadvertently included in
  the last gem.

## 0.3.1 - 5-Aug-2009
* Now compatible with Ruby 1.9.x.
* Changed license to Artistic 2.0
* Updated the gemspec, including the explicit addition of a license and
  test-unit as a development dependency, as well as an updated description. 

## 0.3.0 - 26-Feb-2009
* Added support for OS X and FreeBSD thanks to an awesome patch by Nobuyoshi
  Miyokawa.
* Added the Filesystem.mount_point method that takes a file and returns
  the mount point it's sitting on.

## 0.2.0 - 30-Dec-2008
* Added the Filesystem.mounts method for iterating over mount or volume
  information.

## 0.1.1 - 28-Mar-2007
* Bug fix for BSD flavors.  Thanks go to Jeremy Kemper and Ole Christian
  Rynning for the spot.
* Bug fix for OS X (along the same lines as the BSD fix). Thanks go to
  Aurelian Dehay for the spot.
* Some Rdoc improvements for the C extension.
* Tweaks to the gemspec.
* Added synopsis to the README.

## 0.1.0 - 17-Nov-2006
* Initial release.  Alpha. Code is stable, but API is not.
