---
date: "2015-07-14T19:03:00Z"
tags:
- programming
title: TCP proxy in node.js
url: /2015/07/14/tcp-proxy-in-nodejs/
---

Use like this:

	$ node proxy.js 9001 80

Or forwarding to remote host:

	$ node proxy.js 9001 otherhost:80

Source (save as proxy.js):

The code used to be pasted here, but apparently Jekyll (the static blog generator) has a bug with it,
so find the code from my answer at [StackOverflow](http://stackoverflow.com/questions/6490898/node-js-forward-all-traffic-from-port-a-to-port-b/19637388#19637388).
