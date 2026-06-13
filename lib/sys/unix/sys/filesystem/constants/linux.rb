# frozen_string_literal: true

module Sys
  class Filesystem
    module Constants
      MS_RDONLY = 1
      MS_NOSUID = 2
      MS_NODEV = 4
      MS_NOEXEC = 8
      MS_SYNCHRONOUS = 16
      MS_REMOUNT = 32
      MS_MANDLOCK = 64
      MS_DIRSYNC = 128
      MS_NOATIME = 1024
      MS_NODIRATIME = 2048
      MS_BIND = 4096
      MS_MOVE = 8192
      MS_REC = 16_384
      MS_SILENT = 32_768
      MS_POSIXACL = 1 << 16
      MS_UNBINDABLE = 1 << 17
      MS_PRIVATE = 1 << 18
      MS_SLAVE = 1 << 19
      MS_SHARED = 1 << 20
      MS_RELATIME = 1 << 21
      MS_KERNMOUNT = 1 << 22
      MS_I_VERSION = 1 << 23
      MS_STRICTATIME = 1 << 24
      MS_ACTIVE = 1 << 30
      MS_NOUSER = 1 << 31

      MNT_RDONLY = MS_RDONLY
      MNT_NOSUID = MS_NOSUID
      MNT_NODEV = MS_NODEV
      MNT_NOEXEC = MS_NOEXEC

      MNT_FORCE = 1
      MNT_DETACH = 2
      MNT_EXPIRE = 4
      UMOUNT_NOFOLLOW = 8
    end
  end
end
