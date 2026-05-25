CREATE TABLE profile (
    user_id UUID PRIMARY KEY,
    bio TEXT,
    profile_picture TEXT,
    display_name TEXT
);

CREATE TABLE post (
    post_id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    caption TEXT,
    image_path TEXT,
    posted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE comment (
    comment_id UUID PRIMARY KEY,
    post_id UUID NOT NULL REFERENCES post(post_id),
    user_id UUID NOT NULL,
    text TEXT,
    posted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE likes (
    user_id UUID NOT NULL,
    post_id UUID NOT NULL REFERENCES post(post_id),
    PRIMARY KEY (user_id, post_id)
);

INSERT INTO profile (user_id, display_name, bio, profile_picture)
VALUES (
  '7945e657-ca4b-4eb8-80c5-7de24f6eeb62',
  'Ursi1',
  '',
  ''
);

INSERT INTO profile (user_id, display_name, bio, profile_picture)
VALUES (
  '00000000-0000-0000-0000-000000000000',
  'Karl',
  '',
  ''
);

ALTER TABLE profile
ADD CONSTRAINT unique_display_name UNIQUE (display_name);



CREATE TABLE follow (
    follower_id UUID NOT NULL,
    following_id UUID NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (follower_id, following_id),
    FOREIGN KEY (follower_id) REFERENCES profile(user_id) ON DELETE CASCADE,
    FOREIGN KEY (following_id) REFERENCES profile(user_id) ON DELETE CASCADE,
    CHECK (follower_id <> following_id)
);


ALTER TABLE comment
ADD COLUMN IF NOT EXISTS parent_comment_id UUID REFERENCES comment(comment_id) ON DELETE CASCADE;


ALTER TABLE comment
DROP CONSTRAINT IF EXISTS comment_parent_comment_id_fkey;

ALTER TABLE comment
ADD CONSTRAINT comment_parent_comment_id_fkey
FOREIGN KEY (parent_comment_id)
REFERENCES comment(comment_id)
ON DELETE CASCADE;


CREATE TABLE comment_likes (
    user_id UUID NOT NULL,
    comment_id UUID NOT NULL REFERENCES comment(comment_id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, comment_id)
);