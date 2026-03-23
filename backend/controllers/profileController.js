const pool = require("../db/db");

async function getMyProfile(req, res) {
  try {
    const userId = req.user_id;

    const query = `
      SELECT
        user_id,
        display_name,
        bio,
        profile_picture
      FROM profile
      WHERE user_id = $1
      LIMIT 1
    `;

    const result = await pool.query(query, [userId]);

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        data: null,
        error: "Profile not found",
      });
    }

    return res.status(200).json({
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

async function updateMyProfile(req, res) {
  try {
    const userId = req.user_id;
    const { display_name, bio, profile_picture } = req.body;

    const query = `
      UPDATE profile
      SET
        display_name = COALESCE($1, display_name),
        bio = COALESCE($2, bio),
        profile_picture = COALESCE($3, profile_picture)
      WHERE user_id = $4
      RETURNING user_id, display_name, bio, profile_picture
    `;

    const values = [display_name, bio, profile_picture, userId];
    const result = await pool.query(query, values);

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        data: null,
        error: "Profile not found",
      });
    }

    return res.status(200).json({
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

module.exports = {
  getMyProfile,
  updateMyProfile,
};