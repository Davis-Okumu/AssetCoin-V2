
import express from "express";

import {
  getKycVerificationStatus,
  getKycSubmissionHistory,
  submitKyc,
} from "../controllers/kycController.js";

import {
  authenticateToken,
} from "../middleware/authMiddleware.js";

import {
  uploadKycDocuments,
} from "../middleware/uploadMiddleware.js";

const router = express.Router();

// All KYC routes require authentication.
router.use(authenticateToken);

// GET CURRENT KYC STATUS
router.get("/status", getKycVerificationStatus);

// GET PREVIOUS KYC SUBMISSIONS
router.get("/history", getKycSubmissionHistory);

// SUBMIT IDENTITY DOCUMENTS
router.post(
  "/submit",
  uploadKycDocuments,
  submitKyc
);

export default router;