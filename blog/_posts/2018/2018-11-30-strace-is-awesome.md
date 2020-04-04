---
layout:     post
title:      'strace is awesome'
date:       2018-11-30 14:30:00
tags:       ['programming']
permalink:  /2018/11/30/strace-is-awesome/
---

Your periodic reminder that [strace](https://strace.io/) is awesome..

On Windows you basically know which partition a file is hosted on by looking at the drive letter.

On Linux there's just a global namespace and it is more difficult to know the partition
of a given file (although I think the indirection in the Unix design is better).

I remembered that `$ df` can show me this info:

	$ df /home/vagrant
	Filesystem                   1K-blocks     Used Available Use% Mounted on
	/dev/mapper/vagrant--vg-root  64440148 16413800  44729888  27% /

Ok sure enough, `/dev/mapper/vagrant--vg-root` is just what my program needs to fetch - the
partition the directory is on (mine happens to be at root mount, but it always isn't
the case).

How does it do this? Hmm, just prefix the `df` command with `strace`. I filtered out
non-interesting lines and was left with this:

	$ strace df /home/vagrant
	open("/home/vagrant", O_RDONLY|O_NOCTTY) = 3
	fstat(3, {st_mode=S_IFDIR|0755, st_size=4096, ...}) = 0
	close(3)                                = 0
	open("/proc/self/mountinfo", O_RDONLY)  = 3
	fstat(3, {st_mode=S_IFREG|0444, st_size=0, ...}) = 0
	read(3, "18 23 0:17 / /sys rw,nosuid,node"..., 1024) = 1024
	read(3, "ystemd/systemd-cgroups-agent,nam"..., 1024) = 1024
	read(3, "io rw,nosuid,nodev,noexec,relati"..., 1024) = 1024
	read(3, "1 - overlay overlay rw,lowerdir="..., 1024) = 1024
	read(3, "S63JLQIBVW7YZFJWUO55ZHIU:/var/li"..., 1024) = 1024
	read(3, " 0:3 net:[4026532217] /run/docke"..., 1024) = 1024
	read(3, "3 / /var/lib/docker/overlay2/a2c"..., 1024) = 1024
	read(3, "67ed5b6ad8a07382c15873226/merged"..., 1024) = 1024
	read(3, "rlay overlay rw,lowerdir=/var/li"..., 1024) = 1024
	read(3, "NQDRB346OHVJV6PBKG,upperdir=/var"..., 1024) = 1024
	read(3, "ork\n223 23 0:69 / /var/lib/docke"..., 1024) = 1024
	read(3, "[4026532841] /run/docker/netns/1"..., 1024) = 1024
	read(3, "6a84e38acf4b5f39f321c257c4f2c178"..., 1024) = 1024
	read(3, " rw,nosuid,nodev,noexec,relatime"..., 1024) = 157
	read(3, "", 1024)                       = 0
	lseek(3, 0, SEEK_CUR)                   = 13469
	close(3)                                = 0
	lstat("/home", {st_mode=S_IFDIR|0755, st_size=4096, ...}) = 0
	lstat("/home/vagrant", {st_mode=S_IFDIR|0755, st_size=4096, ...}) = 0
	stat("/", {st_mode=S_IFDIR|0755, st_size=4096, ...}) = 0
	uname({sysname="Linux", nodename="vagrant", ...}) = 0
	statfs("/home/vagrant", {f_type="EXT2_SUPER_MAGIC", f_bsize=4096, f_blocks=16110037, f_bfree=12006561, f_bavail=11182446, f_files=4104192, f_ffree=3738210, f_fsid={-812717494, -1339855268}, f_namelen=255, f_frsize=4096, f_flags=4128}) = 0
	open("/usr/lib/x86_64-linux-gnu/gconv/gconv-modules.cache", O_RDONLY) = 3
	fstat(3, {st_mode=S_IFREG|0644, st_size=26258, ...}) = 0
	mmap(NULL, 26258, PROT_READ, MAP_SHARED, 3, 0) = 0x7f600b2bb000
	close(3)                                = 0
	fstat(1, {st_mode=S_IFCHR|0620, st_rdev=makedev(136, 0), ...}) = 0
	write(1, "Filesystem                   1K-"..., 74) = 74
	write(1, "/dev/mapper/vagrant--vg-root  64"..., 65) = 65
	close(1)                                = 0
	close(2)                                = 0
	+++ exited with 0 +++

`$ df` is using fstat(), lstat(), stat() and statfs(). All but statfs() return struct like
[this](https://linux.die.net/man/2/fstat), so there's no partition location there.

`statfs()` sounded really promising, but there's
[no partition info there](https://linux.die.net/man/2/statfs). It has "Filesystem ID" which
I though I could correlate with data from some other API, but it seemed not be the case.

Ok moving on, `$ df` also accesses `/proc/self/mountinfo`, let's try it:

	$ cat /proc/self/mountinfo
	... (snipped)
	23 0 252:0 / / rw,relatime shared:1 - ext4 /dev/mapper/vagrant--vg-root rw,errors=remount-ro,data=ordered
	... (snipped)

Ok there's basically all we need. The format for this output is documented
[here](https://www.kernel.org/doc/Documentation/filesystems/proc.txt).

So all we need to do to resolve `/home/vagrant`´s partition is grab the longest match of
mount point from output of `/proc/self/mountinfo`.

E.g., given this entire `mountinfo` .. (some numbers just randomized, they're probably wrong):

	23 0 252:0 / / rw,relatime shared:1 - ext4 /dev/mapper/vagrant--vg-root rw,errors=remount-ro,data=ordered
	24 0 0:139 / /home rw,relatime shared:1 - ext4 /dev/mapper/vagrant--vg-homes rw,errors=remount-ro,data=ordered

.. a few mount point resolve examples:

- `/home/vagrant` would be hosted on partition `/dev/mapper/vagrant--vg-homes` (longest match is `/home`)
- `/var/www` would be hosted on `/dev/mapper/vagrant--vg-root` (longest match is `/`)

My intuition about this "longest match" seems to be confirmed by coreutils' `df`
[source code](https://github.com/coreutils/coreutils/blob/e5dae2c6b0bcd0e4ac6e5b212688d223e2e62f79/src/df.c#L716).

There you go, today I learned how to access mount info, quite easily with the help of strace!

p.s. I'm using Go in my program, and I found a
[great library](https://github.com/prometheus/procfs/) for accessing procfs output.
