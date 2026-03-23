const express = require("express");
const router = express.Router();

const authMiddleware = require("../middleware/auth");
const ensureProfile = require("../middleware/ensureProfile");

const { createPost, getPosts } = require("../controllers/postController");
const {
  createComment,
  getCommentsByPost,
} = require("../controllers/commentController");
const {
  likePost,
  unlikePost,
} = require("../controllers/likeController");

// console.log({
//   createPost,
//   getPosts,
//   createComment,
//   getCommentsByPost,
//   likePost,
//   unlikePost,
// });

router.post("/", authMiddleware, ensureProfile, createPost);
router.get("/", authMiddleware, ensureProfile, getPosts);

router.post("/:id/comments", authMiddleware, ensureProfile, createComment);
router.get("/:id/comments", authMiddleware, ensureProfile, getCommentsByPost);

router.post("/:id/like", authMiddleware, ensureProfile, likePost);
router.delete("/:id/like", authMiddleware, ensureProfile, unlikePost);

module.exports = router;