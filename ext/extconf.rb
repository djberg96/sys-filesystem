require 'mkmf'

dir_config('filesystem')

have_header("sys/mnttab.h") || have_header("mntent.h")

have_func("statvfs")
have_func("getextmntent")

if have_func("getmntinfo")
   have_macro("MNT_NOATIME", "sys/mount.h")
   have_macro("MNT_MULTILABEL", "sys/mount.h")
end

if have_header("sys/statvfs.h")
   have_struct_member("struct statvfs", "f_basetype", "sys/statvfs.h")
else
   have_header("sys/vnode.h")
end

create_makefile("sys/filesystem", "sys")
