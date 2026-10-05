import bcrypt from "bcryptjs";
import crypto from "crypto";

// =========================================================
// SECURITY CONFIGURATION
// =========================================================

const DEFAULT_BCRYPT_ROUNDS = 12;

const MIN_PASSWORD_LENGTH = 8;
const MAX_PASSWORD_LENGTH = 128;

const MIN_SECURE_TOKEN_BYTES = 16;
const MAX_SECURE_TOKEN_BYTES = 128;

const DEFAULT_SECURE_TOKEN_BYTES = 48;


// =========================================================
// BCRYPT CONFIGURATION
// =========================================================
//
// ADMIN_BCRYPT_ROUNDS can be configured through .env.
//
// Example:
//
// ADMIN_BCRYPT_ROUNDS=12
//
// bcrypt rounds should generally be kept high enough
// to make password cracking expensive while still
// providing acceptable login performance.
//
// =========================================================

const configuredBcryptRounds = Number(
  process.env.ADMIN_BCRYPT_ROUNDS ??
  DEFAULT_BCRYPT_ROUNDS,
);

const BCRYPT_ROUNDS =
  Number.isInteger(configuredBcryptRounds) &&
    configuredBcryptRounds >= 10 &&
    configuredBcryptRounds <= 16
    ? configuredBcryptRounds
    : DEFAULT_BCRYPT_ROUNDS;


// =========================================================
// HASH ADMIN PASSWORD
// =========================================================
//
// Hash an administrator password using bcrypt.
//
// This function should be used whenever:
//
// - creating an administrator
// - changing an administrator password
// - resetting an administrator password
//
// Raw administrator passwords must NEVER be stored
// in the database.
//
// =========================================================

export async function hashAdminPassword(
  password,
) {
  validatePassword(password);

  return bcrypt.hash(
    password,
    BCRYPT_ROUNDS,
  );
}


// =========================================================
// VERIFY ADMIN PASSWORD
// =========================================================
//
// Compare a plain-text administrator password
// against the stored bcrypt password hash.
//
// Invalid input returns false instead of throwing,
// making this function safe to use during login.
//
// =========================================================

export async function verifyAdminPassword(
  password,
  passwordHash,
) {
  if (
    typeof password !== "string" ||
    typeof passwordHash !== "string"
  ) {
    return false;
  }

  if (
    !password ||
    !passwordHash
  ) {
    return false;
  }

  return bcrypt.compare(
    password,
    passwordHash,
  );
}


// =========================================================
// HASH TOKEN
// =========================================================
//
// Create a SHA-256 hash of a sensitive token.
//
// Raw JWTs, reset tokens, verification tokens,
// and other sensitive tokens should NEVER be stored
// directly in the database.
//
// Example:
//
// sessionTokenHash = SHA256(JWT)
//
// =========================================================

export function hashToken(
  token,
) {
  if (
    !token ||
    typeof token !== "string"
  ) {
    throw new Error(
      "Token is required.",
    );
  }

  return crypto
    .createHash("sha256")
    .update(token, "utf8")
    .digest("hex");
}


// =========================================================
// HASH SECURITY TOKEN
// =========================================================
//
// Dedicated alias for temporary security tokens.
//
// Useful for:
//
// - password reset tokens
// - email verification tokens
// - account recovery tokens
// - administrator action tokens
//
// =========================================================

export function hashSecurityToken(
  token,
) {
  return hashToken(token);
}


// =========================================================
// GENERATE SECURE RANDOM TOKEN
// =========================================================
//
// Generate a cryptographically secure random
// hexadecimal token.
//
// Useful for:
//
// - password reset tokens
// - email verification tokens
// - account recovery tokens
// - temporary security tokens
// - session-related secrets
//
// byteLength refers to the number of random bytes,
// not the resulting hexadecimal string length.
//
// For example:
//
// 32 bytes = 64 hexadecimal characters
// 48 bytes = 96 hexadecimal characters
//
// =========================================================

export function generateSecureToken(
  byteLength = DEFAULT_SECURE_TOKEN_BYTES,
) {
  if (
    !Number.isInteger(byteLength) ||
    byteLength < MIN_SECURE_TOKEN_BYTES ||
    byteLength > MAX_SECURE_TOKEN_BYTES
  ) {
    throw new Error(
      `Secure token length must be between ${MIN_SECURE_TOKEN_BYTES} and ${MAX_SECURE_TOKEN_BYTES} bytes.`,
    );
  }

  return crypto
    .randomBytes(byteLength)
    .toString("hex");
}


// =========================================================
// GENERATE SECURE REFERENCE
// =========================================================
//
// Generate a human-readable reference identifier.
//
// Example:
//
// ADMIN-ACTION-1760000000000-A1B2C3D4...
//
// Useful for:
//
// - audit references
// - administrator actions
// - support references
// - security events
// - transaction/action identifiers
//
// IMPORTANT:
// This is a reference identifier, NOT a secret.
// Do not use it as an authentication credential.
//
// =========================================================

export function generateReference(
  prefix,
) {
  if (
    typeof prefix !== "string" ||
    !prefix.trim()
  ) {
    throw new Error(
      "Reference prefix is required.",
    );
  }

  const normalizedPrefix =
    prefix
      .trim()
      .replace(
        /[^a-zA-Z0-9_-]/g,
        "-",
      )
      .replace(
        /-+/g,
        "-",
      )
      .replace(
        /^-+|-+$/g,
        "",
      )
      .toUpperCase();

  if (!normalizedPrefix) {
    throw new Error(
      "Reference prefix is invalid.",
    );
  }

  const randomPart =
    crypto
      .randomBytes(12)
      .toString("hex")
      .toUpperCase();

  return `${normalizedPrefix}-${Date.now()}-${randomPart}`;
}


// =========================================================
// CONSTANT-TIME STRING COMPARISON
// =========================================================
//
// Compare two strings using crypto.timingSafeEqual.
//
// This helps avoid timing-based comparison attacks
// when comparing sensitive values such as:
//
// - security hashes
// - token digests
// - verification values
//
// The function first checks that both values have
// identical byte lengths because timingSafeEqual()
// requires equal-length buffers.
//
// =========================================================

export function safeCompare(
  valueA,
  valueB,
) {
  if (
    typeof valueA !== "string" ||
    typeof valueB !== "string"
  ) {
    return false;
  }

  const bufferA =
    Buffer.from(
      valueA,
      "utf8",
    );

  const bufferB =
    Buffer.from(
      valueB,
      "utf8",
    );

  if (
    bufferA.length !==
    bufferB.length
  ) {
    return false;
  }

  return crypto.timingSafeEqual(
    bufferA,
    bufferB,
  );
}


// =========================================================
// PASSWORD VALIDATION
// =========================================================
//
// Centralized administrator password validation.
//
// Minimum:
// 8 characters
//
// Maximum:
// 128 characters
//
// Password complexity requirements should normally
// be enforced by the authentication policy rather
// than arbitrarily requiring specific character
// combinations.
//
// =========================================================

function validatePassword(
  password,
) {
  if (
    typeof password !== "string"
  ) {
    throw new Error(
      "Administrator password must be a string.",
    );
  }

  if (
    password.length <
    MIN_PASSWORD_LENGTH
  ) {
    throw new Error(
      `Administrator password must contain at least ${MIN_PASSWORD_LENGTH} characters.`,
    );
  }

  if (
    password.length >
    MAX_PASSWORD_LENGTH
  ) {
    throw new Error(
      `Administrator password cannot exceed ${MAX_PASSWORD_LENGTH} characters.`,
    );
  }
}