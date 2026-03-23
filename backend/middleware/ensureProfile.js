const pool = require("../db/db");

async function ensureProfile(req, res, next) {
  try {
    const userId = req.user_id;
    const username = req.username || "Unknown User";

    const checkQuery = `
      SELECT user_id
      FROM profile
      WHERE user_id = $1
    `;

    const checkResult = await pool.query(checkQuery, [userId]);

    if (checkResult.rows.length === 0) {
      const insertQuery = `
        INSERT INTO profile (user_id, display_name, bio, profile_picture)
        VALUES ($1, $2, $3, $4)
      `;

      await pool.query(insertQuery, [userId, username, "", ""]);
    }

    next();
  } catch (err) {
    console.error("EnsureProfile Error:", err);
    return res.status(500).json({
      success: false,
      data: null,
      error: "Could not ensure profile",
    });
  }
}

module.exports = ensureProfile;