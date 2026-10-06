import { Router } from "express";

import {
    authenticateAdmin,
    requireAdminPermission,
} from "../../middleware/adminAuthMiddleware.js";

import {
    getOverview,
    getEligibleAssets,
    getProposals,
    getProposal,
    createProposal,
    submitProposal,
    reviewProposal,
    approveProposal,
    rejectProposal,
    getOfferings,
    getOffering,
    activateOffering,
    pauseOffering,
    suspendOffering,
    getAssignments,
    assignProposal,
    startAssignment,
    completeAssignment,
    resumeOffering,
    getAssignableOfficers,
    getAssignment,
} from "../../controllers/admin/adminTokenizationController.js";

const router = Router();

// =========================================================
// ADMIN AUTHENTICATION
// =========================================================

router.use(authenticateAdmin);

// =========================================================
// TOKENIZATION OVERVIEW
// =========================================================

router.get(
    "/overview",
    requireAdminPermission("tokenization.view"),
    getOverview,
);

// =========================================================
// ELIGIBLE ASSETS
// =========================================================

router.get(
    "/eligible-assets",
    requireAdminPermission("tokenization.view"),
    getEligibleAssets,
);

// =========================================================
// TOKENIZATION PROPOSALS
// =========================================================

router.get(
    "/proposals",
    requireAdminPermission("tokenization.view"),
    getProposals,
);

router.get(
    "/proposals/:id",
    requireAdminPermission("tokenization.view"),
    getProposal,
);

router.post(
    "/proposals",
    requireAdminPermission("tokenization.create"),
    createProposal,
);

router.post(
    "/proposals/:id/submit",
    requireAdminPermission("tokenization.create"),
    submitProposal,
);

router.post(
    "/proposals/:id/review",
    requireAdminPermission("tokenization.review"),
    reviewProposal,
);

router.post(
    "/proposals/:id/approve",
    requireAdminPermission("tokenization.approve"),
    approveProposal,
);

router.post(
    "/proposals/:id/reject",
    requireAdminPermission("tokenization.reject"),
    rejectProposal,
);

// =========================================================
// TOKEN OFFERINGS
// =========================================================

router.get(
    "/offerings",
    requireAdminPermission("tokenization.view"),
    getOfferings,
);

router.get(
    "/offerings/:id",
    requireAdminPermission("tokenization.view"),
    getOffering,
);

router.patch(
    "/offerings/:id/activate",
    requireAdminPermission("tokenization.activate"),
    activateOffering,
);

router.patch(
    "/offerings/:id/pause",
    requireAdminPermission("tokenization.suspend"),
    pauseOffering,
);

router.patch(
    "/offerings/:id/suspend",
    requireAdminPermission("tokenization.suspend"),
    suspendOffering,
);

// =========================================================
// TOKENIZATION ASSIGNMENTS
// =========================================================

router.get(
    "/assignments",
    requireAdminPermission("tokenization.view"),
    getAssignments,
);

router.post(
    "/proposals/:id/assign",
    requireAdminPermission("tokenization.assign"),
    assignProposal,
);

router.patch(
    "/assignments/:assignmentId/start",
    requireAdminPermission("tokenization.assign"),
    startAssignment,
);

router.patch(
    "/assignments/:assignmentId/complete",
    requireAdminPermission("tokenization.assign"),
    completeAssignment,
);

router.patch(
    "/offerings/:id/resume",
    requireAdminPermission("tokenization.activate"),
    resumeOffering,
);
router.get(
    "/assignment-officers",
    requireAdminPermission("tokenization.assign"),
    getAssignableOfficers,
);
router.get(
    "/assignments/:id",
    requireAdminPermission("tokenization.view"),
    getAssignment,
);

export default router;