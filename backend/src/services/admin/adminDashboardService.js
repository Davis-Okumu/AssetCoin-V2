
import pool from "../../config/database.js";

// =========================================================
// ADMIN DASHBOARD SERVICE
// =========================================================

export async function getAdminDashboard() {
  const connection = await pool.getConnection();

  try {
    // =====================================================
    // OVERVIEW
    // =====================================================

    const [
      [userStats],
      [kycStats],
      [assetStats],
      [tokenStats],
      [walletStats],
      [tradingStats],
      [workflowStats],
    ] = await Promise.all([
      // ---------------------------------------------------
      // USERS
      // ---------------------------------------------------
      connection.execute(`
        SELECT
          COUNT(*) AS totalUsers,

          SUM(
            CASE
              WHEN accountStatus = 'active'
              THEN 1
              ELSE 0
            END
          ) AS activeUsers,

          SUM(
            CASE
              WHEN accountStatus = 'suspended'
              THEN 1
              ELSE 0
            END
          ) AS suspendedUsers,

          SUM(
            CASE
              WHEN createdAt >= DATE_SUB(NOW(), INTERVAL 30 DAY)
              THEN 1
              ELSE 0
            END
          ) AS newUsersLast30Days

        FROM users
      `),

      // ---------------------------------------------------
      // KYC
      // ---------------------------------------------------
      connection.execute(`
        SELECT
          COUNT(*) AS totalKyc,

          SUM(
            CASE
              WHEN status = 'pending'
              THEN 1
              ELSE 0
            END
          ) AS pendingKyc,

          SUM(
            CASE
              WHEN status = 'under_review'
              THEN 1
              ELSE 0
            END
          ) AS underReviewKyc,

          SUM(
            CASE
              WHEN status = 'verified'
              THEN 1
              ELSE 0
            END
          ) AS verifiedKyc,

          SUM(
            CASE
              WHEN status = 'rejected'
              THEN 1
              ELSE 0
            END
          ) AS rejectedKyc

        FROM kyc_records
      `),

      // ---------------------------------------------------
      // ASSETS
      // ---------------------------------------------------
      connection.execute(`
        SELECT
          COUNT(*) AS totalAssets,

          COALESCE(
            SUM(estimatedValue),
            0
          ) AS totalAssetValue,

          SUM(
            CASE
              WHEN status = 'pending'
              THEN 1
              ELSE 0
            END
          ) AS pendingAssets,

          SUM(
            CASE
              WHEN status = 'under_review'
              THEN 1
              ELSE 0
            END
          ) AS assetsUnderReview,

          SUM(
            CASE
              WHEN status = 'changes_required'
              THEN 1
              ELSE 0
            END
          ) AS assetsChangesRequired,

          SUM(
            CASE
              WHEN status = 'approved'
              THEN 1
              ELSE 0
            END
          ) AS approvedAssets,

          SUM(
            CASE
              WHEN status = 'tokenized'
              THEN 1
              ELSE 0
            END
          ) AS tokenizedAssets,

          SUM(
            CASE
              WHEN status = 'rejected'
              THEN 1
              ELSE 0
            END
          ) AS rejectedAssets,

          SUM(
            CASE
              WHEN status = 'suspended'
              THEN 1
              ELSE 0
            END
          ) AS suspendedAssets

        FROM assets
      `),

      // ---------------------------------------------------
      // TOKENS
      // ---------------------------------------------------
      connection.execute(`
        SELECT
          COUNT(*) AS totalTokens,

          COALESCE(
            SUM(totalSupply),
            0
          ) AS totalTokenSupply,

          COALESCE(
            SUM(availableSupply),
            0
          ) AS availableTokenSupply,

          SUM(
            CASE
              WHEN status = 'active'
              THEN 1
              ELSE 0
            END
          ) AS activeTokens,

          SUM(
            CASE
              WHEN status = 'pending'
              THEN 1
              ELSE 0
            END
          ) AS pendingTokens,

          SUM(
            CASE
              WHEN status = 'paused'
              THEN 1
              ELSE 0
            END
          ) AS pausedTokens

        FROM tokens
      `),

      // ---------------------------------------------------
      // WALLETS
      // ---------------------------------------------------
      connection.execute(`
        SELECT
          COUNT(*) AS totalWallets,

          COALESCE(
            SUM(fiatBalance),
            0
          ) AS totalWalletBalance,

          COALESCE(
            SUM(lockedFiatBalance),
            0
          ) AS totalLockedWalletBalance,

          SUM(
            CASE
              WHEN status = 'active'
              THEN 1
              ELSE 0
            END
          ) AS activeWallets,

          SUM(
            CASE
              WHEN status = 'frozen'
              THEN 1
              ELSE 0
            END
          ) AS frozenWallets

        FROM wallets
      `),

      // ---------------------------------------------------
      // TRADING
      // ---------------------------------------------------
      connection.execute(`
        SELECT
          (
            SELECT COUNT(*)
            FROM listings
            WHERE status IN ('active', 'partially_filled')
          ) AS activeListings,

          (
            SELECT COUNT(*)
            FROM orders
            WHERE status IN ('pending', 'open', 'partially_filled')
          ) AS pendingOrders,

          (
            SELECT COUNT(*)
            FROM transactions
            WHERE status = 'completed'
          ) AS completedTransactions,

          (
            SELECT COALESCE(SUM(totalAmount), 0)
            FROM transactions
            WHERE status = 'completed'
          ) AS tradingVolume,

          (
            SELECT COALESCE(SUM(feeAmount), 0)
            FROM transactions
            WHERE status = 'completed'
          ) AS tradingFees,

          (
            SELECT COUNT(*)
            FROM transactions
            WHERE status = 'completed'
            AND createdAt >= DATE_SUB(NOW(), INTERVAL 30 DAY)
          ) AS transactionsLast30Days

      `),

      // ---------------------------------------------------
      // ADMIN WORKFLOW
      // ---------------------------------------------------
      connection.execute(`
        SELECT

          (
            SELECT COUNT(*)
            FROM admin_action_approvals
            WHERE status = 'pending'
          ) AS pendingApprovals,

          (
            SELECT COUNT(*)
            FROM admin_assignments
            WHERE status IN ('assigned', 'in_progress')
          ) AS activeAssignments,

          (
            SELECT COUNT(*)
            FROM support_tickets
            WHERE status IN ('open', 'in_progress', 'waiting_for_user')
          ) AS openSupportTickets,

          (
            SELECT COUNT(*)
            FROM admin_notifications
            WHERE status = 'new'
          ) AS unreadAdminNotifications
      `),
    ]);

    // =====================================================
    // ASSET ACTIVITY
    // =====================================================

    const [assetActivity] = await connection.execute(`
      SELECT
        status,
        COUNT(*) AS count
      FROM assets
      GROUP BY status
      ORDER BY count DESC
    `);

    // =====================================================
    // ASSET TYPES
    // =====================================================

    const [assetTypes] = await connection.execute(`
      SELECT
        assetType,
        COUNT(*) AS count,
        COALESCE(SUM(estimatedValue), 0) AS totalValue
      FROM assets
      GROUP BY assetType
      ORDER BY count DESC
    `);

    // =====================================================
    // KYC SUMMARY
    // =====================================================

    const [kycSummary] = await connection.execute(`
      SELECT
        status,
        COUNT(*) AS count
      FROM kyc_records
      GROUP BY status
      ORDER BY count DESC
    `);

    // =====================================================
    // RECENT TRANSACTIONS
    // =====================================================

    const [recentTransactions] = await connection.execute(`
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

        CONCAT(
          buyer.firstName,
          ' ',
          buyer.lastName
        ) AS buyerName,

        CONCAT(
          seller.firstName,
          ' ',
          seller.lastName
        ) AS sellerName,

        tok.tokenCode,
        tok.tokenName

      FROM transactions t

      INNER JOIN users buyer
        ON buyer.id = t.buyerId

      INNER JOIN users seller
        ON seller.id = t.sellerId

      INNER JOIN tokens tok
        ON tok.id = t.tokenId

      ORDER BY t.createdAt DESC

      LIMIT 10
    `);

    // =====================================================
    // RECENT ADMIN ACTIVITY
    // =====================================================

    const [adminActivity] = await connection.execute(`
      SELECT
        aal.id,
        aal.action,
        aal.module,
        aal.entityType,
        aal.entityId,
        aal.createdAt,

        CONCAT(
          staff.firstName,
          ' ',
          staff.lastName
        ) AS staffName,

        role.name AS roleName

      FROM admin_audit_logs aal

      LEFT JOIN admin_staff staff
        ON staff.id = aal.staffId

      LEFT JOIN admin_roles role
        ON role.id = staff.roleId

      ORDER BY aal.createdAt DESC

      LIMIT 10
    `);

    // =====================================================
    // RECENT ASSET ACTIVITY
    // =====================================================

    const [recentAssetActivity] = await connection.execute(`
      SELECT
        ash.id,
        ash.assetId,
        ash.previousStatus,
        ash.newStatus,
        ash.changeReason,
        ash.createdAt,

        a.assetCode,
        a.name AS assetName,
        a.assetType,

        CONCAT(
          u.firstName,
          ' ',
          u.lastName
        ) AS ownerName

      FROM asset_status_history ash

      INNER JOIN assets a
        ON a.id = ash.assetId

      INNER JOIN users u
        ON u.id = a.ownerId

      ORDER BY ash.createdAt DESC

      LIMIT 10
    `);

    // =====================================================
    // RECENT KYC ACTIVITY
    // =====================================================

    const [recentKycActivity] = await connection.execute(`
      SELECT
        k.id,
        k.userId,
        k.status,
        k.verificationMethod,
        k.submittedAt,
        k.verifiedAt,

        CONCAT(
          u.firstName,
          ' ',
          u.lastName
        ) AS userName,

        u.email

      FROM kyc_records k

      INNER JOIN users u
        ON u.id = k.userId

      ORDER BY k.submittedAt DESC

      LIMIT 10
    `);

    // =====================================================
    // DAILY TRANSACTION ACTIVITY
    // LAST 7 DAYS
    // =====================================================

    const [transactionActivity] = await connection.execute(`
      SELECT
        DATE(createdAt) AS date,

        COUNT(*) AS transactionCount,

        COALESCE(
          SUM(
            CASE
              WHEN status = 'completed'
              THEN totalAmount
              ELSE 0
            END
          ),
          0
        ) AS volume

      FROM transactions

      WHERE createdAt >= DATE_SUB(
        CURDATE(),
        INTERVAL 6 DAY
      )

      GROUP BY DATE(createdAt)

      ORDER BY date ASC
    `);

    // =====================================================
    // DAILY USER REGISTRATIONS
    // LAST 7 DAYS
    // =====================================================

    const [userRegistrationActivity] = await connection.execute(`
      SELECT
        DATE(createdAt) AS date,
        COUNT(*) AS count

      FROM users

      WHERE createdAt >= DATE_SUB(
        CURDATE(),
        INTERVAL 6 DAY
      )

      GROUP BY DATE(createdAt)

      ORDER BY date ASC
    `);

    // =====================================================
    // NORMALIZE NUMBERS
    // =====================================================

    const numericFields = new Set([
      "totalUsers",
      "activeUsers",
      "suspendedUsers",
      "newUsersLast30Days",

      "totalKyc",
      "pendingKyc",
      "underReviewKyc",
      "verifiedKyc",
      "rejectedKyc",

      "totalAssets",
      "totalAssetValue",
      "pendingAssets",
      "assetsUnderReview",
      "assetsChangesRequired",
      "approvedAssets",
      "tokenizedAssets",
      "rejectedAssets",
      "suspendedAssets",

      "totalTokens",
      "totalTokenSupply",
      "availableTokenSupply",
      "activeTokens",
      "pendingTokens",
      "pausedTokens",

      "totalWallets",
      "totalWalletBalance",
      "totalLockedWalletBalance",
      "activeWallets",
      "frozenWallets",

      "activeListings",
      "pendingOrders",
      "completedTransactions",
      "tradingVolume",
      "tradingFees",
      "transactionsLast30Days",

      "pendingApprovals",
      "activeAssignments",
      "openSupportTickets",
      "unreadAdminNotifications",

      "count",
      "totalValue",
      "quantity",
      "pricePerToken",
      "totalAmount",
      "feeAmount",
      "volume",
      "transactionCount",
    ]);

    const normalizeRow = (row) => {
      if (!row) {
        return {};
      }

      const normalized = {};

      for (const [key, value] of Object.entries(row)) {
        if (
          numericFields.has(key) &&
          value !== null &&
          value !== undefined
        ) {
          const number = Number(value);

          normalized[key] = Number.isFinite(number)
              ? number
              : 0;
        } else {
          normalized[key] = value;
        }
      }

      return normalized;
    };

    const normalizeRows = (rows) => {
      return rows.map(normalizeRow);
    };

    // =====================================================
    // RETURN DASHBOARD
    // =====================================================

    return {
      overview: {
        ...normalizeRow(userStats[0]),
        ...normalizeRow(kycStats[0]),
        ...normalizeRow(assetStats[0]),
        ...normalizeRow(tokenStats[0]),
        ...normalizeRow(walletStats[0]),
        ...normalizeRow(tradingStats[0]),
        ...normalizeRow(workflowStats[0]),
      },

      assetActivity: normalizeRows(assetActivity),

      assetTypes: normalizeRows(assetTypes),

      kycSummary: normalizeRows(kycSummary),

      recentTransactions: normalizeRows(
        recentTransactions,
      ),

      adminActivity: normalizeRows(
        adminActivity,
      ),

      recentAssetActivity: normalizeRows(
        recentAssetActivity,
      ),

      recentKycActivity: normalizeRows(
        recentKycActivity,
      ),

      transactionActivity: normalizeRows(
        transactionActivity,
      ),

      userRegistrationActivity: normalizeRows(
        userRegistrationActivity,
      ),
    };
  } finally {
    connection.release();
  }
}
