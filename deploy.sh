#!/bin/bash

set -e

echo "# building site"
jekyll build -s blog/ -d build/

echo "# tarring site up"
tar -zcf joonas.fi-blog.tar.gz build/

echo "# xferring tar package"
scp joonas.fi-blog.tar.gz ubuntu@xs.fi:

echo "# using SSH to run deploy script"
ssh ubuntu@xs.fi './serverside_deploy.sh'

echo "# done!"
