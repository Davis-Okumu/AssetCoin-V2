
import {
  getSecuritySettings,
  getActiveSessions,
  revokeSession,
  revokeOtherSessions,
  getLoginActivity,
  updateSecuritySettings,
} from "../services/securityService.js";

// =========================================================
// SECURITY CONTROLLER
// =========================================================

// =========================
// GET SECURITY OVERVIEW
// =========================

export async function getSecurityOverview(req, res) {
  try {
    const settings = await getSecuritySettings(
      req.user.id
    );

    return res.status(200).json({
      success: true,
      message: "Security settings retrieved successfully.",
      data: {
        settings,
      },
    });
  } catch (error) {
    console.error(
      "Get security overview error:",
      error.message
    );

    return res.status(error.statusCode || 500).json({
      success: false,
      message: error.statusCode
        ? error.message
        : "Unable to retrieve your security settings.",
    });
  }
}

// =========================
// GET ACTIVE SESSIONS
// =========================

export async function getSessions(req, res) {
  try {
    const sessions = await getActiveSessions(
      req.user.id,
      req.session?.id
    );

    return res.status(200).json({
      success: true,
      message: "Active sessions retrieved successfully.",
      data: {
        sessions,
        total: sessions.length,
      },
    });
  } catch (error) {
    console.error(
      "Get active sessions error:",
      error.message
    );

    return res.status(error.statusCode || 500).json({
      success: false,
      message: error.statusCode
        ? error.message
        : "Unable to retrieve active sessions.",
    });
  }
}

// =========================
// REVOKE INDIVIDUAL SESSION
// =========================

export async function revokeDeviceSession(req, res) {
  try {
    const sessionId = Number(req.params.sessionId);

    if (
      !Number.isSafeInteger(sessionId) ||
      sessionId <= 0
    ) {
      return res.status(400).json({
        success: false,
        message: "A valid session ID is required.",
      });
    }

    const result = await revokeSession(
      req.user.id,
      sessionId,
      req.session?.id
    );

    return res.status(200).json({
      success: true,
      message: "Device session revoked successfully.",
      data: result,
    });
  } catch (error) {
    console.error(
      "Revoke session error:",
      error.message
    );

    return res.status(error.statusCode || 500).json({
      success: false,
      message: error.statusCode
        ? error.message
        : "Unable to revoke this device session.",
    });
  }
}

// =========================
// REVOKE OTHER SESSIONS
// =========================

export async function revokeOtherDeviceSessions(req, res) {
  try {
    const result = await revokeOtherSessions(
      req.user.id,
      req.session?.id
    );

    return res.status(200).json({
      success: true,
      message: result.message,
      data: result,
    });
  } catch (error) {
    console.error(
      "Revoke other sessions error:",
      error.message
    );

    return res.status(error.statusCode || 500).json({
      success: false,
      message: error.statusCode
        ? error.message
        : "Unable to log out other devices.",
    });
  }
}

// =========================
// GET LOGIN ACTIVITY
// =========================

export async function getActivity(req, res) {
  try {
    const limit = req.query.limit ?? 30;
    const offset = req.query.offset ?? 0;

    const parsedLimit = Number(limit);
    const parsedOffset = Number(offset);

    if (
      !Number.isInteger(parsedLimit) ||
      parsedLimit < 1 ||
      parsedLimit > 100 ||
      !Number.isInteger(parsedOffset) ||
      parsedOffset < 0
    ) {
      return res.status(400).json({
        success: false,
        message: "Invalid activity pagination parameters.",
      });
    }

    const activities = await getLoginActivity(
      req.user.id,
      parsedLimit,
      parsedOffset
    );

    return res.status(200).json({
      success: true,
      message: "Login activity retrieved successfully.",
      data: {
        activities,
        pagination: {
          limit: parsedLimit,
          offset: parsedOffset,
          count: activities.length,
        },
      },
    });
  } catch (error) {
    console.error(
      "Get login activity error:",
      error.message
    );

    return res.status(error.statusCode || 500).json({
      success: false,
      message: error.statusCode
        ? error.message
        : "Unable to retrieve login activity.",
    });
  }
}

// =========================
// UPDATE SECURITY SETTINGS
// =========================

export async function updateSettings(req, res) {
  try {
    const {
      biometricEnabled,
      loginNotificationEnabled,
    } = req.body;

    const result = await updateSecuritySettings(
      req.user.id,
      {
        biometricEnabled,
        loginNotificationEnabled,
      }
    );

    return res.status(200).json({
      success: true,
      message: "Security settings updated successfully.",
      data: {
        settings: result,
      },
    });
  } catch (error) {
    console.error(
      "Update security settings error:",
      error.message
    );

    return res.status(error.statusCode || 500).json({
      success: false,
      message: error.statusCode
        ? error.message
        : "Unable to update your security settings.",
    });
  }
}