#!/bin/sh

set -eu

title="$1"

id=$(printf '%s' "$title" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')

year=$(date +"%Y")

hugo new --kind posts-bundle "today-i-learned/$year/$id"

chown -R 1000:1000 "content/today-i-learned/$year/$id"
