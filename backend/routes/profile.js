const express = require("express");
const router = express.Router();

const authMiddleware = require("../middleware/auth");
const ensureProfile = require("../middleware/ensureProfile");
const {
  getMyProfile,
  updateMyProfile,
} = require("../controllers/profileController");

router.get("/me", authMiddleware, ensureProfile, getMyProfile);
router.put("/me", authMiddleware, ensureProfile, updateMyProfile);

module.exports = router;