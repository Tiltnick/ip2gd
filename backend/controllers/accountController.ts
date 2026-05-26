import { Response } from "express";
import pool from "../db/db";
import { AuthRequest } from "../types/express";



export async function deleteMyAccount(req: AuthRequest, res: Response): Promise<Response> {
  const client = await pool.connect();

  try {
    const userId = req.user_id;
    const authHeader = req.headers.authorization as string | undefined;

    if (!userId || !authHeader) {
      client.release();

      return res.status(401).json({
        success: false,
        data: null,
        error: "Unauthorized",
      });
    }

    await client.query("BEGIN");

    // 1. Likes auf Kommentare löschen, die der User selbst gesetzt hat
    await client.query(
      `
      DELETE FROM comment_likes
      WHERE user_id = $1
      `,
      [userId]
    );

    // 2. Likes auf Kommentare löschen, die zu Kommentaren des Users gehören
    await client.query(
      `
      DELETE FROM comment_likes
      WHERE comment_id IN (
        SELECT comment_id
        FROM comment
        WHERE user_id = $1
      )
      `,
      [userId]
    );

    // 3. Likes auf Kommentare löschen, die zu Posts des Users gehören
    await client.query(
      `
      DELETE FROM comment_likes
      WHERE comment_id IN (
        SELECT c.comment_id
        FROM comment c
        JOIN post p ON p.post_id = c.post_id
        WHERE p.user_id = $1
      )
      `,
      [userId]
    );

    // 4. Follow-Beziehungen löschen
    await client.query(
      `
      DELETE FROM follow
      WHERE follower_id = $1
      OR following_id = $1
      `,
      [userId]
    );

    // 5. Post-Likes löschen, die der User selbst gesetzt hat
    await client.query(
      `
      DELETE FROM likes
      WHERE user_id = $1
      `,
      [userId]
    );

    // 6. Post-Likes löschen, die auf Posts des Users liegen
    await client.query(
      `
      DELETE FROM likes
      WHERE post_id IN (
        SELECT post_id
        FROM post
        WHERE user_id = $1
      )
      `,
      [userId]
    );

    // 7. Kommentare des Users löschen
    await client.query(
      `
      DELETE FROM comment
      WHERE user_id = $1
      `,
      [userId]
    );

    // 8. Kommentare auf Posts des Users löschen
    await client.query(
      `
      DELETE FROM comment
      WHERE post_id IN (
        SELECT post_id
        FROM post
        WHERE user_id = $1
      )
      `,
      [userId]
    );

    // 9. Posts des Users löschen
    await client.query(
      `
      DELETE FROM post
      WHERE user_id = $1
      `,
      [userId]
    );

    // 10. Profil löschen
    await client.query(
      `
      DELETE FROM profile
      WHERE user_id = $1
      `,
      [userId]
    );

    // 11. Erst wenn PostgreSQL cleanup funktioniert hat: Nakama-Account löschen
    const nakamaResponse = await fetch("http://127.0.0.1:7350/v2/account", {
      method: "DELETE",
      headers: {
        Authorization: authHeader,
        Accept: "application/json",
        "Content-Type": "application/json",
      },
    });

    if (!nakamaResponse.ok) {
      const text = await nakamaResponse.text();
      console.error("Nakama delete failed:", text);

      await client.query("ROLLBACK");
      client.release();

      return res.status(500).json({
        success: false,
        data: null,
        error: "Failed to delete Nakama account",
      });
    }

    await client.query("COMMIT");
    client.release();

    return res.status(200).json({
      success: true,
      data: null,
      error: null,
    });
  } catch (err) {
    await client.query("ROLLBACK");
    client.release();

    console.error("Delete Error:", err);

    return res.status(500).json({
      success: false,
      data: null,
      error: "Internal server error",
    });
  }
}