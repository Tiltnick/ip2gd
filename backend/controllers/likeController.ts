import { Response } from "express";
import pool from "../db/db";
import { AuthRequest } from "../types/express";

export async function likePost(req: AuthRequest, res: Response): Promise<Response> {
  try {
    const userId = req.user_id;
    const postId = req.params.id;

    if (!userId) {
      return res.status(401).json({
        success: false,
        data: null,
        error: "Unauthorized",
      });
    }

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

export async function unlikePost(req: AuthRequest, res: Response): Promise<Response> {
  try {
    const userId = req.user_id;
    const postId = req.params.id;

    if (!userId) {
      return res.status(401).json({
        success: false,
        data: null,
        error: "Unauthorized",
      });
    }

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