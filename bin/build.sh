#!/bin/sh -eu

set -eu

rm -rf public

mkdir -p rel/

hugo

# the root-level RSS feed includes about/contact pages etc, and there's no easy way to fix it without
# overriding (and taking ownership of) the RSS template, so replace the root-level (actually, we also
# disabled rednering it) feed with the blog-specific feed instead.
#
# https://www.refactoredtelegram.net/2020/12/posts-only-rss-feed-in-hugo/
mv public/posts/feed.xml public/feed.xml

(cd public/ && tar -czf ../rel/site.tar.gz *)
