---
layout:     post
title:      'Warning about PayPal - disabled my account without warning'
date:       2020-01-14 15:30:00
tags:       ['technology']
---

Summary: PayPal suspended my account without warning and didn't efficiently tell what's
wrong or give me tools to fix it, causing me trouble with different vendors, and PayPal's
process for resolving this had many conflicting advice and everything was unacceptably confusing.

In the end I found out they just needed to fulfill some "Know your customer" EU regulation
and ask more info about my business **but they did piss-poor job with this**.


First failed payment
--------------------

It all started with me getting email from Spotify about a failed PayPal recurring payment
29th of June 2019. PayPal had sent me an email **the day before** saying that they had
immediately limited my account and that I needed to provide "some info" (actual quote from
the email - they didn't tell what was wrong).

I went to Spotify to try to re-authorize PayPal, and was greeted with this:

(Apologies, some of the screenshots are in Finnish. I'll translate the relevant texts.)

![](/images/2020/paypal-spotify-error.png)

It says:

> Your account usage has been limited. For solving this problem go to PayPal's summary page.

Summary page
------------

PayPal promised in Spotify error message AND the email I received from them that I'll
find more information here, but there's absolutely nothing out of the ordinary:

![](/images/2020/paypal-no-notifications.png)

> "You don't have any notifications."

There's absolutely nothing in my summary page telling me I have a problem with my account.


Help section
------------

After not finding anything from the summary page (even though I was promised so), I find
a help page about removing limitations, saying I need to go to Resolution center. It even
has a video that displays where from Resolution center's UI I should find form to get my
limitations lifted:

![](/images/2020/paypal-help-video.png)


Resolution center
-----------------

When I go to Resolution center, I absolutely can't find anything resembling the video I
was shown, or about any troubles:

![](/images/2020/paypal-nothing-mentioned-in-resolution-center.png)

The big blue "Report a problem" button only allows me to dispute an existing transaction.
I don't have any transaction to dispute, since the problem is me not being able to make
transactions.


Having to contact a human
-------------------------

I am now very frustrated and I need to contact a human being that can help me. I spend like
15 minutes trying to find a contact form instead of the self-service help topics that
are only there to minimize human contact between PayPal <-> customer.

I finally found a form and send a very angry email:

![](/images/2020/paypal-sending-support-email.png)

I got this response:

![](/images/2020/paypal-email-response.png)

Note: also absent is any apologies or admitting that this is too hard for the customer.

They actually asked these questions from me (the customer) in SQL column name format
(`MCC_CODE`) and I had to fill this "form" via email. Would you know what your MCC code is?
I'm using PayPal only to pay for things on behalf of my business - I'm not a merchant.
Does PayPal seem like an organization that knows what it's doing?

Also note them saying:

> If you log into your PayPal account using Internet Explorer or Mozilla Firefox, you
> should see a notification on the right hand side prompting you to ‘update info now’

I responded with screenshot from Firefox (shows the same view as my second screenshot). I also
tried with Internet Explorer but I had the same result. PayPal did not acknowledge or
apologize that I didn't see the magical "fix the problem" button that they said I should see.


Additional read
---------------

I am not the only person with unreasonable problems with PayPal:

- [Jehu Garcia's problem with PayPal (YouTube)](https://www.youtube.com/watch?v=t1rYgD8luGw)
- I am sure there's many more, but mr. Garcia's case I happened to remember seeing before
