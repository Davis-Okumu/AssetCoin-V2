import crypto from "crypto";
import bcrypt from "bcryptjs";

const BCRYPT_ROUNDS = 12;

/**
 * Hash a password using bcrypt.
 */
export async function hashAdminPassword(password) {
  if (!password || typeof password !== "string") {
    throw new Error("Password is required.");
  }

  return bcrypt.hash(password, BCRYPT_ROUNDS);
}

/**
 * Compare a plain password against a bcrypt hash.
 */
export async function verifyAdminPassword(password, passwordHash) {
  if (!password || !passwordHash) {
    return false;
  }

  return bcrypt.compare(password, passwordHash);
}

/**
 * Create a cryptographically secure random token.
 */
export function generateSecureToken(bytes = 48) {
  return crypto.randomBytes(bytes).toString("hex");
}

/**
 * SHA-256 hash.
 *
 * Used for storing session tokens and reset tokens
 * without storing the raw token in the database.
 */
export function hashToken(token) {
  return crypto
    .createHash("sha256")
    .update(token)
    .digest("hex");
}

/**
 * Create a random action/session reference.
 */
export function generateReference(prefix) {
  const randomPart = crypto
    .randomBytes(12)
    .toString("hex")
    .toUpperCase();

  return `${prefix}-${Date.now()}-${randomPart}`;
}

/**
 * Constant-time string comparison.
 */
export function safeCompare(valueA, valueB) {
  if (
    typeof valueA !== "string" ||
    typeof valueB !== "string"
  ) {
    return false;
  }

  const bufferA = Buffer.from(valueA);
  const bufferB = Buffer.from(valueB);

  if (bufferA.length !== bufferB.length) {
    return false;
  }

  return crypto.timingSafeEqual(bufferA, bufferB);
}