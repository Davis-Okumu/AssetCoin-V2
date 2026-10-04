
import fs from "fs/promises";
import path from "path";
import { fileURLToPath } from "url";

import {
  getUserProfile,
  updateUserProfile,
  updateProfilePhoto,
  removeProfilePhoto,
} from "../services/profileService.js";

import {
  verifyUploadedFiles,
  allowedImages,
} from "../middleware/uploadMiddleware.js";

import {
  getUserPreferences,
  updateUserPreferences,
} from "../services/settingsService.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const profilePhotoDirectory = path.resolve(
  __dirname,
  "../../uploads/profile/photos"
);

// =====================================================
// HELPER: REMOVE UPLOADED FILE
// =====================================================

async function deleteUploadedFile(filePath) {
  if (!filePath) return;

  try {
    await fs.unlink(filePath);
  } catch (error) {
    if (error.code !== "ENOENT") {
      console.error("File cleanup error:", error.message);
    }
  }
}

// =====================================================
// HELPER: REMOVE OLD PROFILE PHOTO
// =====================================================

async function deletePreviousProfilePhoto(photoUrl) {
  if (!photoUrl) return;

  const filename = path.basename(photoUrl);

  if (!filename || filename === "." || filename === "..") {
    return;
  }

  const photoPath = path.join(
    profilePhotoDirectory,
    filename
  );

  await deleteUploadedFile(photoPath);
}

// =====================================================
// GET CURRENT PROFILE
// =====================================================

export async function getProfile(req, res) {
  try {
    const profile = await getUserProfile(req.user.id);

    return res.status(200).json({
      success: true,
      message: "Profile retrieved successfully.",
      data: {
        profile,
      },
    });
  } catch (error) {
    console.error("Get profile error:", error.message);

    return res.status(error.statusCode || 500).json({
      success: false,
      message: error.statusCode
        ? error.message
        : "Unable to retrieve your profile.",
    });
  }
}

// =====================================================
// UPDATE PERSONAL INFORMATION
// =====================================================

// =====================================================
// UPDATE PERSONAL INFORMATION
// =====================================================

export async function updateProfile(req, res) {
  try {
    const allowedFields = [
      "firstName",
      "lastName",
      "email",
      "phone",
    ];

    const profileData = {};

    for (const field of allowedFields) {
      if (
        Object.prototype.hasOwnProperty.call(req.body, field)
      ) {
        profileData[field] = req.body[field];
      }
    }

    if (Object.keys(profileData).length === 0) {
      return res.status(400).json({
        success: false,
        message: "Provide at least one profile field to update.",
      });
    }

    // Validate and normalize supplied fields.

    for (const [field, value] of Object.entries(profileData)) {
      if (typeof value !== "string") {
        return res.status(400).json({
          success: false,
          message: `${field} must be a valid string.`,
        });
      }

      profileData[field] = value.trim();
    }

    // =========================
    // VALIDATE FIRST NAME
    // =========================

    if (
      Object.prototype.hasOwnProperty.call(profileData, "firstName") &&
      !profileData.firstName
    ) {
      return res.status(400).json({
        success: false,
        message: "First name cannot be empty.",
      });
    }

    if (
      Object.prototype.hasOwnProperty.call(profileData, "firstName") &&
      profileData.firstName.length > 100
    ) {
      return res.status(400).json({
        success: false,
        message: "First name cannot exceed 100 characters.",
      });
    }

    // =========================
    // VALIDATE LAST NAME
    // =========================

    if (
      Object.prototype.hasOwnProperty.call(profileData, "lastName") &&
      !profileData.lastName
    ) {
      return res.status(400).json({
        success: false,
        message: "Last name cannot be empty.",
      });
    }

    if (
      Object.prototype.hasOwnProperty.call(profileData, "lastName") &&
      profileData.lastName.length > 100
    ) {
      return res.status(400).json({
        success: false,
        message: "Last name cannot exceed 100 characters.",
      });
    }

    // =========================
    // VALIDATE EMAIL
    // =========================

    if (
      Object.prototype.hasOwnProperty.call(profileData, "email")
    ) {
      if (profileData.email.length > 150) {
        return res.status(400).json({
          success: false,
          message: "Email cannot exceed 150 characters.",
        });
      }

      if (
        profileData.email &&
        !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(profileData.email)
      ) {
        return res.status(400).json({
          success: false,
          message: "Enter a valid email address.",
        });
      }

      // An empty email is stored as NULL.
      profileData.email = profileData.email || null;
    }

    // =========================
    // VALIDATE PHONE
    // =========================

    if (
      Object.prototype.hasOwnProperty.call(profileData, "phone") &&
      (
        !profileData.phone ||
        profileData.phone.length > 20
      )
    ) {
      return res.status(400).json({
        success: false,
        message: "Enter a valid phone number.",
      });
    }

    if (
      Object.prototype.hasOwnProperty.call(profileData, "phone") &&
      /[\s]/.test(profileData.phone)
    ) {
      return res.status(400).json({
        success: false,
        message: "Phone number cannot contain spaces.",
      });
    }

    if (
      Object.prototype.hasOwnProperty.call(profileData, "phone") &&
      !/^\+?[0-9]+$/.test(profileData.phone)
    ) {
      return res.status(400).json({
        success: false,
        message: "Enter a valid phone number.",
      });
    }

    // =========================
    // UPDATE PROFILE
    // =========================

    const profile = await updateUserProfile(
      req.user.id,
      profileData
    );

    return res.status(200).json({
      success: true,
      message: "Personal information updated successfully.",
      data: {
        profile,
      },
    });

  } catch (error) {
    console.error("Update profile error:", error.message);

    return res.status(error.statusCode || 500).json({
      success: false,
      message: error.statusCode
        ? error.message
        : "Unable to update your profile.",
    });
  }
}

// =====================================================
// UPLOAD PROFILE PHOTO
// =====================================================

export async function uploadProfilePhoto(req, res) {
  if (!req.file) {
    return res.status(400).json({
      success: false,
      message: "Select a profile photo to upload.",
    });
  }

  try {
    const isValid = await verifyUploadedFiles(
      [req.file],
      allowedImages
    );

    if (!isValid) {
      await deleteUploadedFile(req.file.path);

      return res.status(400).json({
        success: false,
        message: "The uploaded image is invalid.",
      });
    }

    const photoUrl = `/uploads/profile/photos/${req.file.filename}`;

    // Retrieve the previous photo before replacing it.
    const previousProfile = await getUserProfile(req.user.id);

    const profile = await updateProfilePhoto(
      req.user.id,
      photoUrl
    );

    // Remove the old file only after the database update succeeds.
    if (
      previousProfile.profilePhotoUrl &&
      previousProfile.profilePhotoUrl !== photoUrl
    ) {
      await deletePreviousProfilePhoto(
        previousProfile.profilePhotoUrl
      );
    }

    return res.status(200).json({
      success: true,
      message: "Profile photo updated successfully.",
      data: {
        profile,
      },
    });
  } catch (error) {
    await deleteUploadedFile(req.file.path);

    console.error("Profile photo upload error:", error.message);

    return res.status(error.statusCode || 500).json({
      success: false,
      message: error.statusCode
        ? error.message
        : "Unable to upload your profile photo.",
    });
  }
}

// =====================================================
// REMOVE PROFILE PHOTO
// =====================================================

export async function deleteProfilePhoto(req, res) {
  try {
    const result = await removeProfilePhoto(req.user.id);

    if (result.previousPhotoUrl) {
      await deletePreviousProfilePhoto(
        result.previousPhotoUrl
      );
    }

    return res.status(200).json({
      success: true,
      message: "Profile photo removed successfully.",
      data: {
        profile: result.profile,
      },
    });
  } catch (error) {
    console.error("Remove profile photo error:", error.message);

    return res.status(error.statusCode || 500).json({
      success: false,
      message: error.statusCode
        ? error.message
        : "Unable to remove your profile photo.",
    });
  }
}

// =====================================================
// GET USER SETTINGS
// =====================================================

export async function getProfileSettings(req, res) {
  try {
    const settings = await getUserPreferences(req.user.id);

    return res.status(200).json({
      success: true,
      message: "Settings retrieved successfully.",
      data: {
        settings,
      },
    });
  } catch (error) {
    console.error("Get profile settings error:", error.message);

    return res.status(error.statusCode || 500).json({
      success: false,
      message: error.statusCode
        ? error.message
        : "Unable to retrieve your settings.",
    });
  }
}

// =====================================================
// UPDATE USER SETTINGS
// =====================================================

export async function updateProfileSettings(req, res) {
  try {
    const settings = await updateUserPreferences(
      req.user.id,
      req.body
    );

    return res.status(200).json({
      success: true,
      message: "Settings updated successfully.",
      data: {
        settings,
      },
    });
  } catch (error) {
    console.error("Update profile settings error:", error.message);

    return res.status(error.statusCode || 500).json({
      success: false,
      message: error.statusCode
        ? error.message
        : "Unable to update your settings.",
    });
  }
}