---
title: "SQLPage: turn SQL queries to web pages"
tags:
- linux
- web
- databases
date: 2024-08-05T08:56:05Z
# header_image_alt: "just a test"
---

What
----

> Build Web Apps Effortlessly with Only SQL Skills

([Homepage](https://sql.ophir.dev/))

It means you can create small web apps (pages) with just creating SQL scripts.

You can check out the simple SQL queries from below section if you need convincing it's really simple,
but here's the ends result:

{{< video src="demo" >}}


How
---

Create `index.sql` (page):

```sql
SELECT
    'list' as component,
    'Popular playlists' as title;
SELECT
    Name as title,
    'playlist_tracks.sql?playlist='|| PlaylistId as link
FROM playlists;
```

and `playlist_tracks.sql`:

```sql
SELECT
    'table' as component,
    'Playlist tracks' as title;
SELECT
    artists.Name as 'artist',
    albums.Title as 'album',
    tracks.Name as 'track'
FROM playlist_track
INNER JOIN tracks ON tracks.TrackID = playlist_track.TrackID
INNER JOIN albums ON albums.AlbumId = tracks.AlbumId
INNER JOIN artists ON albums.ArtistId = artists.ArtistId
WHERE PlaylistId = (SELECT value FROM (select "key", "value" from json_each(sqlpage.variables())) WHERE "key" = "playlist")
ORDER BY artists.Name, albums.Title;
```

And download SQLite sample database ([credit](https://www.sqlitetutorial.net/sqlite-sample-database/)) by running:

```shell
wget https://www.sqlitetutorial.net/wp-content/uploads/2018/03/chinook.zip
unzip chinook.zip
```

Now you'll have these files:

```
.
├── chinook.db
├── index.sql
└── playlist_tracks.sql
```

You can start container:

```shell
docker run -it --rm -p 8080:8080 --volume "$(pwd):/var/www" -e database_url=sqlite://chinook.db?mode=rwc lovasoa/sqlpage
```

Now you have [http://localhost:8080/](http://localhost:8080/) that should show you the same result as the demo above.