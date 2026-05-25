import express from "express";

import authMiddleware from "../middleware/auth";
import ensureProfile from "../middleware/ensureProfile";

import { createPost, getPosts, deletePost } from "../controllers/postController";
import {
  createComment,
  getCommentsByPost,
  deleteComment,
  likeComment,
  unlikeComment,
} from "../controllers/commentController";
import { likePost, unlikePost } from "../controllers/likeController";

const router = express.Router();

router.post("/", authMiddleware, ensureProfile, createPost);
router.delete("/:id", authMiddleware, ensureProfile, deletePost);
router.get("/", authMiddleware, ensureProfile, getPosts);

router.post("/:id/comments", authMiddleware, ensureProfile, createComment);
router.get("/:id/comments", authMiddleware, ensureProfile, getCommentsByPost);

router.post("/comments/:comment_id/like", authMiddleware, ensureProfile, likeComment);
router.delete("/comments/:comment_id/like", authMiddleware, ensureProfile, unlikeComment);

router.delete("/comments/:comment_id", authMiddleware, ensureProfile, deleteComment);

router.post("/:id/like", authMiddleware, ensureProfile, likePost);
router.delete("/:id/like", authMiddleware, ensureProfile, unlikePost);

export { router };
export default router;