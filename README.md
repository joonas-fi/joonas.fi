⬆️ For table of contents, click the above icon

![Build](https://github.com/joonas-fi/joonas.fi-blog/workflows/Build/badge.svg)

What
====

This is source code for my [personal blog](https://joonas.fi/), powered by [Hugo](https://gohugo.io/).

It gets built as a static site that could be hosted anywhere.

Successfull builds yield a GitHub (draft) release, which is signalled to an event bus where
from [Deployer](https://github.com/function61/deployer) automatically deploys it into production.


Dev mode
========

For testing the content before making an actual build, run:

```
$ bob dev
```

Bob will give you pro-tips on previewing.
