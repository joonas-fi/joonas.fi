---
layout:     post
title:      'The problem with "cute coding"'
date:       2016-12-30 14:42:00
tags:       ['programming']
---

For lack of a better term, I call this "cute coding":

```
{
	...
	weekdaysShort : 'Sun_Mon_Tue_Wed_Thu_Fri_Sat'.split('_'),
	...
}
```

That is essentially the same as:

```
	weekdaysShort : [ 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat' ],
```

Sure, it's a bit longer BUT:

- It's cleaner, because it's not a hack.
- It does NOT incur runtime performance penalty.
- Intent is 100 % clear, while the "cute" variant **requires you to think and know**
  that `split()` takes in a string and returns an array. Sure, that particular example is not that hard to get,
  but all the tiny cute hacks add up.

Some languages like Ruby even encourage you to have multiple ways of doing the same things by having additional syntax
for cute coding, which in my mind is a disastrous idea.

> "The good thing about standards is that there's so many to choose from".

For example in Ruby you would write the above as:

```
weekdaysShort = [ 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat' ]
```

But Ruby also supports this "cute" syntax as well:

```
weekdaysShort = %w(Sun Mon Tue Wed Thu Fri Sat)
```

Essentially, %w takes in a string and splits it into an array by the whitespace.

The obvious criticism for cute syntax like this is that it destroys the most important aspect of source code:
the readability (and therefore also, maintainability). When a person sees that syntax for the first time,
[she doesn't know what it means](http://stackoverflow.com/questions/1274675/what-does-warray-mean), and might
get so confused that she has to spend time finding out. If you'd just used the first form, I bet everyone'd get it.

Software is already hard enough - please don't make it worse by using clever hacks!
