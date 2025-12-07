-- This file contains the code that defines the tables, indexes, and views of my design.

-- Contains all the Spotify Subscription Plans
CREATE TABLE "subscription_plans" (
    "id" INTEGER,
    "name" TEXT NOT NULL UNIQUE,
    "price_per_month" NUMERIC,
    PRIMARY KEY("id")
);

-- Represents Artist entity
CREATE TABLE "artists" (
    "id" INTEGER,
    "name" TEXT NOT NULL UNIQUE,
    PRIMARY KEY("id")
);

-- Represents User entity
CREATE TABLE "users" (
    "id" INTEGER,
    "username" TEXT NOT NULL UNIQUE,
    "password" TEXT NOT NULL,
    "date_joined" TEXT DEFAULT CURRENT_TIMESTAMP
        CHECK(datetime("date_joined") NOT NULL),
    "subscription_id" INTEGER,
    PRIMARY KEY("id"),
    FOREIGN KEY("subscription_id") REFERENCES "subscription_plans"("id")
);

-- Represents Playlist entity
CREATE TABLE "playlists" (
    "id" INTEGER,
    "name" TEXT NOT NULL,
    "user_id" INTEGER NOT NULL,
    "date_created" TEXT DEFAULT CURRENT_TIMESTAMP
        CHECK(datetime("date_created" IS NOT NULL)),
    PRIMARY KEY("id")
    FOREIGN KEY("user_id") REFERENCES "users"("id")
    UNIQUE("user_id", "name")
);

-- Represents Album entity
CREATE TABLE "albums" (
    "id" INTEGER,
    "name" TEXT NOT NULL,
    "artist_id" INTEGER NOT NULL,
    "date_uploaded" TEXT DEFAULT CURRENT_TIMESTAMP
        CHECK(datetime("date_uploaded" IS NOT NULL)),
    PRIMARY KEY("id"),
    FOREIGN KEY("artist_id") REFERENCES "artists"("id")
);

-- Represents Song entity
CREATE TABLE "songs" (
    "id" INTEGER,
    "name" TEXT NOT NULL,
    "date_uploaded" TEXT DEFAULT CURRENT_TIMESTAMP
        CHECK(datetime("date_uploaded" IS NOT NULL)),
    "artist_id" INTEGER NOT NULL,
    "album_id" INTEGER,
    UNIQUE("artist_id", "name"),
    PRIMARY KEY("id"),
    FOREIGN KEY("artist_id") REFERENCES "artists"("id"),
    FOREIGN KEY("album_id") REFERENCES "albums"("id")
);

-- Represents User followers
CREATE TABLE "user_followers" (
    "user1_id" INTEGER NOT NULL,
    "user2_id" INTEGER NOT NULL,
    CHECK ("user1_id" < "user2_id"),
    UNIQUE("user1_id", "user2_id"),
    FOREIGN KEY("user1_id") REFERENCES "users"("id"),
    FOREIGN KEY("user2_id") REFERENCES "users"("id")
);

-- Represents Users following Artists
CREATE TABLE "artist_followers" (
    "user_id" INTEGER NOT NULL,
    "artist_id" INTEGER NOT NULL,
    FOREIGN KEY("user_id") REFERENCES "users"("id"),
    FOREIGN KEY("artist_id") REFERENCES "artists"("id")
);

-- Represents Playlists containing Songs
CREATE TABLE "playlist_songs" (
    "playlist_id" INTEGER NOT NULL,
    "song_id" INTEGER NOT NULL,
    FOREIGN KEY("playlist_id") REFERENCES "playlists"("id"),
    FOREIGN KEY("song_id") REFERENCES "songs"("id")
);


-- Speeds up getting artists
CREATE INDEX "artist_name_search"
ON "artists"("name");

-- Speeds up getting songs
CREATE INDEX "song_name_search"
ON "songs"("name");

-- Speeds up getting the ids for an album for use in subqueries
CREATE INDEX "song_album_id_search"
ON "songs"("album_id");

-- Speeds up getting users
CREATE INDEX "user_username_search"
ON "users"("username");

-- Speeds up getting playlists
CREATE INDEX "playlist_name_search"
ON "playlists"("name");

-- Speeds up getting albums
CREATE INDEX "album_name_search"
ON "albums"("name");

CREATE INDEX "album_artist_id_search"
ON "albums"("artist_id");

-- Speeds up getting the songs within a playlist
CREATE INDEX "songs_from_playlist_search"
ON "playlist_songs"("playlist_id");


-- Shows the total followers for each artist
CREATE VIEW "total_artist_followers" AS
SELECT "name", COUNT(*) AS "followers" FROM "artist_followers"
JOIN "artists"
    ON "artist_followers"."artist_id" = "artists"."id"
GROUP BY "artist_id";

-- Shows all songs with the name of the author and the album it is in if applicable
CREATE VIEW "songs_detailed" AS
SELECT
    "songs"."name" AS "song",
    "artists"."name" AS "artist",
    "albums"."name" AS "album",
    "songs"."date_uploaded" AS "date_uploaded"
FROM "songs"
JOIN "artists" ON "songs"."artist_id" = "artists"."id"
LEFT JOIN "albums" ON "songs"."album_id" = "albums"."id";

-- Shows the number of followers each user has
CREATE VIEW "total_user_followers" AS
SELECT
    "users"."username" AS "username",
    COUNT("uf_pair"."user_id") AS "num_followers"
FROM "users"
LEFT JOIN (
    SELECT "user1_id" AS "user_id" FROM "user_followers"
    UNION ALL
    SELECT "user2_id" FROM "user_followers"
) "uf_pair"
    ON "users"."id" = "uf_pair"."user_id"
GROUP BY "users"."id"
ORDER BY "num_followers" DESC;
