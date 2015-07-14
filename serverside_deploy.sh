#!/bin/bash

set -e

rm -rf /srv/www/joonas.fi/*
tar --strip-components=1 -C /srv/www/joonas.fi/ -zxf joonas.fi-blog.tar.gz
