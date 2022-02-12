---
title: "Programming pattern for ensuring a function is called as root"
tags:
- programming
date: 2022-02-12T14:55:49Z
---

I have recently been writing system-level software that needed many steps with filesystem mounting
etc. - things you generally need to do as root.

For security I wanted to make the program enter root only for the steps that actually need it.


Starting situation
------------------

In pseudo it started like this:

```go
func logic() error {
	mountFoo()

	mountBar()

	return nil
}

func mountFoo() {
	dropPrivileges := enterRoot()
	defer dropPrivileges() // drops privileges when this function is done

	// do stuff
}

func mountBar() {
	dropPrivileges := enterRoot()
	defer dropPrivileges() // drops privileges when this function is done

	// do stuff
}
```

Now when I had to string multiple root-requiring things together, it became repetitive to inside the
function enter root and leave root, just for that to happen right next again.

If we forget performance impact of unnecessary switching, I also had cases where sometimes a
root-requiring function would call another function that required root, but it had two callsites with
the first already being root and the other not being root, so I was left with problem where the code
would do nested root entering-and-leaving (which would not work).

So I *had to* refactor the functions to do the root entering outside.


Refactoring brought a new issue
-------------------------------

After refactoring:

```go
func logic() error {
	dropPrivileges := enterRoot()
	defer dropPrivileges() // drops privileges when this function is done

	mountFoo()

	mountBar()

	return nil
}

// NOTE: need to be called with root
func mountFoo() {
	// do stuff
}

// NOTE: need to be called with root
func mountBar() {
	// do stuff
}
```

But then I was left with the question, what if some other place calls `mountBar()`  that hasn't
entered root? Just relying on a code comment documenting the process privilege state is ugly.


Solution
--------

I had a thought: what if you could use the programming language's type system to ensure to the
function that the privilege state is what it should be.

Let's introduce an opaque token that you can pass to the function to "prove" that we're running in a
required context:

```go
func logic() error {
	privilegeProof, dropPrivileges := enterRoot()
	defer dropPrivileges() // drops privileges when this function is done

	mountFoo(privilegeProof)

	mountBar(privilegeProof)

	return nil
}

// _ because we don't need to do anything with the token. we just want the compiler
// to ensure that one is given.
func mountFoo(_ privilegeProofToken) {
	// do stuff
}

func mountBar(_ privilegeProofToken) {
	// do stuff
}

// an opaque token, type system -level hack to pass proof that we've entered root
type privilegeProofToken struct {}

func enterRoot() (privilegeProofToken, func ()) {
	// FIXME: logic for entering root here

	return privilegeProofToken{}, func() {
		// FIXME: logic for leaving root here
	}
}
```


Caveats
-------

This has nothing to do with security or "hard proofs".
A programmer could just construct the token herself while not actually being root and fool the
function that we call.
This pattern is to just make it harder to accidentally mess up.

Another caveat is that the proof token and privilege enter -> privilege drop lifecycles are coupled
to each other, and you've to just trust the programmer to not use the "proof token" after
`dropPrivileges()` is called.

E.g. returning `privilegeProof` from `logic()` function to the caller would be a mistake, because
`dropPrivileges()` has (in spirit only, unfortunately) already invalidated the proof token.

But if you are aware of the caveats and use it as intended (like in the code example), it shouldn't
be easy to make mistakes and now you've got the compiler to remind you if you've not satisfied the
preconditions for the function to succeed.


Generalizing the pattern
------------------------

By now you probably realize that this pattern can be generalized to also pass other types of proofs.

Some examples follow.


### Available file space check

Let's say that you're writing an installer function that requires that there must be 2 GB of available space
in the partition, and you don't want to check that requirement inside the function (the check has
been done by the caller), so you can use this pattern to pass any kind of "proof" to the installer
function to "ensure" that the space check has been called before.


### Not running as root

Token to prove to the called function that we've checked that we are **not** root: a program that
needs to be ran with user-only privileges. Check not-root once, pass proof to multiple functions.


### Dependency exists -check

Token to prove that we have checked that a dependency exists. For example you're shelling out to
`$ docker` CLI calls, and you've got multiple functions like:

- `dockerPull(image string, _ dockerExistsToken)` and
- `dockerRun(image string, _ dockerExistsToken)`

On your program start you check the Docker existence once, and display really helpful error message
saying "Docker needs to be installed" instead of ugly error message from bowels of `dockerPull`
saying something like `bash: docker: command not found`.

Now just pass the Docker exists token to the Docker-using functions to prove that you've handled the
"missing" case gracefully at your entrypoint.
