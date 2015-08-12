---
layout: post
title: What are the best-kept secrets of great programmers?
date: '2014-09-28T13:40:56+00:00'
tags: ['programming']
tumblr_url: http://joonas-fi.tumblr.com/post/98624571927/what-are-the-best-kept-secrets-of-great
---

Quora: [What are the best-kept secrets of great programmers?](http://www.quora.com/What-are-the-best-kept-secrets-of-great-programmers)

- Most of the time, using inheritance is a bad object oriented design in the long run. It reduces reusability and testability of code. Consider using interfaces instead. See [No, inheritance is not the way to achieve code reuse!](http://littletutorials.com/2008/06/23/inheritance-not-for-code-reuse/). Related;
- Avoid introducing an interface until you are comfortable in your domain. "Premature interfacing" can also lead to design issues down the road.
- Deep nested code (both intra-function and inter-function) is 1) harder to maintain, 2) more prone to bugs and 3) harder to reuse. Shallow code hierarchies generally makes a better foundation for reuse and testing. See note about inheritance above.
- Estimating time is _hard_. One reason why Scrum and sprints are used in many places.
- Proper encryption is _hard_. Don't invent it yourself unless you have a good reason to.
- Side-effect free logic is nice. It makes it easier to reason about state (see below) and generally simplifies automated testing.
- Learn to reason around state and lifecycles. See [Jens Rantil's Hideout](http://jensrantil.github.io/im-a-state-engineer-are-you-too.html).
- Concurrency can be _hard_ without the right primitives. Threadpools, Queues, Observables, and actors can sometimes help a lot.
- Premature optimization is the root of all evil. A good general development process is: 1) Get it to work. 2) Make the code beautiful. 3) Optimize.
- Know your basic data structures and understand time complexity. It's an effective way of making your code much faster without adding complexity.
- Practise back-of-the-envelope calculations. How many items will a piece of code generally hold in memory?
- Write code as you want to read it. Add comments where you think you will not understand your code in a year's time. You will need the comment in a month. Somewhat related;
- Setup you build tooling around a project so that it's easy to get started. Document the (few) commands needed to build, run, test and package in a README file.
- Making sure your projects can build from command line makes things so much easier down the road.
- Handling 3rd party dependencies in many languages can be a real mess (looking at you Java and Python). Specifically when two different libraries depend on different versions. Some key things to take away from this: 1) Constantly question your dependencies. 2) Automated tests can help against this. 3) Always fixate which version of a 3rd party dependency you should use.
- Popular Open Source projects are a great way to learn about good maintainable code and software development process.
- Every single line you add to an application adds complexity and makes it more likely to have bugs. Removing code is a great way to remove bugs.
- Code paths that handles failures are rarely tested/executed (for a reason). This makes them a good candidate for bugs.
- Input validation is not just useful for security reasons. It helps you catch bugs early.
- Somewhat related to above: State validation and output validation can be equally useful as input validation, both in terms of discovering inherent bugs, but also for security sensitive code.
- Code reviews are a great way to improve as a programmer. You will get critique on your code, and you will learn to describe in words why someone else's code is good or bad. It also trains you to discover common mistakes.
- Learning a new programming language is a great way to learn about new paradigms and question old habits.
- _Always_ specify encoding when converting text to and from bytes; be it when reading/writing to network, file or for encryption purposes. If you rely on your locale's character set you are bound to run into data corruption eventually. Use a UTF character set if you can get to choose yourself.
- Know your tools; That includes your editor, the terminal, version control system (such as git) and build tooling.
- Learn to use your tools without a mouse. Learn as many keyboard shortcuts as possible. It will make you more efficient and is generally more ergonomic.
- Reusing code is not an end goal and will not make your code more maintainable per se. Reuse complicated code and be aware that reusing code between two different domains might make them depend on each other more than necessary.
- Sitting for long time by the computer can break your body. 1) Listen to what your body has to say. Think extra about your back, neck and wrists. Take breaks if your body starts to hurt. Creating a pause habit (making tea, grabing coffee) can surprisingly be good for your body and mind. 2) Rest your eyes from time to time by looking away from your screen. 3) Get a good keyboard without awkward wrist movements.
- Automated testing, and in particular unit tests, are not just testing that your code does was it should. They also 1) document how the code is supposed to be used and 2) also helps you put yourself in the shoes of someone who will be using the code. The latter is why some claim test-first approach to development can yield cleaner APIs.
- Test what needs to be tested. Undertesting can slow you down because of bug hunting. Overtesting can slow you down because every change requires updating too many tests.
- Dynamic languages generally need more testing to assert they work properly than compiled languages. (Offline code analysis tools can also help.)
- Race conditions are surprisingly more common than one generally thinks. This is because a computer generally has more TPS than we are used to.
- Understanding the relationship between throughput and latency ([http://en.m.wikipedia.org/wiki/L...](http://en.m.wikipedia.org/wiki/Little%27s_law)) can be very useful when your systems are being optimized. Related;
- Many times high throughput can be achieved by introducing smart batching.
- Commit your code in small, working, chunks.
- Keep your version control system's branches short-lived. My experience is that risk of failures increases exponentially the longer a branch lives. Avoid working on a branch for more than two weeks. For large features, break them into multiple refactoring branches to make the feature easier to implement in a few commits.
- Know your production environment and think about deployment strategies for your change as early as possible.
- Surprisingly, shipping code more frequently tends to _reduce_ risk, not increase it.
- Learning an object oriented language is easy. Mastering good object oriented design is hard. Knowing about [https://en.m.wikipedia.org/wiki/...](https://en.m.wikipedia.org/wiki/SOLID_(object-oriented_design)) and object-oriented [https://sv.m.wikipedia.org/wiki/...](https://sv.m.wikipedia.org/wiki/Design_Patterns) will improve your understanding of OO design.
- It's possible to write crappy code in a well architected system. However, in a well architected system you know that the crap is isolated and easily replaceable. Focus on a sane decoupled architecture first. The rest can be cleaned up later if on a tight schedule.
