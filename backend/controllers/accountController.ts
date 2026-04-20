import { Response } from "express";
import pool from "../db/db";
import { AuthRequest } from "../types/express";



export async function deleteMyAccount(req: AuthRequest, res: Response): Promise<Response> {
  try {
    const userId = req.user_id;

    if (!userId) {
      return res.status(401).json({
        success: false,
        data: null,
        error: "Unauthorized",
      });
    }

    const nakamaResponse = await fetch("http://127.0.0.1:7350/v2/rpc/delete_account", {
      method: "POST",
      headers: {
        Authorization: req.headers.authorization as string,
      },
});
    

    if (!nakamaResponse.ok) {
      const text = await nakamaResponse.text();
      console.error("Nakama delete failed:", text);

      return res.status(500).json({
        success: false,
        data: null,
        error: "Failed to delete Nakama account",
      });
    }

    // DB cleanup
    await pool.query(`DELETE FROM likes WHERE user_id = $1`, [userId]);
    await pool.query(`DELETE FROM comment WHERE user_id = $1`, [userId]);
    await pool.query(`DELETE FROM post WHERE user_id = $1`, [userId]);
    await pool.query(`DELETE FROM profile WHERE user_id = $1`, [userId]);

    return res.status(200).json({
      success: true,
      data: null,
      error: null,
    });

  } catch (err) {
    console.error("Delete Error:", err);
    return res.status(500).json({
      success: false,
      data: null,
      error: "Internal server error",
    });
  }
}