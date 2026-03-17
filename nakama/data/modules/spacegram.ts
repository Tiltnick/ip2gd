function createPost(ctx: nkruntime.Context, logger: nkruntime.Logger, nk: nkruntime.Nakama, payload: string) {
  const data = JSON.parse(payload);

  const userId = ctx.userId;
  const postId = nk.uuidv4();

  const query = `
    INSERT INTO post (post_id, user_id, caption, image_path)
    VALUES ($1, $2, $3, $4)
  `;

  nk.sqlExec(query, [postId, userId, data.caption, data.image_path]);

  return JSON.stringify({
    success: true,
    post_id: postId
  });
}

const InitModule: nkruntime.InitModule = function (ctx, logger, nk, initializer) {
  initializer.registerRpc("create_post", createPost);
  logger.info("Spacegram RPCs registered.");
};