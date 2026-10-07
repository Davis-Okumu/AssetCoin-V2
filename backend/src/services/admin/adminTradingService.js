import pool from "../../config/database.js";

function normalizePagination(page, limit) {
    const parsedPage = Number.parseInt(page, 10);
    const parsedLimit = Number.parseInt(limit, 10);

    const currentPage =
        Number.isFinite(parsedPage) && parsedPage > 0
            ? parsedPage
            : 1;

    const pageSize =
        Number.isFinite(parsedLimit) &&
            parsedLimit > 0 &&
            parsedLimit <= 100
            ? parsedLimit
            : 20;

    return {
        page: currentPage,
        limit: pageSize,
        offset: (currentPage - 1) * pageSize,
    };
}

function normalizeSearch(value) {
    return String(value ?? "").trim();
}

function normalizeStatus(value) {
    return String(value ?? "").trim();
}

function normalizeNumber(value) {
    const number = Number(value);

    return Number.isFinite(number) ? number : 0;
}

/**
 * ============================================================
 * ADMIN TRADING OVERVIEW
 * ============================================================
 */

export async function getTradingOverview() {
    const connection = await pool.getConnection();

    try {
        const [
            [listingStats],
            [orderStats],
            [tradeStats],
            [disputeStats],
            [suspendedStats],
            [recentTrades],
            [recentDisputes],
        ] = await Promise.all([
            connection.query(`
        SELECT
          COUNT(*) AS totalListings,
          SUM(
            CASE
              WHEN status IN ('active', 'partially_filled')
              THEN 1
              ELSE 0
            END
          ) AS activeListings,
          SUM(
            CASE
              WHEN status = 'suspended'
              THEN 1
              ELSE 0
            END
          ) AS suspendedListings,
          SUM(
            CASE
              WHEN status = 'filled'
              THEN 1
              ELSE 0
            END
          ) AS filledListings
        FROM listings
      `),

            connection.query(`
        SELECT
          COUNT(*) AS totalOrders,
          SUM(
            CASE
              WHEN status IN ('pending', 'open', 'partially_filled')
              THEN 1
              ELSE 0
            END
          ) AS openOrders,
          SUM(
            CASE
              WHEN status = 'filled'
              THEN 1
              ELSE 0
            END
          ) AS completedOrders,
          SUM(
            CASE
              WHEN status = 'cancelled'
              THEN 1
              ELSE 0
            END
          ) AS cancelledOrders
        FROM orders
      `),

            connection.query(`
        SELECT
          COUNT(*) AS totalTrades,
          COALESCE(
            SUM(
              CASE
                WHEN status = 'completed'
                THEN 1
                ELSE 0
              END
            ),
            0
          ) AS completedTrades,
          COALESCE(
            SUM(
              CASE
                WHEN status = 'completed'
                THEN totalAmount
                ELSE 0
              END
            ),
            0
          ) AS completedTradeVolume,
          COALESCE(
            SUM(
              CASE
                WHEN status = 'completed'
                THEN feeAmount
                ELSE 0
              END
            ),
            0
          ) AS tradingFees
        FROM transactions
      `),

            connection.query(`
        SELECT
          COUNT(*) AS totalDisputes,
          SUM(
            CASE
              WHEN status IN (
                'open',
                'under_review',
                'awaiting_information'
              )
              THEN 1
              ELSE 0
            END
          ) AS openDisputes,
          SUM(
            CASE
              WHEN status = 'resolved'
              THEN 1
              ELSE 0
            END
          ) AS resolvedDisputes,
          SUM(
            CASE
              WHEN status = 'rejected'
              THEN 1
              ELSE 0
            END
          ) AS rejectedDisputes
        FROM trading_disputes
      `),

            connection.query(`
        SELECT
          COUNT(*) AS suspendedListings
        FROM listings
        WHERE status = 'suspended'
      `),

            connection.query(`
        SELECT
          t.id,
          t.transactionReference,
          t.quantity,
          t.pricePerToken,
          t.totalAmount,
          t.feeAmount,
          t.currency,
          t.status,
          t.createdAt,

          tok.id AS tokenId,
          tok.tokenName,
          tok.tokenCode,

          a.id AS assetId,
          a.name AS assetName,
          a.assetType,

          buyer.id AS buyerId,
          buyer.firstName AS buyerFirstName,
          buyer.lastName AS buyerLastName,

          seller.id AS sellerId,
          seller.firstName AS sellerFirstName,
          seller.lastName AS sellerLastName

        FROM transactions t

        INNER JOIN tokens tok
          ON tok.id = t.tokenId

        INNER JOIN assets a
          ON a.id = tok.assetId

        INNER JOIN users buyer
          ON buyer.id = t.buyerId

        INNER JOIN users seller
          ON seller.id = t.sellerId

        ORDER BY t.createdAt DESC

        LIMIT 10
      `),

            connection.query(`
        SELECT
          d.id,
          d.disputeReference,
          d.disputeType,
          d.priority,
          d.status,
          d.reason,
          d.createdAt,

          d.transactionId,
          d.orderId,
          d.listingId,

          raised.id AS raisedById,
          raised.firstName AS raisedByFirstName,
          raised.lastName AS raisedByLastName,

          assigned.id AS assignedToId,
          assigned.firstName AS assignedToFirstName,
          assigned.lastName AS assignedToLastName

        FROM trading_disputes d

        INNER JOIN users raised
          ON raised.id = d.raisedBy

        LEFT JOIN users assigned
          ON assigned.id = d.assignedTo

        ORDER BY d.createdAt DESC

        LIMIT 10
      `),
        ]);

        return {
            listings: {
                total: normalizeNumber(listingStats[0]?.totalListings),
                active: normalizeNumber(listingStats[0]?.activeListings),
                suspended: normalizeNumber(listingStats[0]?.suspendedListings),
                filled: normalizeNumber(listingStats[0]?.filledListings),
            },

            orders: {
                total: normalizeNumber(orderStats[0]?.totalOrders),
                open: normalizeNumber(orderStats[0]?.openOrders),
                completed: normalizeNumber(orderStats[0]?.completedOrders),
                cancelled: normalizeNumber(orderStats[0]?.cancelledOrders),
            },

            trades: {
                total: normalizeNumber(tradeStats[0]?.totalTrades),
                completed: normalizeNumber(tradeStats[0]?.completedTrades),
                volume: tradeStats[0]?.completedTradeVolume ?? "0.00",
                fees: tradeStats[0]?.tradingFees ?? "0.00",
            },

            disputes: {
                total: normalizeNumber(disputeStats[0]?.totalDisputes),
                open: normalizeNumber(disputeStats[0]?.openDisputes),
                resolved: normalizeNumber(disputeStats[0]?.resolvedDisputes),
                rejected: normalizeNumber(disputeStats[0]?.rejectedDisputes),
            },

            suspendedListings: normalizeNumber(
                suspendedStats[0]?.suspendedListings
            ),

            recentTrades,
            recentDisputes,
        };
    } finally {
        connection.release();
    }
}

/**
 * ============================================================
 * LISTINGS
 * ============================================================
 */

export async function getAdminListings({
    search = "",
    status = "",
    listingType = "",
    page = 1,
    limit = 20,
}) {
    const connection = await pool.getConnection();

    try {
        const pagination = normalizePagination(page, limit);
        const normalizedSearch = normalizeSearch(search);
        const normalizedStatus = normalizeStatus(status);
        const normalizedListingType = normalizeStatus(listingType);

        const conditions = [];
        const params = [];

        if (normalizedSearch) {
            conditions.push(`
        (
          a.name LIKE ?
          OR a.assetCode LIKE ?
          OR tok.tokenName LIKE ?
          OR tok.tokenCode LIKE ?
          OR CONCAT(seller.firstName, ' ', seller.lastName) LIKE ?
          OR seller.email LIKE ?
        )
      `);

            const searchValue = `%${normalizedSearch}%`;

            params.push(
                searchValue,
                searchValue,
                searchValue,
                searchValue,
                searchValue,
                searchValue
            );
        }

        if (normalizedStatus) {
            conditions.push(`l.status = ?`);
            params.push(normalizedStatus);
        }

        if (normalizedListingType) {
            conditions.push(`l.listingType = ?`);
            params.push(normalizedListingType);
        }

        const whereClause =
            conditions.length > 0
                ? `WHERE ${conditions.join(" AND ")}`
                : "";

        const [countRows] = await connection.query(
            `
        SELECT COUNT(*) AS total
        FROM listings l

        INNER JOIN tokens tok
          ON tok.id = l.tokenId

        INNER JOIN assets a
          ON a.id = tok.assetId

        INNER JOIN users seller
          ON seller.id = l.sellerId

        ${whereClause}
      `,
            params
        );

        const [rows] = await connection.query(
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

          tok.tokenName,
          tok.tokenCode,
          tok.status AS tokenStatus,

          a.id AS assetId,
          a.name AS assetName,
          a.assetCode,
          a.assetType,
          a.status AS assetStatus,

          seller.firstName AS sellerFirstName,
          seller.lastName AS sellerLastName,
          seller.email AS sellerEmail

        FROM listings l

        INNER JOIN tokens tok
          ON tok.id = l.tokenId

        INNER JOIN assets a
          ON a.id = tok.assetId

        INNER JOIN users seller
          ON seller.id = l.sellerId

        ${whereClause}

        ORDER BY l.createdAt DESC

        LIMIT ? OFFSET ?
      `,
            [...params, pagination.limit, pagination.offset]
        );

        return {
            listings: rows,
            pagination: {
                page: pagination.page,
                limit: pagination.limit,
                total: normalizeNumber(countRows[0]?.total),
                totalPages: Math.ceil(
                    normalizeNumber(countRows[0]?.total) /
                    pagination.limit
                ),
            },
        };
    } finally {
        connection.release();
    }
}

export async function getAdminListingById(listingId) {
    const connection = await pool.getConnection();

    try {
        const [rows] = await connection.query(
            `
        SELECT
          l.*,

          tok.tokenName,
          tok.tokenCode,
          tok.status AS tokenStatus,
          tok.totalSupply,
          tok.availableSupply,

          a.name AS assetName,
          a.assetCode,
          a.assetType,
          a.status AS assetStatus,

          seller.id AS sellerId,
          seller.firstName AS sellerFirstName,
          seller.lastName AS sellerLastName,
          seller.email AS sellerEmail,
          seller.phone AS sellerPhone

        FROM listings l

        INNER JOIN tokens tok
          ON tok.id = l.tokenId

        INNER JOIN assets a
          ON a.id = tok.assetId

        INNER JOIN users seller
          ON seller.id = l.sellerId

        WHERE l.id = ?

        LIMIT 1
      `,
            [listingId]
        );

        return rows[0] ?? null;
    } finally {
        connection.release();
    }
}

/**
 * ============================================================
 * SUSPEND / REACTIVATE LISTING
 * ============================================================
 */

export async function suspendListing(
    listingId,
    adminId,
    reason
) {
    const connection = await pool.getConnection();

    try {
        await connection.beginTransaction();

        const [rows] = await connection.query(
            `
        SELECT
          id,
          status
        FROM listings
        WHERE id = ?
        FOR UPDATE
      `,
            [listingId]
        );

        if (!rows.length) {
            const error = new Error("Listing not found.");
            error.code = "LISTING_NOT_FOUND";
            throw error;
        }

        const listing = rows[0];

        if (listing.status === "suspended") {
            const error = new Error(
                "Listing is already suspended."
            );
            error.code = "LISTING_ALREADY_SUSPENDED";
            throw error;
        }

        await connection.query(
            `
        UPDATE listings
        SET
          status = 'suspended',
          updatedAt = CURRENT_TIMESTAMP
        WHERE id = ?
      `,
            [listingId]
        );

        await connection.query(
            `
        INSERT INTO audit_logs (
          userId,
          action,
          entityType,
          entityId,
          details,
          createdAt
        )
        VALUES (?, ?, ?, ?, ?, CURRENT_TIMESTAMP)
      `,
            [
                adminId,
                "admin_trading_listing_suspended",
                "listing",
                listingId,
                JSON.stringify({
                    reason: reason || null,
                }),
            ]
        );

        await connection.commit();

        return getAdminListingById(listingId);
    } catch (error) {
        await connection.rollback();
        throw error;
    } finally {
        connection.release();
    }
}

export async function reactivateListing(
    listingId,
    adminId,
    reason
) {
    const connection = await pool.getConnection();

    try {
        await connection.beginTransaction();

        const [rows] = await connection.query(
            `
        SELECT
          id,
          status,
          remainingQuantity,
          expiresAt
        FROM listings
        WHERE id = ?
        FOR UPDATE
      `,
            [listingId]
        );

        if (!rows.length) {
            const error = new Error("Listing not found.");
            error.code = "LISTING_NOT_FOUND";
            throw error;
        }

        const listing = rows[0];

        if (listing.status !== "suspended") {
            const error = new Error(
                "Only suspended listings can be reactivated."
            );
            error.code = "LISTING_NOT_SUSPENDED";
            throw error;
        }

        if (Number(listing.remainingQuantity) <= 0) {
            const error = new Error(
                "Listing has no remaining quantity."
            );
            error.code = "LISTING_EMPTY";
            throw error;
        }

        if (
            listing.expiresAt &&
            new Date(listing.expiresAt) <= new Date()
        ) {
            const error = new Error(
                "Expired listings cannot be reactivated."
            );
            error.code = "LISTING_EXPIRED";
            throw error;
        }

        await connection.query(
            `
        UPDATE listings
        SET
          status = 'active',
          updatedAt = CURRENT_TIMESTAMP
        WHERE id = ?
      `,
            [listingId]
        );

        await connection.query(
            `
        INSERT INTO audit_logs (
          userId,
          action,
          entityType,
          entityId,
          details,
          createdAt
        )
        VALUES (?, ?, ?, ?, ?, CURRENT_TIMESTAMP)
      `,
            [
                adminId,
                "admin_trading_listing_reactivated",
                "listing",
                listingId,
                JSON.stringify({
                    reason: reason || null,
                }),
            ]
        );

        await connection.commit();

        return getAdminListingById(listingId);
    } catch (error) {
        await connection.rollback();
        throw error;
    } finally {
        connection.release();
    }
}

/**
 * ============================================================
 * ORDERS
 * ============================================================
 */

export async function getAdminOrders({
    search = "",
    status = "",
    orderType = "",
    page = 1,
    limit = 20,
}) {
    const connection = await pool.getConnection();

    try {
        const pagination = normalizePagination(page, limit);
        const normalizedSearch = normalizeSearch(search);
        const normalizedStatus = normalizeStatus(status);
        const normalizedOrderType = normalizeStatus(orderType);

        const conditions = [];
        const params = [];

        if (normalizedSearch) {
            conditions.push(`
        (
          o.orderReference LIKE ?
          OR u.email LIKE ?
          OR CONCAT(u.firstName, ' ', u.lastName) LIKE ?
          OR tok.tokenName LIKE ?
          OR tok.tokenCode LIKE ?
        )
      `);

            const value = `%${normalizedSearch}%`;

            params.push(
                value,
                value,
                value,
                value,
                value
            );
        }

        if (normalizedStatus) {
            conditions.push(`o.status = ?`);
            params.push(normalizedStatus);
        }

        if (normalizedOrderType) {
            conditions.push(`o.orderType = ?`);
            params.push(normalizedOrderType);
        }

        const whereClause =
            conditions.length > 0
                ? `WHERE ${conditions.join(" AND ")}`
                : "";

        const [countRows] = await connection.query(
            `
        SELECT COUNT(*) AS total
        FROM orders o

        INNER JOIN users u
          ON u.id = o.userId

        INNER JOIN tokens tok
          ON tok.id = o.tokenId

        ${whereClause}
      `,
            params
        );

        const [rows] = await connection.query(
            `
        SELECT
          o.*,

          u.firstName,
          u.lastName,
          u.email,

          tok.tokenName,
          tok.tokenCode,

          a.name AS assetName,
          a.assetCode

        FROM orders o

        INNER JOIN users u
          ON u.id = o.userId

        INNER JOIN tokens tok
          ON tok.id = o.tokenId

        INNER JOIN assets a
          ON a.id = tok.assetId

        ${whereClause}

        ORDER BY o.createdAt DESC

        LIMIT ? OFFSET ?
      `,
            [...params, pagination.limit, pagination.offset]
        );

        return {
            orders: rows,
            pagination: {
                page: pagination.page,
                limit: pagination.limit,
                total: normalizeNumber(countRows[0]?.total),
                totalPages: Math.ceil(
                    normalizeNumber(countRows[0]?.total) /
                    pagination.limit
                ),
            },
        };
    } finally {
        connection.release();
    }
}

export async function getAdminOrderById(orderId) {
    const connection = await pool.getConnection();

    try {
        const [rows] = await connection.query(
            `
        SELECT
          o.*,

          u.firstName,
          u.lastName,
          u.email,
          u.phone,

          tok.tokenName,
          tok.tokenCode,

          a.name AS assetName,
          a.assetCode,
          a.assetType,

          l.status AS listingStatus

        FROM orders o

        INNER JOIN users u
          ON u.id = o.userId

        INNER JOIN tokens tok
          ON tok.id = o.tokenId

        INNER JOIN assets a
          ON a.id = tok.assetId

        LEFT JOIN listings l
          ON l.id = o.listingId

        WHERE o.id = ?

        LIMIT 1
      `,
            [orderId]
        );

        return rows[0] ?? null;
    } finally {
        connection.release();
    }
}

/**
 * ============================================================
 * COMPLETED TRADES / TRANSACTIONS
 * ============================================================
 */

export async function getAdminTrades({
    search = "",
    status = "completed",
    page = 1,
    limit = 20,
}) {
    const connection = await pool.getConnection();

    try {
        const pagination = normalizePagination(page, limit);
        const normalizedSearch = normalizeSearch(search);
        const normalizedStatus = normalizeStatus(status);

        const conditions = [];
        const params = [];

        if (normalizedSearch) {
            conditions.push(`
        (
          t.transactionReference LIKE ?
          OR buyer.email LIKE ?
          OR seller.email LIKE ?
          OR tok.tokenName LIKE ?
          OR tok.tokenCode LIKE ?
          OR a.name LIKE ?
          OR a.assetCode LIKE ?
        )
      `);

            const value = `%${normalizedSearch}%`;

            params.push(
                value,
                value,
                value,
                value,
                value,
                value,
                value
            );
        }

        if (normalizedStatus) {
            conditions.push(`t.status = ?`);
            params.push(normalizedStatus);
        }

        const whereClause =
            conditions.length > 0
                ? `WHERE ${conditions.join(" AND ")}`
                : "";

        const [countRows] = await connection.query(
            `
        SELECT COUNT(*) AS total
        FROM transactions t

        INNER JOIN users buyer
          ON buyer.id = t.buyerId

        INNER JOIN users seller
          ON seller.id = t.sellerId

        INNER JOIN tokens tok
          ON tok.id = t.tokenId

        INNER JOIN assets a
          ON a.id = tok.assetId

        ${whereClause}
      `,
            params
        );

        const [rows] = await connection.query(
            `
        SELECT
          t.*,

          buyer.firstName AS buyerFirstName,
          buyer.lastName AS buyerLastName,
          buyer.email AS buyerEmail,

          seller.firstName AS sellerFirstName,
          seller.lastName AS sellerLastName,
          seller.email AS sellerEmail,

          tok.tokenName,
          tok.tokenCode,

          a.id AS assetId,
          a.name AS assetName,
          a.assetCode,
          a.assetType

        FROM transactions t

        INNER JOIN users buyer
          ON buyer.id = t.buyerId

        INNER JOIN users seller
          ON seller.id = t.sellerId

        INNER JOIN tokens tok
          ON tok.id = t.tokenId

        INNER JOIN assets a
          ON a.id = tok.assetId

        ${whereClause}

        ORDER BY t.createdAt DESC

        LIMIT ? OFFSET ?
      `,
            [...params, pagination.limit, pagination.offset]
        );

        return {
            trades: rows,
            pagination: {
                page: pagination.page,
                limit: pagination.limit,
                total: normalizeNumber(countRows[0]?.total),
                totalPages: Math.ceil(
                    normalizeNumber(countRows[0]?.total) /
                    pagination.limit
                ),
            },
        };
    } finally {
        connection.release();
    }
}

export async function getAdminTradeById(transactionId) {
    const connection = await pool.getConnection();

    try {
        const [rows] = await connection.query(
            `
        SELECT
          t.*,

          buyer.firstName AS buyerFirstName,
          buyer.lastName AS buyerLastName,
          buyer.email AS buyerEmail,
          buyer.phone AS buyerPhone,

          seller.firstName AS sellerFirstName,
          seller.lastName AS sellerLastName,
          seller.email AS sellerEmail,
          seller.phone AS sellerPhone,

          tok.tokenName,
          tok.tokenCode,

          a.name AS assetName,
          a.assetCode,
          a.assetType

        FROM transactions t

        INNER JOIN users buyer
          ON buyer.id = t.buyerId

        INNER JOIN users seller
          ON seller.id = t.sellerId

        INNER JOIN tokens tok
          ON tok.id = t.tokenId

        INNER JOIN assets a
          ON a.id = tok.assetId

        WHERE t.id = ?

        LIMIT 1
      `,
            [transactionId]
        );

        return rows[0] ?? null;
    } finally {
        connection.release();
    }
}

/**
 * ============================================================
 * DISPUTES
 * ============================================================
 */

export async function getAdminDisputes({
    search = "",
    status = "",
    priority = "",
    page = 1,
    limit = 20,
}) {
    const connection = await pool.getConnection();

    try {
        const pagination = normalizePagination(page, limit);

        const normalizedSearch = normalizeSearch(search);
        const normalizedStatus = normalizeStatus(status);
        const normalizedPriority = normalizeStatus(priority);

        const conditions = [];
        const params = [];

        if (normalizedSearch) {
            conditions.push(`
        (
          d.disputeReference LIKE ?
          OR d.reason LIKE ?
          OR raised.email LIKE ?
          OR CONCAT(
            raised.firstName,
            ' ',
            raised.lastName
          ) LIKE ?
        )
      `);

            const value = `%${normalizedSearch}%`;

            params.push(
                value,
                value,
                value,
                value
            );
        }

        if (normalizedStatus) {
            conditions.push(`d.status = ?`);
            params.push(normalizedStatus);
        }

        if (normalizedPriority) {
            conditions.push(`d.priority = ?`);
            params.push(normalizedPriority);
        }

        const whereClause =
            conditions.length > 0
                ? `WHERE ${conditions.join(" AND ")}`
                : "";

        const [countRows] = await connection.query(
            `
        SELECT COUNT(*) AS total
        FROM trading_disputes d

        INNER JOIN users raised
          ON raised.id = d.raisedBy

        ${whereClause}
      `,
            params
        );

        const [rows] = await connection.query(
            `
        SELECT
          d.*,

          raised.firstName AS raisedByFirstName,
          raised.lastName AS raisedByLastName,
          raised.email AS raisedByEmail,

          againstUser.firstName AS againstUserFirstName,
          againstUser.lastName AS againstUserLastName,
          againstUser.email AS againstUserEmail,

          assigned.firstName AS assignedToFirstName,
          assigned.lastName AS assignedToLastName

        FROM trading_disputes d

        INNER JOIN users raised
          ON raised.id = d.raisedBy

        LEFT JOIN users againstUser
          ON againstUser.id = d.againstUserId

        LEFT JOIN users assigned
          ON assigned.id = d.assignedTo

        ${whereClause}

        ORDER BY
          CASE d.priority
            WHEN 'critical' THEN 1
            WHEN 'high' THEN 2
            WHEN 'normal' THEN 3
            ELSE 4
          END,
          d.createdAt DESC

        LIMIT ? OFFSET ?
      `,
            [...params, pagination.limit, pagination.offset]
        );

        return {
            disputes: rows,
            pagination: {
                page: pagination.page,
                limit: pagination.limit,
                total: normalizeNumber(countRows[0]?.total),
                totalPages: Math.ceil(
                    normalizeNumber(countRows[0]?.total) /
                    pagination.limit
                ),
            },
        };
    } finally {
        connection.release();
    }
}

export async function getAdminDisputeById(disputeId) {
    const connection = await pool.getConnection();

    try {
        const [rows] = await connection.query(
            `
        SELECT
          d.*,

          raised.firstName AS raisedByFirstName,
          raised.lastName AS raisedByLastName,
          raised.email AS raisedByEmail,
          raised.phone AS raisedByPhone,

          againstUser.firstName AS againstUserFirstName,
          againstUser.lastName AS againstUserLastName,
          againstUser.email AS againstUserEmail,

          assigned.firstName AS assignedToFirstName,
          assigned.lastName AS assignedToLastName

        FROM trading_disputes d

        INNER JOIN users raised
          ON raised.id = d.raisedBy

        LEFT JOIN users againstUser
          ON againstUser.id = d.againstUserId

        LEFT JOIN users assigned
          ON assigned.id = d.assignedTo

        WHERE d.id = ?

        LIMIT 1
      `,
            [disputeId]
        );

        return rows[0] ?? null;
    } finally {
        connection.release();
    }
}

function createDisputeReference() {
    const timestamp = Date.now();

    return `DSP-${timestamp}`;
}

export async function createTradingDispute({
    adminId,
    transactionId = null,
    orderId = null,
    listingId = null,
    raisedBy,
    againstUserId = null,
    disputeType = "trade",
    priority = "normal",
    reason,
    description = null,
}) {
    const connection = await pool.getConnection();

    try {
        await connection.beginTransaction();

        const disputeReference = createDisputeReference();

        const [result] = await connection.query(
            `
        INSERT INTO trading_disputes (
          disputeReference,
          transactionId,
          orderId,
          listingId,
          raisedBy,
          againstUserId,
          disputeType,
          priority,
          status,
          reason,
          description,
          createdAt,
          updatedAt
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'open', ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
      `,
            [
                disputeReference,
                transactionId,
                orderId,
                listingId,
                raisedBy,
                againstUserId,
                disputeType,
                priority,
                reason,
                description,
            ]
        );

        await connection.query(
            `
        INSERT INTO audit_logs (
          userId,
          action,
          entityType,
          entityId,
          details,
          createdAt
        )
        VALUES (?, ?, ?, ?, ?, CURRENT_TIMESTAMP)
      `,
            [
                adminId,
                "admin_trading_dispute_created",
                "trading_dispute",
                result.insertId,
                JSON.stringify({
                    disputeReference,
                    transactionId,
                    orderId,
                    listingId,
                    raisedBy,
                    againstUserId,
                    disputeType,
                    priority,
                }),
            ]
        );

        await connection.commit();

        return getAdminDisputeById(result.insertId);
    } catch (error) {
        await connection.rollback();
        throw error;
    } finally {
        connection.release();
    }
}

export async function assignTradingDispute(
    disputeId,
    assignedTo,
    adminId
) {
    const connection = await pool.getConnection();

    try {
        await connection.beginTransaction();

        const [rows] = await connection.query(
            `
        SELECT id, status
        FROM trading_disputes
        WHERE id = ?
        FOR UPDATE
      `,
            [disputeId]
        );

        if (!rows.length) {
            const error = new Error(
                "Dispute not found."
            );
            error.code = "DISPUTE_NOT_FOUND";
            throw error;
        }

        await connection.query(
            `
        UPDATE trading_disputes
        SET
          assignedTo = ?,
          status = CASE
            WHEN status = 'open'
            THEN 'under_review'
            ELSE status
          END,
          updatedAt = CURRENT_TIMESTAMP
        WHERE id = ?
      `,
            [assignedTo, disputeId]
        );

        await connection.query(
            `
        INSERT INTO audit_logs (
          userId,
          action,
          entityType,
          entityId,
          details,
          createdAt
        )
        VALUES (?, ?, ?, ?, ?, CURRENT_TIMESTAMP)
      `,
            [
                adminId,
                "admin_trading_dispute_assigned",
                "trading_dispute",
                disputeId,
                JSON.stringify({
                    assignedTo,
                }),
            ]
        );

        await connection.commit();

        return getAdminDisputeById(disputeId);
    } catch (error) {
        await connection.rollback();
        throw error;
    } finally {
        connection.release();
    }
}

export async function updateTradingDispute(
    disputeId,
    {
        status,
        priority,
        resolutionNotes,
    },
    adminId
) {
    const connection = await pool.getConnection();

    try {
        await connection.beginTransaction();

        const [rows] = await connection.query(
            `
        SELECT
          id,
          status AS currentStatus
        FROM trading_disputes
        WHERE id = ?
        FOR UPDATE
      `,
            [disputeId]
        );

        if (!rows.length) {
            const error = new Error(
                "Dispute not found."
            );
            error.code = "DISPUTE_NOT_FOUND";
            throw error;
        }

        const allowedStatuses = [
            "open",
            "under_review",
            "awaiting_information",
            "resolved",
            "rejected",
            "closed",
        ];

        if (
            status !== undefined &&
            status !== null &&
            !allowedStatuses.includes(status)
        ) {
            const error = new Error(
                "Invalid dispute status."
            );
            error.code = "INVALID_DISPUTE_STATUS";
            throw error;
        }

        const allowedPriorities = [
            "low",
            "normal",
            "high",
            "critical",
        ];

        if (
            priority !== undefined &&
            priority !== null &&
            !allowedPriorities.includes(priority)
        ) {
            const error = new Error(
                "Invalid dispute priority."
            );
            error.code = "INVALID_DISPUTE_PRIORITY";
            throw error;
        }

        const updates = [];
        const params = [];

        if (status !== undefined) {
            updates.push("status = ?");
            params.push(status);
        }

        if (priority !== undefined) {
            updates.push("priority = ?");
            params.push(priority);
        }

        if (resolutionNotes !== undefined) {
            updates.push("resolutionNotes = ?");
            params.push(resolutionNotes);
        }

        if (
            status === "resolved" ||
            status === "rejected" ||
            status === "closed"
        ) {
            updates.push("resolvedBy = ?");
            params.push(adminId);

            updates.push(
                "resolvedAt = CURRENT_TIMESTAMP"
            );
        }

        if (!updates.length) {
            return getAdminDisputeById(disputeId);
        }

        updates.push(
            "updatedAt = CURRENT_TIMESTAMP"
        );

        params.push(disputeId);

        await connection.query(
            `
        UPDATE trading_disputes
        SET ${updates.join(", ")}
        WHERE id = ?
      `,
            params
        );

        await connection.query(
            `
        INSERT INTO audit_logs (
          userId,
          action,
          entityType,
          entityId,
          details,
          createdAt
        )
        VALUES (?, ?, ?, ?, ?, CURRENT_TIMESTAMP)
      `,
            [
                adminId,
                "admin_trading_dispute_updated",
                "trading_dispute",
                disputeId,
                JSON.stringify({
                    status,
                    priority,
                    resolutionNotes,
                }),
            ]
        );

        await connection.commit();

        return getAdminDisputeById(disputeId);
    } catch (error) {
        await connection.rollback();
        throw error;
    } finally {
        connection.release();
    }
}