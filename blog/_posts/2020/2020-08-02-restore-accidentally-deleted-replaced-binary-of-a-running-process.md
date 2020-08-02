---
layout:     post
title:      'Restore accidentally deleted/replaced binary of a running process'
date:       2020-08-02 11:00:00
tags:       ['programming']
---

I compiled [Turbo Bob](https://github.com/function61/turbobob) (a build system) with a bug
that prevented entering a build container, and since Turbo Bob is built with itself,
I could not build a working binary again - chicken-egg problem.

(Of course I could download an old release, but I had some unreleased work I was benefiting
from that the old binary included, and while Bob builds fine with just Go compiler, I didn't
want to install Go tools on my host system only to fix this minor issue. And besides, this
was a fun challenge.)


My problem
----------

I wanted to get the old and working binary back again.


Solution
--------

Luckily I had the old working version of Turbo Bob's binary processes still running for
other projects, and I knew I can dump running process' binary from `/proc` filesystem.

First, identify PIDs for processes we're interested in:

	$ ps aux | grep bob
	vagrant   8141  0.0  0.0 711956  7708 pts/2    Sl+  Jul30   0:00 bob dev
	vagrant  14780  0.0  0.0 711956  7056 pts/3    Sl+  Jul31   0:00 bob dev

I chose `14780`. The Linux proc filesystem contains process's binary in `/proc/14780/exe`.
I thought I could just `$ cp /proc/14780/exe /usr/local/bin/bob` and call it a day, but
apparently the `exe` entry is a symlink:

	$ file /proc/14780/exe
	/proc/14780/exe: broken symbolic link to /usr/local/bin/bob (deleted)

I knew that since the binary is running, it has to keep handles somewhere for the old binary,
because the process' binary file is not physically removed from the filesystem until all
references to it are closed.

Next I inspected the proc filesystem's `maps` (["A file containing the currently mapped
memory regions and their access permissions."](https://man7.org/linux/man-pages/man5/proc.5.html)):

	$ cat /proc/14780/maps
	00400000-00894000 r-xp 00000000 fd:00 657514                             /usr/local/bin/bob (deleted)
	00894000-00d95000 r--p 00494000 fd:00 657514                             /usr/local/bin/bob (deleted)
	00d95000-00ddd000 rw-p 00995000 fd:00 657514                             /usr/local/bin/bob (deleted)
	00ddd000-00e0e000 rw-p 00000000 00:00 0
	c000000000-c004000000 rw-p 00000000 00:00 0
	7fe96e6a8000-7fe970a59000 rw-p 00000000 00:00 0

The `00400000-00894000` looks promising (notice it has an e**x**ecutable bit).

I could dump it out with sudo:

	$ sudo cat /proc/14780/map_files/400000-894000 > maybe_bob
	$ file maybe_bob
	maybe_bob: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically linked, not stripped


Success!


Additional thoughts
-------------------

Why did I use `maps` instead of `fd` (file descriptors)? While any open files by the process
should be found from `/proc/<id>/fd/...`, I suspect the process' binary is special
because technically it's not a file opened by the process, since the binary must exist before
there even is a process that could open any files.

