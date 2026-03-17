function createPost(ctx, logger, nk, payload) {
    var data = JSON.parse(payload);
    var userId = ctx.userId;
    var postId = nk.uuidv4();
    var query = "\n    INSERT INTO post (post_id, user_id, caption, image_path)\n    VALUES ($1, $2, $3, $4)\n  ";
    nk.sqlExec(query, [postId, userId, data.caption, data.image_path]);
    return JSON.stringify({
        success: true,
        post_id: postId
    });
}
var InitModule = function (ctx, logger, nk, initializer) {
    initializer.registerRpc("create_post", createPost);
    logger.info("Spacegram RPCs registered.");
};
