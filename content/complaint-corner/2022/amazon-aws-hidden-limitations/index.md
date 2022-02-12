---
title: "Amazon AWS: hidden limitations"
tags:
- ux-fail
- amazon
date: 2022-02-12T11:34:40Z
---

Amazon Simple Email Service ("SES") promises to be able to also receive email.

I use eu-central-1 (Frankfurt) region for my webservices.

I was frustrated not being able to find receive-related settings.

It was only after I came across some documentation I that realized the issue might be that not all
regions support receiving:

![](docs-email-receiving-endpoints.png)

=> Frankfurt region doesn't support receiving email.

And sure enough, verifying this from UI, the menu item simply disappears when you're in the wrong region:

{{< video src="aws-email-service-not-available-in-all-regions" >}}

(NOTE: the "Unavailable" operation is only due to me changing the region *from* "Email receiving"
page - the warning wasn't visible to me before I wasn't even aware the page can be in the manu)

How hard would it have been to have the "Email receiving" link in menu with passive color with "?"
icon next to it with a tooltip explaining that this feature isn't available in this region?

Amazon must really hate its users since they don't seem to care about UX at all (see other posts tagged #Amazon).
