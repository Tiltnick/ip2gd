SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public';

INSERT INTO profile (user_id, bio, profile_picture, display_name)
VALUES (
    '11111111-1111-1111-1111-111111111111',
    'Test bio',
    'assets/profile.png',
    'Oris'
);

SELECT * FROM profile

INSERT INTO post (post_id, user_id, caption, image_path)
VALUES (
    '22222222-2222-2222-2222-222222222222',
    '11111111-1111-1111-1111-111111111111',
    'Mein erster Post',
    'assets/posts/test.png'
);

SELECT * FROM post;