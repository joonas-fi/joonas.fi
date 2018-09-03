#!/bin/bash -eu

rm -rf build/
mkdir build
jekyll build --source blog/ --destination build/
