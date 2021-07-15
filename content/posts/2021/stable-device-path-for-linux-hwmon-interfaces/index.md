---
title: "Stable device path for Linux hwmon interfaces"
tags:
- technology
date: 2021-07-15T08:43:30Z
---

![](cputemp.gif)


The problem
-----------

`/sys/class/hwmon/hwmon2/temp1_input` reports your CPU temperature.

But the next time you reboot, the path might be `/sys/class/hwmon/hwmon1/temp1_input`.

=> The path is not stable, so you cannot easily refer to it.

Example use case where you might need stable paths is use in
[i3status](https://i3wm.org/docs/i3status.html#_cpu_temperature)
(it's the status bar in the animation on top of this article).


The solution
------------

### Identify hwmon interface (for this boot)

Identify the [hwmon interface](https://www.kernel.org/doc/html/latest/hwmon/hwmon-kernel-api.html)
number that (currently) reports your CPU temperature.

There usually exist multiple instances (one for CPU, GPU, laptop battery etc.):

``` console
$ tree /sys/class/hwmon
/sys/class/hwmon
├── hwmon0
├── hwmon1
├── hwmon2
└── hwmon3
```

Each `hwmon` interface has a name assigned to it. Check their names:

```console
$ cat /sys/class/hwmon/hwmon{0,1,2,3}/name
hidpp_battery_0
atk0110
k10temp
fam15h_power
```

In both my AMD CPU systems [k10temp](https://www.kernel.org/doc/html/latest/hwmon/k10temp.html)
is the driver for reporting temperature of the CPU.

=> `hwmon2` is our interface during this boot.

Usually the driver exposes multiple measurements (identified by `temp<NUMBER>_input` files):

```console
$ ls /sys/class/hwmon/hwmon2/temp*_input
/sys/class/hwmon/hwmon2/temp1_input
/sys/class/hwmon/hwmon2/temp2_input
```

If there are multiple measurements, there might be (but not always!) `temp<NUMBER>_label` files
help you distinguish what precisely it measures:

```console
$ cat /sys/class/hwmon/hwmon2/temp*_label
Tdie
Tctl
```

Many people suggest that [die temperature is the one you should pay attention to](https://www.reddit.com/r/Amd/comments/f21cjx/whats_the_difference_between_cpu_tctltdie_and_cpu/).

=> `/sys/class/hwmon/hwmon2/temp1_input` is our target.


### Find out details for udev rule

We need to write an [udev rule](https://wiki.archlinux.org/title/udev#About_udev_rules) to give our
CPU temperature reading a path that does not change.

Now that we know the hwmon interface is at `/sys/class/hwmon/hwmon2` (for this boot), we can interrogate its
udev attributes to begin writing the rule.

Query the hwmon interfaces's attributes, so we can write a rule that matches the specific device:

```console
$ udevadm info --attribute-walk --path=/sys/class/hwmon/hwmon2

  looking at device '/devices/pci0000:00/0000:00:18.3/hwmon/hwmon2':
    KERNEL=="hwmon2"
    SUBSYSTEM=="hwmon"                      <--
    DRIVER==""
    ATTR{temp1_label}=="Tdie"
    ATTR{temp2_label}=="Tctl"
    ATTR{temp1_input}=="45875"
    ATTR{temp2_input}=="45875"
    ATTR{name}=="k10temp"
    ATTR{temp1_max}=="70000"

  looking at parent device '/devices/pci0000:00/0000:00:18.3':
    KERNELS=="0000:00:18.3"
    SUBSYSTEMS=="pci"
    DRIVERS=="k10temp"
    ATTRS{subsystem_device}=="0x0000"
    ATTRS{local_cpus}=="000000ff"
    ATTRS{class}=="0x060000"
    ATTRS{d3cold_allowed}=="0"
    ATTRS{subsystem_vendor}=="0x0000"
    ATTRS{numa_node}=="-1"
    ATTRS{driver_override}=="(null)"
    ATTRS{irq}=="0"
    ATTRS{device}=="0x15eb"                   <--
    ATTRS{enable}=="0"
    ATTRS{dma_mask_bits}=="32"
    ATTRS{revision}=="0x00"
    ATTRS{local_cpulist}=="0-7"
    ATTRS{msi_bus}=="1"
    ATTRS{ari_enabled}=="0"
    ATTRS{consistent_dma_mask_bits}=="32"
    ATTRS{broken_parity_status}=="0"
    ATTRS{vendor}=="0x1022"                   <--
```

NOTE: I added arrows to show which keys we're interested in.

The (0x1022, 0x15eb) combo identifies an exact PCI device (in this case AMD + "Raven/Raven2 Device 24: Function 3").
You can [look up PCI vendor/device codes online](https://www.pcilookup.com/?ven=1022&dev=15eb&action=submit).


### Write udev rule

Now make `/etc/udev/rules.d/cpu-temp-stable-path.rules`:

```
# Give CPU temp a stable device path

# AMD Ryzen 2400G (Raven/Raven2 Device 24: Function 3)
ACTION=="add", SUBSYSTEM=="hwmon", ATTRS{vendor}=="0x1022", ATTRS{device}=="0x15eb", RUN+="/bin/sh -c 'ln -s /sys$devpath/temp1_input /dev/cpu_temp'"

```

It's safe on each boot make the symlink, because `/dev` is a non-persistent (= RAM-based) filesystem.


### Test the rule

You can test the rule matches by running:

```console
$ udevadm test /sys/class/hwmon/hwmon2
<other output>
run: '/bin/sh -c 'ln -s /sys/devices/pci0000:00/0000:00:18.3/hwmon/hwmon2/temp1_input /dev/cpu_temp''
Unload module index
Unloaded link configuration context.
```

If the output specifies the `run: <make symlink>` line, the rule matches and you're good.


### Sidenote: udev native symlinks don't seem to work for hwmon

There exists a native symlink facility (`SYMLINK+=`) in udev, but we need to "run" a command to make a symlink,
because for some unexplained reason the symlink facility doesn't seem to work for `hwmon` interfaces.
Maybe it's because hwmon natively doesn't live under `/dev`?


Conclusion
----------

We wrote a udev rule that makes sure that `/dev/cpu_temp` should always report your CPU temperature.
Good job!


Additional reading
------------------

- [udev on ArchWiki](https://wiki.archlinux.org/title/udev)
