---
date: "2017-02-20T20:05:00Z"
tags:
- programming
title: Concurrency in Golang and the importance of using locks
url: /2017/02/20/concurrency-in-golang-and-the-importance-of-using-locks/
---

Have this innocent looking code in [Golang](https://golang.org/):

	func incrementWithoutLocking() int {
		counter := 0

		incrementCounter := func(done chan bool) {
			for i := 0; i < 1000000; i++ {
				counter++
			}

			done <- true
		}

		// create a channel to synchronize when both goroutines are finished
		done := make(chan bool)

		// run two goroutines in parallel, both incrementing the shared counter
		go incrementCounter(done)
		go incrementCounter(done)

		// wait for both to finish
		<-done
		<-done

		return counter
	}

Also note, how easy it is to implement concurrency/parallelism
([though they are not the same thing](http://stackoverflow.com/questions/1050222/concurrency-vs-parallelism-what-is-the-difference))
in Golang! :)

Now, observing return values:

	incrementWithoutLocking run #0 = 1104552
	incrementWithoutLocking run #1 = 1012191
	incrementWithoutLocking run #2 = 1033641
	incrementWithoutLocking run #3 = 1096998
	incrementWithoutLocking run #4 = 1031533

2 * 1 000 000 should be 2 000 000 and the return values are seemingly random, so something fishy is going on!

Clearly the integer incrementing (`counter++`) does not get executed on the processor level
as an atomic instruction, but rather it is read-and-written by the processor, and when two
threads are simultaneously doing it, something like this happens:

	thread A: read counter from RAM, value= 10
	thread A: increment by one, 10 + 1 = 11
	thread B: read counter from RAM, value= 10
	thread A: store 11 in RAM
	thread B: increment by one, 10 + 1 = 11  (<-- this should have been 11 + 1 = 12)
	thread B: store 11 in RAM

This is called a [race condition](http://stackoverflow.com/a/34550). This is the simplest and most
obvious form of it, since we can see the counter numbers acting seemingly random and they are
obviously incorrect.

Sadly, in real life race conditions are much easier to accidentally introduce and
really hard to debug.

When we cannot avoid writing code that uses shared mutable state, we need to use locks, meaning
that when we are about to do something that changes the mutable state (including the read), we
surround it with a lock that guarantees that nobody else executes the same computation at the
same time as we do.

Various locking primitives are found in Golang's [sync](https://golang.org/pkg/sync/) package.
The simplest one of them being `Mutex` ("mutual exclusion").

So, our offending code was:

	counter := 0
	
	incrementCounter := func(done chan bool) {
		for i := 0; i < 1000000; i++ {
			counter++
		}
	
		done <- true
	}

Now, let's use a lock by doing these changes:

	counter := 0
	counterLock := sync.Mutex{}
	
	incrementCounter := func(done chan bool) {
		for i := 0; i < 1000000; i++ {
			counterLock.Lock()
			counter++
			counterLock.Unlock()
		}
	
		done <- true
	}

And by running the code again:

	incrementWithLocking run #0 = 2000000
	incrementWithLocking run #1 = 2000000
	incrementWithLocking run #2 = 2000000
	incrementWithLocking run #3 = 2000000
	incrementWithLocking run #4 = 2000000

=> Great success. And it's really rather simple to use!

Full code is here:

	package main
	
	import (
		"fmt"
		"sync"
	)
	
	func incrementWithoutLocking() int {
		counter := 0
	
		incrementCounter := func(done chan bool) {
			for i := 0; i < 1000000; i++ {
				counter++
			}
	
			done <- true
		}
	
		// create a channel to synchronize when both goroutines are finished
		done := make(chan bool)
	
		go incrementCounter(done)
		go incrementCounter(done)
	
		<-done
		<-done
	
		return counter
	}
	
	func incrementWithLocking() int {
		counter := 0
		counterLock := sync.Mutex{}
	
		incrementCounter := func(done chan bool) {
			for i := 0; i < 1000000; i++ {
				counterLock.Lock()
				counter++
				counterLock.Unlock()
			}
	
			done <- true
		}
	
		// create a channel to synchronize when both goroutines are finished
		done := make(chan bool)
	
		go incrementCounter(done)
		go incrementCounter(done)
	
		<-done
		<-done
	
		return counter
	}
	
	func main() {
		for i := 0; i < 5; i++ {
			fmt.Printf("incrementWithoutLocking run #%d = %d\n", i, incrementWithoutLocking())
		}
	
		for i := 0; i < 5; i++ {
			fmt.Printf("incrementWithLocking run #%d = %d\n", i, incrementWithLocking())
		}
	}
