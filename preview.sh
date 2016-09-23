#!/bin/bash -eu

echo "Hit this URL in your momma's browser: http://joonas-blog.dev-laptop.xs.fi:8089"

docker run --rm -it -v "$(pwd):/project" -e VIRTUAL_HOST=joonas-blog.dev-laptop.xs.fi -p 8089:8089 joonas/jekyll-builder:0.1.0 jekyll serve -H 0.0.0.0 -P 8089 --source /project/blog/ --destination /tmp
