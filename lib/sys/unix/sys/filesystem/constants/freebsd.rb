# frozen_string_literal: true

module Sys
  class Filesystem
    module Constants
      MNT_RDONLY      = 0x0000000000000001 # read only filesystem
      MNT_SYNCHRONOUS = 0x0000000000000002 # file system written synchronously
      MNT_NOEXEC      = 0x0000000000000004 # can't exec from filesystem
      MNT_NOSUID      = 0x0000000000000008 # don't honor setuid bits on fs
      MNT_NFS4ACLS    = 0x0000000000000010 # enable NFS version 4 ACLs
      MNT_UNION       = 0x0000000000000020 # union with underlying filesystem
      MNT_ASYNC       = 0x0000000000000040 # file system written asynchronously
      MNT_EXRDONLY    = 0x0000000000000080 # exported read only
      MNT_EXPORTED    = 0x0000000000000100 # filesystem is exported
      MNT_DEFEXPORTED = 0x0000000000000200 # exported to the world
      MNT_EXPORTANON  = 0x0000000000000400 # anon uid mapping for all
      MNT_EXKERB      = 0x0000000000000800 # exported with Kerberos
      MNT_LOCAL       = 0x0000000000001000 # filesystem is stored locally
      MNT_QUOTA       = 0x0000000000002000 # quotas are enabled on filesystem
      MNT_ROOTFS      = 0x0000000000004000 # identifies the root filesystem
      MNT_USER        = 0x0000000000008000 # mounted by a user
      MNT_SUIDDIR     = 0x0000000000100000 # special SUID dir handling
      MNT_SOFTDEP     = 0x0000000000200000 # using soft updates
      MNT_NOSYMFOLLOW = 0x0000000000400000 # do not follow symlinks
      MNT_IGNORE      = 0x0000000000800000 # do not show entry in df
      MNT_GJOURNAL    = 0x0000000002000000 # GEOM journal support enabled
      MNT_MULTILABEL  = 0x0000000004000000 # MAC support for objects
      MNT_ACLS        = 0x0000000008000000 # ACL support enabled
      MNT_NOATIME     = 0x0000000010000000 # disable update of file access time
      MNT_EXPUBLIC    = 0x0000000020000000 # public export (WebNFS)
      MNT_NOCLUSTERR  = 0x0000000040000000 # disable cluster read
      MNT_NOCLUSTERW  = 0x0000000080000000 # disable cluster write
      MNT_SUJ         = 0x0000000100000000 # using journaled soft updates
      MNT_AUTOMOUNTED = 0x0000000200000000 # filesystem was mounted by automounter
      MNT_VERIFIED    = 0x0000000400000000 # filesystem is verified
      MNT_UNTRUSTED   = 0x0000000800000000 # filesystem metadata is untrusted
      MNT_NAMEDATTR   = 0x0000020000000000 # named attributes enabled

      MNT_VISFLAGMASK = (
        MNT_RDONLY | MNT_SYNCHRONOUS | MNT_NOEXEC |
        MNT_NOSUID | MNT_NFS4ACLS | MNT_UNION |
        MNT_ASYNC | MNT_EXRDONLY | MNT_EXPORTED |
        MNT_DEFEXPORTED | MNT_EXPORTANON | MNT_EXKERB |
        MNT_LOCAL | MNT_USER | MNT_QUOTA |
        MNT_ROOTFS | MNT_NOATIME | MNT_NOCLUSTERR |
        MNT_NOCLUSTERW | MNT_SUIDDIR | MNT_SOFTDEP |
        MNT_IGNORE | MNT_EXPUBLIC | MNT_NOSYMFOLLOW |
        MNT_GJOURNAL | MNT_MULTILABEL | MNT_ACLS |
        MNT_NFS4ACLS | MNT_AUTOMOUNTED | MNT_VERIFIED |
        MNT_UNTRUSTED | MNT_NAMEDATTR
      )

      MNT_UPDATE    = 0x0000000000010000
      MNT_DELEXPORT = 0x0000000000020000
      MNT_RELOAD    = 0x0000000000040000
      MNT_FORCE     = 0x0000000000080000
      MNT_SNAPSHOT  = 0x0000000001000000
      MNT_NONBUSY   = 0x0000000004000000
      MNT_BYFSID    = 0x0000000008000000
      MNT_NOCOVER   = 0x0000001000000000
      MNT_EMPTYDIR  = 0x0000002000000000
      MNT_RECURSE   = 0x0000100000000000
      MNT_DEFERRED  = 0x0000200000000000

      MOUNT_OPTION_NAMES = {
        MNT_RDONLY => 'read-only',
        MNT_SYNCHRONOUS => 'synchronous',
        MNT_NOEXEC => 'noexec',
        MNT_NOSUID => 'nosuid',
        MNT_NFS4ACLS => 'nfsv4acls',
        MNT_UNION => 'union',
        MNT_ASYNC => 'asynchronous',
        MNT_EXRDONLY => 'exported-read-only',
        MNT_EXPORTED => 'exported',
        MNT_DEFEXPORTED => 'defexported',
        MNT_EXPORTANON => 'exportanon',
        MNT_EXKERB => 'exkerb',
        MNT_LOCAL => 'local',
        MNT_USER => 'user',
        MNT_QUOTA => 'quotas',
        MNT_ROOTFS => 'rootfs',
        MNT_NOATIME => 'noatime',
        MNT_NOCLUSTERR => 'noclusterr',
        MNT_NOCLUSTERW => 'noclusterw',
        MNT_SUIDDIR => 'suiddir',
        MNT_SOFTDEP => 'soft-updates',
        MNT_IGNORE => 'ignore',
        MNT_EXPUBLIC => 'public',
        MNT_NOSYMFOLLOW => 'nosymfollow',
        MNT_GJOURNAL => 'gjournal',
        MNT_MULTILABEL => 'multilabel',
        MNT_ACLS => 'acls',
        MNT_AUTOMOUNTED => 'automounted',
        MNT_VERIFIED => 'verified',
        MNT_UNTRUSTED => 'untrusted',
        MNT_NAMEDATTR => 'namedattr'
      }.freeze
    end
  end
end
