
import pool from "../config/database.js";

export async function getHomeSummary(userId) {
  // 1. Retrieve the user's wallet.
  const [wallets] = await pool.execute(
    `SELECT
      fiatBalance,
      currency
    FROM wallets
    WHERE userId = ?
    LIMIT 1`,
    [userId]
  );

  const fiatBalance = Number(wallets[0]?.fiatBalance ?? 0);
  const currency = wallets[0]?.currency ?? "KES";

  // 2. Retrieve the user's token holdings and their current value.
  const [holdings] = await pool.execute(
    `SELECT
      COALESCE(SUM(th.quantity), 0) AS tokenBalance,
      COALESCE(
        SUM(th.quantity * t.tokenPrice),
        0
      ) AS tokenValue
    FROM token_holdings th
    INNER JOIN tokens t
      ON t.id = th.tokenId
    WHERE th.userId = ?
      AND t.currency = ?`,
    [userId, currency]
  );

  const tokenBalance = Number(holdings[0]?.tokenBalance ?? 0);
  const tokenValue = Number(holdings[0]?.tokenValue ?? 0);

  // 3. Calculate the combined wallet and token value.
  const totalAssetValue = fiatBalance + tokenValue;

  // 4. Retrieve the latest published announcement.
  const [announcements] = await pool.execute(
    `SELECT
      id,
      title,
      content,
      imageUrl,
      publishedAt,
      expiresAt
    FROM announcements
    WHERE status = 'published'
      AND (
        expiresAt IS NULL
        OR expiresAt > NOW()
      )
    ORDER BY publishedAt DESC
    LIMIT 1`
  );

  // 5. Retrieve the latest published news articles.
  const [news] = await pool.execute(
    `SELECT
      id,
      title,
      summary,
      imageUrl,
      category,
      publishedAt
    FROM news
    WHERE status = 'published'
      AND (
        publishedAt IS NULL
        OR publishedAt <= NOW()
      )
    ORDER BY publishedAt DESC, createdAt DESC
    LIMIT 10`
  );

  // 6. Count the user's unread in-app notifications.
  const [notifications] = await pool.execute(
    `SELECT COUNT(*) AS unreadCount
    FROM notifications
    WHERE userId = ?
      AND deliveryMethod = 'in_app'
      AND status = 'new'
      AND readAt IS NULL`,
    [userId]
  );

  // 7. Return the complete Home summary.
  return {
    user: {
      firstName: "",
    },

    walletSummary: {
      fiatBalance,
      tokenBalance,
      tokenValue,
      totalAssetValue,
      currency,
    },

    announcement: announcements.length > 0
      ? announcements[0]
      : null,

    news,

    unreadNotificationCount: Number(
      notifications[0]?.unreadCount ?? 0
    ),
  };
}