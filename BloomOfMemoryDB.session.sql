insert into comment(comment_id, post_id, user_id, text)
VALUES (
    '33333333-3333-3333-3333-333333333333',
    '22222222-2222-2222-2222-222222222222',
    '11111111-1111-1111-1111-111111111111',
    'Nice post!'
);

SELECT * from comment; 


SELECT COUNT(*)
FROM likes
WHERE post_id = '22222222-2222-2222-2222-222222222222';

