import { Router } from "express";

import {
    authenticateAdmin,
    requireAdminPermission,
} from "../../middleware/adminAuthMiddleware.js";

import {
    getKycApplications,
    getKycStats,
    getKycApplication,
    assignKyc,
    startReview,
    requestInformation,
    approveKycApplication,
    rejectKycApplication,
} from "../../controllers/admin/adminKycController.js";

// =========================================================
// ADMIN KYC ROUTES
// =========================================================
//
// AssetCoin Admin KYC Workflow
//
// Customers:
//   Mobile App
//       ↓
//   Submit KYC
//
// Administrators:
//   Admin Dashboard
//       ↓
//   View submitted KYC
//       ↓
//   Assign
//       ↓
//   Review
//       ↓
//   Request information / Approve / Reject
//
// IMPORTANT:
//
// This router NEVER provides an endpoint for administrators
// to upload customer KYC documents.
//
// =========================================================

const router = Router();


// =========================================================
// AUTHENTICATION
// =========================================================
//
// Every route in this router requires a valid administrator
// session.
//
// authenticateAdmin() verifies:
//
// - Bearer token
// - JWT
// - staffId
// - sessionId
// - database session
// - session expiration
// - session revocation
// - administrator account status
//
// =========================================================

router.use(authenticateAdmin);


// =========================================================
// GET KYC APPLICATIONS
// =========================================================
//
// Permission:
//   kyc.view
//
// Example:
//
// GET /api/admin/kyc
// GET /api/admin/kyc?status=pending
// GET /api/admin/kyc?status=under_review
// GET /api/admin/kyc?search=davis
// GET /api/admin/kyc?page=2&limit=20
//
// =========================================================

router.get(
    "/",
    requireAdminPermission("kyc.view"),
    getKycApplications,
);


// =========================================================
// GET KYC STATISTICS
// =========================================================
//
// Permission:
//   kyc.view
//
// Example:
//
// GET /api/admin/kyc/stats
//
// =========================================================

router.get(
    "/stats",
    requireAdminPermission("kyc.view"),
    getKycStats,
);


// =========================================================
// GET KYC APPLICATION DETAILS
// =========================================================
//
// Permission:
//   kyc.view
//
// Example:
//
// GET /api/admin/kyc/15
//
// =========================================================

router.get(
    "/:id",
    requireAdminPermission("kyc.view"),
    getKycApplication,
);


// =========================================================
// ASSIGN KYC APPLICATION
// =========================================================
//
// Permission:
//   kyc.review
//
// Example:
//
// PATCH /api/admin/kyc/15/assign
//
// Body:
//
// {
//   "assignedTo": 4,
//   "priority": "high",
//   "notes": "Please review national ID carefully."
// }
//
// =========================================================

router.patch(
    "/:id/assign",
    requireAdminPermission("kyc.review"),
    assignKyc,
);


// =========================================================
// START KYC REVIEW
// =========================================================
//
// Permission:
//   kyc.review
//
// Example:
//
// PATCH /api/admin/kyc/15/start-review
//
// =========================================================

router.patch(
    "/:id/start-review",
    requireAdminPermission("kyc.review"),
    startReview,
);


// =========================================================
// REQUEST ADDITIONAL INFORMATION
// =========================================================
//
// Permission:
//   kyc.review
//
// Example:
//
// PATCH /api/admin/kyc/15/request-information
//
// Body:
//
// {
//   "comments": "Please provide a clearer national ID image."
// }
//
// =========================================================

router.patch(
    "/:id/request-information",
    requireAdminPermission("kyc.review"),
    requestInformation,
);


// =========================================================
// APPROVE KYC
// =========================================================
//
// Permission:
//   kyc.approve
//
// Example:
//
// PATCH /api/admin/kyc/15/approve
//
// Body:
//
// {
//   "comments": "Identity documents verified successfully."
// }
//
// =========================================================

router.patch(
    "/:id/approve",
    requireAdminPermission("kyc.approve"),
    approveKycApplication,
);


// =========================================================
// REJECT KYC
// =========================================================
//
// Permission:
//   kyc.reject
//
// Example:
//
// PATCH /api/admin/kyc/15/reject
//
// Body:
//
// {
//   "rejectionReason": "The submitted identity document could not be verified.",
//   "comments": "Please submit a valid government-issued document."
// }
//
// =========================================================

router.patch(
    "/:id/reject",
    requireAdminPermission("kyc.reject"),
    rejectKycApplication,
);


// =========================================================
// EXPORT ROUTER
// =========================================================

export default router;