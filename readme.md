What
====

This is source code for my [personal blog](https://joonas.fi/), powered by Jekyll.

It gets built as a static site, shoved inside a Docker image with a bare static HTTP server.

Dev mode
========

For testing the content before making an actual build, run:

	$ ./preview.sh
	Hit this URL in your momma's browser: joonas-blog.dev-laptop.xs.fi
	...

Assuming you have configured nginx-proxy, the blog is now previewable at the mentioned URL.

nginx-proxy
===========

This is about how you would run nginx-proxy:

	$ docker run -d -p 80:80 -v /var/run/docker.sock:/tmp/docker.sock:ro jwilder/nginx-proxy
