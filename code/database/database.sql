CREATE SCHEMA IF NOT EXISTS lbaw23143;

SET DateStyle TO European;

-----------
-- Drop tables
-----------

DROP TABLE IF EXISTS question_file;
DROP TABLE IF EXISTS answer_file;
DROP TABLE IF EXISTS question_tag;
DROP TABLE IF EXISTS question_followers;
DROP TABLE IF EXISTS game_member;
DROP TABLE IF EXISTS user_badge;
DROP TABLE IF EXISTS notification;
DROP TABLE IF EXISTS report;
DROP TABLE IF EXISTS version_content;
DROP TABLE IF EXISTS tag;
DROP TABLE IF EXISTS vote;
DROP TABLE IF EXISTS comment;
DROP TABLE IF EXISTS answer;
DROP TABLE IF EXISTS question;
DROP TABLE IF EXISTS game;
DROP TABLE IF EXISTS game_category;
DROP TABLE IF EXISTS badge;
DROP TABLE IF EXISTS users;

-----------
-- Drop functions
-----------

DROP FUNCTION IF EXISTS content_search_update;
DROP FUNCTION IF EXISTS game_search_update;
DROP FUNCTION IF EXISTS question_search_update;
DROP TRIGGER IF EXISTS user_search_update ON users;

DROP FUNCTION IF EXISTS user_search_update() CASCADE;

DROP INDEX IF EXISTS search_user;


-----------
-- Drop types
-----------

DROP TYPE IF EXISTS Vote_type;
DROP TYPE IF EXISTS Content_type;
DROP TYPE IF EXISTS Badge_type;
DROP TYPE IF EXISTS Notification_type;
DROP TYPE IF EXISTS Report_type;
DROP TYPE IF EXISTS Rank CASCADE;

-----------
-- Create types
-----------
CREATE TYPE Rank AS ENUM ('Bronze', 'Gold', 'Master');

CREATE TYPE Badge_type AS ENUM ('Best_comment', 'Inquisitive_Pro', 'Well_Rounded', 'Diamond_Dog', 'Griefer');

CREATE TYPE Notification_type AS ENUM ('Report_notification', 'Rank_notification', 'Badge_notification', 'Answer_notification', 'Question_notification', 'Comment_notification', 'Vote_notification', 'Game_notification');

CREATE TYPE Report_type AS ENUM ('Question_report', 'Answer_report', 'Comment_report');

CREATE TYPE Vote_type AS ENUM ('Question_vote', 'Answer_vote');

CREATE TYPE Content_type AS ENUM ('Question_content', 'Answer_content', 'Comment_content');

-----------
-- Create tables
-----------

CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(256) NOT NULL,
  username VARCHAR(256) UNIQUE NOT NULL,
  email VARCHAR(256) UNIQUE NOT NULL,
  password VARCHAR(256) NOT NULL,
  description TEXT,
  rank Rank NOT NULL DEFAULT 'Bronze',
  is_banned BOOLEAN NOT NULL DEFAULT FALSE,
  is_admin BOOLEAN NOT NULL DEFAULT FALSE,
  remember_token VARCHAR,
  profile_image VARCHAR
);

CREATE TABLE badge (
  id SERIAL PRIMARY KEY,
  name Badge_type NOT NULL
);

CREATE TABLE game_category (
  id SERIAL PRIMARY KEY,
  name VARCHAR(256) UNIQUE NOT NULL,
  description TEXT NOT NULL
);

CREATE TABLE game (
  id SERIAL PRIMARY KEY,
  name VARCHAR(256) UNIQUE NOT NULL,
  description TEXT NOT NULL,
  nr_members INTEGER NOT NULL CHECK (nr_members >= 0),
  game_category_id INTEGER REFERENCES game_category(id) ON DELETE CASCADE,
  game_image VARCHAR
);

CREATE TABLE question (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  create_date TIMESTAMP NOT NULL CHECK (create_date <= now()),
  title VARCHAR(256) NOT NULL,
  is_solved BOOLEAN NOT NULL DEFAULT False,
  is_public BOOLEAN NOT NULL DEFAULT True,
  nr_views INTEGER NOT NULL CHECK (nr_views >= 0) DEFAULT 0,
  votes INTEGER NOT NULL DEFAULT 0,
  game_id INTEGER REFERENCES game(id) ON DELETE CASCADE
);

CREATE TABLE answer (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  question_id INTEGER NOT NULL REFERENCES question(id) ON DELETE CASCADE,
  is_public BOOLEAN NOT NULL DEFAULT True,
  is_correct BOOLEAN NOT NULL DEFAULT False,
  votes INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE comment (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  answer_id INTEGER NOT NULL REFERENCES answer(id) ON DELETE CASCADE,
  is_public BOOLEAN NOT NULL DEFAULT True
);

CREATE TABLE vote (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  date TIMESTAMP NOT NULL CHECK (date <= now()),
  reaction BOOLEAN NOT NULL,
  vote_type Vote_type NOT NULL,
  answer_id INTEGER REFERENCES answer(id) ON DELETE CASCADE,
  question_id INTEGER REFERENCES question(id) ON DELETE CASCADE,
  CHECK ((vote_type = 'Question_vote' AND question_id IS NOT NULL AND answer_id IS NULL)
  OR (vote_type = 'Answer_vote' AND answer_id IS NOT NULL AND question_id IS NULL))
);

CREATE TABLE tag (
  id SERIAL PRIMARY KEY,
  name VARCHAR(256) UNIQUE NOT NULL
);

CREATE TABLE version_content (
  id SERIAL PRIMARY KEY,
  date TIMESTAMP NOT NULL CHECK (date <= now()),
  content TEXT NOT NULL,
  content_type Content_type NOT NULL,
  question_id INTEGER REFERENCES question(id) ON DELETE CASCADE,
  answer_id INTEGER REFERENCES answer(id) ON DELETE CASCADE,
  comment_id INTEGER REFERENCES comment(id) ON DELETE CASCADE,
  CHECK ((content_type = 'Question_content' AND question_id IS NOT NULL AND answer_id IS NULL AND comment_id IS NULL)
  OR (content_type = 'Answer_content' AND answer_id IS NOT NULL AND question_id IS NULL AND comment_id IS NULL)
  OR (content_type = 'Comment_content' AND comment_id IS NOT NULL AND question_id IS NULL AND answer_id IS NULL))
);

CREATE TABLE report (
  id SERIAL PRIMARY KEY,
  date TIMESTAMP NOT NULL CHECK (date <= now()),
  reason TEXT NOT NULL,
  explanation TEXT,
  is_solved BOOLEAN NOT NULL DEFAULT False,
  reporter_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  reported_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  report_type Report_type NOT NULL,
  question_id INTEGER REFERENCES question(id) ON DELETE CASCADE,
  answer_id INTEGER REFERENCES answer(id) ON DELETE CASCADE,
  comment_id INTEGER REFERENCES comment(id) ON DELETE CASCADE,
  CHECK ((report_type = 'Question_report' AND question_id IS NOT NULL AND answer_id IS NULL AND comment_id IS NULL)
  OR (report_type = 'Answer_report' AND answer_id IS NOT NULL AND question_id IS NULL AND comment_id IS NULL)
  OR (report_type = 'Comment_report' AND comment_id IS NOT NULL AND question_id IS NULL AND answer_id IS NULL))
);

CREATE TABLE question_followers (
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  question_id INTEGER NOT NULL REFERENCES question(id) ON DELETE CASCADE,
  PRIMARY KEY (user_id, question_id)
);

CREATE TABLE notification (
  id SERIAL PRIMARY KEY,
  date TIMESTAMP NOT NULL CHECK (date <= now()),
  viewed BOOLEAN NOT NULL DEFAULT False,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  notification_type Notification_type NOT NULL,
  question_id INTEGER REFERENCES question(id) ON DELETE CASCADE,
  answer_id INTEGER REFERENCES answer(id) ON DELETE CASCADE,
  comment_id INTEGER REFERENCES comment(id) ON DELETE CASCADE,
  vote_id INTEGER REFERENCES vote(id) ON DELETE CASCADE,
  report_id INTEGER REFERENCES report(id) ON DELETE CASCADE,
  badge_id INTEGER REFERENCES badge(id) ON DELETE CASCADE,
  game_id INTEGER REFERENCES game(id) ON DELETE CASCADE,
  CHECK ((notification_type = 'Report_notification' AND report_id IS NOT NULL AND question_id IS NULL AND answer_id IS NULL AND comment_id IS NULL AND vote_id IS NULL AND badge_id IS NULL AND game_id IS NULL)
  OR (notification_type = 'Question_notification' AND answer_id IS NOT NULL AND report_id IS NULL AND question_id IS NULL AND comment_id IS NULL AND vote_id IS NULL AND badge_id IS NULL AND game_id IS NULL)
  OR (notification_type = 'Answer_notification' AND answer_id IS NOT NULL AND report_id IS NULL AND question_id IS NULL AND comment_id IS NULL AND vote_id IS NULL AND badge_id IS NULL AND game_id IS NULL)
  OR (notification_type = 'Comment_notification' AND comment_id IS NOT NULL AND report_id IS NULL AND answer_id IS NULL AND question_id IS NULL AND vote_id IS NULL AND badge_id IS NULL AND game_id IS NULL)
  OR (notification_type = 'Vote_notification' AND vote_id IS NOT NULL AND report_id IS NULL AND question_id IS NULL AND answer_id IS NULL AND comment_id IS NULL AND badge_id IS NULL AND game_id IS NULL)
  OR (notification_type = 'Rank_notification' AND question_id IS NULL AND report_id IS NULL AND answer_id IS NULL AND comment_id IS NULL AND vote_id IS NULL AND badge_id IS NULL AND game_id IS NULL)
  OR (notification_type = 'Badge_notification' AND badge_id IS NOT NULL AND question_id IS NULL AND report_id IS NULL AND answer_id IS NULL AND comment_id IS NULL AND vote_id IS NULL AND game_id IS NULL)
  OR (notification_type = 'Game_notification' AND question_id IS NOT NULL AND game_id IS NULL AND report_id IS NULL AND answer_id IS NULL AND comment_id IS NULL AND vote_id IS NULL AND badge_id IS NULL))
);

CREATE TABLE user_badge (
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  badge_id INTEGER REFERENCES badge(id) ON DELETE CASCADE,
  PRIMARY KEY (user_id, badge_id)
);

CREATE TABLE game_member (
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  game_id INTEGER REFERENCES game(id) ON DELETE CASCADE,
  PRIMARY KEY (user_id, game_id)
);

CREATE TABLE question_tag (
  question_id INTEGER REFERENCES question(id) ON DELETE CASCADE,
  tag_id INTEGER REFERENCES tag(id) ON DELETE CASCADE,
  PRIMARY KEY (question_id, tag_id)
);

CREATE TABLE question_file (
  question_id INTEGER REFERENCES question(id) ON DELETE CASCADE,
  file_name VARCHAR,
  f_name VARCHAR,
  PRIMARY KEY (question_id, file_name)
);

CREATE TABLE answer_file (
  answer_id INTEGER REFERENCES answer(id) ON DELETE CASCADE,
  file_name VARCHAR,
  f_name VARCHAR,
  PRIMARY KEY (answer_id, file_name)
);

-----------
-- Create triggers
-----------

--Trigger 1

CREATE OR REPLACE FUNCTION update_question_vote_count_trigger_function()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.reaction = TRUE THEN
    UPDATE question
    SET votes = votes + 1
    WHERE id = NEW.question_id;
  ELSE
    UPDATE question
    SET votes = votes - 1
    WHERE id = NEW.question_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_question_vote_count_trigger
AFTER INSERT ON vote
FOR EACH ROW
WHEN (NEW.vote_type = 'Question_vote' AND NEW.question_id IS NOT NULL)
EXECUTE FUNCTION update_question_vote_count_trigger_function();

--Trigger 1.2

-- Trigger function for updating vote count when a row is deleted
CREATE OR REPLACE FUNCTION update_question_vote_count_trigger_function_delete()
RETURNS TRIGGER AS $$
BEGIN
  IF OLD.reaction = TRUE THEN
    UPDATE question
    SET votes = votes - 1
    WHERE id = OLD.question_id;
  ELSE
    UPDATE question
    SET votes = votes + 1
    WHERE id = OLD.question_id;
  END IF;
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Trigger for updating vote count when a row is deleted
CREATE TRIGGER update_question_vote_count_trigger_delete
BEFORE DELETE ON vote
FOR EACH ROW
EXECUTE FUNCTION update_question_vote_count_trigger_function_delete();

CREATE OR REPLACE FUNCTION update_answer_vote_count_trigger_function()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.reaction = TRUE THEN
    UPDATE answer
    SET votes = votes + 1
    WHERE id = NEW.answer_id;
  ELSE
    UPDATE answer
    SET votes = votes - 1
    WHERE id = NEW.answer_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_answer_vote_count_trigger
AFTER INSERT ON vote
FOR EACH ROW
WHEN (NEW.vote_type = 'Answer_vote' AND NEW.answer_id IS NOT NULL)
EXECUTE FUNCTION update_answer_vote_count_trigger_function();


-- Trigger function for updating vote count when a row is deleted
CREATE OR REPLACE FUNCTION update_answer_vote_count_trigger_function_delete()
RETURNS TRIGGER AS $$
BEGIN
  IF OLD.reaction = TRUE THEN
    UPDATE answer
    SET votes = votes - 1
    WHERE id = OLD.answer_id;
  ELSE
    UPDATE answer
    SET votes = votes + 1
    WHERE id = OLD.answer_id;
  END IF;
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Trigger for updating vote count when a row is deleted
CREATE TRIGGER update_answer_vote_count_trigger_delete
BEFORE DELETE ON vote
FOR EACH ROW
EXECUTE FUNCTION update_answer_vote_count_trigger_function_delete();

--Trigger 2

CREATE OR REPLACE FUNCTION prevent_self_upvote_trigger_function()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.vote_type = 'Question_vote' THEN
    IF NEW.question_id IS NOT NULL AND NEW.user_id = (SELECT user_id FROM question WHERE id = NEW.question_id) THEN
      RAISE EXCEPTION 'You cannot upvote your own question.';
    END IF;
  END IF;
  
  IF NEW.vote_type = 'Answer_vote' THEN
    IF NEW.answer_id IS NOT NULL AND NEW.user_id = (SELECT user_id FROM answer WHERE id = NEW.answer_id) THEN
      RAISE EXCEPTION 'You cannot upvote your own answer.';
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER prevent_self_upvote_trigger
BEFORE INSERT ON vote
FOR EACH ROW
EXECUTE FUNCTION prevent_self_upvote_trigger_function();


---Trigger 3  

CREATE OR REPLACE FUNCTION delete_question_cascade_votes_trigger_function()
RETURNS TRIGGER AS $$
BEGIN
  DELETE FROM vote WHERE question_id = OLD.id;

  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER delete_question_cascade_votes_trigger
AFTER DELETE ON question
FOR EACH ROW
EXECUTE FUNCTION delete_question_cascade_votes_trigger_function();

---Trigger 5

CREATE OR REPLACE FUNCTION award_badges() RETURNS TRIGGER AS $$
DECLARE
    user_question_count INTEGER;
    user_correct_answer_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO user_question_count
    FROM question
    WHERE user_id = NEW.user_id;

    SELECT COUNT(*) INTO user_correct_answer_count
    FROM answer
    WHERE user_id = NEW.user_id;

    IF user_question_count >= 50 THEN
        INSERT INTO user_badge (user_id, badge_id)
        VALUES (NEW.user_id, (SELECT id FROM badge WHERE type = 'Best_comment'));
    END IF;

    IF user_correct_answer_count >= 20 THEN
        INSERT INTO user_badge (user_id, badge_id)
        VALUES (NEW.user_id, (SELECT id FROM badge WHERE type = 'Diamond_Dog'));
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER award_badges_on_question_insert
AFTER INSERT ON question
FOR EACH ROW
EXECUTE FUNCTION award_badges();


CREATE OR REPLACE FUNCTION update_question_privacy_on_ban()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.is_banned = TRUE THEN
    UPDATE question
    SET is_public = FALSE
    WHERE user_id = NEW.id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_question_privacy_on_ban
AFTER UPDATE OF is_banned ON users
FOR EACH ROW
EXECUTE FUNCTION update_question_privacy_on_ban();

      
-- Trigger function to update nr_members after an insert or delete in game_member
CREATE OR REPLACE FUNCTION update_nr_members()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE game
    SET nr_members = nr_members + 1
    WHERE id = NEW.game_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE game
    SET nr_members = nr_members - 1
    WHERE id = OLD.game_id;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create triggers to call the trigger function after an insert or delete in game_member
CREATE TRIGGER update_nr_members_insert
AFTER INSERT ON game_member
FOR EACH ROW
EXECUTE FUNCTION update_nr_members();

CREATE TRIGGER update_nr_members_delete
AFTER DELETE ON game_member
FOR EACH ROW
EXECUTE FUNCTION update_nr_members();


--Trigger 8


CREATE OR REPLACE FUNCTION send_answer_notification()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO notification (date, viewed, user_id, notification_type, question_id, answer_id, comment_id, vote_id,report_id, badge_id, game_id)
    VALUES (NOW(), FALSE, (SELECT user_id FROM question WHERE id = NEW.question_id), 'Answer_notification', NULL, NEW.id,  NULL, NULL, NULL, NULL, NULL);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER answer_notification_trigger
AFTER INSERT ON answer
FOR EACH ROW
EXECUTE FUNCTION send_answer_notification();


CREATE OR REPLACE FUNCTION send_comment_notification()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO notification (date, viewed, user_id, notification_type, question_id, answer_id, comment_id, vote_id,report_id, badge_id, game_id)
    VALUES (NOW(), FALSE, (SELECT user_id FROM answer WHERE id = NEW.answer_id), 'Comment_notification', NULL, NULL,  NEW.id, NULL, NULL, NULL, NULL);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER comment_notification_trigger
AFTER INSERT ON comment
FOR EACH ROW
EXECUTE FUNCTION send_comment_notification();


CREATE OR REPLACE FUNCTION send_question_notification()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO notification (date, viewed, user_id, notification_type, question_id, answer_id, comment_id, vote_id, report_id, badge_id, game_id)
  SELECT NOW(), FALSE, qf.user_id, 'Question_notification', NULL, NEW.id, NULL, NULL, NULL, NULL, NULL
  FROM question_followers qf
  WHERE qf.question_id = NEW.question_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER question_answer_notification_trigger
AFTER INSERT ON answer
FOR EACH ROW
EXECUTE FUNCTION send_question_notification();


CREATE OR REPLACE FUNCTION send_vote_notification()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.vote_type = 'Question_vote' THEN
    INSERT INTO notification (date, viewed, user_id, notification_type, question_id, answer_id, comment_id, vote_id, report_id, badge_id, game_id)
    VALUES (NOW(), FALSE, (SELECT user_id FROM question WHERE id = NEW.question_id), 'Vote_notification', NULL, NULL, NULL, NEW.id, NULL, NULL, NULL);

  ELSIF NEW.vote_type = 'Answer_vote' THEN
    INSERT INTO notification (date, viewed, user_id, notification_type, question_id, answer_id, comment_id, vote_id, report_id, badge_id, game_id)
    VALUES (NOW(), FALSE, (SELECT user_id FROM answer WHERE id = NEW.answer_id), 'Vote_notification', NULL, NULL, NULL, NEW.id, NULL, NULL, NULL);

  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER vote_notification_trigger
AFTER INSERT ON vote
FOR EACH ROW
EXECUTE FUNCTION send_vote_notification();


CREATE OR REPLACE FUNCTION send_game_notification()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO notification (date, viewed, user_id, notification_type, question_id, answer_id, comment_id, vote_id, report_id, badge_id, game_id)
  SELECT NOW(), FALSE, gm.user_id, 'Game_notification', NEW.id, NULL, NULL, NULL, NULL, NULL, NULL
  FROM game_member gm
  WHERE gm.game_id = NEW.game_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER game_notification_trigger
AFTER INSERT ON question
FOR EACH ROW
EXECUTE FUNCTION send_game_notification();


CREATE OR REPLACE FUNCTION send_rank_notification()
RETURNS TRIGGER AS $$
BEGIN
  -- Insert a new row into the 'notification' table when the rank is changed
  IF NEW.rank <> OLD.rank THEN
    INSERT INTO notification (date, viewed, user_id, notification_type, question_id, answer_id, comment_id, vote_id, report_id, badge_id, game_id)
    VALUES (NOW(), FALSE, NEW.id, 'Rank_notification', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER rank_notification_trigger
AFTER UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION send_rank_notification();


CREATE OR REPLACE FUNCTION send_badge_notification()
RETURNS TRIGGER AS $$
BEGIN
  -- Insert a new row into the 'notification' table when a new badge is added
  IF TG_OP = 'INSERT' THEN
    INSERT INTO notification (date, viewed, user_id, notification_type, question_id, answer_id, comment_id, vote_id, report_id, badge_id, game_id)
    VALUES (NOW(), FALSE, NEW.user_id, 'Badge_notification', NULL, NULL, NULL, NULL, NULL, NEW.badge_id, NULL);

  -- Insert a new row into the 'notification' table when a badge is removed
  ELSIF TG_OP = 'DELETE' THEN
    INSERT INTO notification (date, viewed, user_id, notification_type, question_id, answer_id, comment_id, vote_id, report_id, badge_id, game_id)
    VALUES (NOW(), FALSE, OLD.user_id, 'Badge_notification', NULL, NULL, NULL, NULL, NULL, OLD.badge_id, NULL);

  END IF;

  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER badge_notification_trigger
AFTER INSERT OR DELETE ON user_badge
FOR EACH ROW
EXECUTE FUNCTION send_badge_notification();


CREATE OR REPLACE FUNCTION send_report_notification()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO notification (date, viewed, user_id, notification_type, question_id, answer_id, comment_id, vote_id, report_id, badge_id, game_id)
  SELECT NOW(), FALSE, us.id, 'Report_notification', NULL, NULL, NULL, NULL, NEW.id, NULL, NULL
  FROM users us
  WHERE us.is_admin;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Attach the trigger to the 'report' table
CREATE TRIGGER report_notification_trigger
AFTER INSERT ON report
FOR EACH ROW
EXECUTE FUNCTION send_report_notification();





--Trigger 12

-- A user cannot report themselves.

CREATE OR REPLACE FUNCTION prevent_self_reporting_trigger_function()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.reporter_id = NEW.reported_id THEN
    RAISE EXCEPTION 'Users cannot report themselves.';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER prevent_self_reporting_trigger
BEFORE INSERT ON report
FOR EACH ROW
EXECUTE FUNCTION prevent_self_reporting_trigger_function();

--Trigger 13

-- trigger to change the deleted user username to anonymous

CREATE OR REPLACE FUNCTION anonymous_user()
RETURNS TRIGGER AS $$
BEGIN
        UPDATE question SET user_id=1 WHERE user_id = OLD.id;
        UPDATE answer SET user_id=1 WHERE user_id = OLD.id;
        UPDATE comment SET user_id=1 WHERE user_id = OLD.id;
        UPDATE vote SET user_id=1 WHERE user_id = OLD.id;
        UPDATE report SET reporter_id=1 WHERE reporter_id = OLD.id;

        RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER anonymous_user
BEFORE DELETE ON users
FOR EACH ROW
EXECUTE FUNCTION anonymous_user();

-----------
-- Create transactions
-----------

-- Insert the content for the question only if the question exists
CREATE OR REPLACE FUNCTION AddQuestionContentVersion(question_id INT, content_id INT) RETURNS VOID AS $$
BEGIN
    BEGIN
        IF EXISTS (SELECT 1 FROM question WHERE id = question_id) THEN
            INSERT INTO version_content (id, date, content, content_type, question_id, answer_id, comment_id)
            VALUES (content_id, NOW(), 'content', 'question_content', question_id, NULL, NULL);
        ELSE
            RAISE EXCEPTION 'Question does not exist';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE EXCEPTION 'An error occurred';
    END;
END;
$$ LANGUAGE plpgsql;

-- Insert the content for an answer only if the question for that answer and the actual answer exists
CREATE OR REPLACE FUNCTION AddAnswerContentVersion(question_id INT, answer_id INT, content_id INT) RETURNS VOID AS $$
BEGIN
    BEGIN
        IF EXISTS (SELECT 1 FROM question WHERE id = question_id) AND EXISTS (SELECT 1 FROM answer WHERE id = answer_id) THEN
            INSERT INTO version_content (id, date, content, content_type, question_id, answer_id, comment_id)
            VALUES (content_id, NOW(), 'content_ans', 'answer_content', NULL, answer_id, NULL);
        ELSE
            RAISE EXCEPTION 'Question or answer does not exist';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE EXCEPTION 'An error occurred';
    END;
END;
$$ LANGUAGE plpgsql;

-- Insert the content for a comment only if the question for that comment and the actual comment exists
CREATE OR REPLACE FUNCTION AddCommentContentVersion(question_id INT, comment_id INT, content_id INT) RETURNS VOID AS $$
BEGIN
    BEGIN
        IF EXISTS (SELECT 1 FROM question WHERE id = question_id) AND EXISTS (SELECT 1 FROM comment WHERE id = comment_id) THEN
            INSERT INTO version_content (id, date, content, content_type, question_id, answer_id, comment_id)
            VALUES (content_id, NOW(), 'content', 'comment_content', NULL, NULL, comment_id);
        ELSE
            RAISE EXCEPTION 'Question or comment does not exist';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE EXCEPTION 'An error occurred';
    END;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION update_question_on_insert()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.content_type = 'Answer_content' THEN
        UPDATE question
        SET title = (SELECT title FROM question WHERE id = (SELECT question_id FROM answer WHERE id = NEW.answer_id))
        WHERE id = (SELECT question_id FROM answer WHERE id = NEW.answer_id);
    END IF;
    IF NEW.content_type = 'Question_content' THEN
        UPDATE question
        SET title = (SELECT title FROM question WHERE id = NEW.question_id)
        WHERE id = NEW.question_id;
    END IF;
     IF NEW.content_type = 'Comment_content' THEN
        UPDATE question
        SET title = (SELECT title FROM question WHERE id = (SELECT question_id FROM answer JOIN comment ON answer.id = comment.answer_id WHERE comment.id = NEW.comment_id))
        WHERE id = (SELECT question_id FROM answer JOIN comment ON answer.id = comment.answer_id WHERE comment.id = NEW.comment_id);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_question_trigger
AFTER INSERT ON version_content
FOR EACH ROW
EXECUTE FUNCTION update_question_on_insert();


CREATE OR REPLACE FUNCTION mark_question_solved()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE question
    SET is_solved = TRUE
    WHERE id = NEW.question_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_question_solved
AFTER UPDATE OF is_correct ON answer
FOR EACH ROW
WHEN (NEW.is_correct = TRUE)
EXECUTE FUNCTION mark_question_solved();


-----------
-- Create indexes
-----------

-- Index 1
CREATE INDEX question_author ON question USING hash (user_id);

-- Index 2
CREATE INDEX question_post_date ON question USING btree (create_date);

-- Index 3
CREATE INDEX game_nr_members ON game USING btree (nr_members);

-- Index 4
ALTER TABLE question 
ADD COLUMN tsvectors TSVECTOR;

-- Create a function to automatically update ts_vectors.
CREATE FUNCTION question_search_update() RETURNS TRIGGER AS $$ 
BEGIN 
  IF TG_OP = 'INSERT' THEN 
    NEW.tsvectors = (
        setweight(to_tsvector('english', COALESCE(NEW.title, '')), 'A') || 
        setweight(to_tsvector('english', COALESCE(
          (SELECT content FROM version_content WHERE question_id = NEW.id ORDER BY date DESC LIMIT 1), '')), 'B')  
      );
  END IF;
  IF TG_OP = 'UPDATE' THEN 
    NEW.tsvectors = (
      setweight(to_tsvector('english', NEW.title), 'A') || 
      setweight(to_tsvector('english', COALESCE((SELECT content FROM version_content WHERE question_id = NEW.id ORDER BY date DESC LIMIT 1), '')), 'B') || 
       setweight(to_tsvector('english', COALESCE(
          (SELECT STRING_AGG(latest_content.content, ' ')
          FROM answer
          JOIN (
              SELECT answer_id, MAX(date) AS max_date
              FROM version_content
              WHERE content_type = 'Answer_content'
              GROUP BY answer_id
          ) AS latest_date ON answer.id = latest_date.answer_id
          JOIN version_content AS latest_content ON latest_date.answer_id = latest_content.answer_id
              AND latest_date.max_date = latest_content.date WHERE answer.question_id = NEW.id), '')), 'C') ||
         setweight(to_tsvector('english', COALESCE(
            (SELECT STRING_AGG(latest_content.content, ' ')
            FROM comment
            JOIN (
                SELECT comment_id, MAX(date) AS max_date
                FROM version_content
                WHERE content_type = 'Comment_content'
                GROUP BY comment_id
            ) AS latest_date ON comment.id = latest_date.comment_id
            JOIN version_content AS latest_content ON latest_date.comment_id = latest_content.comment_id
                AND latest_date.max_date = latest_content.date 
                WHERE comment.answer_id IN 
                (SELECT id FROM answer WHERE question_id = NEW.id)), '')), 'D')
    );
  END IF;
  RETURN NEW;
END $$ 
LANGUAGE plpgsql;

-- Create a trigger before insert or update on question.
CREATE TRIGGER question_search_update 
  BEFORE INSERT OR UPDATE ON question 
  FOR EACH ROW 
  EXECUTE PROCEDURE question_search_update();

-- Finally, create a GIN index for ts_vectors.
CREATE INDEX search_question ON question USING GIN (tsvectors);



-- Index 6
ALTER TABLE game
ADD COLUMN tsvectors TSVECTOR;

-- Create a function to automatically update ts_vectors.
CREATE FUNCTION game_search_update() RETURNS TRIGGER AS $$ 
BEGIN 
  IF TG_OP = 'INSERT' THEN 
    NEW.tsvectors = (
      setweight(to_tsvector('english', NEW.name), 'A') || 
      setweight(to_tsvector('english', NEW.description), 'B')
    );
  END IF;
  IF TG_OP = 'UPDATE' THEN 
    IF (NEW.name <> OLD.name OR NEW.description <> OLD.description) THEN 
      NEW.tsvectors = (
        setweight(to_tsvector('english', NEW.name), 'A') || 
        setweight(to_tsvector('english', NEW.description), 'B')
      ); 
    END IF;
  END IF;
  RETURN NEW;
END $$ 
LANGUAGE plpgsql;

-- Create a trigger before insert or update on game.
CREATE TRIGGER game_search_update 
  BEFORE INSERT OR UPDATE ON game 
  FOR EACH ROW 
  EXECUTE PROCEDURE game_search_update();

-- Finally, create a GIN index for ts_vectors.
CREATE INDEX search_game ON game USING GIN (tsvectors);


-- Index 7
ALTER TABLE users
ADD COLUMN tsvectors TSVECTOR;

-- Create a function to automatically update ts_vectors.
CREATE FUNCTION user_search_update() RETURNS TRIGGER AS $$ 
BEGIN 
  IF TG_OP = 'INSERT' THEN 
    NEW.tsvectors = setweight(to_tsvector('english', NEW.description), 'A'); 
  END IF;
  IF TG_OP = 'UPDATE' THEN 
    IF (NEW.description <> OLD.description) THEN 
      NEW.tsvectors = setweight(to_tsvector('english', NEW.description), 'A');
    END IF;
  END IF;
  RETURN NEW;
END $$ 
LANGUAGE plpgsql;

-- Create a trigger before insert or update on users.
CREATE TRIGGER user_search_update 
 BEFORE INSERT OR UPDATE ON users 
 FOR EACH ROW 
 EXECUTE PROCEDURE user_search_update();

-- Finally, create a GIN index for ts_vectors.
CREATE INDEX search_user ON users USING GIN (tsvectors);


---POPULATE
INSERT INTO users(name, username, email, password, description, rank, is_admin, is_banned, profile_image) VALUES
('Anonymous', 'Anonymous', 'Null', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Null', 'Bronze', False, False, NULL),
('John Doe', 'johndoe', 'johndoe@example.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Some description', 'Bronze', True, False, '090PJ3bfsG7io3zBEURDsdxYNbIjrsdXoyUbMNgz.jpg'),
('Alice Johnson', 'alicej', 'alicejohnson@example.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Another description', 'Bronze', False, True, NULL),
('Michael Smith', 'mikesmith', 'mikesmith@example.com', '5d41402abc4b2a76b9719d911017c592', 'Description for Michael', 'Gold', True, False, NULL),
('Emily Davis', 'emilyd', 'emilydavis@example.com', '5d41402abc4b2a76b9719d911017c592', 'Emilys profile description', 'Bronze', False, True, NULL),
('David Wilson', 'davidw', 'davidwilson@example.com', '5d41402abc4b2a76b9719d911017c592', 'Description for David', 'Bronze', True, False, NULL),
('Sophia Brown', 'sophiab', 'sophiabrown@example.com', '5d41402abc4b2a76b9719d911017c592', 'Sophias profile description', 'Gold', False, True, NULL),
('Liam Lee', 'liaml', 'liamlee@example.com', '5d41402abc4b2a76b9719d911017c592', 'Description for Liam', 'Bronze', False, True, NULL),
('Olivia White', 'oliviaw', 'oliviawhite@example.com', '5d41402abc4b2a76b9719d911017c592', 'Olivias profile description', 'Bronze', False, True, NULL),
('Ethan Johnson', 'ethanj', 'ethanjohnson@example.com', '5d41402abc4b2a76b9719d911017c592', 'Ethans profile description', 'Gold', False, True, NULL),
('Ava Martinez', 'avam', 'avamartinez@example.com', '5d41402abc4b2a76b9719d911017c592', 'Avas profile description', 'Master', False, False, NULL),
('Noah Taylor', 'noaht', 'noahtaylor@example.com', '5d41402abc4b2a76b9719d911017c592', 'Description for Noah', 'Bronze', False, False, NULL),
('Evelyn Lee', 'evelynlee', 'evelynlee@example.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Gold', False, False, NULL),
('Nicholas Campbell', 'nicholascampbell', 'nicholascampbell@example.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Gold', False, False, NULL),
('Aria Scott', 'ariascott', 'ariascott@example.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Bronze', False, False, NULL),
('Jacob Johnson', 'jacobjohnson', 'jacobjohnson@example.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Gold', False, False, NULL),
('Lily White', 'lilywhite', 'lilywhite@example.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Bronze', False, False, NULL),
('Ethan Adams', 'ethanadams', 'ethanadams@example.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Gold', False, False, NULL),
('Isabella Martin', 'isabellamartin', 'isabellamartin@example.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Bronze', False, False, NULL),
('James Brown', 'jamesbrown', 'jamesbrown@example.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Gold', False, False, NULL),
('Avery Taylor', 'averytaylor', 'averytaylor@example.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Bronze', False, False, NULL),
('Emma Rodriguez', 'emmar', 'emmar@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Bronze', False, False, NULL),
('William Garcia', 'williamg', 'williamg@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Bronze', False, False, NULL),
('Madison Martinez', 'madisonm', 'madisonm@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Gold', False, False, NULL),
('James Hernandez', 'jamesh', 'jamesh@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Bronze', False, False, NULL),
('Mason Moore', 'masonm', 'masonm@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Bronze', False, False, NULL),
('Avery Lee', 'averyl', 'averyl@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Gold', False, False, NULL),
('Evelyn Clark', 'evelync', 'evelync@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Gold', False, False, NULL),
('Elijah Perez', 'elijahp', 'elijahp@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Gold', False, False, NULL),
('Lillian Young', 'lilliany', 'lilliany@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Bronze', False, False, NULL),
('Logan Allen', 'logana', 'logana@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Bronze', False, False, NULL),
('Aria Wright', 'ariaw', 'ariaw@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Bronze', False, False, NULL),
('Caleb King', 'calebk', 'calebk@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Bronze', False, False, NULL),
('Abigail Scott', 'abigails', 'abigails@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Bronze', False, False, NULL),
('Owen Green', 'oweng', 'oweng@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Master', False, False, NULL),
('Amelia Baker', 'ameliab', 'ameliab@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Bronze', False, False, NULL),
('Luke Adams', 'lukea', 'lukea@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Bronze', False, False, NULL),
('Harper Nelson', 'harpern', 'harpern@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Bronze', False, False, NULL),
('Levi Carter', 'levic', 'levic@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Bronze', False, False, NULL),
('Emily Mitchell', 'emilym', 'emilym@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Gold', False, False, NULL),
('Carter Perez', 'carterp', 'carterp@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Bronze', False, False, NULL),
('Samantha Lee', 'samanthalee', 'samanthalee@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Bronze', False, False, NULL),
('David Chen', 'davidchen', 'davidchen@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Bronze', False, False, NULL),
('Maria Rodriguez', 'mariarodriguez', 'mariarodriguez@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Gold', False, False, NULL),
('Mohammed Ali', 'mohammedali', 'mohammedali@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Bronze', False, False, NULL),
('Julia Wang', 'juliawang', 'juliawang@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Gold', False, False, NULL),
('Sophia Kim', 'sophiakim', 'sophiakim@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Bronze', False, False, NULL),
('William Davis', 'williamdavis', 'williamdavis@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Bronze', False, False, NULL),
('Gabriel Martinez', 'gabrielmartinez', 'gabrielmartinez@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Gold', False, False, NULL),
('Emma Johnson', 'emmajohnson', 'emmajohnson@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Bronze', False, False, NULL),
('Alexander Brown', 'alexanderbrown', 'alexanderbrown@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Gold', False, False, NULL),
('Sophie Anderson', 'sophieanderson', 'sophieanderson@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Master', False, False, NULL),
('Hiroshi Nakamura', 'hiroshinakamura', 'hiroshinakamura@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Bronze', False, False, NULL),
('Laura Garcia', 'lauragarcia', 'lauragarcia@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Bronze', False, False, NULL),
('Jacob Kim', 'jacobkim', 'jacobkim@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Master', False, False, NULL),
('Mia Davis', 'miadavis', 'miadavis@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Bronze', False, False, NULL),
('Ethan Nguyen', 'ethannguyen', 'ethannguyen@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Gold', False, False, NULL),
('Lily Chen', 'lilychen', 'lilychen@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Master', False, False, NULL),
('Lucas Perez', 'lucasperez', 'lucasperez@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Bronze', False, False, NULL),
('Ava Wilson', 'avawilson', 'avawilson@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Gold', False, False, NULL),
('Nathan Kim', 'nathankim', 'nathankim@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Bronze', False, False, NULL),
('Ella Hernandez', 'ellahernandez', 'ellahernandez@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Bronze', False, False, NULL),
('Sebastian Kim', 'sebastiankim', 'sebastiankim@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Bronze', False, False, NULL),
('Aaliyah Lee', 'aaliyahlee', 'aaliyahlee@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Bronze', False, False, NULL),
('Maxwell Young', 'maxwellyoung', 'maxwellyoung@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Bronze', False, False, NULL),
('Hazel Turner', 'hazelturner', 'hazelturner@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Bronze', False, False, NULL),
('Miles Mitchell', 'milesmitchell', 'milesmitchell@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Gold', False, False, NULL),
('Ariana Scott', 'arianascott', 'arianascott@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Bronze', False, False, NULL),
('Samantha Allen', 'samanthaallen', 'samanthaallen@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Bronze', False, False, NULL),
('Landon Green', 'landongreen', 'landongreen@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Bronze', False, False, NULL),
('Nora Baker', 'norabaker', 'norabaker@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Bronze', False, False, NULL),
('Adam Clark', 'adamclark', 'adamclark@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Bronze', False, False, NULL),
('Emily Rodriguez', 'emilyrodriguez', 'emilyrodriguez@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Bronze', False, False, NULL),
('Benjamin Davis', 'benjamindavis', 'benjamindavis@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Bronze', False, False, NULL),
('Olivia Lee', 'olivialeee', 'olivialeee@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W','Description for Noah', 'Master', False, False, NULL),
('Henry Martinez', 'henrymartinez', 'henrymartinez@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Bronze', False, False, NULL),
('Sophia Hernandez', 'sophiahernandez', 'sophiahernandez@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Bronze', False, False, NULL),
('Michael Adams', 'michaeladams', 'michaeladams@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Master', False, False, NULL),
('Isabella Lewis', 'isabellalewis', 'isabellalewis@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Bronze', False, False, NULL),
('William Jackson', 'williamjackson', 'williamjackson@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Gold', False, False, NULL), 
('Mia Garcia', 'miagarcia', 'miagarcia@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Bronze', False, False, NULL),
('Alexander Nelson', 'alexandernelson', 'alexandernelson@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Bronze', False, False, NULL),
('Abigail White', 'abigailwhite', 'abigailwhite@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W','Description for Noah', 'Bronze', False, False, NULL),
('David Gonzalez', 'davidgonzalez', 'davidgonzalez@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Master', False, False, NULL),
('Victoria Turner', 'victoriaturner', 'victoriaturner@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Bronze', False, False, NULL),
('Christopher Parker', 'christopherparker', 'christopherparker@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Master', False, False, NULL),
('Elizabeth Perez', 'elizabethperez', 'elizabethperez@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Bronze', False, False, NULL),
('Daniel Taylor', 'danieltaylor', 'danieltaylor@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Master', False, False, NULL),
('Evelyn Collins', 'evelyncollins', 'evelyncollins@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Bronze', False, False, NULL),
('Matthew Hernandez', 'matthewhernandez', 'matthewhernandez@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Gold', False, False, NULL),
('Sofia Adams', 'sofiaadams', 'sofiaadams@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Bronze', False, False, NULL),
('Ethan Cooper', 'ethancooper', 'ethancooper@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Bronze', False, False, NULL),
('Avery Jackson', 'averyjackson', 'averyjackson@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Gold', False, False, NULL),
('Evelyn Hill', 'evelynhill', 'evelynhill@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Bronze', False, False, NULL),
('Aiden Parker', 'aidenparker', 'aidenparker@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Bronze', False, False, NULL),
('Madison Adams', 'madisonadams', 'madisonadams@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Bronze', False, False, NULL),
('Oliver Wright', 'oliverwright', 'oliverwright@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Gold', False, False, NULL),
('Brooklyn Lewis', 'brooklynlewis', 'brooklynlewis@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Bronze', False, False, NULL),
('Jacob Green', 'jacobgreen', 'jacobgreen@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Bronze', False, False, NULL),
('Chloe Hall', 'chloehall', 'chloehall@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Bronze', False, False, 'mon1ibfltwHdUPhHBpDQGIWsyyh569SRQomxuCdK.jpg'),
('Miala Davis', 'mialadavis', 'mialadavis@email.com', '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W', 'Description for Noah', 'Gold', False, False, NULL);

INSERT INTO badge(name) VALUES
('Best_comment'),
('Inquisitive_Pro'),
('Well_Rounded'),
('Diamond_Dog'),
('Griefer');

INSERT INTO game_category(name, description) VALUES
('Action', 'These games focus on physical challenges, hand-eye coordination, and reaction time. Examples include platformers, beat em ups, and hack-and-slash games.'), 
('Adventure', 'Adventure games emphasize story-driven gameplay, puzzle-solving, and exploration. Players often navigate through a narrative, making decisions that influence the games outcome.'), 
('Role-Playing', 'RPGs allow players to assume the role of a character in a fictional world. Players often embark on quests, level up, and engage in battles, enhancing their characters abilities and stats.'), 
('Shooter', 'Shooter games are centered around combat where players use ranged weapons to eliminate enemies. They can be first-person shooters (FPS) or third-person shooters (TPS).'), 
('Simulation', 'Simulation games aim to replicate real-world activities, professions, or scenarios. This category includes flight simulators, life simulations, and business management games.'), 
('Strategy', 'Strategy games require players to plan and make decisions to achieve specific goals. They can be turn-based or real-time and often involve resource management, tactical maneuvers, and base-building.'), 
('Sports', 'Sports games simulate real-world sports such as soccer, basketball, football, and racing. Players can compete individually or in teams, replicating the rules and gameplay of the respective sports.'), 
('Horror', 'Horror games are designed to create a sense of fear and suspense. They often feature dark or eerie environments, supernatural elements, and intense gameplay to evoke fear and tension in players.'), 
('Puzzle', 'Puzzle games challenge players with logic, pattern recognition, and problem-solving tasks. These games can range from simple puzzles to complex brain teasers and often require creative thinking.'), 
('Massively Multiplayer Online', 'MMOs allow a large number of players to interact and play in a virtual world simultaneously. Players can collaborate, compete, and socialize with others from around the world in games like MMORPGs (Massively Multiplayer Online Role-Playing Games).');

INSERT INTO game(name, description, nr_members, game_category_id, game_image) VALUES
('Super Mario Bros', 'Super Mario Bros. is a classic platformer where players control Mario as he navigates the Mushroom Kingdom to rescue Princess Peach from the villainous Bowser. The game features iconic side-scrolling levels filled with enemies, obstacles, and power-ups.', 0, 1, 'AaFIpQvNikeEOn5pQ1pG7R0paN4xlb8KEkJ2tbd4.jpg'),
('Devil May Cry', 'Devil May Cry follows the adventures of Dante, a demon hunter with supernatural abilities. Players battle hordes of demons using stylish combos and acrobatic moves, earning style points for their performance.', 0, 1, 'fxdAzlK6kQkNlJUO621IErsrNxtqJ9WKC7WgZotL.jpg'),
('Ninja Gaiden', 'Ninja Gaiden is an action-adventure game series where players take on the role of a skilled ninja, Ryu Hayabusa. Players engage in fast-paced combat, solving puzzles, and exploring a dark and mystical world.', 0, 1, 'IYVDbdB8yaUVYmO3H95ufFt47kmB5pDjPkkLykXx.jpg'),
('Metal Gear Rising: Revengeance', 'In this game, players control Raiden, a cyborg ninja, in a futuristic world. Combining elements of beat "em up and hack-and-slash, players engage in intense sword fights and stealthy missions.', 0, 1, '0ZyCXidJflakijoe8jrLQUwInrmFbwEdh5T09gdx.jpg'),
('Bayonetta', 'Bayonetta is a stylish hack-and-slash game featuring a witch named Bayonetta. Players execute graceful and brutal combos using various weapons and magical attacks while battling angels and demons.', 0, 1, 'nq84GoFRqFEHvDzB1cj2qwaiOmdczWqWa7TxL8CF.jpg'),
('Dark Souls', 'Dark Souls is an action RPG known for its challenging combat and deep lore. Players explore a dark fantasy world, battling formidable enemies and bosses while discovering the interconnected story.', 0, 1, 'ShsbEXD8ufAGN8jJoKJhR70mkHQt0YCKEw8JQkOm.jpg'),
('God of War', 'God of War follows Kratos, a former Greek god, and his son Atreus in their journey through Norse mythology. Players experience intense combat, puzzle-solving, and a compelling narrative in a beautifully crafted world.', 0, 1, 'vv4xPk2LeIKZus7pPOcjzAXW6pLem9wCZQQmnFCp.jpg'),
('Assassins Creed Series', 'Assassin"s Creed games follow assassins throughout various historical periods. Players engage in stealthy assassinations, parkour, and combat, uncovering intricate plots involving secret organizations.', 0, 1, '6nZAWp5kWbw1CH4Rb5YJlAvtVvCmFz5HiHRFkpHB.jpg'),
('Spider-Man', 'In Spider-Man, players swing through an open-world New York City as the iconic superhero. The game combines acrobatic combat, web-slinging traversal, and a compelling story as players battle classic villains.', 0, 1, NULL),
('Hollow Knight', 'Hollow Knight is a Metroidvania-style action-adventure game set in a mysterious underground world. Players control a knight exploring intricate environments, battling enemies, and uncovering secrets, all with a beautiful hand-drawn art style.', 0, 1, 'tgCRirdTJqpf9Qvk0QiEIEq1zwIfRc7yJ6xsAdmF.jpg'),
('The Legend of Zelda: Breath of the Wild', 'In this action-adventure game, players control Link, who explores the vast kingdom of Hyrule, solving puzzles, battling enemies, and uncovering the secrets of an ancient civilization.', 0, 2, 'AaFIpQvNikeEOn5pQ1pG7R0paN4xlb8KEkJ2tbd4.jpg'),
('Red Dead Redemption 2', 'Set in the American Wild West, this game follows Arthur Morgan, a member of the Van der Linde gang, as he navigates the changing times and struggles for survival. Players engage in shootouts, manage their gang, and make moral choices that affect the story.', 0, 2, 'tgCRirdTJqpf9Qvk0QiEIEq1zwIfRc7yJ6xsAdmF.jpg'),
('Grim Fandango', 'Players assume the role of Manny Calavera, a travel agent in the Land of the Dead, in this noir-inspired adventure game. Manny uncovers a conspiracy that spans the afterlife, leading to a captivating journey filled with humor and mystery.', 0, 2, '0ZyCXidJflakijoe8jrLQUwInrmFbwEdh5T09gdx.jpg'),
('The Walking Dead: Telltale Series', 'Based on the popular comic and TV series, this game emphasizes player choices. Players control different characters in a zombie apocalypse, making decisions that affect the storyline and relationships with other survivors.', 0, 2, 'fxdAzlK6kQkNlJUO621IErsrNxtqJ9WKC7WgZotL.jpg'),
('Detroit: Become Human', 'Set in a future where androids serve humans, players control multiple android characters, each with their own storylines. The game explores themes of artificial intelligence, freedom, and identity, with players making decisions that shape the outcome.', 0, 2, 'IYVDbdB8yaUVYmO3H95ufFt47kmB5pDjPkkLykXx.jpg'),
('Firewatch', 'Players assume the role of a fire lookout named Henry in the Wyoming wilderness. Through radio conversations with his supervisor, Delilah, players unravel a mystery and make choices that affect the relationship between the characters.', 0, 2, 'nq84GoFRqFEHvDzB1cj2qwaiOmdczWqWa7TxL8CF.jpg'),
('Heavy Rain', 'A psychological thriller where players control four characters involved in the investigation of the Origami Killer, a serial murderer who uses prolonged rainfall to drown his victims. Choices made by players influence the games plot and multiple endings.', 0, 2, 'vv4xPk2LeIKZus7pPOcjzAXW6pLem9wCZQQmnFCp.jpg'),
('Oxenfree', 'A supernatural thriller about a group of friends who accidentally open a ghostly rift while on a trip. Players control Alex, a teenager, making decisions in dialogues that affect the story and relationships. The game features a unique radio mechanic for communication with the supernatural entities.', 0, 2, '6nZAWp5kWbw1CH4Rb5YJlAvtVvCmFz5HiHRFkpHB.jpg'),
('The Elder Scrolls V: Skyrim', 'An open-world action RPG set in the fantasy world of Tamriel. Players assume the role of the Dragonborn, a hero prophesized to save the world from dragons. Players can explore a vast, detailed world, complete quests, and develop their characters skills and abilities.', 0, 3, 'AaFIpQvNikeEOn5pQ1pG7R0paN4xlb8KEkJ2tbd4.jpg'),
('Final Fantasy VII', 'A classic Japanese RPG (JRPG) set in the fictional world of Gaia. Players follow the story of Cloud Strife and his friends as they battle the mega-corporation Shinra and a powerful villain named Sephiroth. Known for its deep narrative, memorable characters, and turn-based combat.', 0, 3, NULL),
('The Witcher 3: Wild Hunt', 'An action RPG based on the book series by Andrzej Sapkowski. Players control Geralt of Rivia, a monster hunter (Witcher), in a morally ambiguous fantasy world. The game features a rich storyline, complex characters, and a vast open world with numerous quests and activities.', 0, 3, 'ShsbEXD8ufAGN8jJoKJhR70mkHQt0YCKEw8JQkOm.jpg'),
('Dark Souls Series', 'Known for their challenging gameplay and intricate lore, the Dark Souls games are action RPGs set in dark fantasy worlds. Players navigate treacherous environments, battle tough enemies, and engage in methodical combat. The series emphasizes exploration and discovery.', 0, 3, 'vv4xPk2LeIKZus7pPOcjzAXW6pLem9wCZQQmnFCp.jpg'),
('Mass Effect Series', 'A sci-fi RPG where players assume the role of Commander Shepard, tasked with saving the galaxy from various threats, including a race of sentient machines known as Reapers. Players make choices that affect the games story, relationships, and ultimate outcome.', 0, 3, '0ZyCXidJflakijoe8jrLQUwInrmFbwEdh5T09gdx.jpg'),
('Persona 5', 'A JRPG that combines traditional turn-based combat with life simulation elements. Players control a group of high school students who double as supernatural thieves. They balance school life, friendships, and battling supernatural forces in an alternate reality.', 0, 3, 'nq84GoFRqFEHvDzB1cj2qwaiOmdczWqWa7TxL8CF.jpg'),
('Diablo III', 'A dark fantasy action RPG featuring fast-paced combat and loot-driven gameplay. Players choose a character class and embark on quests to defeat hordes of enemies and powerful bosses. The game is known for its cooperative multiplayer and extensive item customization.', 0, 3, 'tgCRirdTJqpf9Qvk0QiEIEq1zwIfRc7yJ6xsAdmF.jpg'),
('World of Warcraft 2', 'An MMORPG set in the high fantasy world of Azeroth. Players create characters from various races and classes, undertake quests, explore dungeons, and engage in player-vs-environment and player-vs-player activities. Its one of the most iconic and enduring MMORPGs in the world.', 0, 3, 'fxdAzlK6kQkNlJUO621IErsrNxtqJ9WKC7WgZotL.jpg'),
('Pokémon Series', 'A series of RPGs where players, known as Pokémon Trainers, capture and train creatures called Pokémon. Players battle other trainers, collect Pokémon, and compete to become the Pokémon Champion. Each game introduces new Pokémon species and regions to explore.', 0, 3, 'IYVDbdB8yaUVYmO3H95ufFt47kmB5pDjPkkLykXx.jpg'),
('Dragon Age: Inquisition', 'n action RPG set in the fictional continent of Thedas. Players become the Inquisitor, tasked with saving the world from a civil unrest and a mysterious tear in the fabric of reality. The game features a rich narrative, strategic combat, and complex character relationships. Players choices significantly impact the games story and world.', 0, 3, '6nZAWp5kWbw1CH4Rb5YJlAvtVvCmFz5HiHRFkpHB.jpg'),
('Call of Duty Series', 'Call of Duty is a highly popular first-person shooter series known for its intense single-player campaigns and competitive multiplayer modes. It covers various historical periods and modern warfare scenarios.', 0, 4, 'AaFIpQvNikeEOn5pQ1pG7R0paN4xlb8KEkJ2tbd4.jpg'),
('Halo Series', 'Halo is a science fiction FPS series set in a futuristic universe. Players assume the role of Master Chief, a supersoldier, and engage in battles against alien forces. Its known for its compelling story and innovative multiplayer modes.', 0, 4, 'nq84GoFRqFEHvDzB1cj2qwaiOmdczWqWa7TxL8CF.jpg'),
('Counter-Strike: Global Offensive', 'Counter-Strike: Global Offensive (CS:GO) is a competitive multiplayer first-person shooter. Players join teams of terrorists and counter-terrorists and engage in objective-based missions, emphasizing strategy and precise aiming.', 0, 4, 'vv4xPk2LeIKZus7pPOcjzAXW6pLem9wCZQQmnFCp.jpg'),
('Overwatch', 'Overwatch is a team-based first-person shooter featuring a diverse cast of heroes, each with unique abilities. Players work together in objective-based game modes, emphasizing teamwork, hero selection, and strategic use of character skills.', 0, 4, 'fxdAzlK6kQkNlJUO621IErsrNxtqJ9WKC7WgZotL.jpg'),
('Destiny 2', 'Destiny 2 combines FPS gameplay with elements of MMO and RPG. Players assume the role of Guardians, exploring different planets, battling aliens, and participating in cooperative and competitive multiplayer activities.', 0, 4, 'ShsbEXD8ufAGN8jJoKJhR70mkHQt0YCKEw8JQkOm.jpg'),
('Gears of War Series', 'Gears of War is a third-person shooter series known for its cover-based combat mechanics. Players fight against a race of subterranean creatures using a mix of firearms and melee attacks, often with a focus on cooperative gameplay.', 0, 4, '0ZyCXidJflakijoe8jrLQUwInrmFbwEdh5T09gdx.jpg'),
('Max Payne Series', 'Max Payne is a neo-noir third-person shooter featuring a troubled protagonist who battles corruption and criminals. The series is known for its intense storytelling, bullet time mechanics, and graphic novel-style presentation.', 0, 4, NULL),
('Uncharted Series', 'Uncharted is a third-person shooter series following the adventures of Nathan Drake, a treasure hunter. Players explore exotic locations, solve puzzles, and engage in intense gunfights, with a strong emphasis on cinematic storytelling.', 0, 4, '6nZAWp5kWbw1CH4Rb5YJlAvtVvCmFz5HiHRFkpHB.jpg'),
('Fortnite', 'Fortnite is a battle royale game where 100 players compete to be the last person or team standing. Players scavenge for weapons, build structures for defense, and engage in fast-paced battles in a vibrant, destructible world.', 0, 4, 'tgCRirdTJqpf9Qvk0QiEIEq1zwIfRc7yJ6xsAdmF.jpg'),
('Apex Legends', 'Apex Legends is a team-based battle royale game where players select unique characters with special abilities. Teams of three players compete for victory, utilizing their chosen characters skills in a fast-paced, squad-oriented battle royale experience.', 0, 4, 'IYVDbdB8yaUVYmO3H95ufFt47kmB5pDjPkkLykXx.jpg'),
('The Sims Series', 'The Sims is a life simulation game where players create and control virtual people, guiding them through various aspects of their lives, such as relationships, careers, and daily activities.', 0, 5, 'AaFIpQvNikeEOn5pQ1pG7R0paN4xlb8KEkJ2tbd4.jpg'),
('Microsoft Flight Simulator', 'A highly realistic flight simulation game that allows players to pilot a wide range of aircraft, exploring detailed and accurate representations of real-world locations.', 0, 5, 'fxdAzlK6kQkNlJUO621IErsrNxtqJ9WKC7WgZotL.jpg'),
('SimCity Series', 'SimCity is a city-building simulation game where players act as mayors, building and managing cities by controlling various aspects such as zoning, infrastructure, and economic development.', 0, 5, 'nq84GoFRqFEHvDzB1cj2qwaiOmdczWqWa7TxL8CF.jpg'),
('Farming Simulator Series', 'Farming Simulator is a farming simulation game where players manage farms, cultivating crops, raising livestock, and handling various aspects of agricultural life.', 0, 5, NULL),
('Cities: Skylines', 'A city-building simulation game that focuses on urban planning and management. Players build and manage cities, balancing the needs of the population, infrastructure, and economy.', 0, 5, 'ShsbEXD8ufAGN8jJoKJhR70mkHQt0YCKEw8JQkOm.jpg'),
('Euro Truck Simulator 2', 'A truck driving simulation game where players become truck drivers, transporting goods across Europe, managing their own trucking business, and experiencing the challenges of the road.', 0, 5, '0ZyCXidJflakijoe8jrLQUwInrmFbwEdh5T09gdx.jpg'),
('Planet Coaster', 'A theme park simulation game that allows players to design and manage their own amusement parks, including creating rides, landscaping, and managing the parks finances.', 0, 5, '6nZAWp5kWbw1CH4Rb5YJlAvtVvCmFz5HiHRFkpHB.jpg'),
('RollerCoaster Tycoon Series', 'Similar to Planet Coaster, RollerCoaster Tycoon is a classic theme park simulation game where players design, build, and manage amusement parks, including roller coasters and other attractions.', 0, 5, 'vv4xPk2LeIKZus7pPOcjzAXW6pLem9wCZQQmnFCp.jpg'),
('Football Manager Series', 'A sports management simulation game where players take on the role of a football (soccer) manager, controlling team tactics, transfers, and other aspects of managing a football club.', 0, 5, 'tgCRirdTJqpf9Qvk0QiEIEq1zwIfRc7yJ6xsAdmF.jpg'),
('Kerbal Space Program', 'A space flight simulation game that allows players to design and manage their own space program. Players build spacecraft, launch them into orbit, and explore celestial bodies within a realistic physics-based environment.', 0, 5, 'IYVDbdB8yaUVYmO3H95ufFt47kmB5pDjPkkLykXx.jpg'),
('Civilization Series', 'Civilization games are turn-based strategy games where players build and expand an empire throughout history. Players manage resources, research technologies, engage in diplomacy, and lead their civilization to victory through various means, such as science, culture, or military conquest.', 0, 6, 'AaFIpQvNikeEOn5pQ1pG7R0paN4xlb8KEkJ2tbd4.jpg'),
('StarCraft', 'StarCraft is a real-time strategy (RTS) game set in a futuristic science fiction universe. Players choose between three unique factions and compete to gather resources, build armies, and engage in strategic battles. The game emphasizes resource management, unit tactics, and base building.', 0, 6, 'vv4xPk2LeIKZus7pPOcjzAXW6pLem9wCZQQmnFCp.jpg'),
('Age of Empires', 'Age of Empires is a historical real-time strategy series where players lead civilizations from different eras, managing resources, constructing buildings, training armies, and engaging in battles. Each game in the series focuses on a different historical period, allowing players to experience various civilizations and their unique units and technologies.', 0, 6, NULL),
('Total War', 'Total War games combine turn-based strategy with real-time tactical battles. Players manage cities, engage in diplomacy, and conduct research on a world map. When battles occur, players command their armies in detailed real-time engagements, emphasizing strategy, positioning, and unit abilities.', 0, 6, 'nq84GoFRqFEHvDzB1cj2qwaiOmdczWqWa7TxL8CF.jpg'),
('XCOM Series', 'XCOM games are turn-based tactical strategy games where players lead a global organization defending Earth from alien threats. Players manage resources, research alien technology, train soldiers, and engage in turn-based combat against extraterrestrial enemies. Permadeath of characters adds a layer of tension and decision-making to the gameplay.', 0, 6, '6nZAWp5kWbw1CH4Rb5YJlAvtVvCmFz5HiHRFkpHB.jpg'),
('Company of Heroes', 'Company of Heroes is an RTS series set during World War II. Players control military units, including infantry, tanks, and artillery, in dynamic and strategic battles. The games emphasize tactical gameplay, cover mechanics, and environmental destruction, providing a realistic and immersive combat experience.', 0, 6, 'tgCRirdTJqpf9Qvk0QiEIEq1zwIfRc7yJ6xsAdmF.jpg'),
('Warcraft III: Reign of Chaos', 'Warcraft III is an RTS game set in the high-fantasy world of Azeroth. Players control hero units and armies, gather resources, build bases, and engage in battles. The game introduced powerful hero characters with unique abilities, adding a role-playing element to the traditional RTS formula.', 0, 6, 'ShsbEXD8ufAGN8jJoKJhR70mkHQt0YCKEw8JQkOm.jpg'),
('Command & Conquer Series', 'Command & Conquer games are classic RTS titles featuring futuristic and modern warfare scenarios. Players build bases, gather resources, and command armies in fast-paced battles. The series is known for its diverse factions, unique unit designs, and engaging single-player campaigns.', 0, 6, '0ZyCXidJflakijoe8jrLQUwInrmFbwEdh5T09gdx.jpg'),
('Sid Meiers Alpha Centauri', 'Alpha Centauri is a turn-based strategy game set in a science fiction future on an alien planet. Players lead one of several factions, each with unique ideologies and technologies. The game focuses on exploration, resource management, and diplomacy, allowing players to shape the future of humanity on the new world.', 0, 6, 'fxdAzlK6kQkNlJUO621IErsrNxtqJ9WKC7WgZotL.jpg'),
('Advance Wars', 'Advance Wars is a turn-based strategy series featuring colorful, grid-based battles. Players command military units on maps, capturing cities, managing resources, and engaging in tactical warfare. The series is known for its accessible gameplay and challenging strategic depth.', 0, 6, 'IYVDbdB8yaUVYmO3H95ufFt47kmB5pDjPkkLykXx.jpg'),
('FIFA', 'FIFA is a popular soccer (football) simulation game series developed by EA Sports. It offers realistic gameplay, featuring teams and players from various leagues worldwide. Players can enjoy single matches, tournaments, and career modes.', 0, 7, 'AaFIpQvNikeEOn5pQ1pG7R0paN4xlb8KEkJ2tbd4.jpg'),
('NBA 2K', 'NBA 2K is a basketball simulation game series renowned for its realistic graphics and gameplay. It allows players to experience the NBA life, featuring teams, players, and arenas from the National Basketball Association.', 0, 7, '0ZyCXidJflakijoe8jrLQUwInrmFbwEdh5T09gdx.jpg'),
('Madden NFL', 'Madden NFL is an American football video game series developed by EA Sports. It simulates the National Football League (NFL) and offers gameplay modes like franchise management, player careers, and competitive online matches.', 0, 7, 'vv4xPk2LeIKZus7pPOcjzAXW6pLem9wCZQQmnFCp.jpg'),
('Rocket League', 'Rocket League combines soccer with rocket-powered cars. Players control customizable cars to score goals on the opposing team. It is a high-octane, physics-based game that offers both casual and competitive gameplay.', 0, 7, 'nq84GoFRqFEHvDzB1cj2qwaiOmdczWqWa7TxL8CF.jpg'),
('WWE 2K', 'WWE 2K is a wrestling simulation game based on the WWE (World Wrestling Entertainment) franchise. Players can control their favorite WWE superstars, engage in matches, and experience various game modes like career and universe mode.', 0, 7, 'fxdAzlK6kQkNlJUO621IErsrNxtqJ9WKC7WgZotL.jpg'),
('Gran Turismo Series', 'Gran Turismo is a highly realistic racing simulation game series known for its attention to detail in car physics and racing tracks. It features a vast selection of cars and offers players the ability to tune and customize their vehicles.', 0, 7, 'tgCRirdTJqpf9Qvk0QiEIEq1zwIfRc7yJ6xsAdmF.jpg'),
('Tony Hawks Pro Skater', 'This series focuses on skateboarding, allowing players to perform tricks, complete challenges, and explore various skate parks. Its known for its intuitive controls and level design.', 0, 7, 'ShsbEXD8ufAGN8jJoKJhR70mkHQt0YCKEw8JQkOm.jpg'),
('EA Sports UFC Series', 'EA Sports UFC is a mixed martial arts (MMA) simulation game series featuring UFC fighters and events. Players can engage in realistic MMA fights, showcasing different fighting styles and techniques.', 0, 7, 'IYVDbdB8yaUVYmO3H95ufFt47kmB5pDjPkkLykXx.jpg'),
('Pro Evolution Soccer', 'Pro Evolution Soccer (PES) is a soccer simulation game series that emphasizes realistic gameplay and player animations. It offers various modes, including leagues, cups, and online multiplayer matches.', 0, 7, NULL),
('Mario Kart Series', 'Mario Kart is a kart racing game series featuring characters from the Mario franchise. Players race on colorful tracks, use power-ups, and compete against each other in both single-player and multiplayer modes.', 0, 7, '6nZAWp5kWbw1CH4Rb5YJlAvtVvCmFz5HiHRFkpHB.jpg'),
('Resident Evil', 'A survival horror franchise where players face hordes of zombies and other supernatural enemies. Known for its intense gameplay, challenging puzzles, and gripping storylines.', 0, 8, 'AaFIpQvNikeEOn5pQ1pG7R0paN4xlb8KEkJ2tbd4.jpg'),
('Silent Hill', 'Players navigate a mysterious town filled with disturbing creatures and psychological horrors. The series is renowned for its atmospheric tension and surreal, psychological narrative.', 0, 8, 'ShsbEXD8ufAGN8jJoKJhR70mkHQt0YCKEw8JQkOm.jpg'),
('Dead Space', 'Set in a futuristic space environment, players battle grotesque alien creatures and solve engineering puzzles. Known for its strategic dismemberment gameplay and eerie ambiance.', 0, 8, NULL),
('Amnesia: The Dark Descent', 'A first-person survival horror game emphasizing puzzle-solving and evasion of monstrous entities. Players explore a dark castle, solving mysteries while struggling to maintain sanity.', 0, 8, '0ZyCXidJflakijoe8jrLQUwInrmFbwEdh5T09gdx.jpg'),
('Outlast', 'Players assume the role of an investigative journalist exploring an insane asylum. Armed only with a camera, they must navigate dark corridors, avoiding deranged inmates and uncovering unsettling truths.', 0, 8, 'vv4xPk2LeIKZus7pPOcjzAXW6pLem9wCZQQmnFCp.jpg'),
('Alien: Isolation', 'Set in the Alien universe, players must survive against a single, relentless Xenomorph. Stealth and resourcefulness are key as players solve puzzles and avoid the alien predator.', 0, 8, 'fxdAzlK6kQkNlJUO621IErsrNxtqJ9WKC7WgZotL.jpg'),
('Until Dawn', 'A narrative-driven horror game where players make choices that affect the storys outcome. Set in a remote mountain lodge, players must keep a group of young adults alive amid various horror movie scenarios.', 0, 8, 'nq84GoFRqFEHvDzB1cj2qwaiOmdczWqWa7TxL8CF.jpg'),
('Layers of Fear', 'An exploration-focused horror game centered around a disturbed painter unraveling the secrets of his mansion. The environment changes dynamically, creating a haunting and immersive experience.', 0, 8, 'tgCRirdTJqpf9Qvk0QiEIEq1zwIfRc7yJ6xsAdmF.jpg'),
('Soma', 'A science fiction horror game exploring themes of consciousness and identity. Players navigate an underwater facility, solving puzzles and making moral decisions that impact the storys direction.', 0, 8, '6nZAWp5kWbw1CH4Rb5YJlAvtVvCmFz5HiHRFkpHB.jpg'),
('PT (Playable Teaser)', 'Although not a full game, PT is a famous demo that was meant to be a teaser for the canceled Silent Hills project. It takes place in a looping, eerie corridor where players experience surreal and terrifying events.', 0, 8, 'IYVDbdB8yaUVYmO3H95ufFt47kmB5pDjPkkLykXx.jpg'),
('Tetris', 'Tetris is a classic tile-matching puzzle game where players manipulate falling blocks to create complete horizontal lines, which then disappear. The game requires quick thinking and spatial arrangement skills.', 0, 9, 'AaFIpQvNikeEOn5pQ1pG7R0paN4xlb8KEkJ2tbd4.jpg'),
('Portal Series', 'Portal and Portal 2 are first-person puzzle-platform games where players use a portal gun to create linked portals between two locations. The games challenge players with intricate puzzles that involve physics and creative problem-solving.', 0, 9, 'nq84GoFRqFEHvDzB1cj2qwaiOmdczWqWa7TxL8CF.jpg'),
('The Witness', 'The Witness is a first-person puzzle game set on a mysterious island. Players explore the island and solve puzzles that are integrated into the environment, gradually uncovering the games narrative while enhancing their puzzle-solving skills.', 0, 9, '6nZAWp5kWbw1CH4Rb5YJlAvtVvCmFz5HiHRFkpHB.jpg'),
('Braid', 'Braid is a puzzle-platformer game that features time manipulation as its core mechanic. Players control the protagonist Tim, solving puzzles by manipulating time, rewinding and altering events to progress through the game.', 0, 9, '0ZyCXidJflakijoe8jrLQUwInrmFbwEdh5T09gdx.jpg'),
('Limbo', 'Limbo is a dark, atmospheric puzzle-platformer game where players control a young boy on a quest to find his sister. The game features challenging puzzles and a unique monochromatic art style, creating a haunting and immersive experience.', 0, 9, 'ShsbEXD8ufAGN8jJoKJhR70mkHQt0YCKEw8JQkOm.jpg'),
('Myst', 'Myst is a graphic adventure puzzle game where players explore surreal and visually stunning worlds. Players solve puzzles by interacting with objects and deciphering clues, uncovering the games intricate storyline and unraveling mysteries.', 0, 9, 'fxdAzlK6kQkNlJUO621IErsrNxtqJ9WKC7WgZotL.jpg'),
('Fez', 'Fez is a puzzle-platformer game where players control Gomez, a 2D character living in a 3D world. The games unique mechanic allows players to rotate the 2D perspective, altering the layout of the levels and revealing hidden paths and puzzles.', 0, 9, NULL),
('Monument Valley', 'Monument Valley is a visually captivating puzzle-adventure game where players guide a character named Ida through impossible architectural structures. Players manipulate the environment to create optical illusions and solve perspective-based puzzles.', 0, 9, 'tgCRirdTJqpf9Qvk0QiEIEq1zwIfRc7yJ6xsAdmF.jpg'),
('Catherine', 'Catherine is a puzzle-platformer and dating simulation game. Players navigate intricate tower puzzles during the night, dealing with themes of commitment, relationships, and infidelity during the day, making moral choices that affect the games outcome.', 0, 9, 'vv4xPk2LeIKZus7pPOcjzAXW6pLem9wCZQQmnFCp.jpg'),
('Lumines', 'Lumines is a music-themed puzzle game where players rotate and align blocks of different colors to form squares. The game features a dynamic soundtrack and a synchronized visual experience, with blocks and background changing in time with the music.', 0, 9, 'IYVDbdB8yaUVYmO3H95ufFt47kmB5pDjPkkLykXx.jpg'),
('World of Warcraft', 'Developed by Blizzard Entertainment, World of Warcraft (WoW) is one of the most iconic MMORPGs. Set in the high-fantasy world of Azeroth, players can choose from various races and classes, embark on quests, explore dungeons, and engage in player versus player (PvP) battles.', 0, 10, 'AaFIpQvNikeEOn5pQ1pG7R0paN4xlb8KEkJ2tbd4.jpg'),
('Final Fantasy XIV', 'A Realm Reborn: Published by Square Enix, Final Fantasy XIV is a MMORPG set in the fantasy world of Eorzea. Players can explore a rich storyline, participate in group dungeons and raids, and engage in large-scale player-driven events. The game is known for its deep narrative and engaging PvE content.', 0, 10, 'ShsbEXD8ufAGN8jJoKJhR70mkHQt0YCKEw8JQkOm.jpg'),
('Guild Wars 2', 'Developed by ArenaNet, Guild Wars 2 offers a dynamic and visually stunning MMO experience. It features a persistent world where events unfold based on players actions. The game emphasizes cooperative gameplay, with a focus on exploration, dynamic events, and large-scale world versus world battles.', 0, 10, 'vv4xPk2LeIKZus7pPOcjzAXW6pLem9wCZQQmnFCp.jpg'),
('EVE Online', 'Developed by CCP Games, EVE Online is a space-based MMO where players can pilot customizable ships, trade goods, mine resources, and engage in large-scale space battles. The game is renowned for its player-driven economy and politics, allowing players to form alliances, wage wars, and influence the games universe.', 0, 10, NULL),
('The Elder Scrolls Online', 'Based on the popular Elder Scrolls series, this MMO by ZeniMax Online Studios allows players to explore the continent of Tamriel. Players can join factions, complete quests, explore dungeons, and participate in PvP battles in the massive open world of the Elder Scrolls universe.', 0, 10, '0ZyCXidJflakijoe8jrLQUwInrmFbwEdh5T09gdx.jpg'),
('Star Wars: The Old Republic', 'Set in the Star Wars universe and developed by BioWare, The Old Republic (SWTOR) offers an immersive MMO experience with fully voiced dialogue, cinematic storytelling, and player choices that impact the games narrative. Players can choose to align with the Sith Empire or the Galactic Republic and experience epic Star Wars adventures.', 0, 10, '6nZAWp5kWbw1CH4Rb5YJlAvtVvCmFz5HiHRFkpHB.jpg'),
('Runescape', 'Developed and published by Jagex, Runescape is a browser-based MMORPG that has been running since 2001. It offers a vast open world, various skills to train, quests to complete, and a player-driven economy. Players can choose between Old School Runescape (based on the games 2007 version) or the modern version with updated graphics and gameplay.', 0, 10, 'fxdAzlK6kQkNlJUO621IErsrNxtqJ9WKC7WgZotL.jpg'),
('Black Desert', 'Developed by Pearl Abyss, Black Desert Online is known for its stunning graphics and action-oriented combat system. Players can engage in trading, fishing, crafting, and large-scale siege warfare. The game features a sandbox world where players can shape the games economy and politics.', 0, 10, 'nq84GoFRqFEHvDzB1cj2qwaiOmdczWqWa7TxL8CF.jpg'),
('Destiny', 'Developed by Bungie, Destiny is a hybrid MMO and first-person shooter set in a sci-fi universe. Players can participate in cooperative and competitive gameplay, explore various planets, complete raids, and engage in intense PvP battles. The game offers a mix of PvE and PvP experiences.', 0, 10, 'tgCRirdTJqpf9Qvk0QiEIEq1zwIfRc7yJ6xsAdmF.jpg'),
('The Division 2', 'Developed by Ubisoft Massive, Tom Clancys The Division 2 is an online action RPG set in a post-apocalyptic Washington D.C. Players can team up with others to explore the open world, complete missions, engage in PvP combat, and participate in endgame content, including raids and strongholds.', 0, 10, 'IYVDbdB8yaUVYmO3H95ufFt47kmB5pDjPkkLykXx.jpg');

INSERT INTO question(user_id, create_date, title, is_solved, is_public, nr_views, game_id) VALUES
(99, '2022-10-01 14:30:00', 'Pokemon GO connection issue', FALSE, TRUE, 100, 1),
(98, '2022-10-02 14:30:00', 'Game client not launching', FALSE, TRUE, 120, 1),
(97, '2022-10-03 14:30:00', 'CS:GO frame rate drop', FALSE, TRUE, 90, 1),
(96, '2022-10-04 14:30:00', 'Connection issues', FALSE, TRUE, 60, 1),
(95, '2022-10-05 14:30:00', 'Fortnite multiplayer problem', FALSE, TRUE, 110, 1),
(94, '2022-10-06 14:30:00', 'Super Mario not loading', FALSE, TRUE, 80, 1),
(93, '2022-10-07 14:30:00', 'Overwatch lagging', FALSE, TRUE, 95, 1),
(92, '2022-10-08 14:30:00', 'Crash when starting game', FALSE, TRUE, 70, 1),
(91, '2022-10-09 14:30:00', 'Overwatch server down', FALSE, TRUE, 85, 1),
(90, '2022-10-10 14:30:00', 'Super Mario Bros. level bug', FALSE, TRUE, 105, 1),
(89, '2022-10-11 14:30:00', 'Need help with game controls', FALSE, TRUE, 65, 2),
(88, '2022-10-12 14:30:00', 'Overwatch character balance issue', FALSE, TRUE, 88, 2),
(87, '2022-10-13 14:30:00', 'Unable to complete a quest', FALSE, TRUE, 72, 2),
(86, '2022-10-14 14:30:00', 'Pokemon Go gym bug', FALSE, TRUE, 93, 2),
(85, '2022-10-15 14:30:00', 'CS:GO matchmaking issue', FALSE, TRUE, 78, 2),
(84, '2022-10-16 14:30:00', 'Super Smash Bros. bug', FALSE, TRUE, 115, 2),
(83, '2022-10-17 14:30:00', 'Need help with a gameplay strategy', FALSE, TRUE, 82, 2),
(82, '2022-10-18 14:30:00', 'League of Legends champion bug', FALSE, TRUE, 97, 2),
(81, '2022-10-19 14:30:00', 'Game of Thrones quest not working', FALSE, TRUE, 68, 2),
(80, '2022-10-20 14:30:00', 'League of Legends login issue', FALSE, TRUE, 89, 2),
(79, '2022-10-20 14:30:00', 'Error purchasing in-game currency', FALSE, TRUE, 100, 3),
(78, '2022-10-20 14:30:00', 'Billing issue', FALSE, TRUE, 120, 3),
(77, '2022-10-21 14:30:00', 'Gamer tag change', FALSE, TRUE, 90, 3),
(76, '2022-10-22 14:30:00', 'Payment not going through', FALSE, TRUE, 60, 3),
(75, '2022-10-23 14:30:00', 'In-game item missing', FALSE, TRUE, 110, 3),
(74, '2022-10-24 14:30:00', 'Subscription renewal error', FALSE, TRUE, 80, 3),
(73, '2022-10-25 14:30:00', 'Cannot link payment method to account', FALSE, TRUE, 95, 3),
(72, '2022-10-26 14:30:00', 'Refund request for accidental purchase', FALSE, TRUE, 70, 3),
(71, '2022-10-27 14:30:00', 'Account suspension or ban', FALSE, TRUE, 85, 3),
(70, '2022-10-28 14:30:00', 'Missing rewards from game event', FALSE, TRUE, 105, 3),
(69, '2022-10-30 14:30:00', 'Request to remove inappropriate player username', FALSE, TRUE, 65, 4),
(68, '2022-10-30 14:30:00', 'Toxic player in chat', FALSE, TRUE, 88, 4),
(67, '2022-10-31 14:30:00', 'Community event suggestion', FALSE, TRUE, 72, 4),
(66, '2022-11-01 14:30:00', 'Reporting inappropriate forum post', FALSE, TRUE, 93, 4),
(65, '2022-11-02 14:30:00', 'Abusive in-game chat behavior', FALSE, TRUE, 78, 4),
(64, '2022-11-03 14:30:00', 'Reporting a player for cheating', FALSE, TRUE, 115, 4),
(63, '2022-11-03 14:30:00', 'Community event feedback', FALSE, TRUE, 82, 4),
(62, '2022-11-04 14:30:00', 'Inappropriate forum post', FALSE, TRUE, 97, 4),
(61, '2022-11-05 14:30:00', 'Incorrect information on website', FALSE, TRUE, 68, 4),
(60, '2022-11-06 14:30:00', 'Esports tournament registration issue', FALSE, TRUE, 89, 4),
(59, '2022-11-07 14:30:00', 'Setting up team for tournament', FALSE, TRUE, 89, 5),
(58, '2022-11-08 14:30:00', 'Unable to register for upcoming tournament', FALSE, TRUE, 89, 5),
(57, '2022-11-09 14:30:00', 'Tournament scheduling conflict', FALSE, TRUE, 89, 5),
(56, '2022-11-10 14:30:00', 'Rule clarification for tournament', FALSE, TRUE, 89, 5),
(55, '2022-11-11 14:30:00', 'Discrepancy in tournament results', FALSE, TRUE, 89, 5),
(54, '2022-11-12 14:30:00', 'Server issues during tournament', FALSE, TRUE, 89, 5),
(53, '2022-11-13 14:30:00', 'Issue with prize distribution', FALSE, TRUE, 89, 5),
(52, '2022-11-14 14:30:00', 'Team disqualification from tournament', FALSE, TRUE, 89, 5),
(51, '2022-11-15 14:30:00', 'Streaming issues during tournamen', FALSE, TRUE, 89, 5),
(50, '2022-11-16 14:30:00', 'Game crashes every time I try to load it', FALSE, TRUE, 89, 5),
(49, '2022-11-17 14:30:00', 'Game freezes during gameplay', FALSE, TRUE, 89, 6),
(48, '2022-11-18 14:30:00', 'Game lags frequently', FALSE, TRUE, 89, 6),
(47, '2022-11-19 14:30:00', 'Audio issue in game', FALSE, TRUE, 89, 6),
(46, '2022-11-19 14:30:00', 'Graphic bug in game', FALSE, TRUE, 89, 6),
(45, '2022-11-19 14:30:00', 'Request for new game feature', FALSE, TRUE, 89, 6),
(44, '2022-12-01 14:30:00', 'Game balance issue', FALSE, TRUE, 89, 6),
(43, '2022-12-02 14:30:00', 'Request for game optimization', FALSE, TRUE, 89, 6),
(42, '2022-12-03 14:30:00', 'Texture issue in game', FALSE, TRUE, 89, 6),
(41, '2022-12-04 14:30:00', 'Bug in game AI', FALSE, TRUE, 89, 6),
(40, '2022-12-05 14:30:00', 'Request for a new game mode', FALSE, TRUE, 89, 6),
(39, '2022-12-06 14:30:00', 'Suggestions for game improvement', FALSE, TRUE, 89, 7),
(38, '2022-12-07 14:30:00', 'In-game reward system is not motivating enough', FALSE, TRUE, 89, 7),
(37, '2022-12-08 14:30:00', 'Level progression too slow', FALSE, TRUE, 89, 7),
(36, '2022-12-09 14:30:00', 'Certain weapons or abilities are overpowered', FALSE, TRUE, 89, 7),
(35, '2022-12-10 14:30:00', 'Need more diverse character designs', FALSE, TRUE, 89, 7),
(34, '2022-12-11 14:30:00', 'Tutorial is confusing and unclear', FALSE, TRUE, 89, 7),
(33, '2022-12-12 14:30:00', 'Map design is too simple', FALSE, TRUE, 89, 7),
(32, '2022-12-13 14:30:00', 'Game character balance issue', FALSE, TRUE, 89, 7),
(31, '2022-12-14 14:30:00', 'Request for a new item', FALSE, TRUE, 89, 7),
(30, '2022-12-15 14:30:00', 'Promotion not applying at checkout', FALSE, TRUE, 89, 7),
(29, '2022-12-17 14:30:00', 'Event page not loading', FALSE, TRUE, 89,  8),
(28, '2022-12-18 14:30:00', 'Incorrect description on promotional email', FALSE, TRUE, 89,  8),
(27, '2022-12-19 14:30:00', 'Missed out on limited-time offer', FALSE, TRUE, 89,  8),
(26, '2022-12-21 14:30:00', 'Need help promoting my Twitch channel', FALSE, TRUE, 89,  8),
(25, '2022-12-13 14:30:00', 'Promotional video not playing', FALSE, TRUE, 89,  8),
(24, '2022-12-23 14:30:00', 'Suggestions for promoting the game on social media', FALSE, TRUE, 89,  8),
(23, '2022-12-14 14:30:00', 'Promotional code not working', FALSE, TRUE, 89,  8),
(22, '2022-12-25 14:30:00', 'Request for a new game trailer', FALSE, TRUE, 89,  8),
(21, '2022-12-29 14:30:00', 'Complaint about misleading advertisement', FALSE, TRUE, 89, 8);

INSERT INTO question_followers (user_id, question_id) VALUES
(30, 1), 
(29, 1), 
(28, 1), 
(27, 1), 
(26, 4), 
(25, 4), 
(24, 4), 
(23, 4), 
(22, 4), 
(21, 3), 
(20, 3), 
(19, 3);

INSERT INTO answer(user_id, question_id, is_public) VALUES
(2, 1, TRUE),
(2, 1, TRUE),
(3, 3, TRUE),
(4, 4, TRUE),
(5, 5, TRUE),
(6, 6, TRUE),
(7, 7, TRUE),
(8, 8, TRUE),
(9, 9, TRUE),
(10, 10, TRUE),
(11, 11, TRUE),
(12, 12, TRUE),
(13, 13, TRUE),
(14, 14, TRUE),
(15, 15, TRUE),
(16, 16, TRUE),
(17, 17, TRUE),
(18, 18, TRUE),
(19, 19, TRUE),
(20, 20, TRUE);

INSERT INTO comment(user_id, answer_id, is_public) VALUES
(99, 1, TRUE),
(98, 2, TRUE),
(97, 3, TRUE),
(96, 4, TRUE),
(95, 5, TRUE),
(94, 6, TRUE),
(93, 7, TRUE),
(92, 8, TRUE),
(91, 8, TRUE),
(90, 9, TRUE),
(89, 10, TRUE),
(88, 11, TRUE),
(87, 12, TRUE),
(86, 13, TRUE),
(85, 14, TRUE),
(84, 15, TRUE),
(83, 16, TRUE),
(82, 17, TRUE),
(81, 18, TRUE),
(80, 19, TRUE);

INSERT INTO vote(user_id, date, reaction, vote_type, answer_id, question_id) VALUES 
(99, '2023-02-01 14:30:00', TRUE, 'Question_vote', NULL, 10),
(98, '2023-02-01 14:30:01', FALSE, 'Question_vote', NULL, 11),
(97, '2023-02-01 14:30:02', TRUE, 'Question_vote', NULL, 12),
(96, '2023-02-01 14:30:03', FALSE, 'Question_vote', NULL, 13),
(95, '2023-02-01 14:30:04', TRUE, 'Question_vote', NULL, 14),
(94, '2023-02-01 14:30:05', FALSE, 'Question_vote', NULL, 15),
(93, '2023-02-01 14:30:06', TRUE, 'Question_vote', NULL, 16),
(92, '2023-02-01 14:30:07', FALSE, 'Question_vote', NULL, 17),
(91, '2023-02-01 14:30:08', TRUE, 'Question_vote', NULL, 18),
(90, '2023-02-01 14:30:09', FALSE, 'Question_vote', NULL, 19),
(89, '2023-02-01 14:30:10', TRUE, 'Question_vote', NULL, 20),
(88, '2023-02-01 14:30:11', FALSE, 'Question_vote', NULL, 21),
(87, '2023-02-01 14:30:12', TRUE, 'Question_vote', NULL, 22),
(86, '2023-02-01 14:30:13', FALSE, 'Question_vote', NULL, 23),
(85, '2023-02-01 14:30:14', TRUE, 'Question_vote', NULL, 24),
(84, '2023-02-01 14:30:15', FALSE, 'Question_vote', NULL, 25),
(83, '2023-02-01 14:30:16', TRUE, 'Question_vote', NULL, 26),
(82, '2023-02-01 14:30:17', FALSE, 'Question_vote', NULL, 27),
(81, '2023-02-01 14:30:18', TRUE, 'Question_vote', NULL, 28),
(80, '2023-02-01 14:30:19', FALSE, 'Question_vote', NULL, 29),
(79, '2023-02-02 14:30:00', TRUE, 'Answer_vote', 1, NULL),
(78, '2023-02-02 14:30:01', FALSE, 'Answer_vote', 2, NULL),
(77, '2023-02-02 14:30:02', TRUE, 'Answer_vote', 3, NULL),
(76, '2023-02-02 14:30:03', FALSE, 'Answer_vote', 4, NULL),
(75, '2023-02-02 14:30:04', TRUE, 'Answer_vote', 5, NULL),
(74, '2023-02-02 14:30:05', FALSE, 'Answer_vote', 6, NULL),
(73, '2023-02-02 14:30:06', TRUE, 'Answer_vote', 7, NULL),
(72, '2023-02-02 14:30:07', FALSE, 'Answer_vote', 8, NULL),
(71, '2023-02-02 14:30:08', TRUE, 'Answer_vote', 9, NULL),
(70, '2023-02-02 14:30:09', FALSE, 'Answer_vote', 1, NULL),
(69, '2023-02-02 14:30:10', TRUE, 'Answer_vote', 12, NULL),
(68, '2023-02-02 14:30:11', FALSE, 'Answer_vote', 12, NULL),
(67, '2023-02-02 14:30:12', TRUE, 'Answer_vote', 13, NULL),
(66, '2023-02-02 14:30:13', FALSE, 'Answer_vote', 14, NULL),
(65, '2023-02-02 14:30:14', TRUE, 'Answer_vote', 15,  NULL),
(64, '2023-02-02 14:30:15', FALSE, 'Answer_vote', 16, NULL),
(63, '2023-02-02 14:30:16', TRUE, 'Answer_vote', 17, NULL),
(62, '2023-02-02 14:30:17', FALSE, 'Answer_vote', 18, NULL),
(61, '2023-02-02 14:30:18', TRUE, 'Answer_vote', 19, NULL),
(60, '2023-02-02 14:30:19', FALSE, 'Answer_vote', 20, NULL);

INSERT INTO tag(name) VALUES
('onlinegamingtips'),
('gamebugs'),
('gameperformance'),
('gaminghardware'),
('esportsnews'),
('multiplayergames'),
('gamecrashes'),
('gamingsoftware'),
('consolegaming'),
('gamingissues');

INSERT INTO version_content(date, content, content_type, question_id, answer_id, comment_id) VALUES
('2022-10-01 14:30:00', 'I cannot connect to the Pokemon GO servers. Is anyone else having this issue?', 'Question_content', 1, NULL, NULL),
('2022-10-02 14:30:00', 'I am having an issue with the game client not launching. I have tried running it as administrator and reinstalling it, but it still wont launch. What can I do to fix this issue?', 'Question_content', 2, NULL, NULL),
('2022-10-03 14:30:00', 'My frame rate drops every time I enter a smoke grenade. How do I fix this?', 'Question_content', 3, NULL, NULL),
('2022-10-04 14:30:00', 'I keep getting disconnected from the game servers while playing. This has been happening for a couple of days now and I am not sure what the problem is. Is there something wrong with the servers or is it an issue on my end?', 'Question_content', 4, NULL, NULL),
('2022-10-05 14:30:00', 'I keep getting disconnected from the Fortnite servers while playing with my friends. Can you help?', 'Question_content', 5, NULL, NULL),
('2022-10-06 14:30:00', 'I am having trouble loading Super Mario on my Nintendo Switch. The game gets stuck on the loading screen and I cannot access the game. Can you help me?', 'Question_content', 6, NULL, NULL),
('2022-10-07 14:30:00', 'I am experiencing a lot of lag while playing Overwatch. This makes it difficult to aim and play the game. I have tried restarting my computer and internet, but it has not helped. Can you suggest a solution?', 'Question_content', 7, NULL, NULL),
('2022-10-08 14:30:00', 'Whenever I try to start the game, it crashes immediately. I have tried uninstalling and reinstalling, but the issue persists. Any suggestions?', 'Question_content', 8, NULL, NULL),
('2022-10-09 14:30:00', 'I cant connect to the Overwatch servers. Is there a problem with them?', 'Question_content', 9, NULL, NULL),
('2022-10-10 14:30:00', 'In world 5-2, there is a glitch where Mario gets stuck in the wall. Please fix!', 'Question_content', 10, NULL, NULL),
('2022-10-11 14:30:00', 'I just started playing this game and I am having trouble with the controls. Is there a tutorial or guide that can help me learn how to play?', 'Question_content', 11, NULL, NULL),
('2022-10-12 14:30:00', 'I think some characters in Overwatch are overpowered and need to be balanced. Can you look into this?', 'Question_content', 12, NULL, NULL),  
('2022-10-13 14:30:00', 'I am currently on the "Retrieve the Lost Artifact" quest, but I am unable to find the artifact. Can you provide some guidance?', 'Question_content', 13, NULL, NULL),
('2022-10-14 14:30:00', 'I am having an issue with the Pokemon Go gyms. Every time I try to challenge a gym, the game freezes and crashes. Is anyone else experiencing this issue?', 'Question_content', 14, NULL, NULL),
('2022-10-15 14:30:00', 'I am having trouble finding a match in CS:GO. Whenever I search for a game, it takes forever and I cannot find any players. This has been happening for a while now. Can you help me?', 'Question_content', 15, NULL, NULL),
('2022-10-16 14:30:00', 'I have found a bug in Super Smash Bros. Whenever I try to use Pikachus thunderbolt move, the game crashes. This happens every time I try to use the move. Can you fix it?', 'Question_content', 16, NULL, NULL),
('2022-10-17 14:30:00', 'I am trying to complete a difficult level in the game, but I keep failing. Can someone give me some tips or a strategy that I can use to beat this level? Thanks!', 'Question_content', 17, NULL, NULL),
('2022-10-18 14:30:00', 'I am having an issue with one of the champions in League of Legends. Whenever I try to use their ability, it doesnt work and the game crashes. Has anyone else experienced this issue? How can I fix it?', 'Question_content', 18, NULL, NULL),
('2022-10-19 14:30:00', 'I am unable to progress in the Game of Thrones game as one of the quests is not working properly. Whenever I try to complete the objective, the game crashes. Has anyone else experienced this issue? How can I fix it?', 'Question_content', 19, NULL, NULL),
('2022-10-20 14:30:00', 'I cannot log in to League of Legends. It says my account is invalid, but I know my information is correct. Please help!', 'Question_content', 20, NULL, NULL),
('2022-10-20 14:30:00', 'I tried to purchase in-game currency, but the transaction failed and I was not credited with the currency. However, the payment was still charged to my account. Can you help me resolve this issue?', 'Question_content', 21, NULL, NULL),
('2022-10-20 14:30:00', 'I have been charged twice for my subscription to World of Warcraft. I only have one account and should only be charged once. Can you refund me for the extra charge?', 'Question_content', 22, NULL, NULL),
('2022-10-21 14:30:00', 'I would like to change my gamer tag in Fortnite. How do I do that?', 'Question_content', 23, NULL, NULL),
('2022-10-22 14:30:00', 'I tried to make a purchase in the game store but my payment isnt going through. What can I do?', 'Question_content', 24, NULL, NULL),
('2022-10-23 14:30:00', 'I purchased an in-game item but its not showing up in my inventory. Can you help me?', 'Question_content', 25, NULL, NULL),
('2022-10-24 14:30:00', 'I am having trouble renewing my subscription for World of Warcraft. Whenever I try to renew, I get an error message saying the payment could not be processed. Can someone help me with this issue?', 'Question_content', 26, NULL, NULL),
('2022-10-25 14:30:00', 'I am trying to link my credit card to my account, but every time I try to do so, I get an error message saying that the payment method could not be added. What could be the issue here?', 'Question_content', 27, NULL, NULL),
('2022-10-26 14:30:00', 'I accidentally purchased a skin in Fortnite that I did not mean to buy. Is it possible to get a refund for this purchase?', 'Question_content', 28, NULL, NULL),
('2022-10-27 14:30:00', 'My account has been suspended/banned and I am not sure why. Can someone help me understand what has happened and what I can do to regain access to my account?', 'Question_content', 29, NULL, NULL),
('2022-10-28 14:30:00', 'I participated in a game event and completed all the challenges, but I did not receive the rewards that were promised. Can you help me get the rewards I earned?', 'Question_content', 30, NULL, NULL),
('2022-10-30 14:30:00', 'There is a player with an inappropriate username that violates community guidelines. Please take action to remove their username.', 'Question_content', 31, NULL, NULL),
('2022-10-30 14:30:00', 'Theres a player in the chat who keeps using offensive language and making other players uncomfortable. Can you do something about this?', 'Question_content', 32, NULL, NULL),
('2022-10-31 14:30:00', 'I have an idea for a community event that I think would be really fun. Can I suggest it to you?', 'Question_content', 33, NULL, NULL),
('2022-11-01 14:30:00', 'There is a forum post that contains inappropriate content and violates community guidelines. Please take action.', 'Question_content', 34, NULL, NULL),
('2022-11-02 14:30:00', 'I encountered a player who was verbally abusive and offensive in the in-game chat. Please take appropriate action.', 'Question_content', 35, NULL, NULL),
('2022-11-03 14:30:00', 'I was playing a game with another player, and I suspect that they were using hacks or cheats to gain an unfair advantage. Can you please investigate this and take appropriate action against the player?', 'Question_content', 36, NULL, NULL),
('2022-11-03 14:30:00', 'I participated in a recent community event and would like to give feedback on the experience. Can someone please assist me with this?', 'Question_content', 37, NULL, NULL),
('2022-11-04 14:30:00', 'There is a post on the forums containing offensive language and inappropriate content. Please remove it as soon as possible.', 'Question_content', 38, NULL, NULL),
('2022-11-05 14:30:00', 'There is incorrect information on the website regarding a game release date. Please update it to reflect the correct date.', 'Question_content', 39, NULL, NULL),
('2022-11-06 14:30:00', 'Im trying to register for an esports tournament but its not letting me. Whats going on?', 'Question_content', 40, NULL, NULL),
('2022-11-07 14:30:00', 'I am trying to set up a team for the upcoming tournament but I am having trouble. Can someone please help me with this?', 'Question_content', 41, NULL, NULL),
('2022-11-08 14:30:00', 'Ive been trying to register for the upcoming CS:GO tournament but keep getting an error message. Can someone please help me out?', 'Question_content', 42, NULL, NULL),
('2022-11-09 14:30:00', 'I just realized that the esports tournament I signed up for is scheduled at the same time as another important event. Is there any way to change the schedule?', 'Question_content', 43, NULL, NULL),
('2022-11-10 14:30:00', 'I have a question about one of the rules for the upcoming esports tournament. Can someone please clarify it for me?', 'Question_content', 44, NULL, NULL),
('2022-11-11 14:30:00', 'There seems to be a discrepancy in the results of the esports tournament I participated in. Can someone please look into this?', 'Question_content', 45, NULL, NULL),
('2022-11-12 14:30:00', 'I experienced server issues during the esports tournament I participated in, and it affected my performance. Can someone please look into this?', 'Question_content', 46, NULL, NULL),
('2022-11-13 14:30:00', 'I won the esports tournament but I have not received my prize yet. Can someone please look into this?', 'Question_content', 47, NULL, NULL),
('2022-11-14 14:30:00', 'Our team was disqualified from the esports tournament and we are not sure why. Can someone please provide more information?', 'Question_content', 48, NULL, NULL),
('2022-11-15 14:30:00', 'There were streaming issues during the esports tournament and many viewers could not watch the games. Can someone please look into this?', 'Question_content', 49, NULL, NULL),
('2022-11-16 14:30:00', 'I have been trying to play the game for the past few days, but it keeps crashing every time I try to load it. I have already tried restarting my computer, updating my graphics card drivers, and reinstalling the game, but nothing seems to work. Please help!', 'Question_content', 50, NULL, NULL),
('2022-11-17 14:30:00', 'The game is freezing randomly during gameplay, causing me to lose progress. Can you please help me troubleshoot this issue?', 'Question_content', 51, NULL, NULL),
('2022-11-18 14:30:00', 'I am experiencing frequent lags in the game that is affecting my gameplay. Can you please help me resolve this issue?', 'Question_content', 52, NULL, NULL),
('2022-11-19 14:30:00', 'I am experiencing audio issues in the game where some sounds are not playing. Can you please help me fix this issue?', 'Question_content', 53, NULL, NULL),
('2022-11-19 14:30:00', 'I noticed a graphic bug in the game where textures are not loading correctly. Can you please look into this issue?', 'Question_content', 54, NULL, NULL),
('2022-11-19 14:30:00', 'I have a suggestion for a new feature that I think would improve the gameplay experience. Can you please consider adding this feature in a future update?', 'Question_content', 55, NULL, NULL),
('2022-12-01 14:30:00', 'I think there is an imbalance in the game where some characters or weapons are too powerful compared to others. Can you please look into this issue and make some adjustments?', 'Question_content', 56, NULL, NULL),
('2022-12-02 14:30:00', 'I am experiencing performance issues with the game where it is not running smoothly on my system. Can you please optimize the game to run better?', 'Question_content', 57, NULL, NULL),
('2022-12-03 14:30:00', 'I have noticed that the textures in the game are glitching out and not loading properly. This is making it difficult to play the game as the visuals are important. Can you please investigate this issue and provide a fix?', 'Question_content', 58, NULL, NULL),
('2022-12-04 14:30:00', 'There is a bug in the game AI that is causing the enemies to act erratically and not follow their intended behavior. This is making the game unplayable and frustrating. Can you please look into this and provide a fix as soon as possible?', 'Question_content', 59, NULL, NULL),
('2022-12-05 14:30:00', 'I would like to suggest a new game mode that allows players to compete against each other in a tournament-style format. Please let me know if this is possible.', 'Question_content', 60, NULL, NULL),
('2022-12-06 14:30:00', 'I love playing this game, but there are some features that I think could be improved. Can I suggest some ideas for how to make the game even better?', 'Question_content', 61, NULL, NULL),
('2022-12-07 14:30:00', 'The current in-game reward system is not motivating enough for players to continue playing. Could the game design team look into ways to improve the rewards system so that players feel more incentivized to keep playing?', 'Question_content', 62, NULL, NULL),
('2022-12-08 14:30:00', 'The rate at which players progress through the levels is too slow. Can the game design team increase the rate of progression or introduce other ways to speed up level progression?', 'Question_content', 63, NULL, NULL),
('2022-12-09 14:30:00', 'Certain weapons or abilities in the game are overpowered, making the game unbalanced. Can the game design team look into ways to balance these weapons or abilities to create a more enjoyable gaming experience?', 'Question_content', 64, NULL, NULL),
('2022-12-10 14:30:00', 'The current character designs in the game lack diversity, and players are requesting more diverse character options. Can the game design team add more diverse character designs to the game?', 'Question_content', 65, NULL, NULL),
('2022-12-11 14:30:00', 'The game tutorial is confusing and unclear, leaving many players feeling lost and frustrated. Can the game design team improve the tutorial to make it more clear and informative?', 'Question_content', 66, NULL, NULL),
('2022-12-12 14:30:00', 'The current maps in the game are too simple, leaving players wanting more complexity and variety. Can the game design team look into creating more complex and varied maps for the game?', 'Question_content', 67, NULL, NULL),
('2022-12-13 14:30:00', 'I think that one of the characters in the game is overpowered compared to the others, which makes the game unfair. Can you please adjust their stats to make it more balanced?', 'Question_content', 68, NULL, NULL),
('2022-12-14 14:30:00', 'I was playing the game and I had an idea for a new item that I think would be really cool. It would be great if you could add it to the game! Can you let me know if this is possible?', 'Question_content', 69, NULL, NULL),
('2022-12-15 14:30:00', 'I am trying to purchase the game with the advertised promotion, but the discount is not applying at checkout. Please help!', 'Question_content', 70, NULL, NULL),
('2022-12-17 14:30:00', 'I am trying to access the event page, but it is not loading. Is there an issue with the website?', 'Question_content', 71, NULL, NULL),
('2022-12-18 14:30:00', 'I received an email about a promotional offer, but the description in the email does not match the offer on the website. Can you please clarify?', 'Question_content', 72, NULL, NULL),
('2022-12-19 14:30:00', 'I just saw the limited-time offer on the website, but it already expired. Can you please extend the offer or provide an alternative?', 'Question_content', 73, NULL, NULL),
('2022-12-21 14:30:00', 'I am a Twitch streamer and would like to explore partnership opportunities with your company. How can I go about this?', 'Question_content', 74, NULL, NULL),
('2022-12-13 14:30:00', 'I clicked on the promotional video on the website, but it is not playing. Is there a problem with the video or my browser?', 'Question_content', 75, NULL, NULL),
('2022-12-23 14:30:00', 'I would like to share the game on social media, but am not sure how to do it effectively. Can you please provide some guidance or resources?', 'Question_content', 76, NULL, NULL),
('2022-12-14 14:30:00', 'I received a promotional code for 10% off my next purchase, but it is not working at checkout. Can you please help me resolve this issue?', 'Question_content', 77, NULL, NULL),
('2022-12-25 14:30:00', 'I am a big fan of your game and I would love to see a new trailer showcasing the latest updates and features. Is it possible to create one? Thanks!', 'Question_content', 78, NULL, NULL),
('2022-12-29 14:30:00', 'I recently saw an advertisement for your game that promised certain features, but when I played the game, those features were not available. This is misleading and I would like to file a complaint. Thank you.', 'Question_content', 79, NULL, NULL),
('2023-01-01 17:40:00', 'Try restarting your device and your internet connection, and then try connecting to the game again', 'Answer_content', NULL, 1, NULL),
('2023-01-01 14:30:00', 'Have you tried updating your graphics card drivers?', 'Answer_content', NULL, 2, NULL),
('2023-01-01 14:40:00', 'I have investigated the issue and have released a patch that should fix the problem.', 'Answer_content', NULL, 3, NULL),
('2023-01-01 14:50:00', 'Ensure your computer meets the minimum system requirements for the game. If your hardware falls short, you might experience performance issues.', 'Answer_content', NULL, 4, NULL),
('2023-01-01 15:00:00', 'Close unnecessary background applications, especially resource-intensive ones like video editing software or browser with multiple tabs. They can hog your system resources.', 'Answer_content', NULL, 5, NULL),
('2023-01-01 15:10:00', 'Lower the graphics settings within the game. This can significantly improve performance, especially on older or less powerful computers.', 'Answer_content', NULL, 6, NULL),
('2023-01-01 15:20:00', 'Make sure your operating system is up to date with the latest patches and updates. Sometimes, system updates can improve overall stability and compatibility with games.', 'Answer_content', NULL, 7, NULL),
('2023-01-01 15:30:00', 'Regularly check for updates or patches released by the game developers. These updates often include bug fixes and optimizations.', 'Answer_content', NULL, 8, NULL),
('2023-01-01 15:40:00', 'Delete temporary files and clear cache on your system. Accumulated junk files can slow down your systems performance.', 'Answer_content', NULL, 9, NULL),
('2023-01-01 15:50:00', 'Perform a full system scan to ensure your computer is not infected with malware or viruses that could be affecting game performance.', 'Answer_content', NULL, 10, NULL),
('2023-01-01 16:00:00', 'Overheating can cause performance issues. Use software to monitor your CPU and GPU temperatures. If they are too high, consider cleaning your computers cooling system.', 'Answer_content', NULL, 11, NULL),
('2023-01-01 16:10:00', 'For online games, a stable internet connection is crucial. Use a wired connection if possible, and avoid peak usage times for a smoother online gaming experience.', 'Answer_content', NULL, 12, NULL),
('2023-01-01 16:20:00', 'Some games require specific versions of DirectX or Visual C++ redistributables. Make sure you have the correct versions installed.', 'Answer_content', NULL, 13, NULL),
('2023-01-01 16:30:00', 'If you are using a game controller or other peripherals, ensure they are properly connected and their drivers are up to date.', 'Answer_content', NULL, 14, NULL),
('2023-01-01 16:40:00', 'If you are experiencing crashes or errors, use the game platform (Steam, Epic Games, etc.) to verify the integrity of game files. Corrupted files can cause issues.', 'Answer_content', NULL, 15, NULL),
('2023-01-01 16:50:00', 'If you have tried everything and the issue persists, contact the games official support. They might have specific solutions for known issues or provide personalized troubleshooting.', 'Answer_content', NULL, 16, NULL),
('2023-01-01 17:00:00', 'Ensure your system meets the games minimum system requirements. Check the games official website or Steam page for this information', 'Answer_content', NULL, 17, NULL),
('2023-01-01 17:10:00', 'Try running the game in compatibility mode for an earlier version of Windows if you are experiencing compatibility issues.', 'Answer_content', NULL, 18, NULL),
('2023-01-01 17:20:00', 'Check for overheating issues. Make sure your PC/console is adequately cooled to prevent performance problems.', 'Answer_content', NULL, 19, NULL),
('2023-01-01 17:30:00', 'Update your operating system to the latest version, as older OS versions can sometimes cause compatibility problems with games.', 'Answer_content', NULL, 20, NULL),

('2023-01-01 17:50:00', 'Thanks for the tip! I will make sure to check the system requirements before getting any new games.', 'Comment_content', NULL, NULL, 1),
('2023-01-01 18:00:00', 'I never thought about compatibility mode. I will try that if I encounter any issues with older games', 'Comment_content', NULL, NULL, 2),
('2023-01-01 18:10:00', 'Overheating might be my problem. I will clean out my PC and see if that helps with the performance issues I have been having.', 'Comment_content', NULL, NULL, 3),
('2023-01-01 18:20:00', 'Updating my OS didnt even cross my mind. Ill do that and see if it resolves the game crashes I have been experiencing.', 'Comment_content', NULL, NULL, 4),
('2023-01-01 18:30:00', 'Verifying game files is a smart idea. Ill do that now to make sure everything is in order.', 'Comment_content', NULL, NULL, 5),
('2023-01-01 18:40:00', 'I did not realize background apps could affect my game. I will close unnecessary programs next time I play.', 'Comment_content', NULL, NULL, 6),
('2023-01-01 18:50:00', 'Running out of storage space might explain the weird glitches I have been seeing. I will clear up some space and see if it helps.', 'Comment_content', NULL, NULL, 7),
('2023-01-01 19:00:00', 'Lowering graphics settings improved my games performance significantly! Thanks for the suggestion.', 'Comment_content', NULL, NULL, 8),
('2023-01-01 19:10:00', 'I found some bug reports online that match my issue. It is good to know the developers are aware and working on a fix.', 'Comment_content', NULL, NULL, 9),
('2023-01-01 19:20:00', 'Updating my audio drivers did the trick! No more sound issues in my games. Thanks for the advice.', 'Comment_content', NULL, NULL, 10),
('2023-01-01 19:30:00', 'I checked my internet connection, and it turns out my Wi-Fi was the problem. I switched to a wired connection, and now online gaming is much smoother.', 'Comment_content', NULL, NULL, 11),
('2023-01-01 19:40:00', 'Changing display resolutions helped with my visual problems. The game looks much better now. Thanks for the recommendation.', 'Comment_content', NULL, NULL, 12),
('2023-01-01 19:50:00', 'Playing in windowed mode fixed my fullscreen problems. I can finally enjoy the game without any issues.', 'Comment_content', NULL, NULL, 13),
('2023-01-01 20:20:00', 'Reinstalling the game was a hassle, but it worked! No more crashes or weird bugs. Thanks for suggesting it.', 'Comment_content', NULL, NULL, 14),
('2023-01-01 20:30:00', 'I contacted customer support, and they were incredibly helpful. They provided a workaround, and now my game runs perfectly. Great suggestion', 'Comment_content', NULL, NULL, 15),
('2023-01-01 20:40:00', 'I tried all the suggestions, but nothing worked. The game still crashes every time I try to launch it. I am really frustrated.', 'Comment_content', NULL, NULL, 16),
('2023-01-01 20:50:00', 'I followed the steps, but my graphics are still glitchy, and the gameplay is unplayable. I am not sure what else to do.', 'Comment_content', NULL, NULL, 17),
('2023-01-01 20:00:00', 'Updating the drivers didnt help at all. The game is still lagging terribly, and I cant enjoy it properly. This is really disappointing.', 'Comment_content', NULL, NULL, 18),
('2023-01-01 20:10:00', 'I attempted all the fixes, but the audio issues persist. I am extremely disappointed because I was looking forward to playing this game.', 'Comment_content', NULL, NULL, 19),
('2023-01-01 20:20:00', 'ven after contacting customer support, my problem remains unresolved. Its been weeks, and I still cant play the game I purchased. This is a major letdown.', 'Comment_content', NULL, NULL, 20);
INSERT INTO report(date, reason, explanation, is_solved, reporter_id, reported_id, report_type, question_id, answer_id, comment_id) VALUES 
('2023-03-01 14:30:00', 'Spam', 'I reported them because they were spamming the forum with irrelevant content.', TRUE, 51, 99, 'Question_report', 1, NULL, NULL),
('2023-03-01 14:40:00', 'Misinformation', 'I noticed they were spreading false information intentionally, so I reported their posts.', FALSE, 52, 98, 'Question_report', 2, NULL, NULL),
('2023-03-01 14:50:00', 'Harassment', 'They insulted me personally, which made me uncomfortable, leading to my report.', FALSE, 53, 97, 'Question_report', 3, NULL, NULL),
('2023-03-01 15:00:00', 'Spam', 'I reported them because they were clearly trolling, trying to provoke others.', FALSE, 54, 96, 'Question_report', 4, NULL, NULL),
('2023-03-01 15:10:00', 'Impersonation', 'They were pretending to be someone else, which is deceptive and harmful.', FALSE, 55, 95, 'Question_report', 5, NULL, NULL),
('2023-03-01 15:20:00', 'Sharing Personal Information', 'They shared my personal information without my consent, so I reported them.', TRUE, 56, 94, 'Question_report', 6, NULL, NULL),
('2023-03-01 15:30:00', 'Spam', 'Their posts were completely off-topic, disrupting the discussion, so I reported them.', FALSE, 57, 93, 'Question_report', 7, NULL, NULL),
('2023-03-01 15:40:00', 'Spam', 'I reported them for attempting to manipulate votes, which is unfair and against the rules', FALSE, 58, 92, 'Question_report', 8, NULL, NULL),
('2023-03-01 15:50:00', 'Harassment', 'I reported them for falsely reporting others, which is disruptive and malicious.', TRUE, 59, 91, 'Question_report', 9, NULL, NULL),
('2023-03-01 16:00:00', 'Sexual Content', 'They were posting content unsuitable for younger audiences, violating age guidelines, and thus, I reported them', FALSE, 60, 90, 'Question_report', 10, NULL, NULL),
('2023-03-01 16:10:00', 'Spam', 'They were exploiting a glitch in the platform to gain unfair advantages in games, affecting fair play and leading to my report.', FALSE, 61, 89, 'Question_report', 11, NULL, NULL),
('2023-03-01 16:20:00', 'Copyright Violation', 'They were sharing illegal download links for games, encouraging piracy, which is a violation of copyright laws, leading to my report.', FALSE, 62, 88, 'Question_report', 12, NULL, NULL),
('2023-03-01 16:30:00', 'Hate', 'Their posts were promoting extremist ideologies, creating a dangerous atmosphere; I reported them to maintain a safe online environment.', TRUE, 63, 1, 'Answer_report', NULL, 1, NULL),
('2023-03-01 16:40:00', 'Harassment', 'They were attempting to hijack other users accounts, posing a significant security threat, leading to my report.', FALSE, 64, 2, 'Answer_report', NULL, 2, NULL),
('2023-03-01 16:50:00', 'Harassment', 'They were stalking me across different discussions, making me uncomfortable, so I reported their behavior.', TRUE, 65, 3, 'Answer_report', NULL, 3, NULL),
('2023-03-01 17:00:00', 'Illegal Activities', 'They were promoting illegal game activities, so I reported their posts.', FALSE, 66, 4, 'Answer_report', NULL, 4, NULL);

INSERT INTO notification(date, viewed, user_id, notification_type, question_id, answer_id, comment_id, vote_id, report_id, badge_id, game_id) VALUES
('2023-03-02 19:30:00', TRUE, 50, 'Answer_notification', NULL, 1, NULL, NULL, NULL, NULL, NULL),
('2023-03-02 19:40:00', TRUE, 51, 'Answer_notification', NULL, 2, NULL, NULL, NULL, NULL, NULL),
('2023-03-02 19:50:00', TRUE, 52, 'Answer_notification', NULL, 3, NULL, NULL, NULL, NULL, NULL),
('2023-03-02 20:00:00', TRUE, 53, 'Answer_notification', NULL, 4, NULL, NULL, NULL, NULL, NULL),
('2023-03-02 20:10:00', FALSE, 54, 'Answer_notification', NULL, 5, NULL, NULL, NULL, NULL, NULL),
('2023-03-02 20:20:00', TRUE, 55, 'Answer_notification', NULL, 6, NULL, NULL, NULL, NULL, NULL),
('2023-03-02 20:30:00', TRUE, 55, 'Answer_notification', NULL, 7, NULL, NULL, NULL, NULL, NULL),
('2023-03-02 20:40:00', TRUE, 55, 'Answer_notification', NULL, 8, NULL, NULL, NULL, NULL, NULL),
('2023-03-02 20:50:00', TRUE, 55, 'Answer_notification', NULL, 9, NULL, NULL, NULL, NULL, NULL),
('2023-03-02 21:00:00', TRUE, 60, 'Answer_notification', NULL, 10, NULL, NULL, NULL, NULL, NULL),
('2023-03-02 21:10:00', FALSE, 19, 'Comment_notification', NULL, NULL, 20, NULL, NULL, NULL, NULL),
('2023-03-02 21:20:00', TRUE, 18, 'Comment_notification', NULL, NULL, 19, NULL, NULL, NULL, NULL),
('2023-03-02 21:30:00', TRUE, 17, 'Comment_notification', NULL, NULL, 18, NULL, NULL, NULL, NULL),
('2023-03-02 21:40:00', TRUE, 16, 'Comment_notification', NULL, NULL, 17, NULL, NULL, NULL, NULL),
('2023-03-02 21:50:00', FALSE, 15, 'Comment_notification', NULL, NULL, 16, NULL, NULL, NULL, NULL),
('2023-03-02 22:00:00', TRUE, 14, 'Comment_notification', NULL, NULL, 15, NULL, NULL, NULL, NULL),
('2023-03-02 22:10:00', TRUE, 13, 'Comment_notification', NULL, NULL, 14, NULL, NULL, NULL, NULL),
('2023-03-02 22:20:00', FALSE, 12, 'Comment_notification', NULL, NULL, 13, NULL, NULL, NULL, NULL),
('2023-03-02 22:30:00', TRUE, 11, 'Comment_notification', NULL, NULL, 12, NULL, NULL, NULL, NULL),
('2023-03-02 22:40:00', TRUE, 10, 'Comment_notification', NULL, NULL, 11, NULL, NULL, NULL, NULL),
('2023-03-02 14:30:00', FALSE, 3, 'Rank_notification', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
('2023-03-02 14:40:00', FALSE, 6, 'Rank_notification', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
('2023-03-02 14:50:00', FALSE, 9, 'Rank_notification', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
('2023-03-02 15:00:00', FALSE, 12, 'Rank_notification', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
('2023-03-02 15:10:00', FALSE, 13, 'Rank_notification', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
('2023-03-02 15:20:00', FALSE, 15, 'Rank_notification', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
('2023-03-02 15:30:00', FALSE, 17, 'Rank_notification', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
('2023-03-02 15:40:00', FALSE, 19, 'Rank_notification', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
('2023-03-02 15:50:00', FALSE, 23, 'Rank_notification', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
('2023-03-02 16:00:00', FALSE, 26, 'Rank_notification', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
('2023-03-02 16:10:00', FALSE, 27, 'Rank_notification', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
('2023-03-02 16:20:00', FALSE, 28, 'Rank_notification', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
('2023-03-02 16:30:00', FALSE, 39, 'Rank_notification', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
('2023-03-02 16:40:00', FALSE, 43, 'Rank_notification', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
('2023-03-02 16:50:00', FALSE, 45, 'Rank_notification', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
('2023-03-02 17:00:00', FALSE, 48, 'Rank_notification', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
('2023-03-02 17:10:00', FALSE, 50, 'Rank_notification', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
('2023-03-02 17:20:00', FALSE, 56, 'Rank_notification', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
('2023-03-02 17:30:00', FALSE, 59, 'Rank_notification', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
('2023-03-02 17:40:00', FALSE, 66, 'Rank_notification', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
('2023-03-02 17:50:00', FALSE, 79, 'Rank_notification', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
('2023-03-02 18:00:00', FALSE, 89, 'Rank_notification', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
('2023-03-02 18:10:00', FALSE, 92, 'Rank_notification', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
('2023-03-02 18:20:00', FALSE, 96, 'Rank_notification', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
('2023-03-02 18:30:00', FALSE, 100, 'Rank_notification', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
('2023-03-03 18:40:00', FALSE, 1, 'Game_notification', 1, NULL, NULL, NULL, NULL, NULL, NULL),
('2023-03-03 19:50:00', FALSE, 2, 'Game_notification', 12, NULL, NULL, NULL, NULL, NULL, NULL),
('2023-03-03 20:00:00', FALSE, 2, 'Game_notification', 33, NULL, NULL, NULL, NULL, NULL, NULL),
('2023-03-04 15:10:00', FALSE, 5, 'Game_notification', 34, NULL, NULL, NULL, NULL, NULL, NULL),
('2023-03-04 19:30:00', FALSE, 10, 'Game_notification', 2, NULL, NULL, NULL, NULL, NULL, NULL),
('2023-03-05 17:50:00', FALSE, 20, 'Game_notification', 3, NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO user_badge(user_id, badge_id) VALUES
(2, 1),
(2, 2),
(3, 1),
(5, 2),
(10, 1),
(10, 3),
(20,1),
(20, 2),
(21, 3),
(30, 1),
(45, 4),
(46, 2),
(55, 4),
(88, 5),
(92, 2);

INSERT INTO game_member(user_id, game_id) VALUES
(2, 1),
(2, 2),
(2, 5),
(2, 6),
(2, 10),
(2, 46),
(2, 17),
(2, 18),
(15, 10),
(15, 20),
(15, 52),
(15, 65),
(15, 11),
(15, 4),
(15, 17),
(15, 19),
(3, 45),
(3, 87),
(3, 54),
(3, 16),
(3, 71),
(3, 3),
(3, 28),
(3, 85),
(3, 13),
(3, 64),
(4, 19),
(4, 95),
(4, 57),
(4, 37),
(4, 82),
(4, 9),
(4, 24),
(4, 65),
(5, 41),
(5, 88),
(5, 53),
(5, 10),
(5, 78),
(5, 15),
(5, 30),
(5, 68),
(5, 29),
(5, 73),
(5, 2),
(5, 3),
(5, 7),
(5, 1),
(6, 1),
(6, 10),
(7, 4),
(7, 7),
(7, 50),
(8, 77),
(8, 36),
(8, 15),
(8, 88),
(8, 27),
(8, 67),
(8, 41),
(8, 53),
(8, 61),
(8, 32),
(9, 10),
(9, 47),
(9, 73),
(9, 98),
(9, 21),
(9, 65),
(9, 85),
(9, 53),
(9, 28),
(9, 42),
(10, 34),
(10, 50),
(10, 22),
(10, 93),
(10, 67),
(10, 12),
(10, 86),
(10, 31),
(10, 78),
(10, 59),
(11, 55),
(11, 38),
(11, 83),
(11, 18),
(11, 64),
(11, 49),
(11, 27),
(11, 92),
(11, 70),
(11, 45),
(12, 60),
(12, 71),
(12, 39),
(12, 16),
(12, 81),
(12, 10),
(12, 49),
(12, 70),
(12, 32),
(12, 79),
(20, 76),
(20, 54),
(20, 39),
(20, 85),
(20, 12),
(20, 28),
(20, 63),
(20, 47),
(20, 91),
(20, 21),
(20, 5),
(20, 90),
(20, 9),
(21, 9),
(21, 2),
(21, 10),
(22, 22),
(23, 1),
(24, 75),
(24, 20),
(24, 31),
(24, 61),
(24, 49),
(24, 14),
(24, 83),
(24, 59),
(24, 56),
(24, 28),
(24, 95),
(40, 53),
(40, 27),
(40, 74),
(40, 19),
(40, 87),
(40, 38),
(40, 66),
(40, 42),
(40, 61),
(40, 8),
(45, 65),
(45, 31),
(45, 94),
(45, 12),
(45, 78),
(45, 58),
(45, 35),
(45, 48),
(45, 22),
(45, 41),
(45, 45),
(50, 26),
(50, 62),
(50, 77),
(50, 16),
(50, 86),
(50, 39),
(50, 55),
(50, 73),
(50, 44),
(50, 19),
(50, 50),
(50, 31),
(50, 81),
(50, 23),
(50, 66),
(50, 14),
(60, 70),
(60, 36),
(60, 90),
(60, 58),
(66, 24),
(66, 68),
(66, 40),
(66, 92),
(66, 11),
(66, 76),
(71, 5),
(71, 42),
(71, 88),
(71, 3),
(71, 70),
(71, 91),
(71, 13),
(71, 37),
(71, 60),
(71, 18),
(72, 84),
(72, 51),
(72, 2),
(72, 25),
(72, 67),
(72, 94),
(74, 9),
(74, 22),
(82, 7),
(83, 1),
(85, 49),
(85, 20),
(85, 93),
(85, 10),
(85, 83),
(85, 53),
(85, 21),
(89, 44),
(89, 30),
(89, 78),
(89, 27),
(89, 95),
(89, 61),
(89, 16),
(89, 39),
(95, 66),
(95, 48),
(95, 12),
(95, 71),
(95, 87),
(95, 7),
(99, 72),
(99, 8),
(99, 49),
(99, 32),
(99, 75),
(99, 31);

INSERT INTO question_tag(question_id, tag_id) VALUES
(1, 1),
(1, 7),
(2, 5),
(2, 2),
(2, 9),
(3, 4),
(3, 10),
(5, 1),
(5, 9),
(7, 3),
(7, 6),
(9, 5),
(9, 1),
(10, 2),
(11, 8),
(11, 3),
(15, 6),
(19, 4),
(19, 9),
(20, 6),
(21, 2),
(22, 10),
(22, 4),
(24, 9),
(24, 1),
(24, 3),
(26, 8),
(27, 5),
(27, 10),
(30, 5),
(30, 9),
(32, 7),
(32, 6),
(32, 4),
(35, 10),
(40, 3),
(40, 6),
(40, 9),
(45, 2),
(45, 8),
(45, 4),
(49, 7),
(49, 5),
(50, 1),
(52, 4),
(52, 5),
(53, 8),
(53, 2),
(56, 10),
(56, 1),
(60, 5),
(65, 8),
(65, 1),
(66, 2),
(66, 9),
(71, 5),
(75, 10),
(75, 1),
(75, 8),
(75, 6),
(78, 4),
(78, 2),
(78, 9);

INSERT INTO question_file(question_id, file_name, f_name) VALUES
(1, 'IHUuFgM1T8a4McoFeDixQ6T89uywof843TkY0jNs.png', 'question.png'),
(79, 'IHUuFgM1T8a4McoFeDixQ6T89uywof843TkY0jNs.png', 'question.png'),
(79, 'oeSuX93uRTHcKA6ODWFLmdaXPOfxRZ4JuTPUG1H7.pdf', 'document.pdf');


INSERT INTO answer_file(answer_id, file_name, f_name) VALUES
(1, 'h5umJWOrhetb9RtaqFaoyG3z5bi1d1bKvmAtg6VU.png', 'answer.png'),
(1, '2fMAEYPeXh6iY2ux4SYEJWM2nTu4UlRLB09LrvCs.pdf', 'document.pdf');