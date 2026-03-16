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