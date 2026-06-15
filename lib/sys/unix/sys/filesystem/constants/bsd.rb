# frozen_string_literal: true

module Sys
  class Filesystem
    module Constants
      MNT_RDONLY      = 0x00000001 # read only filesystem
      MNT_SYNCHRONOUS = 0x00000002 # file system written synchronously
      MNT_NOEXEC      = 0x00000004 # can't exec from filesystem
      MNT_NOSUID      = 0x00000008 # don't honor setuid bits on fs
      MNT_UNION       = 0x00000020 # union with underlying filesystem
      MNT_ASYNC       = 0x00000040 # file system written asynchronously
      MNT_EXPORTED    = 0x00000100 # filesystem is exported
      MNT_LOCAL       = 0x00001000 # filesystem is stored locally
      MNT_QUOTA       = 0x00002000 # quotas are enabled on filesystem
      MNT_ROOTFS      = 0x00004000 # identifies the root filesystem
      MNT_NOATIME     = 0x10000000 # disable update of file access time

      MNT_VISFLAGMASK = (
        MNT_RDONLY | MNT_SYNCHRONOUS | MNT_NOEXEC |
        MNT_NOSUID | MNT_UNION | MNT_ASYNC |
        MNT_EXPORTED | MNT_LOCAL | MNT_QUOTA |
        MNT_ROOTFS | MNT_NOATIME
      )

      MNT_FORCE = 1

      MOUNT_OPTION_NAMES = {
        MNT_RDONLY => 'read-only',
        MNT_SYNCHRONOUS => 'synchronous',
        MNT_NOEXEC => 'noexec',
        MNT_NOSUID => 'nosuid',
        MNT_UNION => 'union',
        MNT_ASYNC => 'asynchronous',
        MNT_EXPORTED => 'exported',
        MNT_LOCAL => 'local',
        MNT_QUOTA => 'quotas',
        MNT_ROOTFS => 'rootfs',
        MNT_NOATIME => 'noatime'
      }.freeze
    end
  end
end
