
import express from "express";

import {
  register,
  login,
  getCurrentUser,
  forgotPassword,
  resetPassword,
  changePassword,
  logout,
} from "../controllers/authController.js";

import {
  authenticateToken,
} from "../middleware/authMiddleware.js";

const router = express.Router();

// =========================
// PUBLIC AUTHENTICATION
// =========================

router.post("/register", register);

router.post("/login", login);

router.post("/forgot-password", forgotPassword);

router.post("/reset-password", resetPassword);

// =========================
// PROTECTED AUTHENTICATION
// =========================

router.get(
  "/me",
  authenticateToken,
  getCurrentUser
);

router.post(
  "/change-password",
  authenticateToken,
  changePassword
);

router.post(
  "/logout",
  authenticateToken,
  logout
);

export default router;