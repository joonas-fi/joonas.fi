---
date: "2018-11-07T12:30:00Z"
tags:
- technology
title: GMail´s spam detector failing?
url: /2018/11/07/gmails-spam-detector-failing/
---

For quite some time, I've been having lots of problems with GMail spam detector's false
positives.

![](gmail-spam-false-positive-scaleway.png)

Loads of legitimate mail going in spam folder. I'm glad I remembered to check the folder,
because the above kind of mail is really fatal if you miss it (credit card expiration =>
service suspension => VMs going offline).

Lately these kinds of mail have gone to spam:

- [eBay](https://www.ebay.com/) "Help us protect your account" mails
- [Scaleway](https://www.scaleway.com/)'s "your credit card is expiring soon"
- [Hetzner](https://www.hetzner.com/) "verify account" mail
- Newsletters from a Finnish retail company (still going to spam even when I consistently
  mark the false positives as "not spam")
- Alerts from [my monitoring system](https://github.com/function61/lambda-alertmanager)
  (though this is probably due to there being HTML as text which might seem suspicious)

Ugh, I don't know the reason for this, but lately I've been becoming increasingly annoyed
with what Google stands for. They seem to be less about
["Don't be evil"](https://gizmodo.com/google-removes-nearly-all-mentions-of-dont-be-evil-from-1826153393)
every passing day.

I'm dreaming of some day abandoning Google altogether and really owning my data.

Extra reading:

- [HackerNews: Alarming number of spam false positives in Gmail](https://news.ycombinator.com/item?id=9190119)
