import jwt from "jsonwebtoken";
import crypto from "crypto";

const ADMIN_JWT_EXPIRES_IN =
  process.env.ADMIN_JWT_EXPIRES_IN || "8h";

function getAdminJwtSecret() {
  const secret = process.env.ADMIN_JWT_SECRET;

  if (!secret) {
    throw new Error(
      "ADMIN_JWT_SECRET is not configured."
    );
  }

  return secret;
}

/**
 * Create an administrator JWT.
 */
export function createAdminJwt({
  staffId,
  sessionId,
  role,
}) {
  return jwt.sign(
    {
      type: "admin",
      staffId,
      sessionId,
      role,
    },
    getAdminJwtSecret(),
    {
      expiresIn: ADMIN_JWT_EXPIRES_IN,
      issuer: "assetcoin-admin",
      audience: "assetcoin-admin-dashboard",
      jwtid: crypto.randomUUID(),
    },
  );
}

/**
 * Verify an administrator JWT.
 */
export function verifyAdminJwt(token) {
  return jwt.verify(
    token,
    getAdminJwtSecret(),
    {
      issuer: "assetcoin-admin",
      audience: "assetcoin-admin-dashboard",
    },
  );
}

/**
 * Extract a Bearer token from Authorization header.
 */
export function extractBearerToken(request) {
  const authorization =
    request.headers.authorization;

  if (!authorization) {
    return null;
  }

  const [scheme, token] =
    authorization.split(" ");

  if (
    !scheme ||
    scheme.toLowerCase() !== "bearer" ||
    !token
  ) {
    return null;
  }

  return token;
}