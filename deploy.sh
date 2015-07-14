#!/bin/bash

set -e

TAR_NAME="joonas.fi-blog.tar.gz"

echo "# building site"
jekyll build -s blog/ -d build/

echo "# tarring site up"
tar -zcf "$TAR_NAME" build/

echo "# xferring tar package"
scp "$TAR_NAME" ubuntu@xs.fi:

echo "# deploying the .tar on the server"
ssh ubuntu@xs.fi "rm -rf /srv/www/joonas.fi/* && tar --strip-components=1 -C /srv/www/joonas.fi/ -zxf \"$TAR_NAME\""

echo "# done!"
