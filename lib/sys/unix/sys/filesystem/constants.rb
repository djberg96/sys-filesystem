module Sys
  class Filesystem
    module Constants
      private

      MNT_RDONLY      = 0x00000001 # read only filesystem
      MNT_SYNCHRONOUS = 0x00000002 # file system written synchronously
      MNT_NOEXEC      = 0x00000004 # can't exec from filesystem
      MNT_NOSUID      = 0x00000008 # don't honor setuid bits on fs
      MNT_NODEV       = 0x00000010 # don't interpret special files
      MNT_UNION       = 0x00000020 # union with underlying filesystem
      MNT_ASYNC       = 0x00000040 # file system written asynchronously
      MNT_CPROTECT    = 0x00000080 # file system supports content protection
      MNT_EXPORTED    = 0x00000100 # file system is exported
      MNT_QUARANTINE  = 0x00000400 # file system is quarantined
      MNT_LOCAL       = 0x00001000 # filesystem is stored locally
      MNT_QUOTA       = 0x00002000 # quotas are enabled on filesystem
      MNT_ROOTFS      = 0x00004000 # identifies the root filesystem
      MNT_DOVOLFS     = 0x00008000 # FS supports volfs (deprecated)
      MNT_DONTBROWSE  = 0x00100000 # FS is not appropriate path to user data
      MNT_IGNORE_OWNERSHIP = 0x00200000 # VFS will ignore ownership info on FS objects
      MNT_AUTOMOUNTED = 0x00400000 # filesystem was mounted by automounter
      MNT_JOURNALED   = 0x00800000 # filesystem is journaled
      MNT_NOUSERXATTR = 0x01000000 # Don't allow user extended attributes
      MNT_DEFWRITE    = 0x02000000 # filesystem should defer writes
      MNT_MULTILABEL  = 0x04000000 # MAC support for individual labels
      MNT_NOATIME     = 0x10000000 # disable update of file access time

      MNT_VISFLAGMASK = (
        MNT_RDONLY | MNT_SYNCHRONOUS | MNT_NOEXEC |
        MNT_NOSUID | MNT_NODEV | MNT_UNION |
        MNT_ASYNC  | MNT_EXPORTED | MNT_QUARANTINE |
        MNT_LOCAL  | MNT_QUOTA |
        MNT_ROOTFS | MNT_DOVOLFS | MNT_DONTBROWSE |
        MNT_IGNORE_OWNERSHIP | MNT_AUTOMOUNTED | MNT_JOURNALED |
        MNT_NOUSERXATTR | MNT_DEFWRITE  | MNT_MULTILABEL |
        MNT_NOATIME | MNT_CPROTECT
      )
    end
  end
end
