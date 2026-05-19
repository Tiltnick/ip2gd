import { Response } from "express";
import pool from "../db/db";
import { AuthRequest } from "../types/express";

export async function createPost(req: AuthRequest, res: Response): Promise<Response> {
  try {
    const userId = req.user_id;
    const { caption, image_path } = req.body as {
      caption?: string;
      image_path?: string;
    };

    if (!userId) {
      return res.status(401).json({
        success: false,
        data: null,
        error: "Unauthorized",
      });
    }

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

export async function getPosts(req: AuthRequest, res: Response): Promise<Response> {
  try {
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
        p.post_id,
        p.user_id,
        p.caption,
        p.image_path,
        p.posted_at,
        pr.display_name,
        pr.profile_picture,
        COUNT(DISTINCT l.user_id) AS like_count,
        COUNT(DISTINCT c.comment_id) AS comment_count,
        EXISTS (
          SELECT 1
          FROM likes my_like
          WHERE my_like.post_id = p.post_id
          AND my_like.user_id = $1
        ) AS liked_by_me
      FROM post p
      JOIN profile pr ON pr.user_id = p.user_id
      LEFT JOIN likes l ON l.post_id = p.post_id
      LEFT JOIN comment c ON c.post_id = p.post_id
      GROUP BY 
        p.post_id,
        p.user_id,
        p.caption,
        p.image_path,
        p.posted_at,
        pr.display_name,
        pr.profile_picture
      ORDER BY p.posted_at DESC
    `;

    const result = await pool.query(query, [userId]);

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

export async function deletePost(req: AuthRequest, res: Response): Promise<Response> {
  const client = await pool.connect();

  try {
    const userId = req.user_id;
    const postId = req.params.id;

    if (!userId) {
      client.release();
      return res.status(401).json({
        success: false,
        data: null,
        error: "Unauthorized",
      });
    }

    await client.query("BEGIN");

    const checkQuery = `
      SELECT *
      FROM post
      WHERE post_id = $1 AND user_id = $2
    `;

    const checkResult = await client.query(checkQuery, [postId, userId]);

    if (checkResult.rows.length === 0) {
      await client.query("ROLLBACK");
      client.release();

      return res.status(404).json({
        success: false,
        data: null,
        error: "Post not found or not owned by user",
      });
    }

    await client.query(`DELETE FROM likes WHERE post_id = $1`, [postId]);
    await client.query(`DELETE FROM comment WHERE post_id = $1`, [postId]);

    const deleteResult = await client.query(
      `
      DELETE FROM post
      WHERE post_id = $1 AND user_id = $2
      RETURNING *
      `,
      [postId, userId]
    );

    await client.query("COMMIT");
    client.release();

    return res.status(200).json({
      success: true,
      data: deleteResult.rows[0],
      error: null,
    });
  } catch (err) {
    await client.query("ROLLBACK");
    client.release();

    console.error("DB Error:", err);
    return res.status(500).json({
      success: false,
      data: null,
      error: "Internal server error",
    });
  }
}