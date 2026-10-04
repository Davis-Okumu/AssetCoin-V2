
import pool from "../config/database.js";

// =====================================================
// SUBMIT KYC APPLICATION
// =====================================================

export async function submitKycApplication(
  userId,
  idDocumentUrl,
  selfieUrl
) {
  const connection = await pool.getConnection();

  try {
    await connection.beginTransaction();

    const [users] = await connection.execute(
      `SELECT
        id,
        nationalId,
        kycStatus
      FROM users
      WHERE id = ?
      LIMIT 1
      FOR UPDATE`,
      [userId]
    );

    if (users.length === 0) {
      const error = new Error("User account not found.");
      error.statusCode = 404;
      throw error;
    }

    const user = users[0];

    const [existingRecords] = await connection.execute(
      `SELECT
        id,
        status
      FROM kyc_records
      WHERE userId = ?
      ORDER BY submittedAt DESC, id DESC
      LIMIT 1
      FOR UPDATE`,
      [userId]
    );

    const latestRecord = existingRecords[0] || null;

    if (
      latestRecord &&
      ["pending", "under_review", "verified"].includes(
        latestRecord.status
      )
    ) {
      const error = new Error(
        latestRecord.status === "verified"
          ? "Your identity has already been verified."
          : "Your KYC application is already being processed."
      );

      error.statusCode = 409;
      throw error;
    }

    const [result] = await connection.execute(
      `INSERT INTO kyc_records (
        userId,
        nationalId,
        idDocumentUrl,
        selfieUrl,
        verificationMethod,
        status,
        submittedAt
      )
      VALUES (?, ?, ?, ?, 'manual', 'pending', CURRENT_TIMESTAMP)`,
      [
        userId,
        user.nationalId,
        idDocumentUrl,
        selfieUrl,
      ]
    );

    // The users enum does not support under_review.
    // Keep its status pending until an administrator decides.
    await connection.execute(
      `UPDATE users
       SET
         kycStatus = 'pending',
         updatedAt = CURRENT_TIMESTAMP
       WHERE id = ?`,
      [userId]
    );

    await connection.commit();

    return {
      submissionId: result.insertId,
      status: "pending",
      submittedAt: new Date(),
    };
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }
}

// =====================================================
// GET KYC STATUS
// =====================================================

export async function getKycStatus(userId) {
  const [users] = await pool.execute(
    `SELECT
      kycStatus
    FROM users
    WHERE id = ?
    LIMIT 1`,
    [userId]
  );

  if (users.length === 0) {
    const error = new Error("User account not found.");
    error.statusCode = 404;
    throw error;
  }

  const [records] = await pool.execute(
    `SELECT
      id,
      status,
      rejectionReason,
      verificationMethod,
      submittedAt,
      verifiedAt
    FROM kyc_records
    WHERE userId = ?
    ORDER BY submittedAt DESC, id DESC
    LIMIT 1`,
    [userId]
  );

  const latestRecord = records[0] || null;

  return {
    status: latestRecord?.status || users[0].kycStatus,
    rejectionReason: latestRecord?.rejectionReason || null,
    verificationMethod:
      latestRecord?.verificationMethod || null,
    submittedAt: latestRecord?.submittedAt || null,
    verifiedAt: latestRecord?.verifiedAt || null,
    submissionId: latestRecord?.id || null,
  };
}

// =====================================================
// GET KYC SUBMISSION HISTORY
// =====================================================

export async function getKycHistory(userId) {
  const [records] = await pool.execute(
    `SELECT
      id,
      status,
      rejectionReason,
      verificationMethod,
      submittedAt,
      verifiedAt
    FROM kyc_records
    WHERE userId = ?
    ORDER BY submittedAt DESC, id DESC`,
    [userId]
  );

  return records.map((record) => ({
    id: record.id,
    status: record.status,
    rejectionReason: record.rejectionReason,
    verificationMethod: record.verificationMethod,
    submittedAt: record.submittedAt,
    verifiedAt: record.verifiedAt,
  }));
}