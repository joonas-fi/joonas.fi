---
date: "2016-12-27T14:48:00Z"
tags:
- programming
title: Stop using protocol-relative URLs
url: /2016/12/27/stop-using-protocol-relative-urls/
---

I still see this confusingly often, even with Twitter's timeline embedding feature. Protocol relative URLs
look like this:

```
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>
```

There is absolutely no reason to do that (anymore)! Take a look at the following table (perspective = the URL over which user the user opens the page) of the results:

| Scheme in URL | Browsed over: HTTP | Browsed over: HTTPS | Browsed over: Filesystem |
|---------------|--------------------|---------------------|--------------------------|
| http          | => http            | => http             | => http                  |
| https         | => https           | => https            | => https                 |
| //            | => http            | => https            | **(broken)**             |

As you can see, with protocol-relative the only "gain" we get (compared to linking via https) is that
for non-secure users, they are offered the resource over an insecure channel. https used to be slow,
and that was the only acceptable reason to use the protocol-relative URL - to gain some speed for folks
who opened the URL over insecure channel.

https works everywhere ([and is not slow anymore](https://www.paulirish.com/2010/the-protocol-relative-url/)),
so if the asset can be fetched over https it should be done so.

Using protocol-relative URLs you're only downgrading the security of your users AND breaking
any web pages that are opened from the filesystem. Shame on you!
