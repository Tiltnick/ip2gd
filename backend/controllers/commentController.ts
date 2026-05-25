import { Response } from "express";
import pool from "../db/db";
import { AuthRequest } from "../types/express";

export async function createComment(req: AuthRequest, res: Response): Promise<Response> {
  try {
    const userId = req.user_id;
    const postId = req.params.id;
    const { text, parent_comment_id } = req.body as {
      text?: string;
      parent_comment_id?: string | null;
    };

    if (!userId) {
      return res.status(401).json({
        success: false,
        data: null,
        error: "Unauthorized",
      });
    }

    if (!text || text.trim().length === 0) {
      return res.status(400).json({
        success: false,
        data: null,
        error: "text is required",
      });
    }

    if (parent_comment_id) {
      const parentCheck = await pool.query(
        `
        SELECT comment_id
        FROM comment
        WHERE comment_id = $1 AND post_id = $2
        `,
        [parent_comment_id, postId]
      );

      if (parentCheck.rows.length === 0) {
        return res.status(404).json({
          success: false,
          data: null,
          error: "Parent comment not found",
        });
      }
    }

    const query = `
      INSERT INTO comment (post_id, user_id, text, parent_comment_id)
      VALUES ($1, $2, $3, $4)
      RETURNING *
    `;

    const values = [postId, userId, text.trim(), parent_comment_id || null];
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
    const userId = req.user_id;

    if (!userId) {
      return res.status(401).json({
        success: false,
        data: null,
        error: "Unauthorized",
      });
    }

    const query = `
      SELECT
        c.comment_id,
        c.post_id,
        c.user_id,
        c.text,
        c.posted_at,
        c.parent_comment_id,
        p.display_name,
        p.profile_picture,
        COUNT(DISTINCT cl.user_id)::int AS like_count,
        EXISTS (
          SELECT 1
          FROM comment_likes my_like
          WHERE my_like.comment_id = c.comment_id
          AND my_like.user_id = $2
        ) AS liked_by_me
      FROM comment c
      JOIN profile p ON p.user_id = c.user_id
      LEFT JOIN comment_likes cl ON cl.comment_id = c.comment_id
      WHERE c.post_id = $1
      GROUP BY
        c.comment_id,
        c.post_id,
        c.user_id,
        c.text,
        c.posted_at,
        c.parent_comment_id,
        p.display_name,
        p.profile_picture
      ORDER BY c.posted_at ASC
    `;

    const result = await pool.query(query, [postId, userId]);

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


export async function likeComment(req: AuthRequest, res: Response): Promise<Response> {
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

    const commentCheck = await pool.query(
      `
      SELECT comment_id
      FROM comment
      WHERE comment_id = $1
      `,
      [commentId]
    );

    if (commentCheck.rows.length === 0) {
      return res.status(404).json({
        success: false,
        data: null,
        error: "Comment not found",
      });
    }

    const query = `
      INSERT INTO comment_likes (user_id, comment_id)
      VALUES ($1, $2)
      ON CONFLICT (user_id, comment_id) DO NOTHING
      RETURNING *
    `;

    const result = await pool.query(query, [userId, commentId]);

    return res.status(200).json({
      success: true,
      data: result.rows[0] || {
        user_id: userId,
        comment_id: commentId,
      },
      error: null,
    });
  } catch (err) {
    console.error("Like Comment Error:", err);
    return res.status(500).json({
      success: false,
      data: null,
      error: "Internal server error",
    });
  }
}


export async function unlikeComment(req: AuthRequest, res: Response): Promise<Response> {
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

    await pool.query(
      `
      DELETE FROM comment_likes
      WHERE user_id = $1 AND comment_id = $2
      `,
      [userId, commentId]
    );

    return res.status(200).json({
      success: true,
      data: null,
      error: null,
    });
  } catch (err) {
    console.error("Unlike Comment Error:", err);
    return res.status(500).json({
      success: false,
      data: null,
      error: "Internal server error",
    });
  }
}