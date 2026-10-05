import {
  extractBearerToken,
  verifyAdminJwt,
} from "../utils/adminJwt.js";

import {
  getCurrentAdmin,
} from "../services/admin/adminAuthService.js";

/**
 * Authenticate an administrator.
 *
 * This performs both:
 *
 * 1. JWT verification
 * 2. Database session verification
 *
 * Therefore a revoked session cannot continue
 * using an otherwise valid JWT.
 */
export async function authenticateAdmin(
  request,
  response,
  next,
) {
  try {
    const token =
      extractBearerToken(request);

    if (!token) {
      return response.status(401).json({
        success: false,
        message:
          "Administrator authentication token is required.",
      });
    }

    const payload =
      verifyAdminJwt(token);

    if (
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

    const admin =
      await getCurrentAdmin({
        staffId: payload.staffId,
        sessionId: payload.sessionId,
        token,
      });

    if (!admin) {
      return response.status(401).json({
        success: false,
        message:
          "Administrator session is invalid or expired.",
      });
    }

    request.admin = admin;

    request.adminAuth = {
      staffId: payload.staffId,
      sessionId: payload.sessionId,
      role: payload.role,
      token,
    };

    return next();
  } catch (error) {
    if (
      error.name ===
      "TokenExpiredError"
    ) {
      return response.status(401).json({
        success: false,
        message:
          "Administrator session has expired.",
      });
    }

    if (
      error.name ===
      "JsonWebTokenError"
    ) {
      return response.status(401).json({
        success: false,
        message:
          "Invalid administrator authentication token.",
      });
    }

    return next(error);
  }
}

/**
 * Require a specific administrator permission.
 */
export function requireAdminPermission(
  permissionCode,
) {
  return (request, response, next) => {
    if (!request.admin) {
      return response.status(401).json({
        success: false,
        message:
          "Administrator authentication is required.",
      });
    }

    const hasPermission =
      request.admin.permissions.includes(
        permissionCode,
      );

    if (!hasPermission) {
      return response.status(403).json({
        success: false,
        message:
          "You do not have permission to perform this action.",
        requiredPermission:
          permissionCode,
      });
    }

    return next();
  };
}

/**
 * Require one of several permissions.
 */
export function requireAnyAdminPermission(
  permissions,
) {
  return (request, response, next) => {
    if (!request.admin) {
      return response.status(401).json({
        success: false,
        message:
          "Administrator authentication is required.",
      });
    }

    const hasPermission =
      permissions.some(
        (permission) =>
          request.admin.permissions.includes(
            permission,
          ),
      );

    if (!hasPermission) {
      return response.status(403).json({
        success: false,
        message:
          "You do not have permission to perform this action.",
      });
    }

    return next();
  };
}

/**
 * Require a specific administrator role.
 */
export function requireAdminRole(
  ...roles
) {
  return (request, response, next) => {
    if (!request.admin) {
      return response.status(401).json({
        success: false,
        message:
          "Administrator authentication is required.",
      });
    }

    if (!roles.includes(request.admin.role)) {
      return response.status(403).json({
        success: false,
        message:
          "Your administrator role cannot perform this action.",
      });
    }

    return next();
  };
}