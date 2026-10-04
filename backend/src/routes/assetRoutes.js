
import express from "express";

import {
  getAssets,
  getAssetDetails,
  getCategories,
  getMarketStats,
  getMySubmissions,
  getMySubmissionDetails,
  createAsset,
} from "../controllers/assetController.js";

import {
  uploadPhotos,
  uploadDocuments,
  downloadAssetDocument,
} from "../controllers/assetUploadController.js";

import { authenticateToken } from "../middleware/authMiddleware.js";

import {
  requireAssetOwnership,
} from "../middleware/assetOwnershipMiddleware.js";

import {
  uploadAssetPhotos,
  uploadAssetDocuments,
} from "../middleware/uploadMiddleware.js";

const router = express.Router();

// =====================================================
// PUBLIC ASSET MARKETPLACE ROUTES
// =====================================================

router.get("/", getAssets);

router.get("/categories", getCategories);

router.get("/market-stats", getMarketStats);


// =====================================================
// AUTHENTICATED USER ASSET ROUTES
// =====================================================

router.get(
  "/my-submissions",
  authenticateToken,
  getMySubmissions
);

router.get(
  "/my-submissions/:id",
  authenticateToken,
  getMySubmissionDetails
);

router.post(
  "/submit",
  authenticateToken,
  createAsset
);


// =====================================================
// ASSET PHOTO UPLOAD
// POST /api/assets/:id/photos
// =====================================================

router.post(
  "/:id/photos",
  authenticateToken,
  requireAssetOwnership,
  uploadAssetPhotos.array("photos", 5),
  uploadPhotos
);

// =====================================================
// ASSET DOCUMENTS UPLOAD
// POST /api/assets/:id/documents
// =====================================================

router.post(
  "/:id/documents",
  authenticateToken,
  requireAssetOwnership,
  uploadAssetDocuments.array("documents", 5),
  uploadDocuments
);

// =====================================================
// PRIVATE ASSET DOCUMENT DOWNLOAD
// GET /api/assets/:id/documents/:documentId/download
// =====================================================

router.get(
  "/:id/documents/:documentId/download",
  authenticateToken,
  downloadAssetDocument
);


// =====================================================
// PUBLIC ASSET DETAILS
// =====================================================

router.get("/:id", getAssetDetails);

export default router;