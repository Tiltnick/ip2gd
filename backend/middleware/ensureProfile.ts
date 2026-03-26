import { Response, NextFunction } from "express";
import pool from "../db/db";
import { AuthRequest } from "../types/express";

async function ensureProfile(
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<Response | void> {
  try {
    const userId = req.user_id;
    const username = req.username || "Unknown User";

    if (!userId) {
      return res.status(401).json({
        success: false,
        data: null,
        error: "Unauthorized",
      });
    }

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

export default ensureProfile;