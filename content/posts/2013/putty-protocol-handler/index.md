---
date: "2013-01-26T14:49:00Z"
tags:
- technology
title: putty:[profile] URL handler
tumblr_url: http://joonas-fi.tumblr.com/post/41517045456/putty-profile-protocol-handler
url: /2013/01/26/putty-profile-protocol-handler/
---

Why: To share clickable shortcuts to PuTTY profiles in version control. Shortcuts to .exes cannot be shared because PuTTY install paths on all machines might not be the same.

Instructions
============

1) Download URLConf from [http://urlconf.codeplex.com/](http://urlconf.codeplex.com/) (use the .msi installer)

2) Run it as an administrator:

![](tumblr_inline_mh8g6nizHZ1qz4rgp.png)

3) Go to "Edit -> New"

4) Enter details as such: 

![](tumblr_inline_mh8g9yXyct1qz4rgp.png)
 

Program:

	C:\Programs\UrlConf\UrlConf.exe

Parameters:

	"%1" – "C:\Programs\PuTTY\PuTTY.exe" -load "$h"

Obviously, replace paths to UrlConf.exe and PuTTY.exe with your corresponding paths.

5) Now create a shortcut somewhere and type putty:<name_of_your_putty_profile> as the URL. 

![](tumblr_inline_mh8gmpQZqc1qz4rgp.png)
