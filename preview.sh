#!/bin/bash

set -e

# need sudo to bind to :80
sudo jekyll serve --host 192.168.56.169 --port 80 -s blog/ -d build/
