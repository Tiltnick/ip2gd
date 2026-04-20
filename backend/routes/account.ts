import express from "express";

import authMiddleware from "../middleware/auth";
import ensureProfile from "../middleware/ensureProfile";

import {
  deleteMyAccount
} from "../controllers/accountController";

const router = express.Router();

router.delete("/me", authMiddleware, ensureProfile, deleteMyAccount);


export default router;