const pool = require("../db/db");

async function createPost(req, res) {
  try {
    const userId = req.user_id;
    const { caption, image_path } = req.body;

    if (!caption || !image_path) {
      return res.status(400).json({
        success: false,
        data: null,
        error: "caption and image_path are required",
      });
    }

    const query = `
      INSERT INTO post (user_id, caption, image_path)
      VALUES ($1, $2, $3)
      RETURNING *
    `;

    const values = [userId, caption, image_path];
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

async function getPosts(req, res) {
  try {
    const query = `
      SELECT 
        p.post_id,
        p.user_id,
        p.caption,
        p.image_path,
        p.posted_at,
        pr.display_name,
        COUNT(DISTINCT l.user_id) AS likes_count,
        COUNT(DISTINCT c.comment_id) AS comments_count
      FROM post p
      JOIN profile pr ON pr.user_id = p.user_id
      LEFT JOIN likes l ON l.post_id = p.post_id
      LEFT JOIN comment c ON c.post_id = p.post_id
      GROUP BY p.post_id, pr.display_name
      ORDER BY p.posted_at DESC
    `;

    const result = await pool.query(query);

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
  createPost,
  getPosts,
};