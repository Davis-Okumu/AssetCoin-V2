
import pool from "../config/database.js";
import crypto from "crypto";

// =====================================================
// TRADING SERVICE
// =====================================================

// =====================================================
// HELPERS
// =====================================================

function generateReference(prefix) {
  return `${prefix}-${crypto
    .randomUUID()
    .replace(/-/g, "")
    .slice(0, 20)
    .toUpperCase()}`;
}

function normalizePagination(page, limit) {
  const safePage = Math.max(
    1,
    Number.parseInt(page, 10) || 1
  );

  const safeLimit = Math.min(
    100,
    Math.max(
      1,
      Number.parseInt(limit, 10) || 20
    )
  );

  return {
    page: safePage,
    limit: safeLimit,
    offset: (safePage - 1) * safeLimit,
  };
}

// =====================================================
// DECIMAL HELPERS
// =====================================================
//
// MySQL DECIMAL values are returned by mysql2 as strings.
// These helpers are used for validation and calculations
// while keeping the database transaction authoritative.
// =====================================================

function parsePositiveNumber(value, fieldName) {
  const parsed = Number(value);

  if (
    !Number.isFinite(parsed) ||
    parsed <= 0
  ) {
    throw new Error(
      `${fieldName} must be greater than zero.`
    );
  }

  return parsed;
}

// =====================================================
// 1. GET MARKETPLACE LISTINGS
// =====================================================
//
// Marketplace only exposes:
//
// - active listings
// - partially filled listings
// - listings with remaining quantity
// - active tokens
// - tokenized assets
//
// Approved-but-not-tokenized assets never appear here.
// =====================================================

export async function getMarketplaceListings({
  search = "",
  category = "",
  listingStatus = "",
  page = 1,
  limit = 20,
} = {}) {
  const pagination = normalizePagination(
    page,
    limit
  );

  const conditions = [
    `
      l.status IN (
        'active',
        'partially_filled'
      )
    `,
    "l.remainingQuantity > 0",
    "t.status = 'active'",
    "a.status = 'tokenized'",
  ];

  const params = [];

  // ---------------------------------------------------
  // SEARCH
  // ---------------------------------------------------

  if (String(search).trim()) {
    const searchValue =
      `%${String(search).trim()}%`;

    conditions.push(`
      (
        a.name LIKE ?
        OR a.assetCode LIKE ?
        OR t.tokenName LIKE ?
        OR t.tokenCode LIKE ?
      )
    `);

    params.push(
      searchValue,
      searchValue,
      searchValue,
      searchValue
    );
  }

  // ---------------------------------------------------
  // CATEGORY
  // ---------------------------------------------------

  if (String(category).trim()) {
    conditions.push(
      "a.assetType = ?"
    );

    params.push(
      String(category).trim()
    );
  }

  // ---------------------------------------------------
  // LISTING STATUS
  // ---------------------------------------------------

  if (String(listingStatus).trim()) {
    conditions.push(
      "l.status = ?"
    );

    params.push(
      String(listingStatus).trim()
    );
  }

  const whereClause =
    conditions.join(" AND ");

  // ---------------------------------------------------
  // LISTINGS
  // ---------------------------------------------------

  const [listings] =
    await pool.execute(
      `
        SELECT
          l.id,
          l.sellerId,
          l.tokenId,
          l.quantity,
          l.remainingQuantity,
          l.pricePerToken,
          l.currency,
          l.listingType,
          l.status,
          l.expiresAt,
          l.createdAt,
          l.updatedAt,

          a.id AS assetId,
          a.assetCode,
          a.assetType,
          a.name AS assetName,
          a.description AS assetDescription,
          a.location AS assetLocation,
          a.estimatedValue AS assetEstimatedValue,
          a.currency AS assetCurrency,
          a.status AS assetStatus,

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

          (
            SELECT ap.photoUrl
            FROM asset_photos ap
            WHERE ap.assetId = a.id
            ORDER BY
              ap.isPrimary DESC,
              ap.displayOrder ASC
            LIMIT 1
          ) AS primaryPhoto

        FROM listings l

        INNER JOIN tokens t
          ON t.id = l.tokenId

        INNER JOIN assets a
          ON a.id = t.assetId

        WHERE ${whereClause}

        ORDER BY
          l.createdAt DESC

        LIMIT ${pagination.limit}
        OFFSET ${pagination.offset}
      `,
      params
    );

  // ---------------------------------------------------
  // COUNT
  // ---------------------------------------------------

  const [countResult] =
    await pool.execute(
      `
        SELECT
          COUNT(*) AS total

        FROM listings l

        INNER JOIN tokens t
          ON t.id = l.tokenId

        INNER JOIN assets a
          ON a.id = t.assetId

        WHERE ${whereClause}
      `,
      params
    );

  const total =
    Number(
      countResult[0]?.total || 0
    );

  return {
    listings,

    pagination: {
      page: pagination.page,
      limit: pagination.limit,
      total,
      totalPages: Math.ceil(
        total /
        pagination.limit
      ),
    },
  };
}

// =====================================================
// 2. GET LISTING DETAILS
// =====================================================

export async function getListingById(
  listingId
) {
  const [rows] =
    await pool.execute(
      `
        SELECT
          l.id,
          l.sellerId,
          l.tokenId,
          l.quantity,
          l.remainingQuantity,
          l.pricePerToken,
          l.currency,
          l.listingType,
          l.status,
          l.expiresAt,
          l.createdAt,
          l.updatedAt,

          a.id AS assetId,
          a.assetCode,
          a.assetType,
          a.name AS assetName,
          a.description AS assetDescription,
          a.location AS assetLocation,
          a.latitude AS assetLatitude,
          a.longitude AS assetLongitude,
          a.registrationNumber,
          a.estimatedValue,
          a.currency AS assetCurrency,
          a.status AS assetStatus,
          a.approvedBy,
          a.approvedAt,

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

        FROM listings l

        INNER JOIN tokens t
          ON t.id = l.tokenId

        INNER JOIN assets a
          ON a.id = t.assetId

        WHERE
          l.id = ?

          AND l.status IN (
            'active',
            'partially_filled'
          )

          AND l.remainingQuantity > 0

          AND t.status = 'active'

          AND a.status = 'tokenized'

        LIMIT 1
      `,
      [listingId]
    );

  if (rows.length === 0) {
    return null;
  }

  const listing = rows[0];

  // ---------------------------------------------------
  // ASSET PHOTOS
  // ---------------------------------------------------

  const [photos] =
    await pool.execute(
      `
        SELECT
          id,
          photoUrl,
          isPrimary,
          displayOrder

        FROM asset_photos

        WHERE assetId = ?

        ORDER BY
          isPrimary DESC,
          displayOrder ASC
      `,
      [listing.assetId]
    );

  // ---------------------------------------------------
  // TOKEN PRICE HISTORY
  // ---------------------------------------------------

  const [priceHistory] =
    await pool.execute(
      `
        SELECT
          price,
          currency,
          source,
          referenceId,
          recordedAt

        FROM token_price_history

        WHERE tokenId = ?

        ORDER BY
          recordedAt DESC

        LIMIT 30
      `,
      [listing.tokenId]
    );

  return {
    ...listing,
    photos,
    priceHistory,
  };
}

// =====================================================
// 3. CREATE LISTING
// =====================================================
//
// A listing represents the seller's intention to sell.
//
// SELL = CREATE LISTING
//
// The underlying asset must already be tokenized and
// the token must be active.
//
// The listed tokens are immediately locked.
// =====================================================

export async function createListing(
  userId,
  {
    tokenId,
    quantity,
    pricePerToken,
    currency = "KES",
    expiresAt = null,
  }
) {
  const parsedTokenId =
    Number.parseInt(tokenId, 10);

  if (
    !Number.isSafeInteger(
      parsedTokenId
    ) ||
    parsedTokenId <= 0
  ) {
    throw new Error(
      "Invalid token ID."
    );
  }

  const parsedQuantity =
    parsePositiveNumber(
      quantity,
      "Listing quantity"
    );

  const parsedPricePerToken =
    parsePositiveNumber(
      pricePerToken,
      "Price per token"
    );

  const normalizedCurrency =
    String(currency || "KES")
      .trim()
      .toUpperCase();

  if (
    !/^[A-Z]{3,10}$/.test(
      normalizedCurrency
    )
  ) {
    throw new Error(
      "Invalid currency code."
    );
  }

  const connection =
    await pool.getConnection();

  try {
    await connection.beginTransaction();

    // -------------------------------------------------
    // 1. LOCK TOKEN + ASSET
    // -------------------------------------------------

    const [tokenRows] =
      await connection.execute(
        `
          SELECT
            t.id,
            t.assetId,
            t.tokenCode,
            t.tokenName,
            t.totalSupply,
            t.availableSupply,
            t.tokenPrice,
            t.currency,
            t.status AS tokenStatus,

            a.ownerId,
            a.assetCode,
            a.assetType,
            a.name AS assetName,
            a.status AS assetStatus,
            a.approvedBy,
            a.approvedAt

          FROM tokens t

          INNER JOIN assets a
            ON a.id = t.assetId

          WHERE t.id = ?

          LIMIT 1

          FOR UPDATE
        `,
        [parsedTokenId]
      );

    if (tokenRows.length === 0) {
      throw new Error(
        "Token not found."
      );
    }

    const token =
      tokenRows[0];

    // -------------------------------------------------
    // 2. VERIFY ASSET TOKENIZATION
    // -------------------------------------------------

    if (
      token.assetStatus !==
      "tokenized"
    ) {
      throw new Error(
        "This asset has not completed tokenization and cannot be listed."
      );
    }

    // -------------------------------------------------
    // 3. VERIFY TOKEN STATUS
    // -------------------------------------------------

    if (
      token.tokenStatus !==
      "active"
    ) {
      throw new Error(
        "This token is not currently active."
      );
    }

    // -------------------------------------------------
    // 4. VERIFY OWNER
    // -------------------------------------------------

    if (
      Number(token.ownerId) !==
      Number(userId)
    ) {
      throw new Error(
        "You are not authorized to list this token."
      );
    }

    // -------------------------------------------------
    // 5. VERIFY HOLDING
    // -------------------------------------------------

    const [holdingRows] =
      await connection.execute(
        `
          SELECT
            id,
            quantity,
            lockedQuantity

          FROM token_holdings

          WHERE
            userId = ?
            AND tokenId = ?

          LIMIT 1

          FOR UPDATE
        `,
        [
          userId,
          parsedTokenId,
        ]
      );

    if (holdingRows.length === 0) {
      throw new Error(
        "You do not own any quantity of this token."
      );
    }

    const holding =
      holdingRows[0];

    const ownedQuantity =
      Number(
        holding.quantity || 0
      );

    const lockedQuantity =
      Number(
        holding.lockedQuantity || 0
      );

    const availableHoldingQuantity =
      ownedQuantity -
      lockedQuantity;

    if (
      parsedQuantity >
      availableHoldingQuantity
    ) {
      throw new Error(
        "You do not have enough available tokens to create this listing."
      );
    }

    // -------------------------------------------------
    // 6. CREATE LISTING
    // -------------------------------------------------

    const [listingResult] =
      await connection.execute(
        `
          INSERT INTO listings (
            sellerId,
            tokenId,
            quantity,
            remainingQuantity,
            pricePerToken,
            currency,
            listingType,
            status,
            expiresAt
          )
          VALUES (
            ?,
            ?,
            ?,
            ?,
            ?,
            ?,
            'sell',
            'active',
            ?
          )
        `,
        [
          userId,
          parsedTokenId,
          parsedQuantity,
          parsedQuantity,
          parsedPricePerToken,
          normalizedCurrency,
          expiresAt || null,
        ]
      );

    const listingId =
      listingResult.insertId;

    // -------------------------------------------------
    // 7. LOCK LISTED TOKENS
    // -------------------------------------------------

    const newLockedQuantity =
      lockedQuantity +
      parsedQuantity;

    await connection.execute(
      `
        UPDATE token_holdings

        SET
          lockedQuantity = ?,
          updatedAt = CURRENT_TIMESTAMP

        WHERE id = ?
      `,
      [
        newLockedQuantity,
        holding.id,
      ]
    );

    // -------------------------------------------------
    // 8. AUDIT
    // -------------------------------------------------

    await connection.execute(
      `
        INSERT INTO audit_logs (
          userId,
          action,
          entityType,
          entityId,
          oldValues,
          newValues
        )
        VALUES (
          ?,
          'create_listing',
          'listing',
          ?,
          ?,
          ?
        )
      `,
      [
        userId,
        listingId,
        JSON.stringify({
          lockedQuantity,
        }),
        JSON.stringify({
          tokenId: parsedTokenId,
          quantity: parsedQuantity,
          remainingQuantity:
            parsedQuantity,
          pricePerToken:
            parsedPricePerToken,
          currency:
            normalizedCurrency,
          listingType: "sell",
          status: "active",
          lockedQuantity:
            newLockedQuantity,
        }),
      ]
    );

    await connection.commit();

    return {
      id: listingId,
      sellerId: userId,
      tokenId: parsedTokenId,
      tokenCode: token.tokenCode,
      assetId: token.assetId,
      assetCode: token.assetCode,
      assetName: token.assetName,
      quantity: parsedQuantity,
      remainingQuantity:
        parsedQuantity,
      pricePerToken:
        parsedPricePerToken,
      currency:
        normalizedCurrency,
      listingType: "sell",
      status: "active",
      expiresAt:
        expiresAt || null,
    };
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }
}

// =====================================================
// 4. GET USER ORDERS
// =====================================================

export async function getUserOrders(
  userId,
  {
    status = "",
    orderType = "",
    page = 1,
    limit = 20,
  } = {}
) {
  const pagination =
    normalizePagination(
      page,
      limit
    );

  const conditions = [
    "o.userId = ?",
  ];

  const params = [userId];

  if (String(status).trim()) {
    conditions.push(
      "o.status = ?"
    );

    params.push(
      String(status).trim()
    );
  }

  if (String(orderType).trim()) {
    conditions.push(
      "o.orderType = ?"
    );

    params.push(
      String(orderType).trim()
    );
  }

  const whereClause =
    conditions.join(" AND ");

  const [orders] =
    await pool.execute(
      `
        SELECT
          o.id,
          o.orderReference,
          o.userId,
          o.tokenId,
          o.listingId,
          o.orderType,
          o.quantity,
          o.filledQuantity,
          o.pricePerToken,
          o.totalAmount,
          o.currency,
          o.status,
          o.createdAt,
          o.updatedAt,

          t.tokenCode,
          t.tokenName,

          a.id AS assetId,
          a.assetCode,
          a.assetType,
          a.name AS assetName,

          (
            SELECT ap.photoUrl
            FROM asset_photos ap
            WHERE ap.assetId = a.id
            ORDER BY
              ap.isPrimary DESC,
              ap.displayOrder ASC
            LIMIT 1
          ) AS primaryPhoto

        FROM orders o

        INNER JOIN tokens t
          ON t.id = o.tokenId

        INNER JOIN assets a
          ON a.id = t.assetId

        WHERE ${whereClause}

        ORDER BY
          o.createdAt DESC

        LIMIT ${pagination.limit}
        OFFSET ${pagination.offset}
      `,
      params
    );

  const [countResult] =
    await pool.execute(
      `
        SELECT
          COUNT(*) AS total

        FROM orders o

        WHERE ${whereClause}
      `,
      params
    );

  const total =
    Number(
      countResult[0]?.total || 0
    );

  return {
    orders,

    pagination: {
      page: pagination.page,
      limit: pagination.limit,
      total,
      totalPages: Math.ceil(
        total /
        pagination.limit
      ),
    },
  };
}

// =====================================================
// 5. GET ORDER DETAILS
// =====================================================

export async function getUserOrderById(
  userId,
  orderId
) {
  const [orders] =
    await pool.execute(
      `
        SELECT
          o.id,
          o.orderReference,
          o.userId,
          o.tokenId,
          o.listingId,
          o.orderType,
          o.quantity,
          o.filledQuantity,
          o.pricePerToken,
          o.totalAmount,
          o.currency,
          o.status,
          o.createdAt,
          o.updatedAt,

          t.tokenCode,
          t.tokenName,
          t.totalSupply,
          t.tokenPrice,
          t.currency AS tokenCurrency,

          a.id AS assetId,
          a.assetCode,
          a.assetType,
          a.name AS assetName,
          a.description AS assetDescription

        FROM orders o

        INNER JOIN tokens t
          ON t.id = o.tokenId

        INNER JOIN assets a
          ON a.id = t.assetId

        WHERE
          o.id = ?
          AND o.userId = ?

        LIMIT 1
      `,
      [
        orderId,
        userId,
      ]
    );

  if (orders.length === 0) {
    return null;
  }

  return orders[0];
}

// =====================================================
// 6. GET USER TOKEN HOLDINGS
// =====================================================

export async function getUserTokenHoldings(
  userId,
  {
    search = "",
    page = 1,
    limit = 20,
  } = {}
) {
  const pagination =
    normalizePagination(
      page,
      limit
    );

  const conditions = [
    "h.userId = ?",
    "h.quantity > 0",
  ];

  const params = [userId];

  if (String(search).trim()) {
    const searchValue =
      `%${String(search).trim()}%`;

    conditions.push(`
      (
        t.tokenCode LIKE ?
        OR t.tokenName LIKE ?
        OR a.assetCode LIKE ?
        OR a.name LIKE ?
      )
    `);

    params.push(
      searchValue,
      searchValue,
      searchValue,
      searchValue
    );
  }

  const whereClause =
    conditions.join(" AND ");

  const [holdings] =
    await pool.execute(
      `
        SELECT
          h.id,
          h.userId,
          h.tokenId,
          h.quantity,
          h.lockedQuantity,

          (
            h.quantity -
            h.lockedQuantity
          ) AS availableQuantity,

          h.averageBuyPrice,
          h.totalInvested,

          t.tokenCode,
          t.tokenName,
          t.tokenPrice,
          t.currency AS tokenCurrency,
          t.decimals,
          t.status AS tokenStatus,

          a.id AS assetId,
          a.assetCode,
          a.assetType,
          a.name AS assetName,
          a.estimatedValue,
          a.currency AS assetCurrency,

          (
            h.quantity *
            t.tokenPrice
          ) AS currentValue,

          (
            (
              h.quantity -
              h.lockedQuantity
            ) *
            t.tokenPrice
          ) AS availableValue,

          (
            SELECT ap.photoUrl
            FROM asset_photos ap
            WHERE ap.assetId = a.id
            ORDER BY
              ap.isPrimary DESC,
              ap.displayOrder ASC
            LIMIT 1
          ) AS primaryPhoto

        FROM token_holdings h

        INNER JOIN tokens t
          ON t.id = h.tokenId

        INNER JOIN assets a
          ON a.id = t.assetId

        WHERE ${whereClause}

        ORDER BY
          h.updatedAt DESC

        LIMIT ${pagination.limit}
        OFFSET ${pagination.offset}
      `,
      params
    );

  const [countResult] =
    await pool.execute(
      `
        SELECT
          COUNT(*) AS total

        FROM token_holdings h

        INNER JOIN tokens t
          ON t.id = h.tokenId

        INNER JOIN assets a
          ON a.id = t.assetId

        WHERE ${whereClause}
      `,
      params
    );

  const total =
    Number(
      countResult[0]?.total || 0
    );

  return {
    holdings,

    pagination: {
      page: pagination.page,
      limit: pagination.limit,
      total,
      totalPages: Math.ceil(
        total /
        pagination.limit
      ),
    },
  };
}

// =====================================================
// 7. GET USER TOKEN HOLDING DETAILS
// =====================================================

export async function getUserTokenHoldingByTokenId(
  userId,
  tokenId
) {
  const [holdings] =
    await pool.execute(
      `
        SELECT
          h.id,
          h.userId,
          h.tokenId,
          h.quantity,
          h.lockedQuantity,

          (
            h.quantity -
            h.lockedQuantity
          ) AS availableQuantity,

          h.averageBuyPrice,
          h.totalInvested,

          t.tokenCode,
          t.tokenName,
          t.description AS tokenDescription,
          t.totalSupply,
          t.availableSupply,
          t.tokenPrice,
          t.currency AS tokenCurrency,
          t.decimals,
          t.status AS tokenStatus,
          t.mintedAt,

          a.id AS assetId,
          a.assetCode,
          a.assetType,
          a.name AS assetName,
          a.description AS assetDescription,
          a.location,
          a.estimatedValue,
          a.currency AS assetCurrency,
          a.status AS assetStatus,

          (
            h.quantity *
            t.tokenPrice
          ) AS currentValue,

          (
            (
              h.quantity -
              h.lockedQuantity
            ) *
            t.tokenPrice
          ) AS availableValue

        FROM token_holdings h

        INNER JOIN tokens t
          ON t.id = h.tokenId

        INNER JOIN assets a
          ON a.id = t.assetId

        WHERE
          h.userId = ?
          AND h.tokenId = ?

        LIMIT 1
      `,
      [
        userId,
        tokenId,
      ]
    );

  if (holdings.length === 0) {
    return null;
  }

  const holding =
    holdings[0];

  // ---------------------------------------------------
  // ASSET PHOTOS
  // ---------------------------------------------------

  const [photos] =
    await pool.execute(
      `
        SELECT
          id,
          photoUrl,
          isPrimary,
          displayOrder

        FROM asset_photos

        WHERE assetId = ?

        ORDER BY
          isPrimary DESC,
          displayOrder ASC
      `,
      [holding.assetId]
    );

  // ---------------------------------------------------
  // PRICE HISTORY
  // ---------------------------------------------------

  const [priceHistory] =
    await pool.execute(
      `
        SELECT
          price,
          currency,
          source,
          referenceId,
          recordedAt

        FROM token_price_history

        WHERE tokenId = ?

        ORDER BY
          recordedAt DESC

        LIMIT 30
      `,
      [holding.tokenId]
    );

  return {
    ...holding,
    photos,
    priceHistory,
  };
}

// =====================================================
// 8. BUY TOKEN
// =====================================================
//
// BUY = execute a purchase against an existing listing.
//
// Successful purchase:
//
//   BUY ORDER
//       ↓
//   TRANSACTION
//       ↓
//   FIAT TRANSFER
//       ↓
//   TOKEN TRANSFER
//       ↓
//   LISTING UPDATE
//
// The seller does NOT receive a SELL order.
//
// The listing already represents the seller's intent
// to sell.
//
// Everything is executed inside one database
// transaction.
// =====================================================

export async function buyToken(
  userId,
  {
    listingId,
    quantity,
  }
) {
  if (!userId) {
    throw new Error(
      "Authentication is required."
    );
  }

  const parsedListingId =
    Number.parseInt(
      listingId,
      10
    );

  if (
    !Number.isSafeInteger(
      parsedListingId
    ) ||
    parsedListingId <= 0
  ) {
    throw new Error(
      "A valid listing ID is required."
    );
  }

  const requestedQuantity =
    parsePositiveNumber(
      quantity,
      "Quantity"
    );

  const connection =
    await pool.getConnection();

  try {
    await connection.beginTransaction();

    // =================================================
    // 1. LOCK LISTING + TOKEN + ASSET
    // =================================================

    const [listingRows] =
      await connection.execute(
        `
          SELECT
            l.id,
            l.sellerId,
            l.tokenId,
            l.quantity,
            l.remainingQuantity,
            l.pricePerToken,
            l.currency,
            l.listingType,
            l.status,
            l.expiresAt,

            t.tokenCode,
            t.tokenName,
            t.status AS tokenStatus,

            a.id AS assetId,
            a.ownerId AS assetOwnerId,
            a.status AS assetStatus

          FROM listings l

          INNER JOIN tokens t
            ON t.id = l.tokenId

          INNER JOIN assets a
            ON a.id = t.assetId

          WHERE l.id = ?

          LIMIT 1

          FOR UPDATE
        `,
        [parsedListingId]
      );

    if (listingRows.length === 0) {
      throw new Error(
        "Listing not found."
      );
    }

    const listing =
      listingRows[0];

    // =================================================
    // 2. VALIDATE LISTING
    // =================================================

    if (
      Number(listing.sellerId) ===
      Number(userId)
    ) {
      throw new Error(
        "You cannot buy your own listing."
      );
    }

    if (
      listing.listingType !==
      "sell"
    ) {
      throw new Error(
        "This listing is not available for purchase."
      );
    }

    if (
      listing.status !== "active" &&
      listing.status !==
        "partially_filled"
    ) {
      throw new Error(
        "This listing is no longer available."
      );
    }

    if (
      listing.tokenStatus !==
      "active"
    ) {
      throw new Error(
        "This token is not currently available for trading."
      );
    }

    if (
      listing.assetStatus !==
      "tokenized"
    ) {
      throw new Error(
        "The underlying asset is not currently available for trading."
      );
    }

    // =================================================
    // 3. CHECK EXPIRATION
    // =================================================
    //
    // We intentionally do NOT change the listing status
    // inside this failed purchase transaction.
    //
    // Otherwise the status change would be rolled back
    // together with the failed purchase.
    //
    // Expiration cleanup can be handled separately.
    // =================================================

    if (
      listing.expiresAt &&
      new Date(
        listing.expiresAt
      ).getTime() <= Date.now()
    ) {
      throw new Error(
        "This listing has expired."
      );
    }

    // =================================================
    // 4. VALIDATE QUANTITY
    // =================================================

    const remainingQuantity =
      Number(
        listing.remainingQuantity
      );

    if (
      !Number.isFinite(
        remainingQuantity
      ) ||
      remainingQuantity <= 0
    ) {
      throw new Error(
        "This listing is no longer available."
      );
    }

    if (
      requestedQuantity >
      remainingQuantity
    ) {
      throw new Error(
        `Only ${remainingQuantity} tokens are available from this listing.`
      );
    }

    const pricePerToken =
      Number(
        listing.pricePerToken
      );

    if (
      !Number.isFinite(
        pricePerToken
      ) ||
      pricePerToken <= 0
    ) {
      throw new Error(
        "Invalid transaction amount."
      );
    }

    // =================================================
    // 5. CALCULATE TOTAL
    // =================================================
    //
    // The database remains the source of truth for the
    // persisted DECIMAL values.
    //
    // This calculation is rounded to the platform's
    // supported 8 decimal places.
    // =================================================

    const totalAmount =
      Number(
        (
          requestedQuantity *
          pricePerToken
        ).toFixed(8)
      );

    if (
      !Number.isFinite(
        totalAmount
      ) ||
      totalAmount <= 0
    ) {
      throw new Error(
        "Invalid transaction amount."
      );
    }

    // =================================================
    // 6. LOCK BUYER WALLET
    // =================================================

    const [buyerWalletRows] =
      await connection.execute(
        `
          SELECT
            id,
            userId,
            fiatBalance,
            lockedFiatBalance,
            currency,
            status

          FROM wallets

          WHERE userId = ?

          LIMIT 1

          FOR UPDATE
        `,
        [userId]
      );

    if (
      buyerWalletRows.length === 0
    ) {
      throw new Error(
        "Buyer wallet not found."
      );
    }

    const buyerWallet =
      buyerWalletRows[0];

    if (
      buyerWallet.status !==
      "active"
    ) {
      throw new Error(
        "Your wallet is not available for trading."
      );
    }

    if (
      buyerWallet.currency !==
      listing.currency
    ) {
      throw new Error(
        `Wallet currency ${buyerWallet.currency} does not match listing currency ${listing.currency}.`
      );
    }

    const buyerBalance =
      Number(
        buyerWallet.fiatBalance
      );

    if (
      !Number.isFinite(
        buyerBalance
      ) ||
      buyerBalance < totalAmount
    ) {
      throw new Error(
        "Insufficient wallet balance."
      );
    }

    // =================================================
    // 7. LOCK SELLER WALLET
    // =================================================

    const [sellerWalletRows] =
      await connection.execute(
        `
          SELECT
            id,
            userId,
            fiatBalance,
            lockedFiatBalance,
            currency,
            status

          FROM wallets

          WHERE userId = ?

          LIMIT 1

          FOR UPDATE
        `,
        [listing.sellerId]
      );

    if (
      sellerWalletRows.length === 0
    ) {
      throw new Error(
        "Seller wallet not found."
      );
    }

    const sellerWallet =
      sellerWalletRows[0];

    if (
      sellerWallet.status !==
      "active"
    ) {
      throw new Error(
        "Seller wallet is not available."
      );
    }

    if (
      sellerWallet.currency !==
      listing.currency
    ) {
      throw new Error(
        `Seller wallet currency ${sellerWallet.currency} does not match listing currency ${listing.currency}.`
      );
    }

    const sellerBalance =
      Number(
        sellerWallet.fiatBalance
      );

    if (
      !Number.isFinite(
        sellerBalance
      )
    ) {
      throw new Error(
        "Invalid seller wallet balance."
      );
    }

    // =================================================
    // 8. LOCK SELLER TOKEN HOLDING
    // =================================================
    //
    // IMPORTANT:
    //
    // The buyer is purchasing tokens reserved by the
    // listing.
    //
    // Therefore we check lockedQuantity, NOT
    // availableQuantity.
    // =================================================

    const [sellerHoldingRows] =
      await connection.execute(
        `
          SELECT
            id,
            userId,
            tokenId,
            quantity,
            lockedQuantity

          FROM token_holdings

          WHERE
            userId = ?
            AND tokenId = ?

          LIMIT 1

          FOR UPDATE
        `,
        [
          listing.sellerId,
          listing.tokenId,
        ]
      );

    if (
      sellerHoldingRows.length === 0
    ) {
      throw new Error(
        "Seller token holding not found."
      );
    }

    const sellerHolding =
      sellerHoldingRows[0];

    const sellerQuantity =
      Number(
        sellerHolding.quantity || 0
      );

    const sellerLockedQuantity =
      Number(
        sellerHolding.lockedQuantity ||
          0
      );

    if (
      sellerQuantity <
      requestedQuantity
    ) {
      throw new Error(
        "Seller no longer has enough tokens to complete this purchase."
      );
    }

    if (
      sellerLockedQuantity <
      requestedQuantity
    ) {
      throw new Error(
        "The seller's reserved token quantity is insufficient for this listing."
      );
    }

    // =================================================
    // 9. CREATE BUY ORDER
    // =================================================

    const orderReference =
      generateReference("ORD");

    const [orderResult] =
      await connection.execute(
        `
          INSERT INTO orders (
            orderReference,
            userId,
            tokenId,
            listingId,
            orderType,
            quantity,
            filledQuantity,
            pricePerToken,
            totalAmount,
            currency,
            status
          )
          VALUES (
            ?,
            ?,
            ?,
            ?,
            'buy',
            ?,
            ?,
            ?,
            ?,
            ?,
            'filled'
          )
        `,
        [
          orderReference,
          userId,
          listing.tokenId,
          listing.id,
          requestedQuantity,
          requestedQuantity,
          pricePerToken,
          totalAmount,
          listing.currency,
        ]
      );

    const buyOrderId =
      orderResult.insertId;

    // =================================================
    // 10. CREATE COMPLETED TRANSACTION
    // =================================================
    //
    // There is intentionally no seller order.
    //
    // The listing is the seller's sell-side intent.
    // =================================================

    const transactionReference =
      generateReference("TXN");

    const [transactionResult] =
      await connection.execute(
        `
          INSERT INTO transactions (
            transactionReference,
            buyerId,
            sellerId,
            tokenId,
            listingId,
            buyOrderId,
            sellOrderId,
            quantity,
            pricePerToken,
            totalAmount,
            feeAmount,
            currency,
            status
          )
          VALUES (
            ?,
            ?,
            ?,
            ?,
            ?,
            ?,
            NULL,
            ?,
            ?,
            ?,
            ?,
            ?,
            'completed'
          )
        `,
        [
          transactionReference,
          userId,
          listing.sellerId,
          listing.tokenId,
          listing.id,
          buyOrderId,
          requestedQuantity,
          pricePerToken,
          totalAmount,
          0,
          listing.currency,
        ]
      );

    const transactionId =
      transactionResult.insertId;

    // =================================================
    // 11. UPDATE BUYER WALLET
    // =================================================

    const buyerBalanceBefore =
      buyerBalance;

    const buyerBalanceAfter =
      Number(
        (
          buyerBalance -
          totalAmount
        ).toFixed(8)
      );

    if (
      buyerBalanceAfter < 0
    ) {
      throw new Error(
        "Insufficient wallet balance."
      );
    }

    await connection.execute(
      `
        UPDATE wallets

        SET
          fiatBalance = ?,
          updatedAt = CURRENT_TIMESTAMP

        WHERE
          id = ?

          AND fiatBalance >= ?
      `,
      [
        buyerBalanceAfter,
        buyerWallet.id,
        totalAmount,
      ]
    );

    // =================================================
    // 12. UPDATE SELLER WALLET
    // =================================================

    const sellerBalanceBefore =
      sellerBalance;

    const sellerBalanceAfter =
      Number(
        (
          sellerBalance +
          totalAmount
        ).toFixed(8)
      );

    await connection.execute(
      `
        UPDATE wallets

        SET
          fiatBalance = ?,
          updatedAt = CURRENT_TIMESTAMP

        WHERE id = ?
      `,
      [
        sellerBalanceAfter,
        sellerWallet.id,
      ]
    );

    // =================================================
    // 13. UPDATE / CREATE BUYER HOLDING
    // =================================================

    const [buyerHoldingRows] =
      await connection.execute(
        `
          SELECT
            id,
            quantity,
            lockedQuantity,
            averageBuyPrice,
            totalInvested

          FROM token_holdings

          WHERE
            userId = ?
            AND tokenId = ?

          LIMIT 1

          FOR UPDATE
        `,
        [
          userId,
          listing.tokenId,
        ]
      );

    if (
      buyerHoldingRows.length === 0
    ) {
      // -----------------------------------------------
      // FIRST PURCHASE
      // -----------------------------------------------

      await connection.execute(
        `
          INSERT INTO token_holdings (
            userId,
            tokenId,
            quantity,
            lockedQuantity,
            averageBuyPrice,
            totalInvested
          )
          VALUES (
            ?,
            ?,
            ?,
            0,
            ?,
            ?
          )
        `,
        [
          userId,
          listing.tokenId,
          requestedQuantity,
          pricePerToken,
          totalAmount,
        ]
      );
    } else {
      // -----------------------------------------------
      // EXISTING HOLDING
      // -----------------------------------------------

      const buyerHolding =
        buyerHoldingRows[0];

      const oldQuantity =
        Number(
          buyerHolding.quantity || 0
        );

      const oldInvested =
        Number(
          buyerHolding.totalInvested ||
            0
        );

      const newQuantity =
        oldQuantity +
        requestedQuantity;

      const newInvested =
        Number(
          (
            oldInvested +
            totalAmount
          ).toFixed(8)
        );

      const newAveragePrice =
        newQuantity > 0
          ? Number(
              (
                newInvested /
                newQuantity
              ).toFixed(8)
            )
          : pricePerToken;

      await connection.execute(
        `
          UPDATE token_holdings

          SET
            quantity = ?,
            averageBuyPrice = ?,
            totalInvested = ?,
            updatedAt = CURRENT_TIMESTAMP

          WHERE id = ?
        `,
        [
          newQuantity,
          newAveragePrice,
          newInvested,
          buyerHolding.id,
        ]
      );
    }

    // =================================================
    // 14. TRANSFER TOKENS FROM SELLER
    // =================================================
    //
    // The sold tokens leave both:
    //
    // - quantity
    // - lockedQuantity
    //
    // because the reserved tokens have now been
    // transferred to the buyer.
    // =================================================

    const newSellerQuantity =
      Number(
        (
          sellerQuantity -
          requestedQuantity
        ).toFixed(8)
      );

    const newSellerLockedQuantity =
      Number(
        (
          sellerLockedQuantity -
          requestedQuantity
        ).toFixed(8)
      );

    if (
      newSellerQuantity < 0 ||
      newSellerLockedQuantity < 0
    ) {
      throw new Error(
        "Invalid seller token balance after purchase."
      );
    }

    await connection.execute(
      `
        UPDATE token_holdings

        SET
          quantity = ?,
          lockedQuantity = ?,
          updatedAt = CURRENT_TIMESTAMP

        WHERE
          id = ?

          AND quantity >= ?

          AND lockedQuantity >= ?
      `,
      [
        newSellerQuantity,
        newSellerLockedQuantity,
        sellerHolding.id,
        requestedQuantity,
        requestedQuantity,
      ]
    );

    // =================================================
    // 15. UPDATE LISTING
    // =================================================

    const newRemainingQuantity =
      Number(
        (
          remainingQuantity -
          requestedQuantity
        ).toFixed(8)
      );

    const newListingStatus =
      newRemainingQuantity <= 0
        ? "filled"
        : "partially_filled";

    await connection.execute(
      `
        UPDATE listings

        SET
          remainingQuantity = ?,
          status = ?,
          updatedAt = CURRENT_TIMESTAMP

        WHERE
          id = ?

          AND remainingQuantity >= ?
      `,
      [
        newRemainingQuantity,
        newListingStatus,
        listing.id,
        requestedQuantity,
      ]
    );

    // =================================================
    // 16. BUYER WALLET TRANSACTION
    // =================================================

    const buyerWalletReference =
      generateReference("WAL");

    await connection.execute(
      `
        INSERT INTO wallet_transactions (
          walletId,
          userId,
          transactionReference,
          transactionType,
          amount,
          currency,
          balanceBefore,
          balanceAfter,
          status,
          description
        )
        VALUES (
          ?,
          ?,
          ?,
          'token_purchase',
          ?,
          ?,
          ?,
          ?,
          'completed',
          ?
        )
      `,
      [
        buyerWallet.id,
        userId,
        buyerWalletReference,
        totalAmount,
        listing.currency,
        buyerBalanceBefore,
        buyerBalanceAfter,
        `Purchase of ${requestedQuantity} ${listing.tokenCode} tokens`,
      ]
    );

    // =================================================
    // 17. SELLER WALLET TRANSACTION
    // =================================================

    const sellerWalletReference =
      generateReference("WAL");

    await connection.execute(
      `
        INSERT INTO wallet_transactions (
          walletId,
          userId,
          transactionReference,
          transactionType,
          amount,
          currency,
          balanceBefore,
          balanceAfter,
          status,
          description
        )
        VALUES (
          ?,
          ?,
          ?,
          'token_sale',
          ?,
          ?,
          ?,
          ?,
          'completed',
          ?
        )
      `,
      [
        sellerWallet.id,
        listing.sellerId,
        sellerWalletReference,
        totalAmount,
        listing.currency,
        sellerBalanceBefore,
        sellerBalanceAfter,
        `Sale of ${requestedQuantity} ${listing.tokenCode} tokens`,
      ]
    );

    // =================================================
    // 18. UPDATE TOKEN MARKET PRICE
    // =================================================

    await connection.execute(
      `
        UPDATE tokens

        SET
          tokenPrice = ?,
          updatedAt = CURRENT_TIMESTAMP

        WHERE id = ?
      `,
      [
        pricePerToken,
        listing.tokenId,
      ]
    );

    // =================================================
    // 19. PRICE HISTORY
    // =================================================

    await connection.execute(
      `
        INSERT INTO token_price_history (
          tokenId,
          price,
          currency,
          source,
          referenceId
        )
        VALUES (
          ?,
          ?,
          ?,
          'transaction',
          ?
        )
      `,
      [
        listing.tokenId,
        pricePerToken,
        listing.currency,
        transactionId,
      ]
    );

    // =================================================
    // 20. LEDGER - BUYER FIAT DEBIT
    // =================================================

    await connection.execute(
      `
        INSERT INTO ledger_entries (
          entryReference,
          userId,
          walletId,
          transactionId,
          entryType,
          assetType,
          amount,
          currency,
          balanceBefore,
          balanceAfter,
          description
        )
        VALUES (
          ?,
          ?,
          ?,
          ?,
          'debit',
          'fiat',
          ?,
          ?,
          ?,
          ?,
          ?
        )
      `,
      [
        generateReference("LED"),
        userId,
        buyerWallet.id,
        transactionId,
        totalAmount,
        listing.currency,
        buyerBalanceBefore,
        buyerBalanceAfter,
        `Token purchase - ${listing.tokenCode}`,
      ]
    );

    // =================================================
    // 21. LEDGER - SELLER FIAT CREDIT
    // =================================================

    await connection.execute(
      `
        INSERT INTO ledger_entries (
          entryReference,
          userId,
          walletId,
          transactionId,
          entryType,
          assetType,
          amount,
          currency,
          balanceBefore,
          balanceAfter,
          description
        )
        VALUES (
          ?,
          ?,
          ?,
          ?,
          'credit',
          'fiat',
          ?,
          ?,
          ?,
          ?,
          ?
        )
      `,
      [
        generateReference("LED"),
        listing.sellerId,
        sellerWallet.id,
        transactionId,
        totalAmount,
        listing.currency,
        sellerBalanceBefore,
        sellerBalanceAfter,
        `Token sale - ${listing.tokenCode}`,
      ]
    );

    // =================================================
    // 22. LEDGER - BUYER TOKEN CREDIT
    // =================================================

    await connection.execute(
      `
        INSERT INTO ledger_entries (
          entryReference,
          userId,
          tokenId,
          transactionId,
          entryType,
          assetType,
          amount,
          description
        )
        VALUES (
          ?,
          ?,
          ?,
          ?,
          'credit',
          'token',
          ?,
          ?
        )
      `,
      [
        generateReference("LED"),
        userId,
        listing.tokenId,
        transactionId,
        requestedQuantity,
        `Token purchase - ${listing.tokenCode}`,
      ]
    );

    // =================================================
    // 23. LEDGER - SELLER TOKEN DEBIT
    // =================================================

    await connection.execute(
      `
        INSERT INTO ledger_entries (
          entryReference,
          userId,
          tokenId,
          transactionId,
          entryType,
          assetType,
          amount,
          description
        )
        VALUES (
          ?,
          ?,
          ?,
          ?,
          'debit',
          'token',
          ?,
          ?
        )
      `,
      [
        generateReference("LED"),
        listing.sellerId,
        listing.tokenId,
        transactionId,
        requestedQuantity,
        `Token sale - ${listing.tokenCode}`,
      ]
    );

    // =================================================
    // 24. AUDIT
    // =================================================

    await connection.execute(
      `
        INSERT INTO audit_logs (
          userId,
          action,
          entityType,
          entityId,
          oldValues,
          newValues
        )
        VALUES (
          ?,
          ?,
          ?,
          ?,
          ?,
          ?
        )
      `,
      [
        userId,
        "buy_token",
        "transaction",
        transactionId,
        JSON.stringify({
          listingId:
            listing.id,

          remainingQuantity,

          buyerBalance:
            buyerBalanceBefore,

          sellerBalance:
            sellerBalanceBefore,

          sellerQuantity,

          sellerLockedQuantity,
        }),
        JSON.stringify({
          orderId:
            buyOrderId,

          quantity:
            requestedQuantity,

          totalAmount,

          remainingQuantity:
            newRemainingQuantity,

          listingStatus:
            newListingStatus,

          buyerBalance:
            buyerBalanceAfter,

          sellerBalance:
            sellerBalanceAfter,

          sellerQuantity:
            newSellerQuantity,

          sellerLockedQuantity:
            newSellerLockedQuantity,
        }),
      ]
    );

    // =================================================
    // 25. COMMIT EVERYTHING
    // =================================================

    await connection.commit();

    return {
      transactionId,
      transactionReference,

      orderId:
        buyOrderId,

      orderReference,

      listingId:
        listing.id,

      tokenId:
        listing.tokenId,

      tokenCode:
        listing.tokenCode,

      quantity:
        requestedQuantity,

      pricePerToken,

      totalAmount,

      currency:
        listing.currency,

      listingStatus:
        newListingStatus,

      remainingQuantity:
        newRemainingQuantity,

      status:
        "completed",
    };
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }
}

// =====================================================
// 9. CANCEL ORDER
// =====================================================
//
// IMPORTANT:
//
// Selling is represented by a listing, not a sell order.
//
// Successful BUY orders are immediately filled and
// therefore cannot be cancelled.
//
// This function remains available for future support
// of pending/open orders.
// =====================================================

export async function cancelOrder(
  userId,
  orderId
) {
  if (!userId) {
    throw new Error(
      "Authentication is required."
    );
  }

  if (
    !orderId ||
    !Number.isInteger(
      Number(orderId)
    )
  ) {
    throw new Error(
      "A valid order ID is required."
    );
  }

  const connection =
    await pool.getConnection();

  try {
    await connection.beginTransaction();

    // -------------------------------------------------
    // 1. LOCK ORDER
    // -------------------------------------------------

    const [orderRows] =
      await connection.execute(
        `
          SELECT
            o.id,
            o.orderReference,
            o.userId,
            o.tokenId,
            o.listingId,
            o.orderType,
            o.quantity,
            o.filledQuantity,
            o.pricePerToken,
            o.totalAmount,
            o.currency,
            o.status

          FROM orders o

          WHERE
            o.id = ?
            AND o.userId = ?

          LIMIT 1

          FOR UPDATE
        `,
        [
          orderId,
          userId,
        ]
      );

    if (orderRows.length === 0) {
      throw new Error(
        "Order not found."
      );
    }

    const order =
      orderRows[0];

    // -------------------------------------------------
    // FILLED BUY ORDERS CANNOT BE CANCELLED
    // -------------------------------------------------

    if (
      order.orderType === "buy" &&
      order.status === "filled"
    ) {
      throw new Error(
        "This order cannot be cancelled because it is already filled."
      );
    }

    if (
      order.status === "filled" ||
      order.status === "cancelled"
    ) {
      throw new Error(
        `This order cannot be cancelled because it is already ${order.status}.`
      );
    }

    if (
      order.status !== "pending" &&
      order.status !== "open" &&
      order.status !==
        "partially_filled"
    ) {
      throw new Error(
        "This order cannot be cancelled."
      );
    }

    // -------------------------------------------------
    // CURRENT IMPLEMENTATION
    // -------------------------------------------------
    //
    // Future pending/open order functionality can add
    // wallet/token reservation reversal here.
    // -------------------------------------------------

    await connection.execute(
      `
        UPDATE orders

        SET
          status = 'cancelled',
          updatedAt = CURRENT_TIMESTAMP

        WHERE id = ?
      `,
      [order.id]
    );

    // -------------------------------------------------
    // AUDIT
    // -------------------------------------------------

    await connection.execute(
      `
        INSERT INTO audit_logs (
          userId,
          action,
          entityType,
          entityId,
          oldValues,
          newValues
        )
        VALUES (
          ?,
          ?,
          ?,
          ?,
          ?,
          ?
        )
      `,
      [
        userId,
        "cancel_order",
        "order",
        order.id,
        JSON.stringify({
          status:
            order.status,

          listingId:
            order.listingId,

          orderType:
            order.orderType,
        }),
        JSON.stringify({
          status:
            "cancelled",
        }),
      ]
    );

    await connection.commit();

    return {
      orderId:
        order.id,

      orderReference:
        order.orderReference,

      status:
        "cancelled",
    };
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }
}

// ============================================================ 
// CANCEL LISTING 
// ============================================================ 
export async function cancelTradingListing(req, res) { 
    try { 
        const userId = getAuthenticatedUserId(req);

        if (!userId) 
            { return res.status(401).json({ 
                success: false, 
                message: "Authentication required.",
             });
            } 
             
             const { id } = req.params;

             const data = await cancelListing({ 
                userId, listingId: id,
            }); 
             
             return res.status(200).json({ 
                success: true, 
                message: "Listing cancelled successfully.", 
                data, 
        }); } catch (error) { 
                return handleControllerError(res, error);
    }
}

