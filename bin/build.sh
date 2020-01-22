#!/bin/bash -eu

rm -rf build/
mkdir build
jekyll build --source blog/ --destination build/

# Docker build fails without this with error msg:
# no permission to read from '/tmp/bob/joonas.fi-blog/workspace/.sass-cache/...
rm -rf .sass-cache rel/

mkdir rel

(cd build/ && tar -czf ../rel/site.tar.gz *)
