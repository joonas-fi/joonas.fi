#!/bin/sh

set -eu

title="$1"

# TODO: translate spaces to dashes
id="$title"

year=$(date +"%Y")

hugo new --kind posts-bundle "complaint-corner/$year/$id"

chown -R 1000:1000 "content/complaint-corner/$year/$id"
