/********************************************************************
 * filesystem.c
 *
 * This is the source file for the sys-filesystem package for Ruby.
 * This is for UNIX platforms only.
 ********************************************************************/
#include <ruby.h>

#include <sys/types.h>

#ifdef HAVE_SYS_STATVFS_H /* Most flavors of UNIX */
#include <sys/statvfs.h>
#else                     /* FreeBSD 4.x */
#include <sys/param.h>
#include <sys/mount.h>
#include <sys/vnode.h>
#endif

#ifdef HAVE_SYS_MNTTAB_H  /* Solaris */

#include <sys/mnttab.h>
#define MNTENT mnttab
#define START_MNT(F,M) fopen(F,M)
#define GET_MNT(FP,MP) (getmntent(FP,MP) == 0)
#define END_MNT(F) fclose(F)
#define MOUNTFILE "/etc/mnttab"

/* Ruby 1.9.x compatibility */
#ifndef RSTRING_PTR
#define RSTRING_PTR(v) (RSTRING(v)->ptr)
#define RSTRING_LEN(v) (RSTRING(v)->len)
#endif

#ifndef RARRAY_PTR
#define RARRAY_PTR(v) (RARRAY(v)->ptr)
#define RARRAY_LEN(v) (RARRAY(v)->len)
#endif

#elif HAVE_GETMNTINFO

struct _ment {
  struct statfs *mntbufp;
  int current;
  int max;
};

#include <sys/param.h>
#include <sys/mount.h>
#include <sys/vnode.h>

#define MNTENT _ment
#define START_MNT(F,M) start_mnt(F,M)
#define GET_MNT(FP,MP) ((MP = get_mnt(MP)) != NULL)
#define END_MNT(F) end_mnt(F)
#define MOUNTFILE "getmntinfo"

#else /* Most flavors of UNIX */

#ifdef HAVE_MNTENT_H
#include <mntent.h>
#define MNTENT mntent
#define START_MNT(F,M) setmntent(F,M)
#define GET_MNT(FP,MP) ((MP = getmntent(FP)) != NULL)
#define END_MNT(F) endmntent(F)
#define MOUNTFILE "/etc/mtab"
#endif

#endif

#ifdef HAVE_GETMNTINFO

/* below table comes from FreeBSD mount.c@1.105 */
static struct opt {
  int o_opt;
  const char *o_name;
} optnames[] = {
  { MNT_ASYNC,    "asynchronous" },
  { MNT_EXPORTED, "NFS exported" },
  { MNT_LOCAL,    "local" },
  { MNT_NOEXEC,      "noexec" },
  { MNT_NOSUID,      "nosuid" },
  { MNT_QUOTA,    "with quotas" },
  { MNT_RDONLY,      "read-only" },
  { MNT_SYNCHRONOUS, "synchronous" },
  { MNT_UNION,    "union" },
#ifdef HAVE_MNT_MULTILABEL
  { MNT_MULTILABEL,  "multilabel" },
#endif
#ifdef HAVE_MNT_NOATIME
  { MNT_NOATIME,  "noatime" },
#endif
#if !defined(__MACH__) || !defined(__APPLE__)
  { MNT_NOSYMFOLLOW, "nosymfollow" },
  { MNT_NOCLUSTERR,  "noclusterr" },
  { MNT_NOCLUSTERW,  "noclusterw" },
  { MNT_SUIDDIR,  "suiddir" },
  { MNT_SOFTDEP,  "soft-updates" },
  { MNT_ACLS,     "acls" },
#endif
  { 0, NULL }
};

static FILE* start_mnt(const char *filename, const char *type)
{
  return (FILE*)!0;     /* do nothing */
}

static struct _ment* get_mnt(struct _ment* m)
{
  struct _ment* ret = m;

  if (m->max == 0) {
    if ((m->max = getmntinfo(&(m->mntbufp), MNT_NOWAIT)) == 0) {
      return NULL;      /* XXX */
    }
    m->current = 0;
  }

  if (m->current >= m->max) {
    ret = NULL;
  }
  m->current++;

  return ret;
}

static void end_mnt(FILE* fp)
{
  /* do nothing */
}

#endif


VALUE mSys, cFilesys, cStat, cMount;

static VALUE create_mount_object(struct MNTENT*);

/* call-seq:
 *    Filesystem.stat(path)
 *
 * Returns a a Filesystem::Stat object containing information about the +path+
 * file system.
 */
static VALUE fs_stat(VALUE klass, VALUE v_path){
   VALUE v_stat;
   char* path = StringValuePtr(v_path);

#ifdef HAVE_STATVFS
   struct statvfs fs;

   if(statvfs(path, &fs) < 0)
      rb_sys_fail("statvfs");
#else
   struct mount mp;
   struct statfs fs;
   struct proc p;

   if(VFS_STATFS(&mp, &fs, &p) < 0)
      rb_sys_fail("VFS_STATFS");
#endif

   v_stat = rb_funcall(cStat, rb_intern("new"), 0, 0);

   rb_iv_set(v_stat, "@path", v_path);

// You gotta love OS X, right?
#ifdef __MACH__
   rb_iv_set(v_stat, "@block_size", ULONG2NUM(fs.f_bsize/256));
#else
   rb_iv_set(v_stat, "@block_size", ULONG2NUM(fs.f_bsize));
#endif

   rb_iv_set(v_stat, "@fragment_size", ULONG2NUM(fs.f_frsize));
   rb_iv_set(v_stat, "@blocks", LONG2NUM(fs.f_blocks));
   rb_iv_set(v_stat, "@blocks_free", LONG2NUM(fs.f_bfree));
   rb_iv_set(v_stat, "@blocks_available", LONG2NUM(fs.f_bavail));
   rb_iv_set(v_stat, "@files", LONG2NUM(fs.f_files));
   rb_iv_set(v_stat, "@files_free", LONG2NUM(fs.f_ffree));
   rb_iv_set(v_stat, "@files_available", LONG2NUM(fs.f_favail));
   rb_iv_set(v_stat, "@filesystem_id", ULONG2NUM(fs.f_fsid));
   rb_iv_set(v_stat, "@flags", ULONG2NUM(fs.f_flag));
   rb_iv_set(v_stat, "@name_max", ULONG2NUM(fs.f_namemax));

#ifdef HAVE_ST_F_BASETYPE
   rb_iv_set(v_stat, "@base_type", rb_str_new2(fs.f_basetype));
#endif

   return rb_obj_freeze(v_stat);
}

/* Convenient methods for converting bytes to kilobytes, megabytes or
 * gigabytes.
 */

/*
 * call-seq:
 *    <tt>fix</tt>.to_kb
 *
 * Returns +fix+ in terms of kilobytes.
 */
static VALUE fixnum_to_kb(VALUE self){
   return ULL2NUM(NUM2ULONG(self) / 1024);
}

/*
 * call-seq:
 *    <tt>fix</tt>.to_mb
 *
 * Returns +fix+ in terms of megabytes.
 */
static VALUE fixnum_to_mb(VALUE self){
   return ULL2NUM(NUM2ULONG(self) / 1048576);
}

/*
 * call-seq:
 *    <tt>fix</tt>.to_gb
 *
 * Returns +fix+ in terms of gigabytes.
 */
static VALUE fixnum_to_gb(VALUE self){
   return ULL2NUM(NUM2ULONG(self) / 1073741824);
}

/*
 * call-seq:
 *    Filesystem.mounts
 *    Filesystem.mounts{ ... }
 *
 * In block form, yields a Filesystem::Mount object for each mounted filesystem
 * on your machine. In non-block form, returns an array of Filesystem::Mount
 * objects instead.
 *
 * Example:
 *
 *    Filesystem.mounts{ |fs|
 *       p fs.name            # => e.g. '/dev/dsk/c0t0d0s0', 'proc', etc
 *       p fs.mount_time      # => e.g. Thu Dec 11 15:07:23 -0700 2008
 *       p fs.mount_type      # => e.g. 'ufs', 'proc', etc
 *       p fs.mount_point     # => e.g. '/', '/proc', '/tmp', etc
 *       p fs.options         # => e.g. "rw,intr,largefiles,logging,xattr,onerror=panic,dev=2200008"
 *       p fs.pass_number     # => e.g. ???
 *       p fs.dump_frequency  # => e.g. ???
 *    }
 */
static VALUE fs_mounts(VALUE klass){
   VALUE v_array;
   FILE* fp;
   struct MNTENT* mp;
#ifdef HAVE_SYS_MNTTAB_H
   struct MNTENT mt;
   mp = &mt;
#elif HAVE_GETMNTINFO
   struct MNTENT mt;
   mt.max = 0;
   mp = &mt;
#endif

   v_array = Qnil;

   if((fp = START_MNT(MOUNTFILE, "r")) == NULL)
      rb_sys_fail(MOUNTFILE);

   if(rb_block_given_p()){
      while(GET_MNT(fp, mp))
         rb_yield(create_mount_object(mp));
   }
   else{
      v_array = rb_ary_new();
      while(GET_MNT(fp, mp))
         rb_ary_push(v_array, create_mount_object(mp));
   }

   END_MNT(fp);

   return v_array; /* nil in block form */
}

/* Private function to create a Filesystem object */
static VALUE create_mount_object(struct MNTENT* mp){
   VALUE v_mount = rb_funcall(cMount, rb_intern("new"), 0, 0);

#ifdef HAVE_SYS_MNTTAB_H
   rb_iv_set(v_mount, "@name", rb_tainted_str_new2(mp->mnt_special));
   rb_iv_set(v_mount, "@mount_point", rb_tainted_str_new2(mp->mnt_mountp));
   rb_iv_set(v_mount, "@mount_type", rb_tainted_str_new2(mp->mnt_fstype));
   rb_iv_set(v_mount, "@options", rb_tainted_str_new2(mp->mnt_mntopts));
   rb_iv_set(v_mount, "@mount_time", rb_time_new(atoi(mp->mnt_time), 0));
   rb_iv_set(v_mount, "@dump_frequency", Qnil);
   rb_iv_set(v_mount, "@pass_number", Qnil);
#elif HAVE_GETMNTINFO
   {
      struct statfs *p = mp->mntbufp + (mp->current-1);
      struct opt *o;
      int flags, mul;
      char ostr[BUFSIZ];

      flags = p->f_flags & MNT_VISFLAGMASK;
      ostr[0] = '\0';

      for (mul = 0, o = optnames; flags && o->o_opt; o++) {
         if (flags & o->o_opt) {
            strlcat(ostr, ((mul++) ? "," : ""), BUFSIZ);
            strlcat(ostr, o->o_name, BUFSIZ);
            flags &= ~o->o_opt;
         }
      }

      rb_iv_set(v_mount, "@name", rb_tainted_str_new2(p->f_mntfromname));
      rb_iv_set(v_mount, "@mount_point", rb_tainted_str_new2(p->f_mntonname));
      rb_iv_set(v_mount, "@mount_type", rb_tainted_str_new2(p->f_fstypename));
      rb_iv_set(v_mount, "@options", rb_tainted_str_new2(ostr));
      rb_iv_set(v_mount, "@mount_time", Qnil);
      rb_iv_set(v_mount, "@dump_frequency", Qnil);
      rb_iv_set(v_mount, "@pass_number", Qnil);
   }
#else
   rb_iv_set(v_mount, "@name", rb_tainted_str_new2(mp->mnt_fsname));
   rb_iv_set(v_mount, "@mount_point", rb_tainted_str_new2(mp->mnt_dir));
   rb_iv_set(v_mount, "@mount_type", rb_tainted_str_new2(mp->mnt_type));
   rb_iv_set(v_mount, "@options", rb_tainted_str_new2(mp->mnt_opts));
   rb_iv_set(v_mount, "@mount_time", Qnil);
   rb_iv_set(v_mount, "@dump_frequency", INT2NUM(mp->mnt_freq));
   rb_iv_set(v_mount, "@pass_number", INT2NUM(mp->mnt_passno));
#endif

   return v_mount;
}

/*
 * call-seq:
 *    Filesystem.mount_point(file)
 *
 * Returns the mount point of the given +file+, or itself if it cannot be
 * determined.
 *
 * Example:
 *
 *    Filesystem.mount_point('/home/djberge/some_file.txt') => '/home'
 */
static VALUE fs_mount_point(VALUE klass, VALUE v_file){
   VALUE v_stat, v_stat_m, v_mounts, v_mount_pt, v_mount;
   VALUE v_found = Qfalse;
   long dev1, dev2;
   int i = 0;

   v_stat   = rb_funcall(rb_cFile, rb_intern("stat"), 1, v_file);
   v_mounts = fs_mounts(klass);
   dev1     = FIX2LONG(rb_funcall(v_stat, rb_intern("dev"), 0, 0));

   /* Stat each mount point and compare its device number with the device
    * number of the file provided. If they match, we have a winner.
    */
   for(i = 0; i < RARRAY_LEN(v_mounts); i++){
      v_mount    = RARRAY_PTR(v_mounts)[i];
      v_mount_pt = rb_funcall(v_mount, rb_intern("mount_point"), 0, 0);
      v_stat_m   = rb_funcall(rb_cFile, rb_intern("stat"), 1, v_mount_pt);
      dev2       = FIX2LONG(rb_funcall(v_stat_m, rb_intern("dev"), 0, 0));

      if(dev1 == dev2){
         v_found = Qtrue;
         break;
      }
   }

   if(v_found == Qtrue)
      return v_mount_pt;
   else
      return v_file;
}

void Init_filesystem(){
   /* The toplevel namespace */
   mSys = rb_define_module("Sys");

   /* The Filesystem class serves an abstract base class. It's methods return
    * objects of other types. Do not instantiate.
    */
   cFilesys = rb_define_class_under(mSys, "Filesystem", rb_cObject);

   /* Instances of this class are returned by the Filesystem.mount method */
   cMount = rb_define_class_under(cFilesys, "Mount", rb_cObject);

   /* Instances of this class are returned by the Filesystem.stat method */
   cStat = rb_define_class_under(cFilesys, "Stat", rb_cObject);

   /* Singleton methods */
   rb_define_singleton_method(cFilesys, "mount_point", fs_mount_point, 1);
   rb_define_singleton_method(cFilesys, "mounts", fs_mounts, 0);
   rb_define_singleton_method(cFilesys, "stat", fs_stat, 1);

   /* Filesystem::Mount accessors */

   /* The name of the mounted resource */
   rb_define_attr(cMount, "name", 1, 0);

   /* The mount point/directory */
   rb_define_attr(cMount, "mount_point", 1, 0);

   /* The type of the file system mount, e.g. 'ufs', 'nfs', etc */
   rb_define_attr(cMount, "mount_type", 1, 0);

   /* A list of comma separated options for the mount, e.g. 'rw', etc */
   rb_define_attr(cMount, "options", 1, 0);

   /* The time the file system was mounted or nil if not supported */
   rb_define_attr(cMount, "mount_time", 1, 0);

   /* The dump frequency in days (or nil if not supported) */
   rb_define_attr(cMount, "dump_frequency", 1, 0);

   /* The pass number of the file system check or nil if not supported */
   rb_define_attr(cMount, "pass_number", 1, 0);

   /* Filesystem::Mount Aliases */

   rb_define_alias(cMount, "fsname", "name");
   rb_define_alias(cMount, "dir", "mount_point");
   rb_define_alias(cMount, "opts", "options");
   rb_define_alias(cMount, "passno", "pass_number");
   rb_define_alias(cMount, "freq", "dump_frequency");

   /* Filesystem::Stat accessors */

   /* The path of the file system */
   rb_define_attr(cStat, "path", 1, 0);

   /* The preferred system block size */
   rb_define_attr(cStat, "block_size", 1, 0);

   /* The fragment size, i.e. fundamental file system block size */
   rb_define_attr(cStat, "fragment_size", 1, 0);

   /* The total number of +fragment_size+ blocks in the file system */
   rb_define_attr(cStat, "blocks", 1, 0);

   /* The total number of free blocks in the file system */
   rb_define_attr(cStat, "blocks_free", 1, 0);

   /* The number of free blocks available to unprivileged processes */
   rb_define_attr(cStat, "blocks_available", 1, 0);

   /* The total number of files/inodes that can be created */
   rb_define_attr(cStat, "files", 1, 0);

   /* The total number of free files/inodes on the file system */
   rb_define_attr(cStat, "files_free", 1, 0);

   /* The number of free files/inodes available to unprivileged processes */
   rb_define_attr(cStat, "files_available", 1, 0);

   /* The file system identifier */
   rb_define_attr(cStat, "filesystem_id", 1, 0);

   /* The file system type, e.g. UFS */
   rb_define_attr(cStat, "base_type", 1, 0);

   /* A bit mask of flags.  See the <tt>Constants</tt> for a list of flags */
   rb_define_attr(cStat, "flags", 1, 0);

   /* The maximum length of a file name permitted on the file system */
   rb_define_attr(cStat, "name_max", 1, 0);

   /* Constants */

   /* 0.3.2: The version of this library (a String) */
   rb_define_const(cFilesys, "VERSION", rb_str_new2("0.3.2"));

   /* 0x00000001: Read only file system */
   rb_define_const(cStat, "RDONLY", INT2FIX(ST_RDONLY));

   /* 0x00000002: File system does not support suid or sgid semantics */
   rb_define_const(cStat, "NOSUID", INT2FIX(ST_NOSUID));

#ifdef ST_NOTRUNC
   /* 0x00000003: File system does not truncate file names longer than +name_max+ */
   rb_define_const(cStat, "NOTRUNC", INT2FIX(ST_NOTRUNC));
#endif

   /* Aliases */
   rb_define_alias(cStat, "inodes", "files");
   rb_define_alias(cStat, "inodes_free", "files_free");
   rb_define_alias(cStat, "inodes_available", "files_available");

   /* Convenient methods for Fixnum */
   rb_define_method(rb_cFixnum, "to_kb", fixnum_to_kb, 0);
   rb_define_method(rb_cFixnum, "to_mb", fixnum_to_mb, 0);
   rb_define_method(rb_cFixnum, "to_gb", fixnum_to_gb, 0);
}
