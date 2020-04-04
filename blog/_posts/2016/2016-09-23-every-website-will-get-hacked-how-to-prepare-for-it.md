---
layout:     post
title:      'Every website will get hacked - how to prepare for it'
date:       2016-09-23 08:29:00
tags:       ['infosec']
permalink:  /2016/09/23/every-website-will-get-hacked-how-to-prepare-for-it/
---

Every website will get hacked?
------------------------------

Yes. It is starting to look like every website - even the major ones, **will get hacked**. It is not a question of "if", but "when".

Just now in the news is that [Yahoo was compromised](http://www.bbc.com/news/world-us-canada-37447016) and the
result was a leak of names, usernames, passwords and other personal data of 500 million accounts - almost
twice the United States population.

Here are examples of a few widely known breached websites (up to September 2016 - this list grows constantly):

| Website | Breached accounts, millions |
|---------|-----------------------------|
| Yahoo | ~500 M |
| MySpace | 359.4 M |
| LinkedIn | 164.6 M |
| Adobe | 152.4 M |
| VKontakte (Russian Facebook) | 93.3 M |
| Dropbox | 68.6 M |
| Tumblr | 65.4 M |
| Ashley Madison (dating site for cheaters) | 30.8 M |
| Last.fm | 37 M |
| Snapchat | 4.6 M |
| Trillian | 3.8 M |
| Patreon | 2.3 M |
| Forbes | 1 M |
| Comcast | 0.6 M |
| Yahoo (old breach) | 0.4 M |
| Avast | 0.4 M |

This list is just the publicly known breaches, and I believe there are plenty that go unreported and/or have already happened,
but are yet to be known to the public. Many breaches have a lead time (= time it takes from the breach until it becomes public knowledge) in years.

More complete list (and sources for the claims) of breaches are found from [haveibeenpwned.com](https://haveibeenpwned.com/PwnedWebsites),
operated by security researcher (and my personal hero) [Troy Hunt](https://www.troyhunt.com/).

Have my details been leaked online?
-----------------------------------

[HaveIBeenPwned](https://haveibeenpwned.com/) is a free website where you can enter your email to see
if your account details have been publicly leaked online.

I know, in this day and age entering your primary email into one more website doesn't sound good - but the operator of
the website is as [trustworthy and as responsible as they get](https://www.troyhunt.com/tag/have-i-been-pwned-3f/).

Different types of websites have different risks
------------------------------------------------

| Type | Example site | Sign-in via | Impact of breach |
|----------|--------------|--------------|------------------|
| Blog | Tumblr | | **Low**: people probably don't have much private content in Tumblr blogs. |
| Social | Twitter | | **Low**: Twitter messages are public anyway (though some people use private messages as well) |
| Social | Twitter | Yes | **Severe**: all your "Sign in via Twitter" -websites are compromised as a result. |
| Social | LinkedIn | | **Low**: my profile and private messages there are not so sensitive. |
| Social | Facebook | | **Severe**: your private messages in Facebook should probably be private. |
| Social | Facebook | Yes | **Severe**: all your "Sign in via Facebook" -websites are compromised as a result. |
| Dating | match.com | | **Severe**: you probably have privacy-sensisive conversations there. |
| Dating | AshleyMadison | | **Catastrophic**: you being a cheater and your sexual preferences become public knowledge. |
| Email | GMail | Yes | **Catastrophic**: "Reset password" links are sent to email. Your email gives full access to all your other services. |
| Health | E-health provider | | **Catastrophic**: your health data, possibly sexual history, awkward illnesses will be made public. |

**BUT**: if you are one of the [59 % who use the same password for different sites](https://www.troyhunt.com/what-do-sony-and-yahoo-have-in-common/),
then the impact of even a Tumblr breach could turn up to be catastrophic because the same password lets hackers into your GMail as well (and from there, to other websites).

Note: above are generalizations. People use websites differently, for example you could use Twitter's private messages a lot more than I do,
so you could be a lot more concerned about a breach than I would be. Or you could not have sensitive private messages in Facebook.

You don't believe me about the catastrophic impact? [Read more](https://www.troyhunt.com/ashley-madison-search-sites-like/)
to learn for example how vulture-like people set up the AshleyMadison records (sexual preferences etc.) for public search
and extorted money from the victims. Yes, you could argue the victims being cheaters, they deserved it - and you'd probably be right.

I believe it's only a matter of time before a huge breach reveals people's really intimate data like health records.
[Philippines voting data](https://www.troyhunt.com/when-nation-is-hacked-understanding/) and
[US government personnel data](https://en.wikipedia.org/wiki/Office_of_Personnel_Management_data_breach) have already been exposed.
Health record data will be breached, and it will get ugly.

As a user, how do I prepare for this?
-------------------------------------

- Super important: use different passwords for every service. Password managers help with this, like the free [Keepass](http://keepass.info/) and others.
- Use strong passwords. Or better yet, [passphrases](https://xkcd.com/936/).
- Use [multi-factor authentication](https://www.youtube.com/watch?v=zMabEyrtPRg) where possible.
  [Google Authenticator](https://play.google.com/store/apps/details?id=com.google.android.apps.authenticator2&hl=en) is awesome
  and works for non-Google websites as well!
- Know the risks (= the data might/will get public) when giving personal data to online websites.
- If your software vendor doesn't do things responsibly, ask them for improvements.

As a website operator, how do we prevent this and/or prepare for this?
----------------------------------------------------------------------

- Take your and your users' security and privacy very seriously. Your users deserve better.
- Support HTTPS. Force HTTPS. CloudFlare handles it all for you, or if you don't use CloudFlare
  [SSL certs nowadays are free](https://letsencrypt.org/) anyway. No excuses!
- Don't use company-wide accounts for any sensitive systems. Have each employee have a unique account
  so access can be audited and privileges managed granularly. If this is painful, you are lacking automation.
- Enforce strong and unpredictable passwords for all employees that have access to critical systems. I've witnessed
  first hand companies having systematic (= predictable) master passwords to critical production systems. Even former
  employees knew the new passwords because they knew the formula the passwords were generated with. A huge no-no!!
- There are many [important issues you need to be aware of](https://www.troyhunt.com/everything-you-ever-wanted-to-know/)
  when building a password reset feature (which you probably need if you are handling user accounts).
- Support multi-factor authentication.
- If your team isn't aware of issues like SQL injection, cross-site scripting, CSRF, or are not familiar with issues documented
  in [OWASP top ten](https://www.owasp.org/index.php/Category:OWASP_Top_Ten_Project), you are not being responsible and should not
  be developing software for other people's use.
- Keep your systems up-to-date and patched. Huge issues like [Heartbleed](https://www.troyhunt.com/everything-you-need-to-know-about3/)
  or [Shellshock](https://www.troyhunt.com/everything-you-need-to-know-about2/) pop up and it's your job to follow the changing landscape and react to issues FAST.
  Even keeping up doesn't quarantee immunity: see [zero-day vulnerabilities](https://en.wikipedia.org/wiki/Zero-day_(computing)).
- Implement rate limiting for logins to prevent brute-forcing passwords online. (PBKDF2 et al. sorta fixes this too..)
- Prepare for the inevitable and protect your users' passwords with current best practices.
  [Hash + salt is nearly useless nowadays](https://www.troyhunt.com/our-password-hashing-has-no-clothes/).
  Look into adaptive hashing formulas like [PBKDF2](https://en.wikipedia.org/wiki/PBKDF2).

And most importantly: foster a culture of security in your team. Many companies don't really care, and I hope those
companies go out of business once they lose their reputation - which you can only lose once.

One example of downplaying important issues: SnapChat was warned about a security issue and they called the attack vector
"theoretical". Theory turned into practice and
[4.6 million usernames and phone numbers were exposed](https://haveibeenpwned.com/PwnedWebsites#Snapchat).
SnapChat deserved the hack but the users didn't. Be responsible!
