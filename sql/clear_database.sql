-- removing tables
DROP TABLE IF EXISTS layers CASCADE;
DROP TABLE IF EXISTS entities CASCADE;
DROP TABLE IF EXISTS links CASCADE;
DROP TABLE IF EXISTS tags CASCADE;
DROP TABLE IF EXISTS entity_tags CASCADE;
DROP TABLE IF EXISTS entity_facts CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS permissions CASCADE;
DROP TABLE IF EXISTS lyrics CASCADE;
DROP TABLE IF EXISTS annotations CASCADE;
DROP TABLE IF EXISTS comments CASCADE;
DROP TABLE IF EXISTS votes CASCADE;
DROP TABLE IF EXISTS reviews CASCADE;
DROP TABLE IF EXISTS visited CASCADE;
DROP TABLE IF EXISTS pqueue CASCADE;
DROP TABLE IF EXISTS reverse_visited CASCADE;
DROP TABLE IF EXISTS reverse_pqueue CASCADE;

-- removing helper functions
DROP FUNCTION IF EXISTS entity_layer(INT) CASCADE;
DROP FUNCTION IF EXISTS layer_id(VARCHAR) CASCADE;
DROP FUNCTION IF EXISTS reachability(INT, INT);
DROP FUNCTION IF EXISTS reverse_reachability(INT, INT);
DROP FUNCTION IF EXISTS amusing_reachability();
DROP FUNCTION IF EXISTS multisource(INT, INT);
DROP FUNCTION IF EXISTS multisource_reachability(INT);
DROP FUNCTION IF EXISTS constrained_reverse_reachability(INT, INT);

-- removing user interaction functions

DROP FUNCTION IF EXISTS create_entity(VARCHAR, VARCHAR, INT, TEXT, VARCHAR, DATE) CASCADE;
DROP FUNCTION IF EXISTS create_link(INT, INT) CASCADE;
DROP FUNCTION IF EXISTS create_tag(VARCHAR) CASCADE;
DROP FUNCTION IF EXISTS add_entity_tag(INT, INT) CASCADE;
DROP FUNCTION IF EXISTS add_entity_fact(INT, TEXT, BOOLEAN) CASCADE;
DROP FUNCTION IF EXISTS create_user(VARCHAR, VARCHAR, BOOLEAN, BOOLEAN) CASCADE;
DROP FUNCTION IF EXISTS grant_permission(INT, INT) CASCADE;
DROP FUNCTION IF EXISTS add_lyrics(TEXT, INT, BOOLEAN) CASCADE;
DROP FUNCTION IF EXISTS add_annotation(TEXT, INT, INT, INT, INT, BOOLEAN) CASCADE;
DROP FUNCTION IF EXISTS add_comment(TEXT, INT, INT, BOOLEAN) CASCADE;
DROP FUNCTION IF EXISTS add_review(TEXT, NUMERIC(1, 1), INT, INT, BOOLEAN) CASCADE;
DROP FUNCTION IF EXISTS add_vote(INT, INT, INT) CASCADE;
DROP FUNCTION IF EXISTS remove_vote(INT, INT) CASCADE;
DROP FUNCTION IF EXISTS get_dependent_entities(INT) CASCADE;
DROP FUNCTION IF EXISTS get_referenced_entities(INT) CASCADE;
DROP FUNCTION IF EXISTS get_referenced_artists(INT) CASCADE;
DROP FUNCTION IF EXISTS can_edit(INT, INT) CASCADE;

-- removing trigger specific functions
DROP FUNCTION IF EXISTS illegal_layer_modification CASCADE;
DROP FUNCTION IF EXISTS illegal_entity_deletion CASCADE;
DROP FUNCTION IF EXISTS entity_modification_check CASCADE;
DROP FUNCTION IF EXISTS illegal_link_modification CASCADE;
DROP FUNCTION IF EXISTS link_insertion_check CASCADE;
DROP FUNCTION IF EXISTS illegal_tag_modification CASCADE;
DROP FUNCTION IF EXISTS illegal_entity_tag_modification CASCADE;
DROP FUNCTION IF EXISTS entity_fact_modification_check CASCADE;
DROP FUNCTION IF EXISTS illegal_user_deletion CASCADE;
DROP FUNCTION IF EXISTS user_modification_check CASCADE;
DROP FUNCTION IF EXISTS illegal_permission_modification CASCADE;
DROP FUNCTION IF EXISTS illegal_lyric_deletion CASCADE;
DROP FUNCTION IF EXISTS lyric_modification_check CASCADE;
DROP FUNCTION IF EXISTS illegal_annotation_deletion CASCADE;
DROP FUNCTION IF EXISTS annotation_insertion_check CASCADE;
DROP FUNCTION IF EXISTS annotation_modification_check CASCADE;
DROP FUNCTION IF EXISTS comment_modification_check CASCADE;
DROP FUNCTION IF EXISTS vote_modification_check CASCADE;
DROP FUNCTION IF EXISTS review_modification_check CASCADE;
