
Prerequisites
=============

Have Docker installed:

	$ curl -sSL https://get.docker.com/ | sh

Building the Jekyll site
========================

Just run:

	$ make

This will use joonas/jekyll-builder to build the Jekyll site, and stuff the build artifact
from that into a container based on docker-nginx, which is just a nginx serving a static site.

Previewing the site
===================

If you don't have nginx-proxy already running:

	$ docker run -d -p 80:80 -v /var/run/docker.sock:/tmp/docker.sock:ro jwilder/nginx-proxy

Of course you can make do without nginx-proxy and just expose the container's port 80 on host 80,
but this example is because that's what I use in production to provide virtual hosting over different containers.

Now start the site:

	$ make preview

Now the site should be accessible at:

	http://joonas.fi.127.0.0.1.xip.io/

Deploying the blog
==================

On dev machine:

	$ make push

After that, on production:

	$ docker rm -f joonas_fi; docker run -d --name joonas_fi dkr.xs.fi/joonas_fi:<version>
