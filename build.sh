#!/bin/bash -eu

#build_inside_docker_image=joonas/jekyll-builder:0.1.0

rm -rf build/
mkdir build
jekyll build --source blog/ --destination build/
