
import pool from "../config/database.js";

// =====================================================
// GET CURRENT USER PROFILE
// =====================================================

export async function getUserProfile(userId) {
  const [users] = await pool.execute(
    `SELECT
      id,
      firstName,
      lastName,
      phone,
      email,
      nationalId,
      profilePhotoUrl,
      kycStatus,
      role,
      accountStatus,
      lastLoginAt,
      createdAt,
      updatedAt
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

  const user = users[0];

  // Retrieve the most recent KYC submission.
  const [kycRecords] = await pool.execute(
    `SELECT
      id,
      status,
      rejectionReason,
      submittedAt,
      verifiedAt
    FROM kyc_records
    WHERE userId = ?
    ORDER BY submittedAt DESC, id DESC
    LIMIT 1`,
    [userId]
  );

  const latestKyc = kycRecords[0] || null;

  // Prefer the latest KYC record when one exists.
  const verificationStatus = latestKyc
    ? latestKyc.status
    : user.kycStatus;

  // Mask the National ID before returning it.
  const nationalId = String(user.nationalId || "");

  const maskedNationalId = nationalId.length > 4
    ? `${"*".repeat(nationalId.length - 4)}${nationalId.slice(-4)}`
    : "****";

  return {
    id: user.id,
    firstName: user.firstName,
    lastName: user.lastName,
    fullName: `${user.firstName} ${user.lastName}`.trim(),
    phone: user.phone,
    email: user.email,
    nationalId: maskedNationalId,
    profilePhotoUrl: user.profilePhotoUrl,

    // Keep this top-level field for ProfileModel.
    kycStatus: verificationStatus,

    // Preserve the detailed verification information.
    verification: {
      status: verificationStatus,
      rejectionReason: latestKyc?.rejectionReason || null,
      submittedAt: latestKyc?.submittedAt || null,
      verifiedAt: latestKyc?.verifiedAt || null,
    },

    role: user.role,
    accountStatus: user.accountStatus,
    lastLoginAt: user.lastLoginAt,
    createdAt: user.createdAt,
    updatedAt: user.updatedAt || null,
  };
}

// =====================================================
// UPDATE PERSONAL INFORMATION
// =====================================================

export async function updateUserProfile(userId, profileData) {
  const allowedFields = [
    "firstName",
    "lastName",
    "email",
    "phone",
  ];

  const updates = [];
  const values = [];

  for (const field of allowedFields) {
    if (Object.prototype.hasOwnProperty.call(profileData, field)) {
      updates.push(`${field} = ?`);
      values.push(profileData[field]);
    }
  }

  if (updates.length === 0) {
    const error = new Error(
      "No valid profile information was provided."
    );
    error.statusCode = 400;
    throw error;
  }

  updates.push("updatedAt = CURRENT_TIMESTAMP");

  values.push(userId);

  try {
    const [result] = await pool.execute(
      `UPDATE users
       SET ${updates.join(", ")}
       WHERE id = ?`,
      values
    );

    if (result.affectedRows === 0) {
      const error = new Error("User account not found.");
      error.statusCode = 404;
      throw error;
    }

    return getUserProfile(userId);
  } catch (error) {
    if (error.code === "ER_DUP_ENTRY") {
      const duplicateError = new Error(
        "The email address or phone number is already registered."
      );

      duplicateError.statusCode = 409;
      throw duplicateError;
    }

    throw error;
  }
}

// =====================================================
// UPDATE PROFILE PHOTO
// =====================================================

export async function updateProfilePhoto(userId, photoUrl) {
  const [result] = await pool.execute(
    `UPDATE users
     SET
       profilePhotoUrl = ?,
       updatedAt = CURRENT_TIMESTAMP
     WHERE id = ?`,
    [photoUrl, userId]
  );

  if (result.affectedRows === 0) {
    const error = new Error("User account not found.");
    error.statusCode = 404;
    throw error;
  }

  return getUserProfile(userId);
}

// =====================================================
// REMOVE PROFILE PHOTO
// =====================================================

export async function removeProfilePhoto(userId) {
  const [users] = await pool.execute(
    `SELECT profilePhotoUrl
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

  const previousPhotoUrl = users[0].profilePhotoUrl;

  await pool.execute(
    `UPDATE users
     SET
       profilePhotoUrl = NULL,
       updatedAt = CURRENT_TIMESTAMP
     WHERE id = ?`,
    [userId]
  );

  return {
    previousPhotoUrl,
    profile: await getUserProfile(userId),
  };
}