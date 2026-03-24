const express = require("express");
const router = express.Router();

const authMiddleware = require("../middleware/auth");
const ensureProfile = require("../middleware/ensureProfile");

const { createPost, getPosts, deletePost } = require("../controllers/postController");
const {
  createComment,
  getCommentsByPost,
  deleteComment,
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
router.delete("/:id", authMiddleware, ensureProfile, deletePost);
router.get("/", authMiddleware, ensureProfile, getPosts);

router.post("/:id/comments", authMiddleware, ensureProfile, createComment);
router.get("/:id/comments", authMiddleware, ensureProfile, getCommentsByPost);
router.delete("/comments/:comment_id", authMiddleware, ensureProfile, deleteComment);

router.post("/:id/like", authMiddleware, ensureProfile, likePost);
router.delete("/:id/like", authMiddleware, ensureProfile, unlikePost);

module.exports = router;