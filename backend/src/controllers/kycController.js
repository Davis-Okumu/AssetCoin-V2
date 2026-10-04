
import fs from "fs/promises";

import {
  submitKycApplication,
  getKycStatus,
  getKycHistory,
} from "../services/kycService.js";

import {
  verifyUploadedFiles,
  allowedKycDocuments,
  allowedKycSelfies,
} from "../middleware/uploadMiddleware.js";

// =====================================================
// CLEAN UP UPLOADED FILES
// =====================================================

async function cleanupFiles(files = []) {
  for (const file of files) {
    if (!file?.path) continue;

    try {
      await fs.unlink(file.path);
    } catch (error) {
      if (error.code !== "ENOENT") {
        console.error(
          "KYC file cleanup error:",
          error.message
        );
      }
    }
  }
}

// =====================================================
// GET KYC STATUS
// =====================================================

export async function getKycVerificationStatus(req, res) {
  try {
    const status = await getKycStatus(req.user.id);

    return res.status(200).json({
      success: true,
      message: "KYC status retrieved successfully.",
      data: {
        verification: status,
      },
    });
  } catch (error) {
    console.error("KYC status error:", error.message);

    return res.status(error.statusCode || 500).json({
      success: false,
      message: error.statusCode
        ? error.message
        : "Unable to retrieve your KYC status.",
    });
  }
}

// =====================================================
// GET KYC SUBMISSION HISTORY
// =====================================================

export async function getKycSubmissionHistory(req, res) {
  try {
    const history = await getKycHistory(req.user.id);

    return res.status(200).json({
      success: true,
      message: "KYC history retrieved successfully.",
      data: {
        history,
      },
    });
  } catch (error) {
    console.error("KYC history error:", error.message);

    return res.status(error.statusCode || 500).json({
      success: false,
      message: error.statusCode
        ? error.message
        : "Unable to retrieve your KYC history.",
    });
  }
}

// =====================================================
// SUBMIT KYC APPLICATION
// =====================================================

export async function submitKyc(req, res) {
  const idDocument = req.files?.idDocument?.[0];
  const selfie = req.files?.selfie?.[0];

  const uploadedFiles = [
    idDocument,
    selfie,
  ].filter(Boolean);

  if (!idDocument || !selfie) {
    await cleanupFiles(uploadedFiles);

    return res.status(400).json({
      success: false,
      message: "Upload both your identity document and selfie.",
    });
  }

  try {
    // Verify actual document contents, not just file extensions.
    const validDocument = await verifyUploadedFiles(
      [idDocument],
      allowedKycDocuments
    );

    const validSelfie = await verifyUploadedFiles(
      [selfie],
      allowedKycSelfies
    );

    if (!validDocument || !validSelfie) {
      await cleanupFiles(uploadedFiles);

      return res.status(400).json({
        success: false,
        message: "One or more uploaded files are invalid.",
      });
    }

    // Store private relative paths.
    // These directories are not publicly served by Express.
    const idDocumentUrl =
      `/uploads/kyc/documents/${idDocument.filename}`;

    const selfieUrl =
      `/uploads/kyc/selfies/${selfie.filename}`;

    const submission = await submitKycApplication(
      req.user.id,
      idDocumentUrl,
      selfieUrl
    );

    return res.status(201).json({
      success: true,
      message: "Your KYC application has been submitted successfully.",
      data: {
        submission,
      },
    });
  } catch (error) {
    await cleanupFiles(uploadedFiles);

    console.error("KYC submission error:", error.message);

    return res.status(error.statusCode || 500).json({
      success: false,
      message: error.statusCode
        ? error.message
        : "Unable to submit your KYC application.",
    });
  }
}