CREATE TABLE "user" (
    user_id UUID PRIMARY KEY,
    username TEXT UNIQUE NOT NULL,
    email TEXT UNIQUE NOT NULL
);

CREATE TABLE profile (
    user_id UUID PRIMARY KEY REFERENCES "user"(user_id),
    bio TEXT,
    profile_picture TEXT,
    display_name TEXT 
);

CREATE TABLE post (
    post_id UUID PRIMARY KEY,
    user_id UUID REFERENCES "user"(user_id),
    caption TEXT,
    image_path TEXT,
    posted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE comment (
    comment_id UUID PRIMARY KEY,
    post_id UUID REFERENCES post(post_id),
    user_id UUID REFERENCES "user"(user_id),
    text TEXT,
    posted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE follow (
    follower_user_id UUID REFERENCES "user"(user_id),
    followed_user_id UUID REFERENCES "user"(user_id),
    status TEXT,
    PRIMARY KEY (follower_user_id, followed_user_id)
);

CREATE TABLE likes (
    user_id UUID REFERENCES "user"(user_id),
    post_id UUID REFERENCES post(post_id),
    PRIMARY KEY (user_id, post_id)
);