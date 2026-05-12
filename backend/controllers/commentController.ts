import { Response } from "express";
import pool from "../db/db";
import { AuthRequest } from "../types/express";

export async function createComment(req: AuthRequest, res: Response): Promise<Response> {
  try {
    const userId = req.user_id;
    const postId = req.params.id;
    const { text } = req.body as { text?: string };

    if (!userId) {
      return res.status(401).json({
        success: false,
        data: null,
        error: "Unauthorized",
      });
    }

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

export async function getCommentsByPost(req: AuthRequest, res: Response): Promise<Response> {
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

export async function deleteComment(req: AuthRequest, res: Response): Promise<Response> {
  try {
    const userId = req.user_id;
    const commentId = req.params.comment_id;

    if (!userId) {
      return res.status(401).json({
        success: false,
        data: null,
        error: "Unauthorized",
      });
    }

    const query = `
      DELETE FROM comment
      WHERE comment_id = $1 AND user_id = $2
      RETURNING *
    `;

    const result = await pool.query(query, [commentId, userId]);

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        data: null,
        error: "Comment not found or not owned by user",
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