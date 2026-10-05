import {
  extractBearerToken,
  verifyAdminJwt,
} from "../utils/adminJwt.js";

import {
  getCurrentAdmin,
} from "../services/admin/adminAuthService.js";

// =========================================================
// ADMIN AUTHENTICATION MIDDLEWARE
// =========================================================
//
// Responsibilities:
//
// 1. Extract the administrator Bearer token.
// 2. Verify the administrator JWT.
// 3. Validate the JWT identity claims.
// 4. Verify the database-backed administrator session.
// 5. Reject revoked or expired sessions.
// 6. Attach the current administrator to req.admin.
// 7. Attach authentication metadata to req.adminAuth.
//
// Authorization helpers:
//
// - requireAdminPermission()
// - requireAnyAdminPermission()
// - requireAdminRole()
//
// IMPORTANT:
// Database session validation is delegated to
// getCurrentAdmin(). That service should verify:
//
// - staffId
// - sessionId
// - SHA-256 token hash
// - expiration
// - revokedAt
// - administrator account status
//
// =========================================================


// =========================================================
// AUTHENTICATE ADMINISTRATOR
// =========================================================

/**
 * Authenticate an administrator.
 *
 * Authentication consists of TWO independent checks:
 *
 * 1. JWT verification
 * 2. Database session verification
 *
 * Therefore, possessing a valid JWT is NOT sufficient.
 *
 * If an administrator session has been revoked, the request
 * is rejected even when the JWT itself is cryptographically
 * valid.
 */
export async function authenticateAdmin(
  request,
  response,
  next,
) {
  try {
    // -------------------------------------------------------
    // Extract Bearer token
    // -------------------------------------------------------

    const token = extractBearerToken(request);

    if (!token) {
      return response.status(401).json({
        success: false,
        message:
          "Administrator authentication token is required.",
      });
    }

    // -------------------------------------------------------
    // Verify JWT
    // -------------------------------------------------------

    const payload = verifyAdminJwt(token);

    // -------------------------------------------------------
    // Validate required admin JWT claims
    // -------------------------------------------------------

    if (
      !payload ||
      payload.type !== "admin" ||
      !payload.staffId ||
      !payload.sessionId
    ) {
      return response.status(401).json({
        success: false,
        message:
          "Invalid administrator authentication token.",
      });
    }

    // -------------------------------------------------------
    // Validate identifiers
    // -------------------------------------------------------

    const staffId = Number(payload.staffId);
    const sessionId = Number(payload.sessionId);

    if (
      !Number.isInteger(staffId) ||
      staffId <= 0 ||
      !Number.isInteger(sessionId) ||
      sessionId <= 0
    ) {
      return response.status(401).json({
        success: false,
        message:
          "Invalid administrator session.",
      });
    }

    // -------------------------------------------------------
    // Verify administrator against database
    // -------------------------------------------------------
    //
    // getCurrentAdmin() should:
    //
    // - locate the administrator
    // - locate the admin session
    // - hash the presented token
    // - compare sessionTokenHash
    // - check expiresAt
    // - check revokedAt
    // - check accountStatus
    // - load role
    // - load permissions
    //
    // -------------------------------------------------------

    const admin = await getCurrentAdmin({
      staffId,
      sessionId,
      token,
    });

    if (!admin) {
      return response.status(401).json({
        success: false,
        message:
          "Administrator session is invalid or expired.",
      });
    }

    // -------------------------------------------------------
    // Attach administrator to request
    // -------------------------------------------------------

    request.admin = admin;

    // -------------------------------------------------------
    // Attach authentication metadata
    // -------------------------------------------------------

    request.adminAuth = {
      staffId,
      sessionId,

      // JWT role information is informational only.
      // Authorization should use the role/permissions loaded
      // from the database.
      role: payload.role ?? null,

      token,
    };

    // -------------------------------------------------------
    // Convenience administrator ID
    // -------------------------------------------------------

    request.adminId = staffId;

    return next();
  } catch (error) {
    // -------------------------------------------------------
    // JWT expired
    // -------------------------------------------------------

    if (
      error?.name ===
      "TokenExpiredError"
    ) {
      return response.status(401).json({
        success: false,
        message:
          "Administrator session has expired.",
      });
    }

    // -------------------------------------------------------
    // Invalid JWT
    // -------------------------------------------------------

    if (
      error?.name ===
      "JsonWebTokenError"
    ) {
      return response.status(401).json({
        success: false,
        message:
          "Invalid administrator authentication token.",
      });
    }

    // -------------------------------------------------------
    // Token not active yet
    // -------------------------------------------------------

    if (
      error?.name ===
      "NotBeforeError"
    ) {
      return response.status(401).json({
        success: false,
        message:
          "Administrator authentication token is not active yet.",
      });
    }

    // -------------------------------------------------------
    // Unexpected error
    // -------------------------------------------------------

    console.error(
      "Admin authentication error:",
      error,
    );

    return next(error);
  }
}


// =========================================================
// REQUIRE ONE ADMIN PERMISSION
// =========================================================

/**
 * Require a specific administrator permission.
 *
 * Example:
 *
 * router.get(
 *   "/",
 *   requireAdminPermission("users.view"),
 *   controller,
 * );
 */
export function requireAdminPermission(
  permissionCode,
) {
  return (request, response, next) => {
    // -------------------------------------------------------
    // Authentication check
    // -------------------------------------------------------

    if (!request.admin) {
      return response.status(401).json({
        success: false,
        message:
          "Administrator authentication is required.",
      });
    }

    // -------------------------------------------------------
    // Validate permission code
    // -------------------------------------------------------

    if (
      typeof permissionCode !== "string" ||
      !permissionCode.trim()
    ) {
      return response.status(500).json({
        success: false,
        message:
          "Administrator permission configuration is invalid.",
      });
    }

    // -------------------------------------------------------
    // Get administrator permissions
    // -------------------------------------------------------

    const permissions =
      Array.isArray(request.admin.permissions)
        ? request.admin.permissions
        : [];

    // -------------------------------------------------------
    // Super administrator
    // -------------------------------------------------------
    //
    // Super administrators inherit all permissions.
    //
    // Support both roleCode and role in case the service
    // exposes either representation.
    //
    // -------------------------------------------------------

    const roleCode =
      request.admin.roleCode ??
      request.admin.role_code ??
      null;

    const role =
      request.admin.role ??
      null;

    if (
      roleCode === "super_admin" ||
      role === "super_admin"
    ) {
      return next();
    }

    // -------------------------------------------------------
    // Permission check
    // -------------------------------------------------------

    if (
      permissions.includes(permissionCode)
    ) {
      return next();
    }

    // -------------------------------------------------------
    // Permission denied
    // -------------------------------------------------------

    return response.status(403).json({
      success: false,
      message:
        "You do not have permission to perform this action.",
      code: "INSUFFICIENT_PERMISSION",
      requiredPermission: permissionCode,
    });
  };
}


// =========================================================
// REQUIRE ANY ADMIN PERMISSION
// =========================================================

/**
 * Require at least one permission from the supplied list.
 *
 * Example:
 *
 * requireAnyAdminPermission([
 *   "users.update",
 *   "users.suspend",
 * ])
 */
export function requireAnyAdminPermission(
  permissions,
) {
  return (request, response, next) => {
    // -------------------------------------------------------
    // Authentication check
    // -------------------------------------------------------

    if (!request.admin) {
      return response.status(401).json({
        success: false,
        message:
          "Administrator authentication is required.",
      });
    }

    // -------------------------------------------------------
    // Validate permission list
    // -------------------------------------------------------

    if (
      !Array.isArray(permissions) ||
      permissions.length === 0
    ) {
      return response.status(500).json({
        success: false,
        message:
          "Administrator permission configuration is invalid.",
      });
    }

    // -------------------------------------------------------
    // Super administrator
    // -------------------------------------------------------

    const roleCode =
      request.admin.roleCode ??
      request.admin.role_code ??
      null;

    const role =
      request.admin.role ??
      null;

    if (
      roleCode === "super_admin" ||
      role === "super_admin"
    ) {
      return next();
    }

    // -------------------------------------------------------
    // Get administrator permissions
    // -------------------------------------------------------

    const adminPermissions =
      Array.isArray(request.admin.permissions)
        ? request.admin.permissions
        : [];

    // -------------------------------------------------------
    // Check whether ANY permission matches
    // -------------------------------------------------------

    const hasPermission =
      permissions.some(
        (permission) =>
          adminPermissions.includes(permission),
      );

    if (hasPermission) {
      return next();
    }

    // -------------------------------------------------------
    // Permission denied
    // -------------------------------------------------------

    return response.status(403).json({
      success: false,
      message:
        "You do not have permission to perform this action.",
      code: "INSUFFICIENT_PERMISSION",
    });
  };
}


// =========================================================
// REQUIRE ADMIN ROLE
// =========================================================

/**
 * Require one of the specified administrator roles.
 *
 * Example:
 *
 * requireAdminRole(
 *   "super_admin",
 *   "admin_manager",
 * )
 */
export function requireAdminRole(
  ...roles
) {
  return (request, response, next) => {
    // -------------------------------------------------------
    // Authentication check
    // -------------------------------------------------------

    if (!request.admin) {
      return response.status(401).json({
        success: false,
        message:
          "Administrator authentication is required.",
      });
    }

    // -------------------------------------------------------
    // Validate roles
    // -------------------------------------------------------

    if (roles.length === 0) {
      return response.status(500).json({
        success: false,
        message:
          "Administrator role configuration is invalid.",
      });
    }

    // -------------------------------------------------------
    // Read current role
    // -------------------------------------------------------

    const currentRole =
      request.admin.roleCode ??
      request.admin.role_code ??
      request.admin.role ??
      null;

    // -------------------------------------------------------
    // Role check
    // -------------------------------------------------------

    if (roles.includes(currentRole)) {
      return next();
    }

    // -------------------------------------------------------
    // Role denied
    // -------------------------------------------------------

    return response.status(403).json({
      success: false,
      message:
        "Your administrator role cannot perform this action.",
      code: "INSUFFICIENT_ROLE",
      requiredRoles: roles,
    });
  };
}