#!/bin/sh

set -eu

title="$1"

id=$(printf '%s' "$title" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')

year=$(date +"%Y")

hugo new --kind posts-bundle "posts/$year/$id"
