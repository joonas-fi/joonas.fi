#!/bin/bash -eu

echo "Hit this URL in your momma's browser: joonas-blog.dev-laptop.xs.fi"

docker run --rm -it -v "$(pwd):/project" -e VIRTUAL_HOST=joonas-blog.dev-laptop.xs.fi -p 8080 joonas/jekyll-builder:0.1.0 jekyll serve -H 0.0.0.0 -P 8080 --source /project/blog/ --destination /tmp
