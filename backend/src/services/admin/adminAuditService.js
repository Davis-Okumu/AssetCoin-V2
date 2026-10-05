import crypto from "crypto";

import pool from "../../config/database.js";

// =========================================================
// ADMIN AUDIT LOG SERVICE
// =========================================================
//
// Responsibilities:
// - Write hash-linked administrator audit records.
// - Support an existing transaction connection so business
//   mutations and audit records can commit/rollback together.
// - Provide a standalone convenience function when no
//   surrounding transaction exists.
// - Generate deterministic SHA-256 audit hashes.
// - Protect the previous-hash lookup against concurrent writes.
//
// =========================================================


// =========================================================
// DETERMINISTIC JSON SERIALIZATION
// =========================================================

/**
 * Serialize a value consistently before it is included in
 * the audit hash.
 *
 * null and undefined are represented by an empty string
 * inside the hash payload.
 */
function serializeValue(value) {
  if (value === undefined || value === null) {
    return "";
  }

  if (typeof value === "string") {
    return JSON.stringify(value);
  }

  return JSON.stringify(value);
}


// =========================================================
// GET PREVIOUS AUDIT HASH
// =========================================================

/**
 * Retrieve the most recent audit log hash.
 *
 * The latest audit row is locked when this function is used
 * inside an active transaction. This helps prevent concurrent
 * audit writers from reading the same previous hash.
 */
async function getPreviousHash(connection) {
  const [rows] = await connection.execute(
    `
      SELECT id, logHash
      FROM admin_audit_logs
      ORDER BY id DESC
      LIMIT 1
      FOR UPDATE
    `,
  );

  return {
    id: rows[0]?.id ?? null,
    hash: rows[0]?.logHash ?? null,
  };
}


// =========================================================
// GENERATE AUDIT HASH
// =========================================================

/**
 * Generate the SHA-256 hash for an audit record.
 *
 * The previous hash is included in the payload so that every
 * audit record becomes cryptographically linked to the record
 * immediately before it.
 */
function generateAuditHash({
  previousHash,
  staffId,
  action,
  module,
  entityType,
  entityId,
  oldValues,
  newValues,
  ipAddress,
  userAgent,
  createdAt,
}) {
  const payload = [
    previousHash ?? "",
    staffId ?? "",
    action ?? "",
    module ?? "",
    entityType ?? "",
    entityId ?? "",
    serializeValue(oldValues),
    serializeValue(newValues),
    ipAddress ?? "",
    userAgent ?? "",
    createdAt ?? "",
  ].join("|");

  return crypto
    .createHash("sha256")
    .update(payload, "utf8")
    .digest("hex");
}


// =========================================================
// WRITE ADMIN AUDIT LOG
// =========================================================

/**
 * Write a hash-linked administrator audit record.
 *
 * IMPORTANT:
 * The caller can provide an existing database connection.
 *
 * This is the preferred method when an administrative action
 * changes business data because the business mutation and the
 * audit record can then participate in the SAME transaction.
 *
 * Example:
 *
 *   const connection = await pool.getConnection();
 *
 *   try {
 *     await connection.beginTransaction();
 *
 *     await connection.execute(...);
 *
 *     await writeAdminAuditLog({
 *       connection,
 *       staffId: req.user.id,
 *       action: "USER_UPDATED",
 *       module: "users",
 *       entityType: "user",
 *       entityId: userId,
 *       oldValues,
 *       newValues,
 *     });
 *
 *     await connection.commit();
 *   } catch (error) {
 *     await connection.rollback();
 *     throw error;
 *   } finally {
 *     connection.release();
 *   }
 */
export async function writeAdminAuditLog({
  connection,
  staffId = null,
  action,
  module,
  entityType = null,
  entityId = null,
  oldValues = null,
  newValues = null,
  ipAddress = null,
  userAgent = null,
}) {
  if (!connection) {
    throw new Error(
      "A database connection is required to write an admin audit log.",
    );
  }

  if (!action) {
    throw new Error(
      "Admin audit log action is required.",
    );
  }

  if (!module) {
    throw new Error(
      "Admin audit log module is required.",
    );
  }

  // ---------------------------------------------------------
  // Get previous hash
  // ---------------------------------------------------------

  const {
    hash: previousHash,
  } = await getPreviousHash(connection);

  // ---------------------------------------------------------
  // Generate timestamp
  // ---------------------------------------------------------
  //
  // MySQL DATETIME-compatible UTC timestamp.
  //
  // Example:
  // 2026-10-05 19:11:42
  //
  // ---------------------------------------------------------

  const createdAt = new Date()
    .toISOString()
    .slice(0, 19)
    .replace("T", " ");

  // ---------------------------------------------------------
  // Generate cryptographic hash
  // ---------------------------------------------------------

  const logHash = generateAuditHash({
    previousHash,
    staffId,
    action,
    module,
    entityType,
    entityId,
    oldValues,
    newValues,
    ipAddress,
    userAgent,
    createdAt,
  });

  // ---------------------------------------------------------
  // Serialize values once
  // ---------------------------------------------------------

  const serializedOldValues =
    oldValues === null || oldValues === undefined
      ? null
      : JSON.stringify(oldValues);

  const serializedNewValues =
    newValues === null || newValues === undefined
      ? null
      : JSON.stringify(newValues);

  // ---------------------------------------------------------
  // Insert audit record
  // ---------------------------------------------------------

  const [result] = await connection.execute(
    `
      INSERT INTO admin_audit_logs (
        staffId,
        action,
        module,
        entityType,
        entityId,
        oldValues,
        newValues,
        ipAddress,
        userAgent,
        previousHash,
        logHash,
        createdAt
      )
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `,
    [
      staffId,
      action,
      module,
      entityType,
      entityId,
      serializedOldValues,
      serializedNewValues,
      ipAddress,
      userAgent,
      previousHash,
      logHash,
      createdAt,
    ],
  );

  // ---------------------------------------------------------
  // Return useful audit information
  // ---------------------------------------------------------

  return {
    id: result.insertId,
    logHash,
    previousHash,
    createdAt,
  };
}


// =========================================================
// STANDALONE ADMIN AUDIT LOG
// =========================================================

/**
 * Convenience wrapper for audit events that do not already
 * belong to another business transaction.
 *
 * This function creates its own connection and transaction,
 * then delegates the actual audit creation to
 * writeAdminAuditLog().
 *
 * For business mutations, prefer writeAdminAuditLog() with
 * the caller's existing connection.
 */
export async function createAdminAuditLog({
  staffId = null,
  action,
  module,
  entityType = null,
  entityId = null,
  oldValues = null,
  newValues = null,
  ipAddress = null,
  userAgent = null,
}) {
  const connection = await pool.getConnection();

  try {
    await connection.beginTransaction();

    const auditLog = await writeAdminAuditLog({
      connection,
      staffId,
      action,
      module,
      entityType,
      entityId,
      oldValues,
      newValues,
      ipAddress,
      userAgent,
    });

    await connection.commit();

    return auditLog;
  } catch (error) {
    try {
      await connection.rollback();
    } catch (rollbackError) {
      console.error(
        "Admin audit rollback failed:",
        rollbackError,
      );
    }

    throw error;
  } finally {
    connection.release();
  }
}