# frozen_string_literal: true

module Sys
  class Filesystem
    module Constants
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
        MNT_NOUSERXATTR | MNT_DEFWRITE | MNT_MULTILABEL |
        MNT_NOATIME | MNT_CPROTECT
      )

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
      MS_REC = 16384
      MS_SILENT = 32768
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

      MNT_FORCE = 1
      MNT_DETACH = 2
      MNT_EXPIRE = 4
      UMOUNT_NOFOLLOW = 8

      module FTYPES
        ADFS_SUPER_MAGIC      = 0xadf5
        AFFS_SUPER_MAGIC      = 0xadff
        AFS_SUPER_MAGIC       = 0x5346414F
        AUTOFS_SUPER_MAGIC    = 0x0187
        CEPH_SUPER_MAGIC      = 0x00c36400
        CODA_SUPER_MAGIC      = 0x73757245
        CRAMFS_MAGIC          = 0x28cd3d4
        CRAMFS_MAGIC_WEND     = 0x453dcd28
        DEBUGFS_MAGIC         = 0x64626720
        SECURITYFS_MAGIC      = 0x73636673
        SELINUX_MAGIC         = 0xf97cff8c
        SMACK_MAGIC           = 0x43415d53
        RAMFS_MAGIC           = 0x858458f6
        TMPFS_MAGIC           = 0x01021994
        HUGETLBFS_MAGIC       = 0x958458f6
        SQUASHFS_MAGIC        = 0x73717368
        ECRYPTFS_SUPER_MAGIC  = 0xf15f
        EFS_SUPER_MAGIC       = 0x414A53
        EROFS_SUPER_MAGIC_V1  = 0xE0F5E1E2
        EXT2_SUPER_MAGIC      = 0xEF53
        EXT3_SUPER_MAGIC      = 0xEF53
        XENFS_SUPER_MAGIC     = 0xabba1974
        EXT4_SUPER_MAGIC      = 0xEF53
        BTRFS_SUPER_MAGIC     = 0x9123683E
        NILFS_SUPER_MAGIC     = 0x3434
        F2FS_SUPER_MAGIC      = 0xF2F52010
        HPFS_SUPER_MAGIC      = 0xf995e849
        ISOFS_SUPER_MAGIC     = 0x9660
        JFFS2_SUPER_MAGIC     = 0x72b6
        XFS_SUPER_MAGIC       = 0x58465342
        PSTOREFS_MAGIC        = 0x6165676C
        EFIVARFS_MAGIC        = 0xde5e81e4
        HOSTFS_SUPER_MAGIC    = 0x00c0ffee
        OVERLAYFS_SUPER_MAGIC = 0x794c7630
        FUSE_SUPER_MAGIC      = 0x65735546

        MINIX_SUPER_MAGIC     = 0x137F
        MINIX_SUPER_MAGIC2    = 0x138F
        MINIX2_SUPER_MAGIC    = 0x2468
        MINIX2_SUPER_MAGIC2   = 0x2478
        MINIX3_SUPER_MAGIC    = 0x4d5a

        MSDOS_SUPER_MAGIC     = 0x4d44
        EXFAT_SUPER_MAGIC     = 0x2011BAB0
        NCP_SUPER_MAGIC       = 0x564c
        NFS_SUPER_MAGIC       = 0x6969
        OCFS2_SUPER_MAGIC     = 0x7461636f
        OPENPROM_SUPER_MAGIC  = 0x9fa1
        QNX4_SUPER_MAGIC      = 0x002f
        QNX6_SUPER_MAGIC      = 0x68191122
        AFS_FS_MAGIC          = 0x6B414653

        REISERFS_SUPER_MAGIC  = 0x52654973

        SMB_SUPER_MAGIC       = 0x517B
        CIFS_SUPER_MAGIC      = 0xFF534D42
        SMB2_SUPER_MAGIC      = 0xFE534D42

        CGROUP_SUPER_MAGIC    = 0x27e0eb
        CGROUP2_SUPER_MAGIC   = 0x63677270

        RDTGROUP_SUPER_MAGIC  = 0x7655821

        STACK_END_MAGIC       = 0x57AC6E9D

        TRACEFS_MAGIC         = 0x74726163

        V9FS_MAGIC            = 0x01021997

        BDEVFS_MAGIC          = 0x62646576
        DAXFS_MAGIC           = 0x64646178
        BINFMTFS_MAGIC        = 0x42494e4d
        DEVPTS_SUPER_MAGIC    = 0x1cd1
        BINDERFS_SUPER_MAGIC  = 0x6c6f6f70
        FUTEXFS_SUPER_MAGIC   = 0xBAD1DEA
        PIPEFS_MAGIC          = 0x50495045
        PROC_SUPER_MAGIC      = 0x9fa0
        SOCKFS_MAGIC          = 0x534F434B
        SYSFS_MAGIC           = 0x62656572
        USBDEVICE_SUPER_MAGIC = 0x9fa2
        MTD_INODE_FS_MAGIC    = 0x11307854
        ANON_INODE_FS_MAGIC   = 0x09041934
        BTRFS_TEST_MAGIC      = 0x73727279
        NSFS_MAGIC            = 0x6e736673
        BPF_FS_MAGIC          = 0xcafe4a11
        AAFS_MAGIC            = 0x5a3c69f0
        ZONEFS_MAGIC          = 0x5a4f4653
        UDF_SUPER_MAGIC       = 0x15013346
        DMA_BUF_MAGIC         = 0x444d4142
        DEVMEM_MAGIC          = 0x454d444d
        SECRETMEM_MAGIC       = 0x5345434d
      end
    end
  end
end
