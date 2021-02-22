---
date: "2018-12-04T09:30:00Z"
tags:
- programming
title: An idea to fix Go´s logging mess
url: /2018/12/04/an-idea-to-fix-gos-logging-mess/
---

I believe I have came up with an acceptable compromise for the logger mess in Go. This is
an approach that embraces the Unix philosophy of pipes and plaintext streams.

TL;DR: If you want to see the end result as a demo, scroll to the "Demo code" section!

TL;DR 2: The standard `log.Logger` is enough, just use it everywhere as pipes and we'll
compose more on top of it!


Defining the problem
--------------------

The problem: different projects choose different logger implementations
([standard](https://godoc.org/log), [Logrus](https://github.com/sirupsen/logrus),
[glog](https://github.com/golang/glog),
[google/logger](https://github.com/google/logger) etc.), and since none of them share a
common interface, that lead us to situation where different packages you import will use
different logging implementations. I have come across many dependencies where you cannot
suppress their log output. And nobody likes to have multiple logging implementations in
one program (bloat & increased attack surface). Current situation is not good.

This fragmentation is totally understandable, because the
[standard log package](https://godoc.org/log) has many problems:

- No exported interface for competing logger implementations, so all code in the Go
  ecosystem that use the standard logger is coupled to the standard log *implementation*,
  preventing competition and additional features.
- No log levels (debug, info, error etc.)
- No library-level log prefixes. You can have a log prefix but that is shared across your
  entire application. You can have many loggers with their specific prefixes but that
  then you need to configure all of them in one place, and this breaks down once you have
  dependencies of dependencies.
- No outputting logs to something other than `io.Writer`
- No suppressing output from specific libraries/loggers
- No structured logging (some people want to log key/values or JSON)


Proposed fix
------------

Have one standard interface in one's package API
(think `NewYourLibrary(conf YourLibraryConfig, logger *log.Logger)`) that everybody agrees
to. Since it would be too difficult for everybody to agree which one of the available
interfaces should be used, let's use the most idiomatic and conservative choice - the
standard logger.

But what, you said that it has all these problems? Yes it has, but there's a way around
them - just use the logger implementation as a dumb pipe and compose the solutions to the
problems around the pipe!

First, let's learn how to use `log.Logger` as an (log delivery) interface instead of
strictly as the implementation for both the producer (creates log messages) and the
consumer (e.g. writes them to stderr). Since `log.Logger` takes `io.Writer` as its output,
we can write `io.Writer` adapters to capture the log output! The standard logger logs to
`stderr` by default but we can pass the messages anywhere else we want. Here's an
`OutputToAnotherLog` adapter that pushes the output to another logger, so we can build
logger hierarchies:

```go
// pipes Logger's output (io.Writer) into another Logger
func OutputToAnotherLog(another *log.Logger) io.Writer {
	return &anotherLogWriter{another}
}

type anotherLogWriter struct {
	another *log.Logger
}

func (d *anotherLogWriter) Write(msg []byte) (int, error) {
	return len(msg), d.another.Output(2, string(msg))
}
```

Sidenote:

> This is actually somewhat of a hack (that's why I called this approach a compromise),
> but I feel that the net sum is still positive since we all benefit from standardizing on
> `log.Logger` for source-level compatibility while we still get better features!

Why would I want logger hierarchies - that sounds unnecessary? Good question! Short
answer: we want to configure the logging once (preferably in your `main()` or equivalent) -
the root logger, to output somewhere and all other specializations like prefixes or log
levels should observe the same settings no matter how deep in the calling hierarchy the
logger is instantiated - even in a different project's module (dependency of dependency).

This design follows the same hierarchy concept as the
[context package](https://godoc.org/context).

Now that we can have a logger that logs to another logger, we can create a prefix logger
(composability is awesome!):

```go
// Prefix() creates a new Logger whose output is piped to parent logger with a prefix
func Prefix(prefix string, parent *log.Logger) *log.Logger {
	return log.New(OutputToAnotherLog(parent), prefix+" ", 0)
}
```

Note: we are using a new instance of the standard logger to attach the prefix.
This plumbing code is minimal.

The `Prefix` logger is a primitive, that can be again composed to build a `Leveled` logger:

```go
type Leveled struct {
	Debug *log.Logger
	Info  *log.Logger
	Error *log.Logger
}

func Levels(parent *log.Logger) *Leveled {
	return &Leveled{
		Debug: Prefix("[DEBUG]", parent),
		Info:  Prefix("[INFO]", parent),
		Error: Prefix("[ERROR]", parent),
	}
}
```

Now we've introduced quite many concepts without explanation of why they're useful, I know.
Let's jump into demo code to show how all of this actually makes sense!


Demo code
---------

The `logex` ("logging extensions") package we're referring here is on
[GitHub](https://github.com/function61/gokit/tree/master/logex). Disclaimer:
I am not proposing this as production ready, but rather to discuss ideas. That being said,
since the idea revolves around extending the standard logger and passing standard logger
instances, it should not be a reckless idea to use this as-is, because the standard logger
is mature and it works.

Carrying on, the demo app.. it's an application that has these components:

- Server (uses leveled logging)
	* server uses Library A (uses plain logging)
	* server uses Library B (uses leveled logging)
	* server uses Library C (uses badly behaving, non-configurable by caller, logging)
- Client (uses plain logging)
- main function that initializes and runs server and client

Code of `LibraryA`:

```go
type LibraryA struct {
	log *log.Logger
}

func NewLibraryA(logger *log.Logger) *LibraryA {
	return &LibraryA{logger}
}

func (l *LibraryA) Work() {
	l.log.Printf("reticulating %d spline(s)", 13)
}
```

Code of `LibraryB`:

```go
type LibraryB struct {
	log *logex.Leveled
}

func NewLibraryB(log *log.Logger) *LibraryB {
	return &LibraryB{
		log: logex.Levels(log),
	}
}

func (l *LibraryB) Work() {
	err := errors.New("low voltage in flux capacitor")

	l.log.Error.Printf("spline reticulation failed: %v", err)
}
```

Code of `LibraryC`:

```go
type LibraryC struct{}

func NewLibraryC() *LibraryC {
	return &LibraryC{}
}

func (l *LibraryC) Work() {
	log.Println("hurr durr I'm a special snowflake")
}
```

Then the rest of the demo app: server, client and main:

```go
type MyServer struct {
	log  *logex.Leveled
	libA *LibraryA
	libB *LibraryB
	libC *LibraryC
}

func NewMyServer(log *log.Logger) *MyServer {
	return &MyServer{
		log:  logex.Levels(log), // logger used by server
		libA: NewLibraryA(logex.Prefix("LibraryA", log)), // parent always configures its child loggers' prefix
		libB: NewLibraryB(logex.Prefix("LibraryB", log)),
		libC: NewLibraryC(),
	}
}

func (m *MyServer) Run() {
	m.log.Debug.Println("at start of Run()")
	defer m.log.Debug.Println("returning from Run()")

	m.libA.Work()
	m.libB.Work()
	m.libC.Work()

	m.log.Error.Println("not all workers succeeded")
}

type MyClient struct {
	log *log.Logger
}

func (m *MyClient) Run() {
	m.log.Println("ran successfully")
}

func main() {
	rootLogger := log.New(os.Stderr, "", log.LstdFlags)

	// redirect all badly behaving loggers (uses global log.std) to our own log with a prefix
	logex.RedirectGlobalStdLog(logex.Prefix("__GLOBAL", rootLogger))

	server := NewMyServer(logex.Prefix("server", rootLogger))
	server.Run()

	(&MyClient{logex.Prefix("client", rootLogger)}).Run()
}
```

Now let's observe the output:

	2018/12/03 13:32:09 server [DEBUG] at start of Run()
	2018/12/03 13:32:09 server LibraryA reticulating 13 spline(s)
	2018/12/03 13:32:09 server LibraryB [ERROR] spline reticulation failed: low voltage in flux capacitor
	2018/12/03 13:32:09 __GLOBAL hurr durr I'm a special snowflake
	2018/12/03 13:32:09 server [ERROR] not all workers succeeded
	2018/12/03 13:32:09 server [DEBUG] returning from Run()
	2018/12/03 13:32:09 client ran successfully

From above output, the logger hierarchy tells it pretty clearly: Library A and B belongs
to the server.

It'll probably always be a problem, that some badly behaving packages will have non-configurable
log output to `log.std`. If there's only one such package in your project, you can just assume
that all global log calls belong to LibraryC (in our example):

```diff
	 func main() {
	        rootLogger := log.New(os.Stderr, "", log.LstdFlags)

	-       // redirect all badly behaving loggers (uses global log.std) to our own log with a prefix
	-       logex.RedirectGlobalStdLog(logex.Prefix("__GLOBAL", rootLogger))
	+       // LibraryC behaves badly and logs to log.std
	+       logex.RedirectGlobalStdLog(logex.Prefix("server LibraryC", rootLogger))

	        server := NewMyServer(logex.Prefix("server", rootLogger))
	        server.Run()
```

Output would be now:

	2018/12/03 13:32:09 server [DEBUG] at start of Run()
	2018/12/03 13:32:09 server LibraryA reticulating 13 spline(s)
	2018/12/03 13:32:09 server LibraryB [ERROR] spline reticulation failed: low voltage in flux capacitor
	2018/12/03 13:32:09 server LibraryC hurr durr I'm a special snowflake
	2018/12/03 13:32:09 server [ERROR] not all workers succeeded
	2018/12/03 13:32:09 server [DEBUG] returning from Run()
	2018/12/03 13:32:09 client ran successfully

Also to demonstrate configurability better, our root logger config reflects to all log calls in the program:

```diff
	 func main() {
	-       rootLogger := log.New(os.Stderr, "", log.LstdFlags)
	+       // don't use timestamps
	+       rootLogger := log.New(os.Stderr, "", 0)

	        // LibraryC behaves badly and logs to log.std
	        logex.RedirectGlobalStdLog(logex.Prefix("server LibraryC", rootLogger))
```

Output is now:

	server [DEBUG] at start of Run()
	server LibraryA reticulating 13 spline(s)
	server LibraryB [ERROR] spline reticulation failed: low voltage in flux capacitor
	server LibraryC hurr durr I'm a special snowflake
	server [ERROR] not all workers succeeded
	server [DEBUG] returning from Run()
	client ran successfully

What if we want to suppress `LibraryB` output? Just pass a `Discard` logger:

```diff
	        return &MyServer{
	                log:  logex.Levels(log),                          // logger used by server
	                libA: NewLibraryA(logex.Prefix("LibraryA", log)), // parent always configures its child logger's prefix
	-               libB: NewLibraryB(logex.Prefix("LibraryB", log)),
	+               libB: NewLibraryB(logex.Discard),
	                libC: NewLibraryC(),
	        }
	 }
```

Output:

	server [DEBUG] at start of Run()
	server LibraryA reticulating 13 spline(s)
	server LibraryC hurr durr I'm a special snowflake
	server [ERROR] not all workers succeeded
	server [DEBUG] returning from Run()
	client ran successfully

If you're wondering, here's how `logex.Discard` is implemented:

	var Discard = log.New(ioutil.Discard, "", 0)

`ioutil.Discard` basically is `dev/null` but faster (it is `io.Writer` whose `Write()`
does nothing).

Sidenote:

> A well-behaving library should default to a `Discard` logger if its constructor / options
> doesn't specify a non-nil `log.Logger`. This way our code could give `nil` (which is more
> idiomatic Go as the zero value should be meaningful in structs etc.) as the logger to
> suppress the log output.

But what if the logging that we want to discard is from a dependency's dependency, and
we don't have any control over its injected log facility to use `Discard`? What if we want
to filter the logging from `main()` only in some complex way?

In an ideal world, all dependencies would be instantiated from your `main()`, but I know in
reality.. I guess you could use a `regexp` just before the root level logger:

```diff
	 func main() {
	        // don't use timestamps
	-       rootLogger := log.New(os.Stderr, "", 0)
	+       // only log messages from LibraryA or LibraryB
	+       rootLogger := logex.Filter(
	+               regexp.MustCompile("(LibraryA|LibraryC)"),
	+               log.New(os.Stderr, "", 0))

	        // LibraryC behaves badly and logs to log.std
	        logex.RedirectGlobalStdLog(logex.Prefix("server LibraryC", rootLogger))
```

Output:

	server LibraryA reticulating 13 spline(s)
	server LibraryC hurr durr I'm a special snowflake

This filtering idea is similar to [HashiCorp](https://github.com/hashicorp/logutils)'s
idea of injecting a filtering proxy at the `log.std` to filter by log levels.

You might also realize that the regexp idea could also be used to filter by log level. This
was just a quick hack to demonstrate that better solutions could quite easily be implemented.

How about structured logging? Remember, `log.Logger` should be treated pretty much as a dumb
pipe, and higher level abstractions could be built on top of it. Log producer (your library)
and log consumer don't necessarily need to use the exact same concepts. You can internally
derive more fancy loggers like the `Prefix`, `Leveled`, and a fictional `KvLogger`, from
the `log.Logger` that was given to you. Let's change LibraryA a bit:

```go
func NewLibraryA(logger *log.Logger) *LibraryA {
	return &LibraryA{KvLogger(logger)}
}

type LibraryA struct {
	log *kvLogger
}

func (l *LibraryA) Work() {
	l.log.Print(
		"operation", "splineReticulation",
		"splineCount", "13")
}

func KvLogger(logger *log.Logger) *kvLogger {
	return &kvLogger{logger}
}

type kvLogger struct {
	log *log.Logger
}

func (k *kvLogger) Print(kvs ...string) {
	kvLen := len(kvs)

	parts := []string{}

	for i := 0; i < kvLen; i += 2 {
		parts = append(parts, kvs[i]+"="+kvs[i+1])
	}

	k.log.Println(strings.Join(parts, " "))
}
```

And the output:

	server LibraryA operation=splineReticulation splineCount=13
	server LibraryC hurr durr I'm a special snowflake

This post is getting long, but I think you get the idea now.


Recap
-----

Let's see what problems this idea has solved:

- Everybody can standardize on one log interface: ✓
- Log levels: ✓ (extend on top of standard logger)
- Library-level log prefixes: ✓ (consumer - the "parent", of library decides where the
  library logs and what prefix it has)
- Suppressing output from specific loggers: ✓
	* a) well behaving library shouldn't log if given `nil` as `log.Logger`
	* b) pass `Discard` logger for badly behaving ones or
	* c) or filter programmatically from `main` if you don't have any control
- Outputting logs to other than `io.Writer`: ✓ (writing an adapter was demonstrated)
- Structured logging: ✓ (extend on top of standard logger)
- Handling output from misbehaving libraries: ✓ (output can be redirected and re-prefixed)
- Can benefit (add log prefix) to libraries that only use the plain standard logger
  mechanism without any extensions: ✓
	* The library that produces log output via `log.Logger` isn't aware that its output
	is plugged to a fancy pipeline instead of `stderr`

I'd like to hear your thoughts on this in the comments!


Other thoughts
--------------

Many people say "libraries shouldn't log", but I think they say it because of the
mess that we're in, where a library using the standard logger pushes log messages to your
`stderr` *without your consent*. I get it, it's a shitty state we're in, but do you
seriously think complex libraries like [Raft](https://github.com/hashicorp/raft) shouldn't
log? Good luck in troubleshooting when shit goes wrong.

I think if a library benefits from logging, it should log, but only if it lets the user
(who instantiates the library) control all aspects of the logging - it doesn't have to be
complicated.
