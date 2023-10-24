-- helper functions
CREATE FUNCTION entity_layer(v INT) RETURNS INT AS $$
BEGIN
    RETURN (SELECT layer FROM entities WHERE id = v);
END; $$ LANGUAGE plpgsql;

CREATE FUNCTION layer_id(entity_type VARCHAR) RETURNS INT AS $$
BEGIN
    RETURN (SELECT id FROM layers WHERE "name" = entity_type);
END; $$ LANGUAGE plpgsql;

CREATE FUNCTION reachability(source_id INT, sink_id INT DEFAULT -1) RETURNS BOOLEAN AS $$
DECLARE
    current_id INT;
BEGIN
    IF (SELECT COUNT(*) FROM entities WHERE id = source_id) = 0 THEN
        RAISE EXCEPTION 'source entity does not exist';
    END IF;
    DELETE FROM visited;
    DELETE FROM pqueue;
    INSERT INTO pqueue SELECT source_id;
    LOOP
        EXIT WHEN (SELECT COUNT(*) FROM pqueue) = 0 OR (SELECT COUNT(*) FROM visited WHERE entity_id = sink_id) > 0;
        SELECT entity_id FROM pqueue LIMIT 1 INTO current_id;
        DELETE FROM pqueue WHERE entity_id = current_id;
        IF (SELECT COUNT(*) FROM visited WHERE entity_id = current_id) = 0 THEN
            INSERT INTO visited SELECT current_id;
            INSERT INTO pqueue SELECT "to" FROM links WHERE "from" = current_id;
        END IF;
    END LOOP;
    DELETE FROM visited WHERE entity_id = source_id;
    IF (SELECT COUNT(*) FROM visited WHERE entity_id = sink_id) > 0 THEN
        RETURN TRUE;
    END IF;
    RETURN FALSE;
END; $$ LANGUAGE plpgsql;

CREATE FUNCTION multisource(_user_id INT, sink_id INT DEFAULT -1) RETURNS TABLE (entity_id INT) AS $$
BEGIN
    DELETE FROM pqueue;
    DELETE FROM visited;
    if (SELECT COUNT(*) FROM users WHERE _user_id = id) = 0 THEN
        RAISE EXCEPTION 'user does not exist';
    END IF;
    INSERT INTO pqueue (SELECT p.entity_id FROM permissions p WHERE p.user_id = _user_id);
    PERFORM multisource_reachability(sink_id);
    RETURN QUERY SELECT v.entity_id FROM visited v;
END; $$ LANGUAGE plpgsql;

CREATE FUNCTION multisource_reachability(sink_id INT) RETURNS BOOLEAN AS $$
DECLARE
    current_id INT;
BEGIN
    LOOP
        EXIT WHEN (SELECT COUNT(*) FROM pqueue) = 0 OR (SELECT COUNT(*) FROM visited WHERE entity_id = sink_id) > 0;
        SELECT entity_id FROM pqueue LIMIT 1 INTO current_id;
        DELETE FROM pqueue WHERE entity_id = current_id;
        IF (SELECT COUNT(*) FROM visited WHERE entity_id = current_id) = 0 THEN
            INSERT INTO visited SELECT current_id;
            INSERT INTO pqueue SELECT "to" FROM links WHERE "from" = current_id;
        END IF;
    END LOOP;
    RETURN TRUE;
END; $$ LANGUAGE plpgsql;

CREATE FUNCTION reverse_reachability(source_id INT, sink_id INT DEFAULT -1) RETURNS BOOLEAN AS $$
DECLARE
    current_id INT;
BEGIN
    IF (SELECT COUNT(*) FROM entities WHERE id = source_id) = 0 THEN
        RAISE EXCEPTION 'source entity does not exist';
    END IF;
    DELETE FROM reverse_visited;
    DELETE FROM reverse_pqueue;
    INSERT INTO reverse_pqueue SELECT source_id;
    LOOP
        EXIT WHEN (SELECT COUNT(*) FROM reverse_pqueue) = 0 OR (SELECT COUNT(*) FROM reverse_visited WHERE entity_id = sink_id) > 0;
        SELECT entity_id FROM reverse_pqueue LIMIT 1 INTO current_id;
        DELETE FROM reverse_pqueue WHERE entity_id = current_id;
        IF (SELECT COUNT(*) FROM reverse_visited WHERE entity_id = current_id) = 0 THEN
            INSERT INTO reverse_visited SELECT current_id;
            INSERT INTO reverse_pqueue SELECT "from" FROM links WHERE "to" = current_id;
        END IF;
    END LOOP;
    DELETE FROM reverse_visited WHERE entity_id = source_id;
    IF (SELECT COUNT(*) FROM reverse_visited WHERE entity_id = sink_id) > 0 THEN
        RETURN TRUE;
    END IF;
    RETURN FALSE;
END; $$ LANGUAGE plpgsql;

CREATE FUNCTION constrained_reverse_reachability(source_id INT, sink_id INT DEFAULT -1) RETURNS BOOLEAN AS $$
DECLARE
    current_id INT;
BEGIN
    IF (SELECT COUNT(*) FROM entities WHERE id = source_id) = 0 THEN
        RAISE EXCEPTION 'source entity does not exist';
    END IF;
    DELETE FROM reverse_visited;
    DELETE FROM reverse_pqueue;
    INSERT INTO reverse_pqueue SELECT source_id;
    LOOP
        EXIT WHEN (SELECT COUNT(*) FROM reverse_pqueue) = 0 OR (SELECT COUNT(*) FROM reverse_visited WHERE entity_id = sink_id) > 0;
        SELECT entity_id FROM reverse_pqueue LIMIT 1 INTO current_id;
        DELETE FROM reverse_pqueue WHERE entity_id = current_id;
        IF (SELECT COUNT(*) FROM reverse_visited WHERE entity_id = current_id) = 0 THEN
            INSERT INTO reverse_visited SELECT current_id;
            IF (SELECT layer FROM entities WHERE id = current_id) > 3 THEN
                INSERT INTO reverse_pqueue SELECT "from" FROM links WHERE "to" = current_id;
            END IF;
        END IF;
    END LOOP;
    DELETE FROM reverse_visited WHERE entity_id = source_id;
    IF (SELECT COUNT(*) FROM reverse_visited WHERE entity_id = sink_id) > 0 THEN
        RETURN TRUE;
    END IF;
    RETURN FALSE;
END; $$ LANGUAGE plpgsql;

CREATE FUNCTION amusing_reachability() RETURNS BOOLEAN AS $$
DECLARE
    current_id INT;
    found_other_side BOOLEAN := FALSE;
BEGIN
    DELETE FROM pqueue;
    INSERT INTO pqueue SELECT * FROM visited;
    DELETE FROM visited;
    LOOP
        EXIT WHEN (SELECT COUNT(*) FROM pqueue) = 0;
        SELECT entity_id FROM pqueue LIMIT 1 INTO current_id;
        DELETE FROM pqueue WHERE entity_id = current_id;
        IF (SELECT COUNT(*) FROM visited WHERE entity_id = current_id) = 0 THEN
            IF (SELECT COUNT(*) FROM reverse_visited WHERE entity_id = current_id) > 0 THEN
                found_other_side := TRUE;
                EXIT;
            END IF;
            INSERT INTO visited SELECT current_id;
            INSERT INTO pqueue SELECT "from" FROM links WHERE "to" = current_id;
        END IF;
    END LOOP;
    RETURN found_other_side;
END; $$ LANGUAGE plpgsql;

-- user interaction functions

CREATE FUNCTION create_entity(entity_type VARCHAR, entity_name VARCHAR, entity_views INT DEFAULT 0, entity_about TEXT DEFAULT NULL, entity_photo_link VARCHAR(250) DEFAULT NULL, entity_date DATE DEFAULT NULL) RETURNS INT AS $$
DECLARE
    entity_id INT := NULL;
BEGIN
    INSERT INTO entities (layer, "name", views, about, photo_link, "date") VALUES (layer_id(entity_type), entity_name, entity_views, entity_about, entity_photo_link, entity_date) RETURNING id INTO entity_id;
    RETURN entity_id;
END; $$ LANGUAGE plpgsql;

CREATE FUNCTION create_link(source_entity INT, sink_entity INT) RETURNS INT AS $$
BEGIN
    INSERT INTO links ("from", "to") VALUES (source_entity, sink_entity);
    RETURN 0;
END; $$ LANGUAGE plpgsql;

CREATE FUNCTION create_tag(tag_name VARCHAR) RETURNS INT AS $$
DECLARE
    tag_id INT := NULL;
BEGIN
    INSERT INTO tags ("name") VALUES (tag_name) RETURNING id INTO tag_id;
    RETURN tag_id;
END; $$ LANGUAGE plpgsql;

CREATE FUNCTION add_entity_tag(_entity_id INT, _tag_id INT) RETURNS INT AS $$
BEGIN
    INSERT INTO entity_tags (entity_id, tag_id) VALUES (_entity_id, _tag_id);
    RETURN 0;
END; $$ LANGUAGE plpgsql;

CREATE FUNCTION add_entity_fact(_entity_id INT, _contents TEXT, "_visible" BOOLEAN DEFAULT TRUE) RETURNS INT AS $$
DECLARE
    entity_fact_id INT := NULL;
BEGIN
    INSERT INTO entity_facts (entity_id, contents, "visible") VALUES (_entity_id, _contents, "_visible") RETURNING id INTO entity_fact_id;
    RETURN entity_fact_id;
END; $$ LANGUAGE plpgsql;

CREATE FUNCTION create_user(_username VARCHAR, _password VARCHAR, "_admin" BOOLEAN DEFAULT FALSE, _critic BOOLEAN DEFAULT FALSE) RETURNS INT AS $$
DECLARE
    user_id INT := NULL;
BEGIN
    INSERT INTO users (username, password_hash, "admin", critic) VALUES (_username, (SELECT MD5(_password)), "_admin", _critic) RETURNING id INTO user_id;
    RETURN user_id;
END; $$ LANGUAGE plpgsql;

CREATE FUNCTION grant_permission(_user_id INT, _entity_id INT) RETURNS INT AS $$
BEGIN
    INSERT INTO permissions (user_id, entity_id) VALUES (_user_id, _entity_id);
    RETURN 0;
END; $$ LANGUAGE plpgsql;

CREATE FUNCTION add_lyrics(_contents TEXT, _song_id INT, _visible BOOLEAN DEFAULT TRUE) RETURNS INT AS $$
DECLARE
    lyric_id INT := NULL;
    lyric_len INT;
BEGIN
    SELECT ARRAY_LENGTH(REGEXP_SPLIT_TO_ARRAY(TRIM(REGEXP_REPLACE(_contents, E'<[^>]+>', '', 'gi')), E'\\W+'), 1) INTO lyric_len;
    INSERT INTO lyrics (contents, "length", song_id, visible) VALUES (_contents, lyric_len, _song_id, _visible) RETURNING id INTO lyric_id;
    RETURN lyric_id;
END; $$ LANGUAGE plpgsql;

CREATE FUNCTION add_annotation(_contents TEXT, _lyric_id INT, _user_id INT, _first_word INT, _last_word INT, _visible BOOLEAN DEFAULT TRUE) RETURNS INT AS $$
DECLARE
    annotation_id INT := NULL;
BEGIN
    INSERT INTO annotations (contents, lyric_id, user_id, first_word, last_word, visible) VALUES (_contents, _lyric_id, _user_id, _first_word, _last_word, _visible) RETURNING id INTO annotation_id;
    RETURN annotation_id;
END; $$ LANGUAGE plpgsql;

CREATE FUNCTION add_comment(_contents TEXT, _user_id INT, _annotation_id INT, _visible BOOLEAN DEFAULT TRUE) RETURNS INT AS $$
DECLARE
    comment_id INT := NULL;
BEGIN
    INSERT INTO comments (contents, user_id, annotation_id, visible) VALUES (_contents, _user_id, _annotation_id, _visible) RETURNING id INTO comment_id;
    RETURN comment_id;
END; $$ LANGUAGE plpgsql;

CREATE FUNCTION add_vote("_value" INT, _user_id INT, _annotation_id INT) RETURNS INT AS $$
BEGIN
    IF (SELECT COUNT(*) FROM votes WHERE user_id = _user_id AND annotation_id = _annotation_id) = 0 THEN
        INSERT INTO votes ("value", user_id, annotation_id) VALUES ("_value", _user_id, _annotation_id);
    ELSE
        UPDATE votes SET "value" = "_value" WHERE user_id = _user_id AND annotation_id = _annotation_id;
    END IF;
    RETURN 0;
END; $$ LANGUAGE plpgsql;

CREATE FUNCTION remove_vote(_user_id INT, _annotation_id INT) RETURNS INT AS $$
BEGIN
    IF (SELECT COUNT(*) FROM votes WHERE user_id = _user_id AND annotation_id = _annotation_id) > 0 THEN
        DELETE FROM votes WHERE user_id = _user_id AND annotation_id = _annotation_id;
    END IF;
    RETURN 0;
END; $$ LANGUAGE plpgsql;

CREATE FUNCTION add_review(_contents TEXT, _rating NUMERIC(1, 1), _user_id INT, _entity_id INT, _visible BOOLEAN DEFAULT TRUE) RETURNS INT AS $$
DECLARE
    review_id INT := NULL;
BEGIN
    IF (SELECT COUNT(*) FROM reviews WHERE user_id = _user_id AND entity_id = _entity_id) > 0 THEN
        UPDATE reviews SET contents = _contents, rating = _rating WHERE user_id = _user_id AND entity_id = _entity_id;
        RETURN NULL;
    ELSE
        INSERT INTO reviews (contents, rating, user_id, entity_id, visible) VALUES (_contents, _rating, _user_id, _entity_id, _visible) RETURNING id INTO review_id;
    END IF;
    RETURN review_id;
END; $$ LANGUAGE plpgsql;

CREATE FUNCTION get_dependent_entities(_entity_id INT) RETURNS TABLE (entity_id INT) AS $$
BEGIN
    PERFORM reachability(_entity_id);
    RETURN QUERY SELECT v.entity_id FROM visited v;
END; $$ LANGUAGE plpgsql;

CREATE FUNCTION get_referenced_entities(_entity_id INT) RETURNS TABLE (entity_id INT) AS $$
BEGIN
    PERFORM reverse_reachability(_entity_id);
    RETURN QUERY SELECT v.entity_id FROM reverse_visited v;
END; $$ LANGUAGE plpgsql;

CREATE FUNCTION get_referenced_artists(_entity_id INT) RETURNS TABLE (entity_id INT) AS $$
BEGIN
    PERFORM constrained_reverse_reachability(_entity_id);
    RETURN QUERY SELECT v.entity_id FROM reverse_visited v;
END; $$ LANGUAGE plpgsql;

CREATE FUNCTION can_edit(_user_id INT, _entity_id INT) RETURNS BOOLEAN AS $$
DECLARE 
    permitted record;
BEGIN
    PERFORM reverse_reachability(_entity_id);
    FOR permitted IN (SELECT entity_id FROM permissions WHERE user_id = _user_id) LOOP
        IF (SELECT COUNT(*) FROM reverse_visited WHERE entity_id = permitted.entity_id) > 0 THEN
            RETURN TRUE;
        END IF;
    END LOOP;
    RETURN FALSE;
END; $$ LANGUAGE plpgsql;

-- trigger specific functions

CREATE FUNCTION illegal_layer_modification() RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'attempted to modify layers';
END; $$ LANGUAGE plpgsql;

CREATE FUNCTION illegal_entity_deletion() RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'attempted to delete an entity';
END; $$ LANGUAGE plpgsql;

CREATE FUNCTION entity_modification_check() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.id != OLD.id OR NEW.layer != OLD.layer OR NEW."name" != OLD."name" OR (NEW."date" != OLD."date" AND OLD."date" IS NOT NULL) THEN
        RAISE EXCEPTION 'attempted to modify existing final columns of an entity';
    END IF;
    IF NEW.views NOT IN (OLD.views, OLD.views + 1) THEN
        RAISE EXCEPTION 'attempted to modify entity view count by more than one';
    END IF;
    RETURN NEW;
END; $$ LANGUAGE plpgsql;

CREATE FUNCTION illegal_link_modification() RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'attempted to modify links';
END; $$ LANGUAGE plpgsql;

CREATE FUNCTION link_insertion_check() RETURNS TRIGGER AS $$
DECLARE
    from_layer INT;
    to_layer INT;
BEGIN
    from_layer = entity_layer(NEW."from");
    to_layer = entity_layer(NEW."to");
    IF from_layer >= to_layer THEN
        RAISE EXCEPTION 'attempted to insert link between unlinkable layers';
    END IF;
    IF to_layer = layer_id('alias') THEN
        IF (SELECT COUNT(*) FROM links lnks WHERE lnks."to" = NEW."to") > 0 THEN
            RAISE EXCEPTION 'attempted to give the same alias to two different artists';
        END IF;
    END IF;
    PERFORM reachability(NEW."to");
    PERFORM reverse_reachability(NEW."from");
    IF (SELECT amusing_reachability()) = TRUE THEN
        RAISE EXCEPTION 'attempted to insert link which would violate entity to entity path uniqueness constraint';
    END IF;
    RETURN NEW;
END; $$ LANGUAGE plpgsql;

CREATE FUNCTION illegal_tag_modification() RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'attempted to modify tags';
END; $$ LANGUAGE plpgsql;

CREATE FUNCTION illegal_entity_tag_modification() RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'attempted to modify entity tags';
END; $$ LANGUAGE plpgsql;

CREATE FUNCTION entity_fact_modification_check() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.id != OLD.id OR NEW.entity_id != OLD.entity_id THEN
        RAISE EXCEPTION 'attempted to modify entity fact id or entity fact entity_id';
    END IF;
    RETURN NEW;
END; $$ LANGUAGE plpgsql;

CREATE FUNCTION illegal_user_deletion() RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'attempted to delete a user';
END; $$ LANGUAGE plpgsql;

CREATE FUNCTION user_modification_check() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.id != OLD.id OR NEW.username != OLD.username THEN
        RAISE EXCEPTION 'attempted to modify user id or user username';
    END IF;
    RETURN NEW;
END; $$ LANGUAGE plpgsql;

CREATE FUNCTION illegal_permission_modification() RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'attempted to modify a permission';
END; $$ LANGUAGE plpgsql;

CREATE FUNCTION illegal_lyric_deletion() RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'attempted to delete a lyric';
END; $$ LANGUAGE plpgsql;

CREATE FUNCTION lyric_modification_check() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.id != OLD.id OR NEW.song_id != OLD.song_id THEN
        RAISE EXCEPTION 'attempted to modify final columns of a lyric';
    END IF;
    RETURN NEW;
END; $$ LANGUAGE plpgsql;

CREATE FUNCTION illegal_annotation_deletion() RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'attempted to delete an annotation';
END; $$ LANGUAGE plpgsql;

CREATE FUNCTION annotation_insertion_check() RETURNS TRIGGER AS $$
DECLARE
    i RECORD;
    lb INT;
    rb INT;
BEGIN
    IF NEW.visible = FALSE THEN
        RETURN NEW;
    END IF;
    IF NEW.last_word - 1 > (SELECT "length" FROM lyrics WHERE id = NEW.lyric_id) THEN
        RAISE EXCEPTION 'annotation is too long';
    END IF;
    FOR i IN (SELECT * FROM annotations WHERE lyric_id = NEW.lyric_id) LOOP
        IF NEW.first_word > i.first_word THEN
            lb = NEW.first_word;
        ELSE
            lb = i.first_word;
        END IF;
        IF NEW.last_word < i.last_word THEN
            rb = NEW.last_word;
        ELSE
            rb = i.last_word;
        END IF;
        IF lb <= rb - 1 AND i.visible THEN
            RAISE EXCEPTION 'attempted to insert anotation in a way that would collide with existing annotation';
        END IF;
    END LOOP;
    RETURN NEW;
END; $$ LANGUAGE plpgsql;

CREATE FUNCTION annotation_modification_check() RETURNS TRIGGER AS $$
DECLARE
    i RECORD;
    lb INT;
    rb INT;
BEGIN
    IF NEW.id != OLD.id OR NEW.lyric_id != OLD.lyric_id OR NEW.user_id != OLD.user_id THEN
        RAISE EXCEPTION 'attempted to modify final columns of an annotation';
    END IF;
    IF NEW.visible = FALSE THEN
        RETURN NEW;
    END IF;
    IF NEW.last_word - 1 > (SELECT "length" FROM lyrics WHERE id = NEW.lyric_id) THEN
        RAISE EXCEPTION 'annotation is too long';
    END IF;
    FOR i IN (SELECT * FROM annotations WHERE lyric_id = NEW.lyric_id) LOOP
        IF NEW.first_word > i.first_word THEN
            lb = NEW.first_word;
        ELSE
            lb = i.first_word;
        END IF;
        IF NEW.last_word < i.last_word THEN
            rb = NEW.last_word;
        ELSE
            rb = i.last_word;
        END IF;
        IF lb <= rb - 1 AND i.visible AND i.id != NEW.id THEN
            RAISE EXCEPTION 'attempted to modify anotation in a way that would collide with existing annotation';
        END IF;
    END LOOP;
    RETURN NEW;
END; $$ LANGUAGE plpgsql;

CREATE FUNCTION comment_modification_check() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.id != OLD.id OR NEW.user_id != OLD.user_id OR NEW.annotation_id != OLD.annotation_id THEN
        RAISE EXCEPTION 'attempted to modify final columns of a comment';
    END IF;
    RETURN NEW;
END; $$ LANGUAGE plpgsql;

CREATE FUNCTION vote_modification_check() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.user_id != OLD.user_id OR NEW.annotation_id != OLD.annotation_id THEN
        RAISE EXCEPTION 'attempted to modify final columns of a vote';
    END IF;
    RETURN NEW;
END; $$ LANGUAGE plpgsql;

CREATE FUNCTION review_modification_check() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.id != OLD.id OR NEW.user_id != OLD.user_id OR NEW.entity_id != OLD.entity_id THEN
        RAISE EXCEPTION 'attempted to modify final columns of a review';
    END IF;
    RETURN NEW;
END; $$ LANGUAGE plpgsql;
