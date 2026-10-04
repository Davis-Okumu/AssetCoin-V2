
import {
  registerUser,
  loginUser,
} from "../services/authService.js";

import {
  requestPasswordReset,
  resetPassword as resetPasswordService,
  changePassword as changePasswordService,
} from "../services/passwordResetService.js";

import {
  logoutCurrentSession,
} from "../services/securityService.js";

// =========================
// REGISTER
// =========================

export async function register(req, res) {
  try {
    const result = await registerUser(req.body, {
      ipAddress: req.ip,
      userAgent: req.get("user-agent") || null,
    });

    return res.status(201).json({
      success: true,
      message: "Account created successfully.",
      data: result,
    });
  } catch (error) {
    console.error("Registration error:", error.message);

    return res.status(error.statusCode || 500).json({
      success: false,
      message: error.statusCode
        ? error.message
        : "Unable to create your account. Please try again.",
    });
  }
}

// =========================
// LOGIN
// =========================

export async function login(req, res) {
  try {
    const { identifier, password } = req.body;

    const result = await loginUser(
      identifier,
      password,
      {
        ipAddress: req.ip,
        userAgent: req.get("user-agent") || null,
      }
    );

    return res.status(200).json({
      success: true,
      message: "Login successful.",
      data: result,
    });
  } catch (error) {
    console.error("Login error:", error.message);

    return res.status(error.statusCode || 500).json({
      success: false,
      message: error.statusCode
        ? error.message
        : "Unable to log in. Please try again.",
    });
  }
}

// =========================
// GET CURRENT USER
// =========================

export async function getCurrentUser(req, res) {
  return res.status(200).json({
    success: true,
    message: "User profile retrieved successfully.",
    data: {
      user: req.user,
    },
  });
}

// =========================
// FORGOT PASSWORD
// =========================

export async function forgotPassword(req, res) {
  try {
    const { email } = req.body;

    const result = await requestPasswordReset(email);

    const response = {
      success: true,
      message: result.message,
    };

    // Keep the response compatible with Flutter's data.resetToken parser.
    // Never expose reset tokens in production.
    if (
      process.env.NODE_ENV === "development" &&
      result.resetToken
    ) {
      response.data = {
        resetToken: result.resetToken,
      };
    }

    return res.status(200).json(response);
  } catch (error) {
    console.error("Forgot password error:", error.message);

    return res.status(error.statusCode || 500).json({
      success: false,
      message:
        error.message ||
        "Password reset could not be requested.",
    });
  }
}

// =========================
// RESET PASSWORD
// =========================

export async function resetPassword(req, res) {
  try {
    const result = await resetPasswordService({
      token: req.body.token,
      newPassword: req.body.newPassword,
    });

    return res.status(200).json({
      success: true,
      message: result.message,
    });
  } catch (error) {
    console.error(
      "Reset password error:",
      error.message
    );

    return res.status(
      error.statusCode || 500
    ).json({
      success: false,
      message: error.statusCode
        ? error.message
        : "Unable to reset your password. Please try again.",
    });
  }
}


// =========================
// CHANGE PASSWORD
// =========================

export async function changePassword(req, res) {
  try {
    const result = await changePasswordService({
      userId: req.user.id,
      currentPassword: req.body.currentPassword,
      newPassword: req.body.newPassword,
    });

    return res.status(200).json({
      success: true,
      message: result.message,
    });
  } catch (error) {
    console.error(
      "Change password error:",
      error.message
    );

    return res.status(error.statusCode || 500).json({
      success: false,
      message: error.statusCode
        ? error.message
        : "Unable to change your password. Please try again.",
    });
  }
}

// =========================
// LOG OUT
// =========================

export async function logout(req, res) {
  try {
    const result = await logoutCurrentSession(
      req.user.id,
      req.session?.id
    );

    return res.status(200).json({
      success: true,
      message: result.message,
    });
  } catch (error) {
    console.error(
      "Logout error:",
      error.message
    );

    return res.status(error.statusCode || 500).json({
      success: false,
      message: error.statusCode
        ? error.message
        : "Unable to log out. Please try again.",
    });
  }
}