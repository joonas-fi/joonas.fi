---
layout:     post
title:      'Chaining should be an operator in the language itself'
date:       2018-10-05 11:45:00
tags:       ['programming']
permalink:  /2018/10/05/chaining-should-be-an-operator-in-the-language-itself/
---

What is chaining?
-----------------

jQuery at least popularized this pattern:

	$('.someElement')
		.attr('title', 'Changing some title')
		.text('here is content for you')
		.on('click', () => { alert('clicked'); });

The above code could also be written like this:

	$('.someElement').attr('title', 'Changing some title');
	$('.someElement').text('here is content for you')
	$('.someElement').on('click', () => { alert('clicked'); });

	// or to not query DOM multiple times, save the reference in a variable:

	const el = $('.someElement');
	el.attr(...);
	el.text(...);
	el.on(...);

So the chaining pattern is essentially just for making code shorter/prettier by not having to
repeat the subject of the multiple operations that we're doing.

If you'd take a look at the definition of that `attr()`, it'd look something like this:

	jqueryset.prototype.attr = function (key, value) {
		// ... here some actual stuff related changing element attribute

		return this; // this is required to enable chaining
	};


The problem
-----------

There are downsides to this:

- Each function has to explicitly support chaining. If you want to use chaining and the
  function doesn't return anything, you have to go add `return this` first.
- This means that you cannot change the function in the future to actually return something
  important (like event listener count in the `on()` example), since the return value is
  now explicitly reserved for chaining.
- This is not semantic. Seeing function signature to return same type as the instance it was
  called on does not directly tell you if it's for chaining, or if it for example makes an
  another instance of the same type (think clone-type functions or copy constructors)

There are actually security issues with this approach. E.g. jQuery's
[text()](http://api.jquery.com/text/) is two different APIs:

- Get text, if called without arguments
- Set text, if called with arguments

That might make for pretty code, but it's a dangerous design decision. Since in JavaScript there
is no distinction between `function argument not given` vs. `value that is simply undefined`,
this can happen:

	const textFromSomewhere = fetchText();
	
	const elementCount = $('.someElement')
		.text(textFromSomewhere)
		.length;
	
	console.log('Count of .someElement in page:', elementCount);

jQuery's `.length` reports count of elements that were found (in this case with selector `.someElement`).
But what happens is if `fetchText()` returns `undefined` for some reason? Since you end up calling
`.text(undefined)`, semantics of `text()` changes to getter (instead of setter) and you'll be
returned a string with text from the DOM element. If the DOM element contained `foo` as text,
due to chaining you will end up calling `"foo".length` which makes your code think there were
three `.someElement` in the page, which clearly was not your intent.

Are you really comfortable with code whose functionality accidentally changes, if you and
everybody in your team at coding time don't exactly know when `undefined` can happen and
how these caveats trigger?

There was actually a problem at work with one project related to this, so this is not a
theoretical issue. The security issues are not limited to the harmless example I gave you.
In reality your program can unexpectedly crash or at worst it could be an attack vector.


The solution
------------

As suggested in the title of this post, the chaining operator should be at the language level.
Just as a though exercice, the operator could look like this:

	$('.someElement')
		| .attr('title', 'Changing some title')
		| .text('here is content for you')
		| .on('click', () => { alert('clicked'); });

This could be easily under the covers rewritten by the compiler to this form:

	const _chain = $('.someElement')
	_chain.attr('title', 'Changing some title')
	_chain.text('here is content for you')
	_chain.on('click', () => { alert('clicked'); });

This would fix all the downsides:

- Chaining support need not be implemented in every function you want to use chaining with
- Function's return value is not reserved for chaining use
- Code is more semantic, since `on(event: string, listener: function): void` type functions
  can remain `void` instead of confusing return type just for chaining purpose
- No security issues. You can see that the compiler-rewritten version is safe from the security
  issue I previously described. You would not accidentally call `.length` on the wrong object
