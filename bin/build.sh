#!/bin/sh -eu

set -eu

rm -rf public

mkdir -p rel/

hugo

(cd public/ && tar -czf ../rel/site.tar.gz *)
