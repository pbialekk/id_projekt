CREATE TRIGGER illegal_layer_modification BEFORE INSERT OR UPDATE OR DELETE ON layers FOR EACH ROW EXECUTE PROCEDURE illegal_layer_modification();

CREATE TRIGGER illegal_entity_deletion BEFORE DELETE ON entities FOR EACH ROW EXECUTE PROCEDURE illegal_entity_deletion();

CREATE TRIGGER entity_modification_check BEFORE UPDATE ON entities FOR EACH ROW EXECUTE PROCEDURE entity_modification_check();

CREATE TRIGGER illegal_link_modification BEFORE UPDATE OR DELETE ON links FOR EACH ROW EXECUTE PROCEDURE illegal_link_modification();

CREATE TRIGGER link_insertion_check BEFORE INSERT ON links FOR EACH ROW EXECUTE PROCEDURE link_insertion_check();

CREATE TRIGGER illegal_tag_modification BEFORE UPDATE OR DELETE ON tags FOR EACH ROW EXECUTE PROCEDURE illegal_tag_modification();

CREATE TRIGGER illegal_entity_tag_modification BEFORE UPDATE OR DELETE ON tags FOR EACH ROW EXECUTE PROCEDURE illegal_entity_tag_modification();

CREATE TRIGGER entity_fact_modification_check BEFORE UPDATE ON entity_facts FOR EACH ROW EXECUTE PROCEDURE entity_fact_modification_check();

CREATE TRIGGER illegal_user_deletion BEFORE DELETE ON users FOR EACH ROW EXECUTE PROCEDURE illegal_user_deletion();

CREATE TRIGGER user_modification_check BEFORE UPDATE ON users FOR EACH ROW EXECUTE PROCEDURE user_modification_check();

CREATE TRIGGER illegal_permission_modification BEFORE UPDATE ON permissions FOR EACH ROW EXECUTE PROCEDURE illegal_permission_modification();

CREATE TRIGGER illegal_lyric_deletion BEFORE DELETE ON lyrics FOR EACH ROW EXECUTE PROCEDURE illegal_lyric_deletion();

CREATE TRIGGER lyric_modification_check BEFORE UPDATE ON lyrics FOR EACH ROW EXECUTE PROCEDURE lyric_modification_check();

CREATE TRIGGER illegal_annotation_deletion BEFORE DELETE ON annotations FOR EACH ROW EXECUTE PROCEDURE illegal_annotation_deletion();

CREATE TRIGGER annotation_insertion_check BEFORE INSERT ON annotations FOR EACH ROW EXECUTE PROCEDURE annotation_insertion_check();

CREATE TRIGGER annotation_modification_check BEFORE UPDATE ON annotations FOR EACH ROW EXECUTE PROCEDURE annotation_modification_check();

CREATE TRIGGER comment_modification_check BEFORE UPDATE ON comments FOR EACH ROW EXECUTE PROCEDURE comment_modification_check();

CREATE TRIGGER vote_modification_check BEFORE UPDATE ON votes FOR EACH ROW EXECUTE PROCEDURE vote_modification_check();

CREATE TRIGGER review_modification_check BEFORE UPDATE ON reviews FOR EACH ROW EXECUTE PROCEDURE review_modification_check();
