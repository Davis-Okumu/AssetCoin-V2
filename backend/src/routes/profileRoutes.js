
import express from "express";

import {
  getProfile,
  updateProfile,
  uploadProfilePhoto,
  deleteProfilePhoto,
  getProfileSettings,
  updateProfileSettings,
} from "../controllers/profileController.js";

import {
  authenticateToken,
} from "../middleware/authMiddleware.js";

import {
  uploadProfilePhoto as profilePhotoUpload,
} from "../middleware/uploadMiddleware.js";

const router = express.Router();

// All Profile routes require authentication.
router.use(authenticateToken);

// GET CURRENT USER PROFILE
router.get("/", getProfile);

// UPDATE PERSONAL INFORMATION
router.patch("/", updateProfile);

// UPLOAD OR CHANGE PROFILE PHOTO
router.post(
  "/photo",
  profilePhotoUpload.single("photo"),
  uploadProfilePhoto
);

// REMOVE PROFILE PHOTO
router.delete("/photo", deleteProfilePhoto);

// =====================================================
// USER SETTINGS
// =====================================================

// GET USER SETTINGS
router.get("/settings", getProfileSettings);

// UPDATE USER SETTINGS
router.patch("/settings", updateProfileSettings);

export default router;