---
title: "QMK numpad hack for TKL keyboards"
tags:
- qmk
date: 2022-05-15T11:24:51Z
---

Problem
-------

TKL keyboard ("tenkeyless") means there is no numpad.

Sometimes you want a numpad, so it would be great if there was a hack to get one.


Solution
--------

[QMK](https://qmk.fm/) makes this easy.

I made `Scroll lock` a key that activates the temporary numpad layer, and for good measure I made the
numpad light up blue.

These are the keys in the numpad layer:

![](tkl-keypad-hack-keys.png)

I arranged the keys as close as possible to how they are in a "numpad-ful" keyboard.

(Holding `Scroll lock` disables the layer)


Demonstration
-------------

Here's me entering `123.4560`:

{{< video src="usage" >}}


Code
----

See [my example code here](https://github.com/joonas-fi/qmk_firmware/commit/38398114c4a6f0c8fd969395ef66612819b8314f)
