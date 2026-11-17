-- FoodFriend schema (CSE 111 Checkpoint 2)
-- Implements the 10 relations from the Checkpoint 1 relation specification.
-- Build: sqlite3 Checkpoint2-dbase.sqlite3 < schema.sql

PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS Follows;
DROP TABLE IF EXISTS SavedRestaurant;
DROP TABLE IF EXISTS Serves;
DROP TABLE IF EXISTS Mentions;
DROP TABLE IF EXISTS Transcript;
DROP TABLE IF EXISTS Video;
DROP TABLE IF EXISTS Cuisine;
DROP TABLE IF EXISTS Restaurant;
DROP TABLE IF EXISTS Creator;
DROP TABLE IF EXISTS User;

-- Entities -------------------------------------------------------------------

CREATE TABLE User (
    user_id       INTEGER PRIMARY KEY,
    username      TEXT NOT NULL UNIQUE,
    email         TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    created_at    TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Creator (
    creator_id   INTEGER PRIMARY KEY,
    handle       TEXT NOT NULL UNIQUE,
    display_name TEXT
);

CREATE TABLE Video (
    video_id     INTEGER PRIMARY KEY,
    tiktok_url   TEXT NOT NULL UNIQUE,   -- a link is only processed once
    caption      TEXT,
    posted_at    TEXT,
    submitted_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    creator_id   INTEGER NOT NULL REFERENCES Creator(creator_id),
    submitted_by INTEGER NOT NULL REFERENCES User(user_id)
);

-- 1:1 with Video, enforced by the UNIQUE foreign key
CREATE TABLE Transcript (
    transcript_id INTEGER PRIMARY KEY,
    video_id      INTEGER NOT NULL UNIQUE REFERENCES Video(video_id) ON DELETE CASCADE,
    text          TEXT NOT NULL,
    language      TEXT NOT NULL DEFAULT 'en',
    model         TEXT NOT NULL DEFAULT 'whisper-1',
    created_at    TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- latitude/longitude stay NULL when an address cannot be geocoded
CREATE TABLE Restaurant (
    restaurant_id INTEGER PRIMARY KEY,
    name          TEXT NOT NULL,
    street        TEXT,
    city          TEXT,
    state         TEXT,
    zip           TEXT,
    latitude      REAL CHECK (latitude  BETWEEN -90  AND 90),
    longitude     REAL CHECK (longitude BETWEEN -180 AND 180),
    phone         TEXT,
    UNIQUE (name, street, city)          -- a restaurant is stored once
);

CREATE TABLE Cuisine (
    cuisine_id INTEGER PRIMARY KEY,
    name       TEXT NOT NULL UNIQUE
);

-- Many-to-many relationships -------------------------------------------------

CREATE TABLE Mentions (
    transcript_id INTEGER NOT NULL REFERENCES Transcript(transcript_id) ON DELETE CASCADE,
    restaurant_id INTEGER NOT NULL REFERENCES Restaurant(restaurant_id) ON DELETE CASCADE,
    snippet       TEXT,
    confidence    REAL CHECK (confidence BETWEEN 0 AND 1),
    PRIMARY KEY (transcript_id, restaurant_id)
);

CREATE TABLE Serves (
    restaurant_id INTEGER NOT NULL REFERENCES Restaurant(restaurant_id) ON DELETE CASCADE,
    cuisine_id    INTEGER NOT NULL REFERENCES Cuisine(cuisine_id) ON DELETE CASCADE,
    PRIMARY KEY (restaurant_id, cuisine_id)
);

CREATE TABLE SavedRestaurant (
    user_id       INTEGER NOT NULL REFERENCES User(user_id) ON DELETE CASCADE,
    restaurant_id INTEGER NOT NULL REFERENCES Restaurant(restaurant_id) ON DELETE CASCADE,
    saved_at      TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    note          TEXT,
    PRIMARY KEY (user_id, restaurant_id)
);

CREATE TABLE Follows (
    user_id     INTEGER NOT NULL REFERENCES User(user_id) ON DELETE CASCADE,
    creator_id  INTEGER NOT NULL REFERENCES Creator(creator_id) ON DELETE CASCADE,
    followed_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, creator_id)
);
