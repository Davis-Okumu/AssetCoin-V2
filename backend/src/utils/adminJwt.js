import jwt from "jsonwebtoken";
import crypto from "crypto";

// =========================================================
// ADMIN JWT CONFIGURATION
// =========================================================

const ADMIN_JWT_EXPIRES_IN =
  process.env.ADMIN_JWT_EXPIRES_IN || "8h";

const ADMIN_JWT_ISSUER =
  "assetcoin-admin";

const ADMIN_JWT_AUDIENCE =
  "assetcoin-admin-dashboard";


// =========================================================
// GET ADMIN JWT SECRET
// =========================================================

/**
 * Retrieve and validate the administrator JWT secret.
 *
 * Administrator authentication uses a dedicated secret rather
 * than the normal user JWT secret.
 *
 * This provides separation between:
 *
 * User authentication
 *        ↓
 * JWT_SECRET
 *
 * Administrator authentication
 *        ↓
 * ADMIN_JWT_SECRET
 */
function getAdminJwtSecret() {
  const secret =
    process.env.ADMIN_JWT_SECRET;

  if (
    !secret ||
    typeof secret !== "string"
  ) {
    throw new Error(
      "ADMIN_JWT_SECRET is not configured.",
    );
  }

  if (secret.length < 32) {
    throw new Error(
      "ADMIN_JWT_SECRET must contain at least 32 characters.",
    );
  }

  return secret;
}


// =========================================================
// VALIDATE ADMIN IDENTIFIERS
// =========================================================

function validatePositiveInteger(
  value,
  fieldName,
) {
  const numericValue =
    Number(value);

  if (
    !Number.isInteger(numericValue) ||
    numericValue <= 0
  ) {
    throw new Error(
      `Invalid administrator ${fieldName}.`,
    );
  }

  return numericValue;
}


// =========================================================
// CREATE ADMIN JWT
// =========================================================

/**
 * Create an administrator JWT.
 *
 * Required claims:
 *
 * - type
 * - staffId
 * - sessionId
 * - role
 *
 * The JWT does NOT replace database session validation.
 *
 * The database-backed admin session remains the source
 * of truth for authentication and revocation.
 */
export function createAdminJwt({
  staffId,
  sessionId,
  role,
}) {
  const normalizedStaffId =
    validatePositiveInteger(
      staffId,
      "staff ID",
    );

  const normalizedSessionId =
    validatePositiveInteger(
      sessionId,
      "session ID",
    );

  if (
    !role ||
    typeof role !== "string" ||
    !role.trim()
  ) {
    throw new Error(
      "Administrator role is required.",
    );
  }

  const normalizedRole =
    role.trim();

  return jwt.sign(
    {
      type: "admin",

      staffId:
        normalizedStaffId,

      sessionId:
        normalizedSessionId,

      role:
        normalizedRole,
    },

    getAdminJwtSecret(),

    {
      // ---------------------------------------------------
      // Token lifetime
      // ---------------------------------------------------

      expiresIn:
        ADMIN_JWT_EXPIRES_IN,

      // ---------------------------------------------------
      // Token issuer
      // ---------------------------------------------------

      issuer:
        ADMIN_JWT_ISSUER,

      // ---------------------------------------------------
      // Token audience
      // ---------------------------------------------------
      //
      // Must match verifyAdminJwt().
      //
      // ---------------------------------------------------

      audience:
        ADMIN_JWT_AUDIENCE,

      // ---------------------------------------------------
      // Unique JWT ID
      // ---------------------------------------------------

      jwtid:
        crypto.randomUUID(),
    },
  );
}


// =========================================================
// VERIFY ADMIN JWT
// =========================================================

/**
 * Verify and decode an administrator JWT.
 *
 * This verifies:
 *
 * - signature
 * - expiration
 * - issuer
 * - audience
 *
 * The returned payload is still NOT enough to authenticate
 * the administrator.
 *
 * The authentication middleware must additionally validate
 * the database-backed admin session.
 *
 * Possible JWT errors:
 *
 * - TokenExpiredError
 * - JsonWebTokenError
 * - NotBeforeError
 */
export function verifyAdminJwt(token) {
  if (
    !token ||
    typeof token !== "string"
  ) {
    throw new jwt.JsonWebTokenError(
      "Administrator token is required.",
    );
  }

  const payload =
    jwt.verify(
      token,
      getAdminJwtSecret(),
      {
        issuer:
          ADMIN_JWT_ISSUER,

        audience:
          ADMIN_JWT_AUDIENCE,
      },
    );

  // -------------------------------------------------------
  // Validate payload structure
  // -------------------------------------------------------

  if (
    !payload ||
    typeof payload !== "object"
  ) {
    throw new jwt.JsonWebTokenError(
      "Invalid administrator token payload.",
    );
  }

  // -------------------------------------------------------
  // Validate token type
  // -------------------------------------------------------

  if (
    payload.type !== "admin"
  ) {
    throw new jwt.JsonWebTokenError(
      "Invalid administrator token type.",
    );
  }

  // -------------------------------------------------------
  // Validate staff ID
  // -------------------------------------------------------

  const staffId =
    Number(payload.staffId);

  if (
    !Number.isInteger(staffId) ||
    staffId <= 0
  ) {
    throw new jwt.JsonWebTokenError(
      "Invalid administrator staff ID.",
    );
  }

  // -------------------------------------------------------
  // Validate session ID
  // -------------------------------------------------------

  const sessionId =
    Number(payload.sessionId);

  if (
    !Number.isInteger(sessionId) ||
    sessionId <= 0
  ) {
    throw new jwt.JsonWebTokenError(
      "Invalid administrator session ID.",
    );
  }

  // -------------------------------------------------------
  // Validate role
  // -------------------------------------------------------

  if (
    !payload.role ||
    typeof payload.role !== "string"
  ) {
    throw new jwt.JsonWebTokenError(
      "Invalid administrator role.",
    );
  }

  // -------------------------------------------------------
  // Return normalized payload
  // -------------------------------------------------------

  return {
    ...payload,

    staffId,

    sessionId,

    role:
      payload.role.trim(),
  };
}


// =========================================================
// EXTRACT BEARER TOKEN
// =========================================================

/**
 * Extract the JWT from:
 *
 * Authorization: Bearer <token>
 *
 * Returns:
 *
 * token string
 *     OR
 * null
 */
export function extractBearerToken(
  request,
) {
  const authorization =
    request?.headers?.authorization;

  if (
    !authorization ||
    typeof authorization !== "string"
  ) {
    return null;
  }

  // -------------------------------------------------------
  // Normalize whitespace
  // -------------------------------------------------------

  const parts =
    authorization
      .trim()
      .split(/\s+/);

  // -------------------------------------------------------
  // Require exactly:
  //
  // Bearer
  // token
  // -------------------------------------------------------

  if (
    parts.length !== 2 ||
    parts[0].toLowerCase() !==
    "bearer"
  ) {
    return null;
  }

  const token =
    parts[1]?.trim();

  return token || null;
}