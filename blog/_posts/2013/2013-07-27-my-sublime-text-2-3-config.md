---
layout: post
title: My Sublime Text (2 & 3) config
date: '2013-07-27T15:59:00+00:00'
tags: ['programming']
tumblr_url: http://joonas-fi.tumblr.com/post/56601684361/my-sublime-text-2-3-config
---

1) Disable word wrap

Preferences -> Settings - user

	"word_wrap": false,
	"default_line_ending": "unix",


2) "Ctrl + tab" & "Ctrl + shift + tab" to toggle tabs to left/right just like browsers:

Preferences -> Key bindings - user

	{ "keys": ["ctrl+tab"], "command": "next_view" },
	{ "keys": ["ctrl+shift+tab"], "command": "prev_view" },


3) Install package control

View -> Show console
Paste this (Sublime Text 2):

	import urllib2,os; pf='Package Control.sublime-package'; ipp=sublime.installed_packages_path(); os.makedirs(ipp) if not os.path.exists(ipp) else None; urllib2.install_opener(urllib2.build_opener(urllib2.ProxyHandler())); open(os.path.join(ipp,pf),''wb').write(urllib2.urlopen(''http://sublime.wbond.net/'+pf.replace(' ','%20')).read()); print(''Please restart Sublime Text to finish installation')


or for Sublime Text 3:

	import urllib.request,os; pf = ''Package Control.sublime-package'; ipp = sublime.installed_packages_path(); urllib.request.install_opener( urllib.request.build_opener( urllib.request.ProxyHandler()) ); open(os.path.join(ipp, pf), ''wb').write(urllib.request.urlopen( ''http://sublime.wbond.net/' + pf.replace(' ','%20')).read())

4) Install Emmet (provides Zen coding)

Ctrl + shift + p -> Package control install > Emmet

5) Install All Autocomplete (autocompletes from all open tabs)

Ctrl + shift + p -> Package control install > All Autocomplete

6) Install MiniPy (allows to execute inline Python code)

Ctrl + shift + p -> Package control install > MiniPy

Now write some Python code, select it and Ctrl + x

(tip: $ is used as an incrementing counter in multiple selections)
