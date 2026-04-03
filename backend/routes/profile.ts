import express from "express";

import authMiddleware from "../middleware/auth";
import ensureProfile from "../middleware/ensureProfile";

import {
  getMyProfile,
  updateMyProfile,
  getProfileByUserId,
} from "../controllers/profileController";

const router = express.Router();

router.get("/me", authMiddleware, ensureProfile, getMyProfile);
router.put("/me", authMiddleware, ensureProfile, updateMyProfile);
router.get("/:user_id", authMiddleware, ensureProfile, getProfileByUserId);

export default router;