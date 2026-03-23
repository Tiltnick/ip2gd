const pool = require("../db/db");

async function createComment(req, res) {
  try {
    const userId = req.user_id;
    const postId = req.params.id;
    const { text } = req.body;

    if (!text) {
      return res.status(400).json({
        success: false,
        data: null,
        error: "text is required",
      });
    }

    const query = `
      INSERT INTO comment (post_id, user_id, text)
      VALUES ($1, $2, $3)
      RETURNING *
    `;

    const values = [postId, userId, text];
    const result = await pool.query(query, values);

    return res.status(201).json({
      success: true,
      data: result.rows[0],
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

async function getCommentsByPost(req, res) {
  try {
    const postId = req.params.id;

    const query = `
      SELECT
        c.comment_id,
        c.post_id,
        c.user_id,
        c.text,
        c.posted_at,
        p.display_name
      FROM comment c
      JOIN profile p ON p.user_id = c.user_id
      WHERE c.post_id = $1
      ORDER BY c.posted_at ASC
    `;

    const result = await pool.query(query, [postId]);

    return res.status(200).json({
      success: true,
      data: result.rows,
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
  createComment,
  getCommentsByPost,
};