import fs from "fs/promises";

import path from "path";
import {
  getAssetDocumentForAccess,
} from "../services/assetService.js";

import {
  saveAssetPhotos,
  saveAssetDocuments,
} from "../services/assetService.js";

import {
  verifyUploadedFiles,
} from "../middleware/uploadMiddleware.js";

// =====================================================
// UPLOAD ASSET PHOTOS
// POST /api/assets/:id/photos
// =====================================================

export async function uploadPhotos(req, res) {
  const files = req.files || [];

  // Helper to remove files from disk.
  async function removeUploadedFiles() {
    await Promise.allSettled(
      files.map((file) => fs.unlink(file.path))
    );
  }

  if (files.length === 0) {
    return res.status(400).json({
      success: false,
      message: "Please select at least one photo.",
    });
  }

  // Verify actual file contents before saving database records.
    // Verify actual file contents before saving database records.
  // Verify actual file contents before saving database records.
  try {
    const isValid = await verifyUploadedFiles(files, {
      "image/jpeg": [".jpg", ".jpeg"],
      "image/png": [".png"],
      "image/webp": [".webp"],
    });

    if (!isValid) {
      await removeUploadedFiles();

      return res.status(400).json({
        success: false,
        message: "One or more uploaded photos have invalid file contents.",
      });
    }
  } catch (error) {
    console.error("Photo content validation error:", error);

    await removeUploadedFiles();

    return res.status(400).json({
      success: false,
      message: "Unable to validate uploaded photos.",
    });
  }
}

// =====================================================
// UPLOAD ASSET DOCUMENTS
// POST /api/assets/:id/documents
// =====================================================

export async function uploadDocuments(req, res) {
  const files = req.files ?? [];

  if (files.length === 0) {
    return res.status(400).json({
      success: false,
      message: "Please upload at least one PDF document.",
    });
  }

  const validDocumentTypes = [
    "ownership",
    "valuation",
    "registration",
    "identification",
    "legal",
    "inspection",
    "other",
  ];

  const documentType = req.body.documentType;

  if (!validDocumentTypes.includes(documentType)) {
    await Promise.allSettled(
      files.map((file) => fs.unlink(file.path))
    );

    return res.status(400).json({
      success: false,
      message: "Please provide a valid document type.",
    });
  }

  try {
    const isValid = await verifyUploadedFiles(files, {
      "application/pdf": [".pdf"],
    });

    if (!isValid) {
      await Promise.allSettled(
        files.map((file) => fs.unlink(file.path))
      );

      return res.status(400).json({
        success: false,
        message: "Only valid PDF documents are allowed.",
      });
    }

    const result = await saveAssetDocuments(
      req.assetId,
      files,
      documentType
    );

    return res.status(201).json({
      success: true,
      message: "Asset documents uploaded successfully.",
      data: result,
    });
  } catch (error) {
    await Promise.allSettled(
      files.map((file) => fs.unlink(file.path))
    );

    console.error("Upload asset documents error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to upload asset documents.",
    });
  }
}

// =====================================================
// DOWNLOAD PRIVATE ASSET DOCUMENT
// GET /api/assets/:id/documents/:documentId/download
// =====================================================

export async function downloadAssetDocument(req, res) {
  try {
    const assetId = Number.parseInt(req.params.id, 10);
    const documentId = Number.parseInt(
      req.params.documentId,
      10
    );

    const userId =
      req.user?.id ??
      req.user?.userId ??
      req.user?.sub;

    const userRole = req.user?.role;

    if (
      !Number.isSafeInteger(assetId) ||
      assetId <= 0 ||
      !Number.isSafeInteger(documentId) ||
      documentId <= 0
    ) {
      return res.status(400).json({
        success: false,
        message: "Invalid asset or document ID.",
      });
    }

    const document = await getAssetDocumentForAccess(
      assetId,
      documentId,
      userId,
      userRole
    );

    if (!document) {
      return res.status(404).json({
        success: false,
        message: "Document not found.",
      });
    }

    const filename = path.basename(document.documentUrl);

    const documentPath = path.resolve(
      process.cwd(),
      "uploads",
      "assets",
      "documents",
      filename
    );

    return res.download(
      documentPath,
      document.documentName,
      (error) => {
        if (error) {
          console.error(
            "Private document download error:",
            error
          );

          if (!res.headersSent) {
            res.status(500).json({
              success: false,
              message: "Unable to download document.",
            });
          }
        }
      }
    );
  } catch (error) {
    console.error(
      "Download asset document error:",
      error
    );

    if (!res.headersSent) {
      return res.status(500).json({
        success: false,
        message: "Failed to download asset document.",
      });
    }
  }
}

