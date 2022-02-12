---
title: "Amazon AWS: numbers need units to have meaning"
tags:
- ux-fail
- amazon
date: 2022-02-12T10:44:49Z
---

From Amazon "Simple Email Service":

![](no-unit.png)

I can send one email? One during the lifetime of the universe? One per day? One per second?

The number has no meaning without a unit.

Only after you open the "more information" link, they tell you that the 200 is per day and the 1 is per second.

**They're using different units for numbers right next to each other, without specifying the unit.** 🤡

This is how it should be done (from AWS Lambda):

![](proper-units.png)

This "no unit" problem in AWS is really prevalent. Here's throttling limits in API Gateway:

![](no-unit-in-api-gateway.png)

(And no, when you go to edit the limits, the units won't be revealed there either.)

For a company with 1.6 trillion valuation, one would think they'd have the resources to hire at
least one person who cares, or a UX designer who would spot this problem immediately. 🤷
