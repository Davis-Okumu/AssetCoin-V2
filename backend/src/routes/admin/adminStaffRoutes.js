
import { Router } from "express";

import {
    authenticateAdmin,
    requireAdminPermission,
} from "../../middleware/adminAuthMiddleware.js";

import {
    getStaffOverview,
    listStaff,
    getStaffDetails,
    listStaffRoles,
    listStaffPermissions,
    createStaff,
    updateStaff,
    updateStaffStatus,
    updateStaffPermissions,
    removeStaffPermissionOverride,
    getStaffActivity,
    getStaffSessions,
    revokeStaffSession,
} from "../../controllers/admin/adminStaffController.js";

const router = Router();

/**
 * ============================================================
 * ADMIN STAFF ROUTES
 * Base path: /api/admin/staff
 * ============================================================
 *
 * Staff management for authorized platform operators.
 *
 * All routes require an authenticated administrator.
 *
 * Permissions:
 * staff.view        - View staff, roles, permissions and activity
 * staff.create      - Create staff accounts
 * staff.update      - Update staff profiles and revoke sessions
 * staff.suspend     - Change staff account status
 * staff.permissions - Manage individual permission overrides
 *
 * ============================================================
 */

router.use(authenticateAdmin);

// ------------------------------------------------------------
// OVERVIEW
// Static routes must be declared before dynamic staff routes.
// ------------------------------------------------------------

router.get(
    "/overview",
    requireAdminPermission("staff.view"),
    getStaffOverview,
);

// ------------------------------------------------------------
// ROLES AND PERMISSIONS
// ------------------------------------------------------------

router.get(
    "/roles",
    requireAdminPermission("staff.view"),
    listStaffRoles,
);

router.get(
    "/permissions",
    requireAdminPermission("staff.view"),
    listStaffPermissions,
);

// ------------------------------------------------------------
// STAFF DIRECTORY
// ------------------------------------------------------------

router.get(
    "/",
    requireAdminPermission("staff.view"),
    listStaff,
);

// Create a staff account.
router.post(
    "/",
    requireAdminPermission("staff.create"),
    createStaff,
);

// ------------------------------------------------------------
// STAFF ACTIVITY AND SESSIONS
// ------------------------------------------------------------

// View a staff member's audit/login activity.
router.get(
    "/:staffId/activity",
    requireAdminPermission("staff.view"),
    getStaffActivity,
);

// View a staff member's active and historical sessions.
router.get(
    "/:staffId/sessions",
    requireAdminPermission("staff.view"),
    getStaffSessions,
);

// Revoke a staff member's session.
router.post(
    "/:staffId/sessions/:sessionId/revoke",
    requireAdminPermission("staff.update"),
    revokeStaffSession,
);

// ------------------------------------------------------------
// STAFF PERMISSIONS
// ------------------------------------------------------------

// Set or replace permission overrides.
router.put(
    "/:staffId/permissions",
    requireAdminPermission("staff.permissions"),
    updateStaffPermissions,
);

// Remove an individual permission override.
router.delete(
    "/:staffId/permissions/:permissionId",
    requireAdminPermission("staff.permissions"),
    removeStaffPermissionOverride,
);

// ------------------------------------------------------------
// STAFF ACCOUNT STATUS
// ------------------------------------------------------------

// Activate, suspend, deactivate or lock a staff account,
// subject to the validation rules in the service.
router.patch(
    "/:staffId/status",
    requireAdminPermission("staff.suspend"),
    updateStaffStatus,
);

// ------------------------------------------------------------
// STAFF DETAILS AND PROFILE
// ------------------------------------------------------------

// View one staff member.
router.get(
    "/:staffId",
    requireAdminPermission("staff.view"),
    getStaffDetails,
);

// Update staff profile details or role.
router.patch(
    "/:staffId",
    requireAdminPermission("staff.update"),
    updateStaff,
);

export default router;
