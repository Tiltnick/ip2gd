import { Response, NextFunction } from "express";
import jwt, { JwtPayload } from "jsonwebtoken";
import dotenv from "dotenv";
import path from "path";

import { AuthRequest } from "../types/express";

dotenv.config({ path: path.join(__dirname, "..", ".env") });

interface NakamaTokenPayload extends JwtPayload {
  uid?: string;
  usn?: string;
}

function authMiddleware(req: AuthRequest, res: Response, next: NextFunction): Response | void {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return res.status(401).json({
      success: false,
      data: null,
      error: "Missing or invalid authorization header",
    });
  }

  const token = authHeader.split(" ")[1];
  const sessionKey = process.env.NAKAMA_SESSION_ENCRYPTION_KEY;

  if (!sessionKey) {
    console.error("Missing NAKAMA_SESSION_ENCRYPTION_KEY in environment");

    return res.status(500).json({
      success: false,
      data: null,
      error: "Server configuration error",
    });
  }

  try {
    const payload = jwt.verify(token, sessionKey, {
      algorithms: ["HS256"],
    }) as NakamaTokenPayload;

    if (!payload.uid) {
      return res.status(401).json({
        success: false,
        data: null,
        error: "Invalid token payload",
      });
    }

    req.user_id = payload.uid;
    req.username = payload.usn || null;
    req.token_claims = payload;

    next();
  } catch (err) {
    if (err instanceof Error) {
      console.error("JWT verify failed:", err.name, err.message);
    } else {
      console.error("JWT verify failed:", err);
    }

    return res.status(401).json({
      success: false,
      data: null,
      error: "Invalid or expired token",
    });
  }
}

export default authMiddleware;