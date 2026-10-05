import crypto from "crypto";

import pool from "../../config/database.js";

/**
 * Convert a value into a deterministic JSON representation.
 */
function serializeValue(value) {
  if (value === undefined || value === null) {
    return "";
  }

  if (typeof value === "string") {
    return value;
  }

  return JSON.stringify(value);
}

/**
 * Get the previous audit log hash.
 */
async function getPreviousHash(connection) {
  const [rows] = await connection.execute(
    `
      SELECT logHash
      FROM admin_audit_logs
      ORDER BY id DESC
      LIMIT 1
    `,
  );

  return rows[0]?.logHash || null;
}

/**
 * Generate the hash for an audit record.
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
  createdAt,
}) {
  const payload = [
    previousHash || "",
    staffId || "",
    action || "",
    module || "",
    entityType || "",
    entityId || "",
    serializeValue(oldValues),
    serializeValue(newValues),
    createdAt || "",
  ].join("|");

  return crypto
    .createHash("sha256")
    .update(payload)
    .digest("hex");
}

/**
 * Write an administrator audit record.
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
  const connection =
    await pool.getConnection();

  try {
    await connection.beginTransaction();

    const previousHash =
      await getPreviousHash(connection);

    const createdAt =
      new Date()
        .toISOString()
        .slice(0, 19)
        .replace("T", " ");

    const logHash = generateAuditHash({
      previousHash,
      staffId,
      action,
      module,
      entityType,
      entityId,
      oldValues,
      newValues,
      createdAt,
    });

    await connection.execute(
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
        oldValues
          ? JSON.stringify(oldValues)
          : null,
        newValues
          ? JSON.stringify(newValues)
          : null,
        ipAddress,
        userAgent,
        previousHash,
        logHash,
        createdAt,
      ],
    );

    await connection.commit();

    return {
      logHash,
      previousHash,
    };
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }
}