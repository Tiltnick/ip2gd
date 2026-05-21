import express from "express";

import authMiddleware from "../middleware/auth";
import ensureProfile from "../middleware/ensureProfile";

import {
  getMyProfile,
  updateMyProfile,
  getProfileByUserId,
  followProfile,
  unfollowProfile,
  getFollowing,
} from "../controllers/profileController";

const router = express.Router();

router.get("/me", authMiddleware, ensureProfile, getMyProfile);
router.put("/me", authMiddleware, ensureProfile, updateMyProfile);

router.get("/following", authMiddleware, ensureProfile, getFollowing);

router.post("/:user_id/follow", authMiddleware, ensureProfile, followProfile);
router.delete("/:user_id/follow", authMiddleware, ensureProfile, unfollowProfile);

router.get("/:user_id", authMiddleware, ensureProfile, getProfileByUserId);

export default router;