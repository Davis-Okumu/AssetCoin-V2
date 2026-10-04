import pool from "../config/database.js";

async function getWalletSummary(userId) {
  const connection = await pool.getConnection();

  try {
    /*
     * Get the user's wallet.
     */
    const [walletRows] = await connection.query(
      `
        SELECT
          id,
          userId,
          walletAddress,
          fiatBalance,
          lockedFiatBalance,
          currency,
          status
        FROM wallets
        WHERE userId = ?
        LIMIT 1
      `,
      [userId],
    );

    if (walletRows.length === 0) {
      throw Object.assign(
        new Error("Wallet not found."),
        { statusCode: 404 },
      );
    }

    const wallet = walletRows[0];

    /*
     * Get all token holdings for the user.
     *
     * Current token value is calculated by the backend from:
     *
     * quantity × current token price
     *
     * Flutter only displays the resulting value.
     */
    const [holdingRows] = await connection.query(
      `
        SELECT
          th.tokenId,
          t.tokenCode,
          t.tokenName,
          th.quantity,
          th.lockedQuantity,
          t.tokenPrice,
          t.currency
        FROM token_holdings th
        INNER JOIN tokens t
          ON t.id = th.tokenId
        WHERE th.userId = ?
          AND t.status IN ('active', 'fully_sold')
        ORDER BY t.tokenName ASC
      `,
      [userId],
    );

    const tokenHoldings = holdingRows.map((holding) => {
      const quantity = Number(holding.quantity ?? 0);
      const lockedQuantity = Number(
        holding.lockedQuantity ?? 0,
      );
      const tokenPrice = Number(
        holding.tokenPrice ?? 0,
      );

      const currentValue = quantity * tokenPrice;

      return {
        tokenId: Number(holding.tokenId),
        tokenCode: holding.tokenCode,
        tokenName: holding.tokenName,
        quantity,
        lockedQuantity,
        tokenPrice,
        currentValue,
        currency: holding.currency ?? wallet.currency,
      };
    });

    /*
     * The backend is authoritative for the aggregate values.
     */
    const tokenValue = tokenHoldings.reduce(
      (total, holding) => total + holding.currentValue,
      0,
    );

    const fiatBalance = Number(
      wallet.fiatBalance ?? 0,
    );

    const lockedFiatBalance = Number(
      wallet.lockedFiatBalance ?? 0,
    );

    const totalAssetValue = fiatBalance + tokenValue;

    return {
      fiatBalance,
      lockedFiatBalance,
      currency: wallet.currency,
      tokenValue,
      totalAssetValue,
      tokenHoldings,
    };
  } finally {
    connection.release();
  }
}

async function getWalletTransactions(userId) {
  const connection = await pool.getConnection();

  try {
    /*
     * Only wallet_transactions belong in the Wallet transaction
     * history.
     *
     * Marketplace transactions from the `transactions` table
     * are intentionally not merged here.
     */
    const [rows] = await connection.query(
      `
        SELECT
          id,
          walletId,
          userId,
          transactionReference,
          transactionType,
          amount,
          currency,
          balanceBefore,
          balanceAfter,
          status,
          description,
          createdAt
        FROM wallet_transactions
        WHERE userId = ?
        ORDER BY createdAt DESC, id DESC
      `,
      [userId],
    );

    return rows;
  } finally {
    connection.release();
  }
}

async function getWalletTransaction(
  userId,
  transactionId,
) {
  const connection = await pool.getConnection();

  try {
    const [rows] = await connection.query(
      `
        SELECT
          id,
          walletId,
          userId,
          transactionReference,
          transactionType,
          amount,
          currency,
          balanceBefore,
          balanceAfter,
          status,
          description,
          createdAt
        FROM wallet_transactions
        WHERE id = ?
          AND userId = ?
        LIMIT 1
      `,
      [transactionId, userId],
    );

    if (rows.length === 0) {
      throw Object.assign(
        new Error("Wallet transaction not found."),
        { statusCode: 404 },
      );
    }

    return rows[0];
  } finally {
    connection.release();
  }
}

export {
  getWalletSummary,
  getWalletTransactions,
  getWalletTransaction,
};