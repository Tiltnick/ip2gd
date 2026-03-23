const pool = require("../db/db");

async function likePost(req, res) {
  try {
    const userId = req.user_id;
    const postId = req.params.id;

    const query = `
      INSERT INTO likes (user_id, post_id)
      VALUES ($1, $2)
      ON CONFLICT (user_id, post_id) DO NOTHING
      RETURNING *
    `;

    const values = [userId, postId];
    const result = await pool.query(query, values);

    return res.status(200).json({
      success: true,
      data: result.rows[0] || { user_id: userId, post_id: postId },
      error: null,
    });
  } catch (err) {
    console.error("DB Error:", err);
    return res.status(500).json({
      success: false,
      data: null,
      error: "Internal server error",
    });
  }
}

async function unlikePost(req, res) {
  try {
    const userId = req.user_id;
    const postId = req.params.id;

    const query = `
      DELETE FROM likes
      WHERE user_id = $1 AND post_id = $2
      RETURNING *
    `;

    const values = [userId, postId];
    const result = await pool.query(query, values);

    return res.status(200).json({
      success: true,
      data: result.rows[0] || { user_id: userId, post_id: postId },
      error: null,
    });
  } catch (err) {
    console.error("DB Error:", err);
    return res.status(500).json({
      success: false,
      data: null,
      error: "Internal server error",
    });
  }
}

module.exports = {
  likePost,
  unlikePost,
};