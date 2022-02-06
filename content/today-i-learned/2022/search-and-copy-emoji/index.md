---
title: "Search and copy emoji"
tags:
- linux
date: 2022-02-05T17:31:19Z
---

The problem
-----------

When I need some emoji, think ice cream 🍦, my (far from ideal) workflow has been to web search
`ice cream emoji` and hope that the emoji is in search result text somewhere close for easy copying.


A (bloated) solution
--------------------

I'm already using [Rofi](https://github.com/davatorium/rofi), so when I came across
[Rofimoji](https://github.com/fdw/rofimoji) at first I was excited that this solves my use case.

But I'd like to keep my computer as free from additional bloat as possible.
I tried running Rofimoji in Docker, but it required dependencies like it directly calling Rofi or a
copy-paste tool. I don't understand why it has to internally invoke those utils.

I simply wanted it to output list of emojis for Rofi to select, and do copying outside of it.
Seems like it isn't possible, and there's quite lot of code in Rofimoji for what it does, really.


The solution
------------

I decided to de-bloat, create empty directory `/var/lib/rofimoji-data` and simply to copy
[emojis.scv](https://github.com/fdw/rofimoji/blob/main/src/picker/data/emojis.csv) (+ `emoticons.csv`) to it.
The dir looks like:

```
/var/lib/rofimoji-data
├── emojis.csv
└── emoticons.csv
```

And I made a simple shell script `emoji.sh`, that's all there really should be to it:

```bash
#!/bin/bash -eu

emojiAndDescription="$(cat /var/lib/rofimoji-data/* | rofi -dmenu -p 'Emoji')"

# "<emoji> <description>" => "<emoji>"
emoji="$(echo -n "$emojiAndDescription" | cut -d ' ' -f 1)"

# copy to clipboard
echo -n "$emoji" | xclip -selection clipboard
```

Here's a video demo:

{{< video src="demo" >}}
