const express = require("express");
const router = express.Router();

const authMiddleware = require("../middleware/auth");
const ensureProfile = require("../middleware/ensureProfile");
const {
  getMyProfile,
  updateMyProfile,
  getProfileByUserId,
} = require("../controllers/profileController");

router.get("/me", authMiddleware, ensureProfile, getMyProfile);
router.put("/me", authMiddleware, ensureProfile, updateMyProfile);
router.get("/:user_id", authMiddleware, ensureProfile, getProfileByUserId);

module.exports = router;