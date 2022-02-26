---
title: "Golang: debugging a running process"
tags:
- golang
date: 2022-02-26T09:45:00Z
---

About the problem in general
----------------------------

Usually one can debug by changing your program code.

This can be called *instrumentation*: adding *debug instrumentation* to aid in learning about the bug,
and then running the problematic action again.

The instrumentation can either be "print statements" or something more elegant like adding debugger
breakpoints, or even building your code unchanged but
[asking the compiler to add debug symbols](https://gcc.gnu.org/onlinedocs/gcc/Debugging-Options.html).

But sometimes the problem you're encountering might happen so rarely that you can't rebuild
(and thus re-run) the binary, but instead you're left with debugging a running process.
This post is about that case, with Go.


Option 1: attach a debugger to a running program
------------------------------------------------

You can use a debugger, such as [Delve](https://github.com/go-delve/delve) to attach to an existing
process. No recompilation or instrumentation adding needed.

Assuming the PID of our process is `4040133`:

```
$ sudo ./dlv attach 4040133
Type 'help' for list of commands.
(dlv) goroutines
... goroutines' state is dumped here ...
```

That was easy! Delve is of course much more powerful: you can set breakpoints, watch variables,
step through code, etc.


Option 2: quit with a stack trace, when you can see the process's stderr
------------------------------------------------------------------------

Go offers this nice feature out of the box: when you send it
[SIGQUIT signal](https://pkg.go.dev/os/signal#hdr-Default_behavior_of_signals_in_Go_programs), it
exits with a stack dump.
The stack dump is shown for all goroutines, so you can know what each "thread" was doing at the time
of receiving `SIGQUIT`.

So in practice, this stack trace is really valuable to you. Now let's learn to dig it out.

You can get that dump written to the process's stderr by running (still assuming our PID is `4040133`):

```console
$ kill -QUIT 4040133
```

In the other terminal where you're running your program (or where it writes its stderr, maybe
`$ journalctl` if your app is running under systemd) you'll see:

```console
SIGQUIT: quit
PC=0x464ce1 m=0 sigcode=0

goroutine 0 [idle]:
runtime.futex()
	/usr/local/go/src/runtime/sys_linux_amd64.s:552 +0x21
runtime.futexsleep(0x7fff3a356560?, 0x441df3?, 0xc000032000?)
	/usr/local/go/src/runtime/os_linux.go:56 +0x36
runtime.notesleep(0xbf91d0)
	/usr/local/go/src/runtime/lock_futex.go:159 +0x87
runtime.mPark()
	/usr/local/go/src/runtime/proc.go:1447 +0x2a
runtime.stoplockedm()
	/usr/local/go/src/runtime/proc.go:2611 +0x65
runtime.schedule()
	/usr/local/go/src/runtime/proc.go:3308 +0x3d
runtime.park_m(0xc0001251e0?)
	/usr/local/go/src/runtime/proc.go:3525 +0x14d
runtime.mcall()
	/usr/local/go/src/runtime/asm_amd64.s:425 +0x43

goroutine 1 [chan receive, 21508 minutes]:
github.com/function61/gokit/sync/taskrunner.(*Runner).Wait(...)
	/go/pkg/mod/github.com/function61/gokit@v0.0.0-20211228101508-315ec8b830c9/sync/taskrunner/taskrunner.go:79
github.com/joonas-fi/joonas-sys/pkg/statusbar.logic({0x96f6f8, 0xc000030cc0})
	/workspace/pkg/statusbar/bar.go:150 +0x1bf
github.com/joonas-fi/joonas-sys/pkg/statusbar.Entrypoint.func1(0xc0001bc780?, {0xc28ab8?, 0x0?, 0x0?})
	/workspace/pkg/statusbar/bar.go:34 +0x25
github.com/spf13/cobra.(*Command).execute(0xc0001bc780, {0xc28ab8, 0x0, 0x0})
	/go/pkg/mod/github.com/spf13/cobra@v1.2.1/command.go:860 +0x663
github.com/spf13/cobra.(*Command).ExecuteC(0xc000187b80)
	/go/pkg/mod/github.com/spf13/cobra@v1.2.1/command.go:974 +0x3b4
github.com/spf13/cobra.(*Command).Execute(...)
	/go/pkg/mod/github.com/spf13/cobra@v1.2.1/command.go:902
main.main()
	/workspace/cmd/jsys/main.go:42 +0x434

goroutine 17 [syscall, 21508 minutes]:
os/signal.signal_recv()
	/usr/local/go/src/runtime/sigqueue.go:168 +0x98
os/signal.loop()
	/usr/local/go/src/os/signal/signal_unix.go:23 +0x19
created by os/signal.Notify.func1.1
	/usr/local/go/src/os/signal/signal.go:151 +0x2a

goroutine 18 [chan receive, 21508 minutes]:
github.com/function61/gokit/os/osutil.CancelOnInterruptOrTerminate.func1()
	/go/pkg/mod/github.com/function61/gokit@v0.0.0-20211228101508-315ec8b830c9/os/osutil/canceloninterruptorterminate.go:32 +0x4d
created by github.com/function61/gokit/os/osutil.CancelOnInterruptOrTerminate
	/go/pkg/mod/github.com/function61/gokit@v0.0.0-20211228101508-315ec8b830c9/os/osutil/canceloninterruptorterminate.go:31 +0x10a

goroutine 19 [syscall, 4080 minutes]:
syscall.Syscall(0x0, 0x0, 0xc0000ea3e4, 0xc1c)
	/usr/local/go/src/syscall/asm_linux_amd64.s:20 +0x5
syscall.read(0xc000072060?, {0xc0000ea3e4?, 0x9?, 0xc0002e2ea0?})
	/usr/local/go/src/syscall/zsyscall_linux_amd64.go:696 +0x4d
syscall.Read(...)
	/usr/local/go/src/syscall/syscall_unix.go:188
internal/poll.ignoringEINTRIO(...)
	/usr/local/go/src/internal/poll/fd_unix.go:794
internal/poll.(*FD).Read(0xc000072060?, {0xc0000ea3e4?, 0xc1c?, 0xc1c?})
	/usr/local/go/src/internal/poll/fd_unix.go:163 +0x285
os.(*File).read(...)
	/usr/local/go/src/os/file_posix.go:31
os.(*File).Read(0xc00000e010, {0xc0000ea3e4?, 0x1?, 0x120?})
	/usr/local/go/src/os/file.go:119 +0x5e
bufio.(*Scanner).Scan(0xc0000e3ef8)
	/usr/local/go/src/bufio/scan.go:215 +0x865
github.com/joonas-fi/joonas-sys/pkg/statusbar.logic.func1({0x0?, 0x0?})
	/workspace/pkg/statusbar/bar.go:61 +0x89
github.com/function61/gokit/sync/taskrunner.(*Runner).Start.func1()
	/go/pkg/mod/github.com/function61/gokit@v0.0.0-20211228101508-315ec8b830c9/sync/taskrunner/taskrunner.go:51 +0x45
created by github.com/function61/gokit/sync/taskrunner.(*Runner).Start
	/go/pkg/mod/github.com/function61/gokit@v0.0.0-20211228101508-315ec8b830c9/sync/taskrunner/taskrunner.go:50 +0x105

goroutine 23 [chan receive, 1390 minutes]:
github.com/function61/gokit/sync/taskrunner.(*Runner).waitInternal.func2(...)
	/go/pkg/mod/github.com/function61/gokit@v0.0.0-20211228101508-315ec8b830c9/sync/taskrunner/taskrunner.go:101
github.com/function61/gokit/sync/taskrunner.(*Runner).waitInternal(0xc0000b2140)
	/go/pkg/mod/github.com/function61/gokit@v0.0.0-20211228101508-315ec8b830c9/sync/taskrunner/taskrunner.go:134 +0x30a
github.com/function61/gokit/sync/taskrunner.(*Runner).Done.func1.1()
	/go/pkg/mod/github.com/function61/gokit@v0.0.0-20211228101508-315ec8b830c9/sync/taskrunner/taskrunner.go:63 +0x25
created by github.com/function61/gokit/sync/taskrunner.(*Runner).Done.func1
	/go/pkg/mod/github.com/function61/gokit@v0.0.0-20211228101508-315ec8b830c9/sync/taskrunner/taskrunner.go:62 +0x5a

goroutine 34 [chan send, 1390 minutes]:
github.com/vishvananda/netlink.routeSubscribeAt.func2()
	/go/pkg/mod/github.com/vishvananda/netlink@v1.1.0/route_linux.go:1075 +0x453
created by github.com/vishvananda/netlink.routeSubscribeAt
	/go/pkg/mod/github.com/vishvananda/netlink@v1.1.0/route_linux.go:1037 +0x2f2

rax    0xca
rbx    0x0
rcx    0x464ce3
rdx    0x0
rdi    0xbf91d0
rsi    0x80
rbp    0x7fff3a356530
rsp    0x7fff3a3564e8
r8     0x0
r9     0x0
r10    0x0
r11    0x286
r12    0x43c400
r13    0x0
r14    0xbf8940
r15    0x7fb0d47ba96c
rip    0x464ce1
rflags 0x286
cs     0x33
fs     0x0
gs     0x0
```

One under-appreciated thing about the dump is that it shows how long the syscalls have been waiting
for events! I knew my process' problems started roughly 23h 15m ago, and the `1390 minutes`
correspond pretty much exactly with that!

With the above stack dump I was able to figure out where the bug was.


Option 3: quit with a stack trace, when you can't see the process's stderr
--------------------------------------------------------------------------

If you're unsure where the process' `stderr` goes, I would suggest first finding if there's an easy
solution for that. Let's say your process ID is `4040133`. Look up file descriptor #2
([it's always stderr](https://man7.org/linux/man-pages/man3/stdout.3.html#DESCRIPTION)) to know where
the `stderr` is connected:

```console
$ ls -al /proc/4040133/fd/2
l-wx------ 1 joonas joonas 64 Feb 20 19:37 /proc/4040133/fd/2 -> /home/joonas/.xsession-errors
```

In my case my program was run under X.org server and the `stderr` simply was written to my
`.xsession-errors` file. I could've saved trouble if I had realized that earlier.

Since at the time I wasn't sure where the `stderr` was being written to, I went with the nuclear option.

(This works even in cases where you assumed `stderr` was not valuable and you redirected it to `/dev/null`!!!)

The trick is to `$ strace` to your existing process and capture the `write(2, ...)` syscalls.
The first argument to `write()` syscall is the *file descriptor number*, where `2` again means `stderr`.

So attach to the process with `strace`:

```console
$ sudo strace -p 2143770 -s 512 -ewrite 2> /tmp/strace.log
```

Then in another terminal, ask your process to exit (this will trigger Go runtime to write the stack
trace, which would normally end discarded, by proxy of writing to `/dev/null`):

```console
$ kill -QUIT 2143770
```

The process now dumps the stack trace to `/dev/null`, but it must do so by issuing syscalls, which
`strace` logs for you.

When you review the log file `/tmp/strace.log`, it looks like:

```
strace: Process 4040133 attached
--- SIGQUIT {si_signo=SIGQUIT, si_code=SI_USER, si_pid=2140770, si_uid=1000} ---
write(2, "SIGQUIT: quit", 13)           = 13
write(2, "\n", 1)                       = 1
write(2, "PC=", 3)                      = 3
write(2, "0x464ce1", 8)                 = 8
write(2, " m=", 3)                      = 3
write(2, "0", 1)                        = 1
write(2, " sigcode=", 9)                = 9
write(2, "0", 1)                        = 1
write(2, "\n", 1)                       = 1
write(2, "\n", 1)                       = 1
write(2, "goroutine ", 10)              = 10
write(2, "0", 1)                        = 1
write(2, " [", 2)                       = 2
write(2, "idle", 4)                     = 4
write(2, "]:\n", 3)                     = 3
write(2, "runtime.futex", 13)           = 13
write(2, "(", 1)                        = 1
write(2, ")\n", 2)                      = 2
write(2, "\t", 1)                       = 1
write(2, "/usr/local/go/src/runtime/sys_linux_amd64.s", 43) = 43
write(2, ":", 1)                        = 1
write(2, "552", 3)                      = 3
write(2, " +", 2)                       = 2
write(2, "0x21", 4)                     = 4
write(2, "\n", 1)                       = 1
write(2, "runtime.futexsleep", 18)      = 18
write(2, "(", 1)                        = 1
write(2, "0x7ffc12443b70", 14)          = 14
write(2, "?", 1)                        = 1
write(2, ", ", 2)                       = 2
write(2, "0x441df3", 8)                 = 8
write(2, "?", 1)                        = 1
write(2, ", ", 2)                       = 2
write(2, "0xc000036500", 12)            = 12
write(2, "?", 1)                        = 1
write(2, ")\n", 2)                      = 2
write(2, "\t", 1)                       = 1
write(2, "/usr/local/go/src/runtime/os_linux.go", 37) = 37
write(2, ":", 1)                        = 1
write(2, "56", 2)                       = 2
write(2, " +", 2)                       = 2
write(2, "0x36", 4)                     = 4
write(2, "\n", 1)                       = 1
write(2, "runtime.notesleep", 17)       = 17
write(2, "(", 1)                        = 1
write(2, "0xbfd370", 8)                 = 8
write(2, ")\n", 2)                      = 2
write(2, "\t", 1)                       = 1
... output snipped ...
write(2, "0xbfcae0", 8)                 = 8
write(2, "\n", 1)                       = 1
write(2, "r15    ", 7)                  = 7
write(2, "0x7ff9ba37ce03", 14)          = 14
write(2, "\n", 1)                       = 1
write(2, "rip    ", 7)                  = 7
write(2, "0x464ce1", 8)                 = 8
write(2, "\n", 1)                       = 1
write(2, "rflags ", 7)                  = 7
write(2, "0x286", 5)                    = 5
write(2, "\n", 1)                       = 1
write(2, "cs     ", 7)                  = 7
write(2, "0x33", 4)                     = 4
write(2, "\n", 1)                       = 1
write(2, "fs     ", 7)                  = 7
write(2, "0x0", 3)                      = 3
write(2, "\n", 1)                       = 1
write(2, "gs     ", 7)                  = 7
write(2, "0x0", 3)                      = 3
write(2, "\n", 1)                       = 1
+++ exited with 2 +++
```

These are raw syscalls, so you need a bit of text processing to turn that back into human-readable
content.

[A script like this may help you.](https://gist.github.com/psobot/6814658)

But the basic idea is this, let's take the first a few lines:

```
write(2, "SIGQUIT: quit", 13)           = 13
write(2, "\n", 1)                       = 1
write(2, "PC=", 3)                      = 3
write(2, "0x464ce1", 8)                 = 8
write(2, " m=", 3)                      = 3
write(2, "0", 1)                        = 1
write(2, " sigcode=", 9)                = 9
write(2, "0", 1)                        = 1
write(2, "\n", 1)                       = 1
write(2, "\n", 1)                       = 1
write(2, "goroutine ", 10)              = 10
write(2, "0", 1)                        = 1
write(2, " [", 2)                       = 2
write(2, "idle", 4)                     = 4
write(2, "]:\n", 3)                     = 3
write(2, "runtime.futex", 13)           = 13
write(2, "(", 1)                        = 1
write(2, ")\n", 2)                      = 2
write(2, "\t", 1)                       = 1
write(2, "/usr/local/go/src/runtime/sys_linux_amd64.s", 43) = 43
write(2, ":", 1)                        = 1
write(2, "552", 3)                      = 3
write(2, " +", 2)                       = 2
write(2, "0x21", 4)                     = 4
write(2, "\n", 1)                       = 1
```

Just take the raw strings, you can even evaluate them as JavaScript `+` operator in your browser's
JS console for example to re-assemble them:

```
"SIGQUIT: quit" +
"\n" +
"PC=" +
"0x464ce1" +
" m=" +
"0" +
" sigcode=" +
"0" +
"\n" +
"\n" +
"goroutine " +
"0" +
" [" +
"idle" +
"]:\n" +
"runtime.futex" +
"(" +
")\n" +
"\t" +
"/usr/local/go/src/runtime/sys_linux_amd64.s" +
":" +
"552" +
" +" +
"0x21" +
"\n";
```

->

```
SIGQUIT: quit\nPC=0x464ce1 m=0 sigcode=0\n\ngoroutine 0 [idle]:\nruntime.futex()\n\t/usr/local/go/src/runtime/sys_linux_amd64.s:552 +0x21\n
```

And then replacing the `\n` with newline and `\t` with tab:

```
SIGQUIT: quit
PC=0x464ce1 m=0 sigcode=0

goroutine 0 [idle]:
runtime.futex()
	/usr/local/go/src/runtime/sys_linux_amd64.s:552 +0x21

```

So we recovered important data even from a situation where the data was being sent to the dumpster! 🗑

Have fun with your new superpowers!
