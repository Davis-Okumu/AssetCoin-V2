import {
  loginAdmin,
  getCurrentAdmin,
  logoutAdmin,
} from "../../services/admin/adminAuthService.js";

import {
  getRequestMetadata,
} from "../../utils/adminRequest.js";

/**
 * POST /api/admin/auth/login
 */
export async function adminLogin(
  request,
  response,
  next,
) {
  try {
    const {
      identifier,
      password,
    } = request.body;

    if (
      !identifier ||
      typeof identifier !== "string"
    ) {
      return response.status(400).json({
        success: false,
        message:
          "Email or phone number is required.",
      });
    }

    if (
      !password ||
      typeof password !== "string"
    ) {
      return response.status(400).json({
        success: false,
        message:
          "Password is required.",
      });
    }

    const metadata =
      getRequestMetadata(request);

    const result =
      await loginAdmin({
        identifier,
        password,
        ...metadata,
      });

    if (!result.success) {
      return response.status(401).json({
        success: false,
        code: result.code,
        message: result.message,
      });
    }

    return response.status(200).json({
      success: true,
      message:
        "Administrator login successful.",
      token: result.token,
      expiresAt: result.expiresAt,
      admin: result.admin,
    });
  } catch (error) {
    return next(error);
  }
}

/**
 * GET /api/admin/auth/me
 */
export async function adminMe(
  request,
  response,
  next,
) {
  try {
    const admin =
      await getCurrentAdmin({
        staffId:
          request.adminAuth.staffId,
        sessionId:
          request.adminAuth.sessionId,
        token:
          request.adminAuth.token,
      });

    if (!admin) {
      return response.status(401).json({
        success: false,
        message:
          "Administrator session is invalid or expired.",
      });
    }

    return response.status(200).json({
      success: true,
      admin,
    });
  } catch (error) {
    return next(error);
  }
}

/**
 * POST /api/admin/auth/logout
 */
export async function adminLogout(
  request,
  response,
  next,
) {
  try {
    await logoutAdmin({
      staffId:
        request.adminAuth.staffId,
      sessionId:
        request.adminAuth.sessionId,
    });

    return response.status(200).json({
      success: true,
      message:
        "Administrator logout successful.",
    });
  } catch (error) {
    return next(error);
  }
}