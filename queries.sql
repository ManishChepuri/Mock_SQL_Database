-- This file contains queries that are commonly writtent to get data. The indexes within the schema file help to speed up these queries.

-- Gets the number of followers an artist has
SELECT COUNT(*) as "total_followers" FROM "artist_followers"
WHERE "artist_id" = (
    SELECT "id" FROM "artists"
    WHERE "name" = 'Drake'
); jfjfj

-- Gets the playlists of a user
SELECT "name" FROM "playlists"
WHERE "user_id" = (
    SELECT "id" FROM "users"
    WHERE "username" = "machepur"
);

-- Gets the songs within a playlist
SELECT "name" FROM "songs"
WHERE "id" IN (
    SELECT "song_id" FROM "playlist_songs"
    WHERE "playlist_id" = (
        SELECT "id" FROM "playlists"
        WHERE "name" = 'My Playlist'
        AND "user_id" = (
            SELECT "id" FROM "users"
            WHERE "username" = 'machepur'
        )
    )
);

-- Gets the songs within an album
SELECT "name" FROM "songs"
WHERE "album_id" = (
    SELECT "id" FROM "albums"
    WHERE "name" = 'More Life'
);

-- Gets all the songs an artist made
SELECT "name" FROM "songs"
WHERE "artist_id" = (
    SELECT "id" FROM "artists"
    WHERE "name" = 'Drake'
);

-- Gets all the albums an artist made
SELECT "name" FROM "albums"
WHERE "artist_id" = (
    SELECT "id" FROM "artists"
    WHERE "name" = 'Drake'
);

-- Gets all the followers of a user
SELECT "username" FROM "users"
WHERE "id" IN (
    SELECT "user2_id" FROM "user_followers"
    WHERE "user1_id" = (
        SELECT "id" FROM "users"
        WHERE "username" = 'machepur'
    )
);

-- Add a new user
INSERT INTO "users" ("username", "password", "subscription_id")
SELECT 'machepur', '123',
    (SELECT "id" FROM "subscription_plans" WHERE "name" = 'Free');

-- Add a new artist
INSERT INTO "artists" ("name")
VALUES ('Drake');

-- Add a new album
INSERT INTO "albums" ("name", "date_uploaded", "artist_id")
SELECT 'More Life', '2017-03-18',
    (SELECT "id" FROM "artists" WHERE "name" = 'Drake');

-- Add a new song
INSERT INTO "songs" ("name", "artist_id", "album_id")
SELECT 'Passionfruit',
    (SELECT "id" FROM "artists" WHERE "name" = 'Drake'),
    (SELECT "id" FROM "albums" WHERE "name" = 'More Life');

-- Add a new playlist
INSERT INTO "playlists" ("name", "user_id")
SELECT 'My Playlist',
    (SELECT "id" FROM "users" WHERE "username" = 'machepur');

-- Add a song to a playlist for a user
INSERT INTO "playlist_songs" ("playlist_id", "song_id")
SELECT
    (SELECT "id" FROM "playlists"
        WHERE "name" = 'My Playlist' AND "user_id" = (
            SELECT "id" FROM "users" WHERE "username" = 'machepur'
        )
    ),
    (SELECT "id" FROM "songs"
        WHERE "name" = 'Passionfruit' AND "artist_id" = (
            SELECT "id" from "artists" WHERE "name" = 'Drake'
        )
    );

-- Add a new user to user follow relationship
INSERT INTO "user_followers" ("user1_id", "user2_id")
SELECT
    (SELECT "id" FROM "users" WHERE "username" = 'machepur'),
    (SELECT "id" FROM "users" WHERE "username" = 'gpsubash');


-- Add a new user to artist follow relationship
INSERT INTO "artist_followers" ("user_id", "artist_id")
SELECT
    (SELECT "id" FROM "users" WHERE "username" = 'machepur'),
    (SELECT "id" FROM "artists" WHERE "name" = 'Drake');