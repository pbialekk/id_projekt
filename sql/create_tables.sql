CREATE TABLE layers (
    id INT PRIMARY KEY,
    "name" VARCHAR(10) NOT NULL UNIQUE
);

CREATE TABLE entities (
    id SERIAL PRIMARY KEY,
    layer INT NOT NULL REFERENCES layers(id),
    "name" VARCHAR(100) NOT NULL,
    views INT NOT NULL DEFAULT 0,
    about TEXT,
    photo_link VARCHAR(250),
    "date" DATE
);

CREATE TABLE links (
    "from" INT NOT NULL REFERENCES entities(id),
    "to" INT NOT NULL REFERENCES entities(id),
    CONSTRAINT unique_links PRIMARY KEY("from", "to")
);

CREATE TABLE tags (
    id SERIAL PRIMARY KEY,
    "name" VARCHAR(100) NOT NULL
);

CREATE TABLE entity_tags (
    entity_id INT NOT NULL REFERENCES entities(id),
    tag_id INT NOT NULL REFERENCES tags(id),
    CONSTRAINT unique_tags PRIMARY KEY(entity_id, tag_id)
);

CREATE TABLE entity_facts (
    id SERIAL PRIMARY KEY,
    entity_id INT NOT NULL REFERENCES entities(id),
    contents TEXT NOT NULL,
    "visible" BOOLEAN NOT NULL
);

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(100) NOT NULL,
    "admin" BOOLEAN NOT NULL,
    critic BOOLEAN NOT NULL
);

CREATE TABLE permissions (
    user_id INT NOT NULL REFERENCES users(id),
    entity_id INT NOT NULL REFERENCES entities(id),
    CONSTRAINT unique_permissions PRIMARY KEY(user_id, entity_id)
);

CREATE TABLE lyrics (
    id SERIAL PRIMARY KEY,
    contents TEXT NOT NULL,
    "length" INT NOT NULL,
    song_id INT NOT NULL REFERENCES entities(id),
    visible BOOLEAN NOT NULL
);

CREATE TABLE annotations (
    id SERIAL PRIMARY KEY,
    contents TEXT NOT NULL,
    lyric_id INT NOT NULL REFERENCES lyrics(id),
    user_id INT NOT NULL REFERENCES users(id),
    first_word INT NOT NULL CHECK(first_word > 0),
    last_word INT NOT NULL,
    visible BOOLEAN NOT NULL,
    CHECK (first_word <= last_word)
);

CREATE TABLE comments (
    id SERIAL PRIMARY KEY,
    contents TEXT NOT NULL,
    user_id INT NOT NULL REFERENCES users(id),
    annotation_id INT NOT NULL REFERENCES annotations(id),
    visible BOOLEAN NOT NULL
);

CREATE TABLE votes (
    "value" INT NOT NULL CHECK (ABS("value") = 1),
    user_id INT NOT NULL REFERENCES users(id),
    annotation_id INT NOT NULL REFERENCES annotations(id),
    CONSTRAINT unique_votes PRIMARY KEY(user_id, annotation_id)
);

CREATE TABLE reviews (
    id SERIAL PRIMARY KEY,
    contents TEXT NOT NULL,
    rating NUMERIC(2, 1) NOT NULL CHECK (rating >= 0 AND rating <= 5),
    user_id INT NOT NULL REFERENCES users(id),
    entity_id INT NOT NULL REFERENCES entities(id),
    visible BOOLEAN NOT NULL
);

CREATE TABLE visited (
    entity_id INT REFERENCES entities(id)
);

CREATE TABLE pqueue (
    entity_id INT REFERENCES entities(id)
);

CREATE TABLE reverse_visited (
    entity_id INT REFERENCES entities(id)
);

CREATE TABLE reverse_pqueue (
    entity_id INT REFERENCES entities(id)
);
