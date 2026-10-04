
import jwt from "jsonwebtoken";
import crypto from "crypto";

import pool from "../config/database.js";

// =========================
// AUTHENTICATE TOKEN
// =========================


export async function authenticateToken(req, res, next) {
  try {
    // =========================
    // CHECK JWT CONFIGURATION
    // =========================

    if (!process.env.JWT_SECRET) {
      console.error("JWT_SECRET is not configured.");

      return res.status(500).json({
        success: false,
        message: "Authentication service is not configured.",
      });
    }

    // =========================
    // READ AUTHORIZATION HEADER
    // =========================

    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return res.status(401).json({
        success: false,
        message: "Authentication token is required.",
      });
    }

    const token = authHeader.slice(7).trim();

    if (!token) {
      return res.status(401).json({
        success: false,
        message: "Authentication token is required.",
      });
    }

    // =========================
    // VERIFY JWT
    // =========================

    const decoded = jwt.verify(
      token,
      process.env.JWT_SECRET
    );

    if (
      !decoded ||
      !decoded.sid ||
      !decoded.sub
    ) {
      return res.status(401).json({
        success: false,
        message: "Invalid authentication session. Please log in again.",
      });
    }

    // =========================
    // HASH PRESENTED TOKEN
    // =========================

    const sessionTokenHash = crypto
      .createHash("sha256")
      .update(token)
      .digest("hex");

    // =========================
    // VERIFY DATABASE SESSION
    // =========================

    const [sessions] = await pool.execute(
      `SELECT
        id,
        userId,
        expiresAt,
        revokedAt
      FROM user_sessions
      WHERE id = ?
        AND userId = ?
        AND sessionTokenHash = ?
        AND expiresAt > CURRENT_TIMESTAMP
        AND revokedAt IS NULL
      LIMIT 1`,
      [
        decoded.sid,
        decoded.sub,
        sessionTokenHash,
      ]
    );

    if (sessions.length === 0) {
      return res.status(401).json({
        success: false,
        message: "Your session is invalid or has expired. Please log in again.",
      });
    }

    const session = sessions[0];

    // =========================
    // RETRIEVE CURRENT USER
    // =========================

    const [users] = await pool.execute(
      `SELECT
        id,
        firstName,
        lastName,
        phone,
        email,
        kycStatus,
        role,
        accountStatus
      FROM users
      WHERE id = ?
      LIMIT 1`,
      [decoded.sub]
    );

    if (users.length === 0) {
      return res.status(401).json({
        success: false,
        message: "User account not found.",
      });
    }

    const user = users[0];

    // =========================
    // CHECK ACCOUNT STATUS
    // =========================

    if (user.accountStatus !== "active") {
      return res.status(403).json({
        success: false,
        message: "Your account is not currently active.",
      });
    }

    // =========================
    // UPDATE SESSION ACTIVITY
    // =========================

    await pool.execute(
      `UPDATE user_sessions
       SET lastActiveAt = CURRENT_TIMESTAMP
       WHERE id = ?
         AND userId = ?
         AND revokedAt IS NULL`,
      [
        session.id,
        decoded.sub,
      ]
    );

    // =========================
    // MAKE USER AVAILABLE
    // =========================

    req.user = user;
    req.session = session;

    return next();

  } catch (error) {

    // =========================
    // JWT ERRORS
    // =========================

    if (
      error.name === "JsonWebTokenError" ||
      error.name === "TokenExpiredError" ||
      error.name === "NotBeforeError"
    ) {
      return res.status(401).json({
        success: false,
        message: "Invalid or expired authentication token.",
      });
    }

    // =========================
    // OTHER ERRORS
    // =========================

    console.error(
      "Authentication error:",
      error.message
    );

    return res.status(500).json({
      success: false,
      message: "Authentication could not be completed.",
    });
  }
}