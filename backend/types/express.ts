import { Request } from "express";

export interface AuthRequest extends Request {
  user_id?: string;
  username?: string | null;
  token_claims?: unknown;
}