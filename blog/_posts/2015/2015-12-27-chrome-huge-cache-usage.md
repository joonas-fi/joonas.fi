---
layout:     post
title:      'Chrome: huge cache usage'
date:       2015-12-27 15:00:00
tags:       ['technology']
permalink:  /2015/12/27/chrome-huge-cache-usage/
---

I had this issue where Chrome browser was using 20 GB of cache, effectively suffocating my SSD's 60 GB system partition.

I pinpointed the problem with [TreeSize free](https://www.jam-software.com/treesize_free/) (highly recommend!).

![](/images/2015/12/chrome-huge-cache.PNG)

There were 32 000+ files:

![](/images/2015/12/chrome-huge-cache-2.PNG)

Clearing browser history didn't do nothing to the cache folder:

![](/images/2015/12/chrome-huge-cache-3.PNG)

What worked was closing Chrome, deleting the whole folder (make sure not to use the recycle bin) and starting it up again.

After a couple of days, the folder was at ~900 files with 300 MB, and clearing the cache now reduces it to 14 files with 6 MB - a level to be expected.

I don't know what the problem was - posting here in hopes that this helps other people struggling with this (though I didn't find any exact same experiences by Googling..).
