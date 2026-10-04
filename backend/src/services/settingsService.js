
import pool from "../config/database.js";

// =========================================================
// DEFAULT USER PREFERENCES
// =========================================================

const DEFAULT_PREFERENCES = {
  theme: "light",
  language: "en",
  displayCurrency: "KES",
  profileVisibility: "private",
  showEmail: false,
  showPhone: false,
  marketingNotificationsEnabled: false,
  emailUpdatesEnabled: true,
};

// =========================================================
// VALIDATION HELPERS
// =========================================================

function validateUserId(userId) {
  const id = Number(userId);

  if (!Number.isSafeInteger(id) || id <= 0) {
    const error = new Error("Invalid user account.");
    error.statusCode = 400;
    throw error;
  }

  return id;
}

function validatePreferences(settings) {
  if (
    !settings ||
    typeof settings !== "object" ||
    Array.isArray(settings)
  ) {
    const error = new Error("Invalid preferences data.");
    error.statusCode = 400;
    throw error;
  }

  const allowedFields = Object.keys(DEFAULT_PREFERENCES);

  const suppliedFields = Object.keys(settings);

  const unsupportedFields = suppliedFields.filter(
    field => !allowedFields.includes(field)
  );

  if (unsupportedFields.length > 0) {
    const error = new Error(
      `Unsupported preference fields: ${unsupportedFields.join(", ")}`
    );

    error.statusCode = 400;
    throw error;
  }

  if (suppliedFields.length === 0) {
    const error = new Error("Provide at least one preference to update.");
    error.statusCode = 400;
    throw error;
  }

  const validated = {};

  if (settings.theme !== undefined) {
    if (!["light", "dark", "system"].includes(settings.theme)) {
      const error = new Error("Invalid application theme.");
      error.statusCode = 400;
      throw error;
    }

    validated.theme = settings.theme;
  }

  if (settings.language !== undefined) {
    if (
      typeof settings.language !== "string" ||
      !/^[a-zA-Z]{2,10}(-[a-zA-Z0-9]{2,8})*$/.test(
        settings.language
      )
    ) {
      const error = new Error("Invalid language preference.");
      error.statusCode = 400;
      throw error;
    }

    validated.language = settings.language.toLowerCase();
  }

  if (settings.displayCurrency !== undefined) {
    if (
      typeof settings.displayCurrency !== "string" ||
      !/^[A-Za-z]{3,10}$/.test(settings.displayCurrency)
    ) {
      const error = new Error("Invalid display currency.");
      error.statusCode = 400;
      throw error;
    }

    validated.displayCurrency =
      settings.displayCurrency.toUpperCase();
  }

  if (settings.profileVisibility !== undefined) {
    if (
      !["private", "public"].includes(
        settings.profileVisibility
      )
    ) {
      const error = new Error("Invalid profile visibility setting.");
      error.statusCode = 400;
      throw error;
    }

    validated.profileVisibility = settings.profileVisibility;
  }

  const booleanFields = [
    "showEmail",
    "showPhone",
    "marketingNotificationsEnabled",
    "emailUpdatesEnabled",
  ];

  for (const field of booleanFields) {
    if (settings[field] !== undefined) {
      if (typeof settings[field] !== "boolean") {
        const error = new Error(
          `${field} must be true or false.`
        );

        error.statusCode = 400;
        throw error;
      }

      validated[field] = settings[field];
    }
  }

  return validated;
}

// =========================================================
// FORMAT PREFERENCES
// =========================================================

function formatPreferences(row) {
  if (!row) {
    return { ...DEFAULT_PREFERENCES };
  }

  return {
    theme: row.theme,
    language: row.language,
    displayCurrency: row.displayCurrency,
    profileVisibility: row.profileVisibility,
    showEmail: Boolean(row.showEmail),
    showPhone: Boolean(row.showPhone),
    marketingNotificationsEnabled: Boolean(
      row.marketingNotificationsEnabled
    ),
    emailUpdatesEnabled: Boolean(row.emailUpdatesEnabled),
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  };
}

// =========================================================
// GET USER PREFERENCES
// =========================================================

export async function getUserPreferences(userId) {
  const id = validateUserId(userId);

  const [rows] = await pool.execute(
    `SELECT
      theme,
      language,
      displayCurrency,
      profileVisibility,
      showEmail,
      showPhone,
      marketingNotificationsEnabled,
      emailUpdatesEnabled,
      createdAt,
      updatedAt
    FROM user_preferences
    WHERE userId = ?
    LIMIT 1`,
    [id]
  );

  if (rows.length === 0) {
    return { ...DEFAULT_PREFERENCES };
  }

  return formatPreferences(rows[0]);
}

// =========================================================
// UPDATE USER PREFERENCES
// =========================================================

export async function updateUserPreferences(userId, settings) {
  const id = validateUserId(userId);

  const validatedSettings = validatePreferences(settings);

  const connection = await pool.getConnection();

  try {
    await connection.beginTransaction();

    // Ensure a preferences record exists before locking it.
    await connection.execute(
      `INSERT IGNORE INTO user_preferences (
        userId,
        theme,
        language,
        displayCurrency,
        profileVisibility,
        showEmail,
        showPhone,
        marketingNotificationsEnabled,
        emailUpdatesEnabled
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        id,
        DEFAULT_PREFERENCES.theme,
        DEFAULT_PREFERENCES.language,
        DEFAULT_PREFERENCES.displayCurrency,
        DEFAULT_PREFERENCES.profileVisibility,
        DEFAULT_PREFERENCES.showEmail,
        DEFAULT_PREFERENCES.showPhone,
        DEFAULT_PREFERENCES.marketingNotificationsEnabled,
        DEFAULT_PREFERENCES.emailUpdatesEnabled,
      ]
    );

    // Lock the user's preferences record.
    const [rows] = await connection.execute(
      `SELECT
        theme,
        language,
        displayCurrency,
        profileVisibility,
        showEmail,
        showPhone,
        marketingNotificationsEnabled,
        emailUpdatesEnabled
      FROM user_preferences
      WHERE userId = ?
      LIMIT 1
      FOR UPDATE`,
      [id]
    );

    if (rows.length === 0) {
      const error = new Error(
        "Unable to retrieve user preferences."
      );

      error.statusCode = 500;
      throw error;
    }

    const currentPreferences = formatPreferences(rows[0]);

    // Merge only the supplied, validated fields.
    const updatedPreferences = {
      ...currentPreferences,
      ...validatedSettings,
    };

    await connection.execute(
      `UPDATE user_preferences
       SET
        theme = ?,
        language = ?,
        displayCurrency = ?,
        profileVisibility = ?,
        showEmail = ?,
        showPhone = ?,
        marketingNotificationsEnabled = ?,
        emailUpdatesEnabled = ?
       WHERE userId = ?`,
      [
        updatedPreferences.theme,
        updatedPreferences.language,
        updatedPreferences.displayCurrency,
        updatedPreferences.profileVisibility,
        updatedPreferences.showEmail,
        updatedPreferences.showPhone,
        updatedPreferences.marketingNotificationsEnabled,
        updatedPreferences.emailUpdatesEnabled,
        id,
      ]
    );

    // Retrieve the saved record.
    const [updatedRows] = await connection.execute(
      `SELECT
        theme,
        language,
        displayCurrency,
        profileVisibility,
        showEmail,
        showPhone,
        marketingNotificationsEnabled,
        emailUpdatesEnabled,
        createdAt,
        updatedAt
      FROM user_preferences
      WHERE userId = ?
      LIMIT 1`,
      [id]
    );

    await connection.commit();

    return formatPreferences(updatedRows[0]);

  } catch (error) {
    try {
      await connection.rollback();
    } catch (rollbackError) {
      console.error(
        "Preferences transaction rollback failed:",
        rollbackError.message
      );
    }

    throw error;

  } finally {
    connection.release();
  }
}