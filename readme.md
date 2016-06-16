What
====

This is source code for my [personal blog](https://joonas.fi/), powered by Jekyll.

It gets built as a static site, shoved inside a Docker image with a bare static HTTP server.

Dev mode
========

For testing the content before making an actual build:

	$ docker run --rm -it -v "$(pwd):/project" -e VIRTUAL_HOST=joonas-blog.dev-laptop.xs.fi -p 8080 joonas/jekyll-builder:0.1.0 jekyll serve -H 0.0.0.0 -P 8080 --source /project/blog/ --destination /tmp

Assuming you have configured nginx-proxy, the blog is now previewable at host "joonas-blog.dev-laptop.xs.fi".

nginx-proxy
===========

This is about how you would run nginx-proxy:

	$ docker run -d -p 80:80 -v /var/run/docker.sock:/tmp/docker.sock:ro jwilder/nginx-proxy
