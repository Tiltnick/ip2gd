import { Response } from "express";
import pool from "../db/db";
import { AuthRequest } from "../types/express";

export async function getMyProfile(req: AuthRequest, res: Response): Promise<Response> {
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

export async function updateMyProfile(req: AuthRequest, res: Response): Promise<Response> {
  try {
    const userId = req.user_id;
    const { display_name, bio, profile_picture } = req.body as {
      display_name?: string;
      bio?: string;
      profile_picture?: string;
    };

    if (!userId) {
      return res.status(401).json({
        success: false,
        data: null,
        error: "Unauthorized",
      });
    }

    if (display_name !== undefined) {
      const trimmedDisplayName = display_name.trim();

      if (trimmedDisplayName.length === 0) {
        return res.status(400).json({
          success: false,
          data: null,
          error: "DISPLAY_NAME_REQUIRED",
        });
      }

      if (trimmedDisplayName.length > 12) {
        return res.status(400).json({
          success: false,
          data: null,
          error: "DISPLAY_NAME_TOO_LONG",
        });
      }
    }

    const query = `
      UPDATE profile
      SET
        display_name = COALESCE($1, display_name),
        bio = COALESCE($2, bio),
        profile_picture = COALESCE($3, profile_picture)
      WHERE user_id = $4
      RETURNING user_id, display_name, bio, profile_picture
    `;

    const values = [display_name?.trim(), bio, profile_picture, userId];
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
  } catch (err: any) {
    console.error("DB Error:", err);
    if (err.code === "23505") {
      return res.status(400).json({
        success: false,
        data: null,
        error: "DISPLAY_NAME_TAKEN",
      });
    }
    return res.status(500).json({
      success: false,
      data: null,
      error: "Internal server error",
    });
  }
}

export async function getProfileByUserId(req: AuthRequest, res: Response): Promise<Response> {
  try {
    const userId = req.params.user_id;

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

export async function followProfile(req: AuthRequest, res: Response): Promise<Response> {
  try {
    const followerId = req.user_id;
    const followingId = req.params.user_id;

    if (!followerId) {
      return res.status(401).json({
        success: false,
        data: null,
        error: "Unauthorized",
      });
    }

    if (followerId === followingId) {
      return res.status(400).json({
        success: false,
        data: null,
        error: "CANNOT_FOLLOW_SELF",
      });
    }

    const profileCheck = await pool.query(
      `SELECT user_id FROM profile WHERE user_id = $1`,
      [followingId]
    );

    if (profileCheck.rows.length === 0) {
      return res.status(404).json({
        success: false,
        data: null,
        error: "Profile not found",
      });
    }

    const query = `
      INSERT INTO follow (follower_id, following_id)
      VALUES ($1, $2)
      ON CONFLICT (follower_id, following_id) DO NOTHING
      RETURNING *
    `;

    const result = await pool.query(query, [followerId, followingId]);

    return res.status(200).json({
      success: true,
      data: result.rows[0] || {
        follower_id: followerId,
        following_id: followingId,
      },
      error: null,
    });
  } catch (err) {
    console.error("Follow Error:", err);
    return res.status(500).json({
      success: false,
      data: null,
      error: "Internal server error",
    });
  }
}


export async function unfollowProfile(req: AuthRequest, res: Response): Promise<Response> {
  try {
    const followerId = req.user_id;
    const followingId = req.params.user_id;

    if (!followerId) {
      return res.status(401).json({
        success: false,
        data: null,
        error: "Unauthorized",
      });
    }

    await pool.query(
      `
      DELETE FROM follow
      WHERE follower_id = $1 AND following_id = $2
      `,
      [followerId, followingId]
    );

    return res.status(200).json({
      success: true,
      data: null,
      error: null,
    });
  } catch (err) {
    console.error("Unfollow Error:", err);
    return res.status(500).json({
      success: false,
      data: null,
      error: "Internal server error",
    });
  }
}


export async function getFollowing(req: AuthRequest, res: Response): Promise<Response> {
  try {
    const followerId = req.user_id;

    if (!followerId) {
      return res.status(401).json({
        success: false,
        data: null,
        error: "Unauthorized",
      });
    }

    const query = `
      SELECT
        p.user_id,
        p.display_name,
        p.bio,
        p.profile_picture,
        f.created_at
      FROM follow f
      JOIN profile p ON p.user_id = f.following_id
      WHERE f.follower_id = $1
      ORDER BY f.created_at DESC
    `;

    const result = await pool.query(query, [followerId]);

    return res.status(200).json({
      success: true,
      data: result.rows,
      error: null,
    });
  } catch (err) {
    console.error("Get Following Error:", err);
    return res.status(500).json({
      success: false,
      data: null,
      error: "Internal server error",
    });
  }
}