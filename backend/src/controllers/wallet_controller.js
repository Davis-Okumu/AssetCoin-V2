import {
  getWalletSummary,
  getWalletTransactions,
  getWalletTransaction,
} from "../services/wallet_service.js";

function getAuthenticatedUserId(req) {
  const userId = req.user?.id ?? req.user?.userId ?? req.user?.sub;

  const parsedUserId = Number(userId);

  if (!Number.isInteger(parsedUserId) || parsedUserId <= 0) {
    throw Object.assign(
      new Error("Authenticated user could not be identified."),
      { statusCode: 401 },
    );
  }

  return parsedUserId;
}

function getErrorStatusCode(error) {
  return Number.isInteger(error?.statusCode)
    ? error.statusCode
    : 500;
}

function getErrorMessage(error) {
  if (error?.statusCode && error.statusCode < 500) {
    return error.message;
  }

  return "An unexpected error occurred.";
}

async function getWallet(req, res) {
  try {
    const userId = getAuthenticatedUserId(req);

    const wallet = await getWalletSummary(userId);

    return res.status(200).json({
      success: true,
      data: wallet,
    });
  } catch (error) {
    const statusCode = getErrorStatusCode(error);

    return res.status(statusCode).json({
      success: false,
      message: getErrorMessage(error),
    });
  }
}

async function getTransactions(req, res) {
  try {
    const userId = getAuthenticatedUserId(req);

    const transactions = await getWalletTransactions(userId);

    return res.status(200).json({
      success: true,
      data: transactions,
    });
  } catch (error) {
    const statusCode = getErrorStatusCode(error);

    return res.status(statusCode).json({
      success: false,
      message: getErrorMessage(error),
    });
  }
}

async function getTransaction(req, res) {
  try {
    const userId = getAuthenticatedUserId(req);

    const transactionId = Number(req.params.id);

    if (
      !Number.isInteger(transactionId) ||
      transactionId <= 0
    ) {
      return res.status(400).json({
        success: false,
        message: "Invalid wallet transaction ID.",
      });
    }

    const transaction = await getWalletTransaction(
      userId,
      transactionId,
    );

    return res.status(200).json({
      success: true,
      data: transaction,
    });
  } catch (error) {
    const statusCode = getErrorStatusCode(error);

    return res.status(statusCode).json({
      success: false,
      message: getErrorMessage(error),
    });
  }
}

export {
  getWallet,
  getTransactions,
  getTransaction,
};