---
layout:     post
title:      'Go is not a simple language'
date:       2020-02-24 11:37:00
tags:       ['programming']
---

I still love Go and it's the best language I've used - but like in mature relationships,
I've aware of both the good and bad parts of the relationship.

Go is still, compared to many popular languages, **simpler** language - but many times
when people claim Go is a simple language what is being implied is that Go is minimalistic &
it scoffs at unnecessary features.

This post is about where Go fails at minimalism. I.e. these are features I think a truly
"simple" language should not have.

Note: I'm actually for Go to add generics, pattern matching enums and not a hardcore
"Go should be simple" -type of person. So I'm not advocating for Go to be hardcore simple -
these are mainly my observations for:

- where Go could have been simpler
- OR where said feature is totally reasonable, but is necessarily not *simple* or easy to
  understand

I've had this article as a draft for quite some time, but
[yesterday's post of Dave Cheney's](https://dave.cheney.net/2020/02/23/the-zen-of-go)
prompted me to finally finish this, probably due to these quotes:

> Go holds simplicity as a core value.
> (...)
> Go is a simple language, only 25 keywords.
> (...)
> We want to optimise our code to be clear to the reader.


Contents:

- [Package import path different than package name](#package-import-path-different-than-package-name)
- [`func foo(a, b, c string)`](#func-fooa-b-c-string)
- [`goto <label>` (and `break <label>`) support](#goto-label-and-break-label-support)
- [`new` keyword](#new-keyword)
- [Naked return](#naked-return)
- [Octal number support](#octal-number-support)
- [Recent number literal addition](#recent-number-literal-addition)
- [Language-level support for side-effect imports](#language-level-support-for-side-effect-imports)
- [`import . "something"`](#import--something)
- [Easy to make mistakes with range pointers](#easy-to-make-mistakes-with-range-pointers)
- [Conditional compilation syntax](#conditional-compilation-syntax)
- [`defer` behaviour](#defer-behaviour)
- [Typed vs untyped nil](#typed-vs-untyped-nil)
- [Semi-unstructured struct member annotations](#semi-unstructured-struct-member-annotations)
- [`var` keyword](#var-keyword)
- [Other idiosyncrasies in stdlib](#other-idiosyncrasies-in-stdlib)
  * [Leave hard security details to callers](#leave-hard-security-details-to-callers)
  * [Stdlib encourages for global state / side effects](#stdlib-encourages-for-global-state--side-effects)
  * [net/http package defaults](#nethttp-package-defaults)
  * [Non-POSIX compliant flag package](#non-posix-compliant-flag-package)
- [Conclusion](#conclusion)


Package import path different than package name
-----------------------------------------------

Most of the time it goes like this:

	import (
		"github.com/function61/gokit/systemdinstaller"
		"github.com/joonas-fi/modemrebooter/pkg/internetupdetector"
	)
	
	func main() {
		systemdinstaller.Install()
		internetupdetector.Up()
	}

You can deduce the package name from the import path. E.g. `import "foo/bar/systemdinstaller"`
is usually `systemdinstaller`.

BUT, it's only usually - not always.

This behaviour is really prevalent. Guess the names of these packages:

	import (
		"github.com/microsoft/go-winio"
		"github.com/nsf/termbox-go"
		"google.golang.org/api/drive/v3"
	)
	
	func main() {
		// correct answers
		winio.DialPipe()
		termbox.Init()
		drive.NewService()
	}

Note: I am not complaining about the ability to alias the import (there needs to be a way
to mitigate collisions) - that's a different matter. I'm just saying there shouldn't be a
way for reusable package authors to export a different name than the import path is.


`func foo(a, b, c string)`
--------------------------

Yeah it's fast to type when all of the params have the same type, but this it somewhat
rarely used magic syntax that one has to be aware of when reading code.

It's cute, sure - I've even used it many times, out of laziness, despite feeling like I
need to take a shower after typing that out.

But I don't think the feature carries its own weight.


`goto <label>` (and `break <label>`) support
--------------------------------------------

See [example use case](https://stackoverflow.com/a/11105482/2176740).

I've cranked out a metric shit-ton of Go code (see my
[professional GitHub profile](https://github.com/function61) and my
[personal GitHub profile](https://github.com/joonas-fi)), and not once have I needed to
reach out for `goto` or labeled `break`.

The closest I've come to needing those was to break out of `for { select { } }`
[here](https://twitter.com/joonas_fi/status/1230771329294405634) but instead I opted for a
`return` inside an immediately-executing function expression.

I also could have opted in for a simple variable but it would have been a few more lines of
code.

Bonus reading:
[Dijkstra on GOTO](https://homepages.cwi.nl/~storm/teaching/reader/Dijkstra68.pdf).


`new` keyword
-------------

Another keyword I don't think I've used even once.

These are basically the same:

	struct personGreeter {
		name string
	}
	
	func main() {
		bar1 := &personGreeter{}
		bar2 := new(personGreeter)
	}

Why two ways to do the same thing?

`new` is even inferior because you can't initialize members at the same time like this:

	bar1 := &personGreeter{name: "Joonas"}


Naked return
------------

This sounds sexy, but it's not. This is another one of those features that don't carry
its own weight.

Example usage from
[Ardan Labs](https://www.ardanlabs.com/blog/2013/10/functions-and-naked-returns-in-go.html):

	func ReturnId() (id int, err error) {
	   id = 10
	
	   if id == 10 {
	      err := fmt.Errorf("Invalid Id\n")
	      return
	   }
	
	   return
	}

That is the same as:

	func ReturnId() (int, error) {
	   id := 10
	
	   if id == 10 {
	      // actually this is even better, since our error case
	      // returns explicit "garbage ID" (instead of 10)
	      return 0, fmt.Errorf("Invalid Id\n")
	   }
	
	   return id, nil
	}

Also note, that we are no longer reassigning to "id" variable. One nice thing about Go
that I like is that you've to be explicit about reassigning values to variables (`:=` vs `=`).
Immutability makes things safer and simpler. Immutability is sexy. Naked returns are not.

I always read `id = ...` as a bit dangerous looking, since it warns me that the value of the
variable is different during its lifetime. The original example was under the hood more
like this:

	func ReturnId() (id int, err error) {
	   var id int // basically id := 0
	   id = 10
	
	   if id == 10 {
	      err := fmt.Errorf("Invalid Id\n")
	      return
	   }
	
	   return
	}

Now of course this example still doesn't look too dangerous, but imagine in real world
code there could be lots of lines before the `id = 10` is reassigned.


Octal number support
--------------------

This might look familiar:

	ioutil.WriteFile("hello.txt", []byte("hello world\n"), 0755)

Numbers starting with `0<more digits>` are octal numbers. Basically it encodes three bits
in a one (base 10) digit.

I personally haven't seen octal numbers used for anything else than "chmod bits" i.e.
owner bits + group bits + other bits. `0755` therefore decodes to:

- Owner = `read`, `write`, `execute`
- Group = `read`, `execute`
- Other = `read`, `execute`

Since the "chmod bit groups" is just a single `int` under the hood, why not just have a
function for generating the int? Something like
`func FilePerms(owner uint8, group uint8, other uint8) int` that you could still call like
this:

	FilePerms(7,5,5) // looks familiar enough

	// or even:
	FilePerms(RWX, RX, RX)

I'm sounding like a broken record, but... this feature doesn't carry its own weight.


Recent number literal addition
------------------------------

[A new proposal landed](https://golang.org/doc/go1.13#language) that:

- Expands the octal number support from `0755` to also include `0o755` (also `0o7_5_5` because YOLO?)

- Allows you two write `1000000` as `1_000_000`

  * Not necessarily a bad thing for readability, though

- Added binary literals: `0b1000` (8 in decimal). Also `0b1_0_0_0`

- Makes this a legal number: `0x_A_A.d_bp8i` (hat tip: [Francesc Campoy](https://youtu.be/0c-1KJwSMCw?t=106))

All in all, these make the language more complex and not simple, but I mainly criticize
adding more support to octal numbers.

I think adding complexity is very ok if the feature carries its own weight.


Language-level support for side-effect imports
----------------------------------------------

Go compiler errors if you import a package you're not explicitly using (I think this is
very good). This means though that you cannot compile code that imports a package only for
side effects, unless you use a special syntax to tell the compiler "yes, this is what I
want". This is the syntax: `import _ "path/to/module"`.

I get that side effects can be useful sometimes.. But side effects are used somewhat widely
often in Go's stdlib (more of this later). This looks like the language gives first-class
support for doing something that should be frowned upon. I think there just could've been
a warning suppression through an annotation syntax or a more shameful keyword like
`import _side_effects "path/to/module"` :D.


`import . "something"`
----------------------

This will import all of package's identifiers so intead of `something.Foo` you can just
use `Foo`.

I don't know of any code that uses this, and in fact I learned of this just today. This
kind of magic makes it harder for people to read code because you've to know all of the
syntax's intricacies to understand. Code should be optimized for reading.


Easy to make mistakes with range pointers
-----------------------------------------

Honestly, this is a rookie level mistake but I'll confess that even after years of Go
coding, I got bitten by this and I realize it's embarrassing because this is a pretty basic
programming language thing and I should have known better.

But, I still wish the language didn't allow me to make the mistake. A demo:

	// takes a non-pointer string, and returns a pointer to it
	func stringToStringPointer(input string) *string { return &input }
	
	func main() {
		ptrs1 := []*string{}
		ptrs2 := []*string{}
	
		for _, x := range []string{"foo", "bar"} {
			// since we need to take pointer from "x",
			// it's clearly a non-pointer?
			ptrs1 = append(ptrs1, &x)
	
			// also non-pointer because we can give "x"
			// to non-pointer arg in fn as-is?
			ptrs2 = append(ptrs2, stringToStringPointer(x))
		}
	
		fmt.Printf("ptrs1[0] = %s\n", *ptrs1[0])
		fmt.Printf("ptrs1[1] = %s\n", *ptrs1[1])
	
		fmt.Printf("ptrs2[0] = %s\n", *ptrs2[0])
		fmt.Printf("ptrs2[1] = %s\n", *ptrs2[1])
	}

This prints out:

	ptrs1[0] = bar
	ptrs1[1] = bar
	ptrs2[0] = foo
	ptrs2[1] = bar

Because you have to be aware, that even when "x" looks and behaves like a non-pointer,
it's a pointer under the hood (presumably for optimization for `range` operations)

I had an actual issue related to this, producing a hard-to-debug problem, but I'm glad I was
able to find a lint rule for it.


Conditional compilation syntax
------------------------------

This works:

	// +build !windows
	
	package sshagent

This is silently ignored (tries to build on Windows):

	// +build !windows
	package sshagent

Also this is ignored:

	//+build !windows
	package sshagent

To be fair, static analysis tool `$ go vet` finds both of these errors. But not this:

	//build !windows
	package sshagent

If the syntax is as unstructured as this ("structure inside unstructured comment"), I'd
appreciate if mistakes were not this easy to make.


`defer` behaviour
-----------------

`defer` is used as kind-of (from other languages) `with () {}` or `finally {}` structure
for all kinds of "ensure cleanup no matter where from I exit in this function":

- Close opened file
- Rollback DB transaction
- Unlock mutex etc.

I have nothing against `defer`. But I'll argue it's not simple you having to be aware of
these caveats:

	func say(stuff string) {
		fmt.Println(stuff)
	}
	
	func main() {
		defer say("msg 1")
		defer say("msg 2")
	}

Prints `msg 2` first. Also, can you spot the bug:

	func logic1(tx *transaction) error {
		defer tx.Rollback()
	
		tx.Execute("UPDATE users SET ...")
		return tx.Commit()
	}
	
	func logic2(tx *transaction) {
		// add error logging if rollback fails
		defer logIfError(tx.Rollback())
	
		tx.Execute("UPDATE users SET ...")
		return tx.Commit()
	}
	
	func logIfError(err error) {
		if err != nil {
			log.Printf("ERROR: %v", err)
		}
	}

Only in `logic2` the transaction is rolled back, before the `tx.Execute()` call.


Typed vs untyped nil
--------------------

Guess what this outputs:

	type Greeter interface {
		Greet()
	}
	
	type helloer struct {}
	func (h *helloer) Greet() { fmt.Println("hello") }
	
	func newGreeter1() Greeter {
		var x *helloer
		return x
	}
	
	func newGreeter2() *helloer {
		var x *helloer
		return x
	}
	
	func newGreeter3() Greeter {
		var x Greeter
		return x
	}
	
	func main() {
		// all of the greeters sematically return nil and something that implements Greeter
		fmt.Printf("newGreeter1 nil: %v\n", newGreeter1() == nil)
		fmt.Printf("newGreeter2 nil: %v\n", newGreeter2() == nil)
		fmt.Printf("newGreeter3 nil: %v\n", newGreeter3() == nil)
	}

It outputs:

	newGreeter1 nil: false
	newGreeter2 nil: true
	newGreeter3 nil: true

More about this on [Dave Cheney's post](https://dave.cheney.net/2017/08/09/typed-nils-in-go-2)

One has to
[reach for reflection to detect nil in all cases](https://stackoverflow.com/questions/13476349/check-for-nil-and-nil-interface-in-go).

In real world code I had a case like this recently that crashed at runtime:

	// should have been:
	//   var transport http.RoundTripper
	var transport *http.Transport 
	if true { // this expression was of course dynamicin my code
		transport = &http.Transport{
			TLSClientConfig: &tls.Config{
				ServerName: "foo",
			},
		}
	}
	return &backend{&httputil.ReverseProxy{
		Transport: transport,

`RoundTripper` is an interface, and `*http.Transport` is its concrete implementation.
`ReverseProxy` takes `RoundTripper` but I gave it `*http.Transport` - it compiles and
everything should be good, right? No, it crashed at runtime because the type of my
fucking `var` was nil and not *typed nil*. (╯°□°)╯︵ ┻━┻ 


Semi-unstructured struct member annotations
-------------------------------------------

To encode a struct as JSON, we can control the key name in JSON with a struct member annotation:

	type person struct {
		Name string `json:"name"`
	}
	
	func main() {
		asJson, _ := json.Marshal(&person{Name: "Joonas"})
		fmt.Printf("%s\n", asJson)
	}

Prints `{"name":"Joonas"}` - this is what we wanted.

What if you forget quotes from the annotation?

	type person struct {
		Name string `json:name`
	}

It builds and JSON now incorrectly prints `{"Name":"Joonas"}`. To be fair, even though the
compiler is happy, Go's static analysis tool `$ go vet` finds this error.

How about a typo in the annotation:

	type person struct {
		Name string `jon:"name"`
	}

The compiler and static analysis are happy, with incorrect result.

How about other annotations given to JSON encoder?

	type person struct {
		Name       string `json:"name"`
		Occupation string `json:"occupation"`
	}
	
	func main() {
		asJson, _ := json.Marshal(&person{Name: "Joonas"})
		fmt.Printf("%s\n", asJson)
	}

Prints `{"name":"Joonas","occupation":""}`. What if we want the `occupation` key to be
omitted if the value is empty? This is know as `omitempty` flag to JSON encoder:

	type person struct {
		Name       string `json:"name"`
		Occupation string `json:"occupation,omitempty"`
	}

Now correctly prints `{"name":"Joonas"}`. What if we typo it:

	type person struct {
		Name       string `json:"name"`
		Occupation string `json:"occupation,omltempty"`
	}

Incorrectly prints `{"name":"Joonas"}` while the compiler and static alazyer are happy.

My gripe is that the annotations are not structural enough to prevent easy mistakes.


`var` keyword
-------------

I find needing this somewhat rarely. The common reason I need it for is to have a nil pointer:

	var x *MyStruct

Honestly, I was debating on including this because I know it's stupid to criticize without
offering solutions. I'm not smart enough to say how nil pointers could have been implemented
in other way, but it's just my observation that I need `var` rarely and it has always felt
weird to me.

The other place `var` is needed for is package-level variables - i.e. global mutable state.
A point could be made about globals (and Go's stdlib uses too much of it - more on this later)
but pragmatically speaking I get that it's good in moderation.


Other idiosyncrasies in stdlib
------------------------------

### Leave hard security details to callers

Why am I talking about issues in stdlib? One could argue this is no longer about
programming language itself? Fair point, but I think language's standard library is
somewhat part of the language - at least an integral part to its ecosystem. And the stdlib
should be a good example for the ecosystem to follow. Quote from Dave's article:

> APIs should be easy to use and hard to misuse.

I recently came upon a really popular file archiver/compression/decompression Go-based project
that had (and still has) a serious
[path traversal vulnerability](https://snyk.io/research/zip-slip-vulnerability).

Upon digging, I found from Go's `archive/zip` docs that the responsibility is
[just outsourced to the caller](https://pkg.go.dev/archive/zip?tab=doc#FileHeader) -
leading to vulnerable software because the API is easy to misuse **dangerously** (the
vulnerability can usually easily be used to gain remote access):

> When reading zip files, the Name field is populated from the zip file directly and is
> not validated for correctness. It is the caller's responsibility to sanitize it as
> appropriate, including canonicalizing slash directions, validating that paths are relative,
> and preventing path traversal through filenames ("../../../").

To make matters worse, [archive/tar](https://pkg.go.dev/archive/tar) doesn't warn of this
security issue (consistency), leaving some - including me, to deduce `archive/tar` maybe
doesn't suffer from this issue. But `archive/tar` is vulnerable too.

What could have been done better? Path traversal below root of the archive is almost
always a red flag and probably is needed in 0.01 % of the cases. "But in some cases
you need unsanitized low-level access to the archive"? There could have been a flag for
those cases, think:

	zip.NewReader(file, zip.DontErrorOnInsecurePathTraversal)

Or if the problem's much harder, at least the file's `Name` string could have been of a
different type like `type TaintedFilepath string` that you'd have to un-taint by piping it
through stdlib or 3rd party provided function. And if you really wanted "safety=off" just
cast it to string.


### Stdlib encourages for global state / side effects

A few from top of my head:

- Importing [net/http/pprof](https://godoc.org/net/http/pprof) attaches HTTP handlers
- `image.Decode()` can open PNG files if any of your packages (or your dependencies) has
  imported (at least for side effect) `image/png` etc.
- `net/http` has a default router (`net/http.DefaultServeMux`) that any code can attach
  handlers to via side effects (I mention `pprof` again), and code examples in `net/http`
  encourage use of this global default router.


### net/http package defaults

- Not common-case defaults
	* [No boilerplate-free support](https://github.com/function61/gokit/blob/c2d99cc8b9622b1365b86d5579af307c329bf349/ezhttp/ezhttp.go#L112)
	  for `context` (= cancellation)
	* Doesn't give error for error responses (only errors for transport-level errors)
	* Common cases could've been handled and for low-level cases there
	  [could'be been an opt-in](https://github.com/function61/gokit/blob/c2d99cc8b9622b1365b86d5579af307c329bf349/ezhttp/ezhttp_test.go#L122)
- Though I understand, the package is older part of the codebase and must keep backwards compat 
	* In this regard, the package has aged amazingly well (gaining transparent HTTP2 support etc.)


### Non-POSIX compliant flag package

I really wanted to love the [flag](https://pkg.go.dev/flag?tab=doc) package since I
believe it benefits the entire ecosystem to have one quality package everyone agrees to use
so there's not 10 competing implementations everyone has to spend time researching and
[vetting](https://www.agwa.name/blog/post/always_review_your_dependencies).

But the flag package is just too weird to be loved - it's different than practically every
CLI we're used to. This is what we're used to:

	$ foo --help
	Options:
	  -u, --broker-url string   Broker URL (default "localhost")
	  -c, --client-id string    MQTT Client Id
	  -r, --reticulate bool     Reticulate
	  -s, --splines bool        Splines also
	
	$ foo --broker-url localhost

Instead, the `flag` package makes your CLIs look like:

	$ foo --help
	Options:
	  -broker-url  string
	               Broker URL (default "localhost")
	  -client-id   string
	               MQTT Client Id
	  -reticulate  Reticulate
	  -splines     Splines also

One dash? Sure, it supports `--` also, but it doesn't support having both a short option
and a long option that we're used to. In the first (good) example these are equivalent:

	$ foo --broker-url localhost
	$ foo -u localhost

Also, `flag` doesn't support combining boolean flags. E.g. what we're used to with
extracting TAR archives:

	$ tar -xzf example.tar.gz

	# same as
	$ tar -x -z -f example.tar.gz

	# same as
	$ tar --extract --gzip --file example.tar.gz


Conclusion
----------

No conclusion - I just vomited what I felt could have been simpler. Take it however you will.

Thanks for reading this far. 💖
