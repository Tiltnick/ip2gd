CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE profile (
    user_id UUID PRIMARY KEY,
    bio TEXT,
    profile_picture TEXT,
    display_name TEXT
);

CREATE TABLE post (
    post_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES profile(user_id),
    caption TEXT,
    image_path TEXT,
    posted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE comment (
    comment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id UUID NOT NULL REFERENCES post(post_id),
    user_id UUID NOT NULL REFERENCES profile(user_id),
    text TEXT,
    posted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE likes (
    user_id UUID NOT NULL REFERENCES profile(user_id),
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


