
import pool from "../config/database.js";
import crypto from "crypto";

// =====================================================
// ASSET SERVICE
// =====================================================

// =====================================================
// 1. GET PUBLISHED ASSETS
// =====================================================

export async function getPublishedAssets({
  search = "",
  category = "",
  page = 1,
  limit = 20,
} = {}) {
  const safePage = Math.max(1, Number.parseInt(page, 10) || 1);
  const safeLimit = Math.min(
    100,
    Math.max(1, Number.parseInt(limit, 10) || 20)
  );

  const offset = (safePage - 1) * safeLimit;

  const conditions = [
    "a.status = 'tokenized'",
    "t.status = 'active'",
  ];

  const params = [];

  if (search.trim()) {
    conditions.push(`
      (
        a.name LIKE ?
        OR a.assetCode LIKE ?
        OR t.tokenName LIKE ?
        OR t.tokenCode LIKE ?
      )
    `);

    const searchValue = `%${search.trim()}%`;

    params.push(
      searchValue,
      searchValue,
      searchValue,
      searchValue
    );
  }

  if (category.trim()) {
    conditions.push("a.assetType = ?");
    params.push(category.trim());
  }

  const whereClause = conditions.join(" AND ");

  const [assets] = await pool.execute(
    `
      SELECT
        a.id,
        a.assetCode,
        a.assetType,
        a.name,
        a.description,
        a.location,
        a.estimatedValue,
        a.currency,
        a.status,

        t.id AS tokenId,
        t.tokenCode,
        t.tokenName,
        t.totalSupply,
        t.availableSupply,
        t.tokenPrice,
        t.currency AS tokenCurrency,
        t.status AS tokenStatus,

        (
          SELECT ap.photoUrl
          FROM asset_photos ap
          WHERE ap.assetId = a.id
          ORDER BY ap.isPrimary DESC, ap.displayOrder ASC
          LIMIT 1
        ) AS primaryPhoto

      FROM assets a

      INNER JOIN tokens t
        ON t.assetId = a.id

      WHERE ${whereClause}

      ORDER BY a.createdAt DESC

      LIMIT ${safeLimit}
      OFFSET ${offset}
    `,
    params
  );

  const [countResult] = await pool.execute(
    `
      SELECT COUNT(*) AS total

      FROM assets a

      INNER JOIN tokens t
        ON t.assetId = a.id

      WHERE ${whereClause}
    `,
    params
  );

  const total = Number(countResult[0].total);

  return {
    assets,
    pagination: {
      page: safePage,
      limit: safeLimit,
      total,
      totalPages: Math.ceil(total / safeLimit),
    },
  };
}


// =====================================================
// 2. GET ASSET DETAILS
// =====================================================

export async function getAssetById(assetId) {
  const [assets] = await pool.execute(
    `
      SELECT
        a.id,
        a.assetCode,
        a.assetType,
        a.name,
        a.description,
        a.location,
        a.latitude,
        a.longitude,
        a.registrationNumber,
        a.estimatedValue,
        a.currency,
        a.createdAt,

        t.id AS tokenId,
        t.tokenCode,
        t.tokenName,
        t.description AS tokenDescription,
        t.totalSupply,
        t.availableSupply,
        t.tokenPrice,
        t.currency AS tokenCurrency,
        t.decimals,
        t.status AS tokenStatus,
        t.mintedAt

      FROM assets a

      INNER JOIN tokens t
        ON t.assetId = a.id

      WHERE
        a.id = ?
        AND a.status = 'tokenized'
        AND t.status = 'active'

      LIMIT 1
    `,
    [assetId]
  );

  if (assets.length === 0) {
    return null;
  }

  const asset = assets[0];

  const [photos] = await pool.execute(
    `
      SELECT
        id,
        photoUrl,
        isPrimary,
        displayOrder

      FROM asset_photos

      WHERE assetId = ?

      ORDER BY isPrimary DESC, displayOrder ASC
    `,
    [assetId]
  );

  const [priceHistory] = await pool.execute(
    `
      SELECT
        price,
        currency,
        source,
        recordedAt

      FROM token_price_history

      WHERE tokenId = ?

      ORDER BY recordedAt DESC

      LIMIT 30
    `,
    [asset.tokenId]
  );

  return {
    ...asset,
    photos,
    priceHistory,
  };
}


// =====================================================
// 3. GET ASSET CATEGORIES
// =====================================================


export async function getAssetCategories() {
  const categories = [
    "land",
    "livestock",
    "produce",
    "vehicle",
    "property",
    "equipment",
    "other",
  ];

  return categories.map((category) => ({
    category,
  }));
}


// =====================================================
// 4. GET MARKETPLACE STATISTICS
// =====================================================

export async function getAssetMarketStats() {
  const [stats] = await pool.execute(
    `
      SELECT
        COUNT(DISTINCT a.id) AS totalAssets,
        COUNT(DISTINCT t.id) AS totalTokens,

        COALESCE(
          SUM(a.estimatedValue),
          0
        ) AS totalAssetValue,

        COALESCE(
          SUM(t.availableSupply * t.tokenPrice),
          0
        ) AS totalAvailableTokenValue

      FROM assets a

      INNER JOIN tokens t
        ON t.assetId = a.id

      WHERE
        a.status = 'tokenized'
        AND t.status = 'active'
    `
  );

  return stats[0];
}


// =====================================================
// 5. GET USER ASSET SUBMISSIONS
// =====================================================

export async function getUserAssetSubmissions(userId) {
  const [assets] = await pool.execute(
    `
      SELECT
        a.id,
        a.assetCode,
        a.assetType,
        a.name,
        a.description,
        a.location,
        a.estimatedValue,
        a.currency,
        a.status,
        a.rejectionReason,
        a.createdAt,
        a.updatedAt,

        (
          SELECT ap.photoUrl
          FROM asset_photos ap
          WHERE ap.assetId = a.id
          ORDER BY ap.isPrimary DESC, ap.displayOrder ASC
          LIMIT 1
        ) AS primaryPhoto

      FROM assets a

      WHERE a.ownerId = ?

      ORDER BY a.createdAt DESC
    `,
    [userId]
  );

  return assets;
}


// =====================================================
// 6. GET USER SUBMISSION DETAILS
// =====================================================

export async function getUserAssetSubmissionById(userId, assetId) {
  const [assets] = await pool.execute(
    `
      SELECT
        id,
        ownerId,
        assetCode,
        assetType,
        name,
        description,
        location,
        latitude,
        longitude,
        registrationNumber,
        estimatedValue,
        currency,
        status,
        rejectionReason,
        createdAt,
        updatedAt

      FROM assets

      WHERE
        id = ?
        AND ownerId = ?

      LIMIT 1
    `,
    [assetId, userId]
  );

  if (assets.length === 0) {
    return null;
  }

  const asset = assets[0];

  const [photos] = await pool.execute(
    `
      SELECT
        id,
        photoUrl,
        isPrimary,
        displayOrder

      FROM asset_photos

      WHERE assetId = ?

      ORDER BY isPrimary DESC, displayOrder ASC
    `,
    [assetId]
  );

  const [documents] = await pool.execute(
    `
      SELECT
        id,
        documentType,
        documentName,
        documentUrl,
        status,
        createdAt

      FROM asset_documents

      WHERE assetId = ?

      ORDER BY createdAt DESC
    `,
    [assetId]
  );

  return {
    ...asset,
    photos,
    documents,
  };
}

// =====================================================
// 7. CREATE ASSET SUBMISSION
// =====================================================

export async function createAssetSubmission(userId, assetData) {
  const {
    assetType,
    name,
    description,
    location,
    latitude,
    longitude,
    registrationNumber,
    estimatedValue,
    currency = "KES",
  } = assetData;

  const connection = await pool.getConnection();

  try {
    await connection.beginTransaction();

    const assetCode = `AST-${crypto.randomUUID()
      .replace(/-/g, "")
      .slice(0, 12)
      .toUpperCase()}`;

    const [result] = await connection.execute(
      `
        INSERT INTO assets (
          ownerId,
          assetCode,
          assetType,
          name,
          description,
          location,
          latitude,
          longitude,
          registrationNumber,
          estimatedValue,
          currency,
          status
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'pending')
      `,
      [
        userId,
        assetCode,
        assetType,
        name,
        description || null,
        location || null,
        latitude ?? null,
        longitude ?? null,
        registrationNumber || null,
        estimatedValue ?? null,
        currency,
      ]
    );

    const assetId = result.insertId;

    await connection.commit();

    return {
      id: assetId,
      assetCode,
      assetType,
      name,
      status: "pending",
      message: "Asset submitted successfully.",
    };
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }
}


export async function verifyAssetOwnership(userId, assetId) {
  const [rows] = await pool.execute(
    `
      SELECT id
      FROM assets
      WHERE id = ?
        AND ownerId = ?
      LIMIT 1
    `,
    [assetId, userId]
  );

  return rows.length > 0;
}


export async function saveAssetPhotos(assetId, files) {
  if (!files || files.length === 0) {
    throw new Error("No photos were provided.");
  }

  const connection = await pool.getConnection();

  try {
    await connection.beginTransaction();

    const [existingPhotos] = await connection.execute(
      `
        SELECT COUNT(*) AS photoCount
        FROM asset_photos
        WHERE assetId = ?
      `,
      [assetId]
    );

    const hasExistingPhotos =
      Number(existingPhotos[0].photoCount) > 0;

    for (let index = 0; index < files.length; index++) {
      const file = files[index];

      const photoUrl = `/uploads/assets/photos/${file.filename}`;

      const isPrimary =
        !hasExistingPhotos && index === 0 ? 1 : 0;

      await connection.execute(
        `
          INSERT INTO asset_photos (
            assetId,
            photoUrl,
            isPrimary,
            displayOrder
          )
          VALUES (?, ?, ?, ?)
        `,
        [
          assetId,
          photoUrl,
          isPrimary,
          index + 1,
        ]
      );
    }

    await connection.commit();

    return {
      assetId,
      uploadedCount: files.length,
    };
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }
}

export async function saveAssetDocuments(assetId, files, documentType) {
  if (!files || files.length === 0) {
    throw new Error("No documents were provided.");
  }

  const validDocumentTypes = [
    "ownership",
    "valuation",
    "registration",
    "identification",
    "legal",
    "inspection",
    "other",
  ];

  if (!validDocumentTypes.includes(documentType)) {
    throw new Error("Invalid document type.");
  }

  const connection = await pool.getConnection();

  try {
    await connection.beginTransaction();

    const savedDocuments = [];

    for (const file of files) {
      const fileBuffer = await import("fs/promises")
        .then((fs) => fs.readFile(file.path));

      const documentHash = crypto
        .createHash("sha256")
        .update(fileBuffer)
        .digest("hex");

      const documentUrl =
        `/private/uploads/assets/documents/${file.filename}`;

      const documentName = file.originalname.slice(0, 150);

      const [result] = await connection.execute(
        `
          INSERT INTO asset_documents (
            assetId,
            documentType,
            documentName,
            documentUrl,
            documentHash,
            status
          )
          VALUES (?, ?, ?, ?, ?, 'pending')
        `,
        [
          assetId,
          documentType,
          documentName,
          documentUrl,
          documentHash,
        ]
      );

      savedDocuments.push({
        id: result.insertId,
        assetId,
        documentType,
        documentName,
        documentUrl,
        documentHash,
        status: "pending",
      });
    }

    await connection.commit();

    return {
      assetId,
      uploadedCount: savedDocuments.length,
      documents: savedDocuments,
    };
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }
}

// =====================================================
// GET PRIVATE ASSET DOCUMENT
// =====================================================

export async function getAssetDocumentForAccess(
  assetId,
  documentId,
  userId,
  userRole
) {
  const [documents] = await pool.execute(
    `
      SELECT
        d.id,
        d.assetId,
        d.documentType,
        d.documentName,
        d.documentUrl,
        d.documentHash,
        d.status,
        d.createdAt

      FROM asset_documents d

      INNER JOIN assets a
        ON a.id = d.assetId

      WHERE
        a.id = ?
        AND d.id = ?
        AND (
          a.ownerId = ?
          OR ? = 'admin'
        )

      LIMIT 1
    `,
    [
      assetId,
      documentId,
      userId,
      userRole,
    ]
  );

  if (documents.length === 0) {
    return null;
  }

  return documents[0];
}
