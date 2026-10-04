
import express from "express";

import {
  getSecurityOverview,
  getSessions,
  revokeDeviceSession,
  revokeOtherDeviceSessions,
  getActivity,
  updateSettings,
} from "../controllers/securityController.js";

import {
  authenticateToken,
} from "../middleware/authMiddleware.js";

const router = express.Router();

// All security endpoints require authentication.
router.use(authenticateToken);

// Security overview
router.get("/", getSecurityOverview);

// Active device sessions
router.get("/sessions", getSessions);

// Revoke a particular device session
router.delete(
  "/sessions/:sessionId",
  revokeDeviceSession
);

// Revoke all other device sessions
router.post(
  "/sessions/revoke-others",
  revokeOtherDeviceSessions
);

// Login and security activity
router.get("/activity", getActivity);

// Update security preferences
router.patch("/settings", updateSettings);

export default router;