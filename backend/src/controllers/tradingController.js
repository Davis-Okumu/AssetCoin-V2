
import {
  getMarketplaceListings,
  getListingById,
  createListing,
  buyToken,
  cancelOrder,
  getUserOrders,
  getUserOrderById,
  getUserTokenHoldings,
  getUserTokenHoldingByTokenId,
} from "../services/tradingService.js";

// =====================================================
// TRADING CONTROLLER
// =====================================================

function getAuthenticatedUserId(req) {
  return req.user?.id ?? req.user?.userId ?? req.user?.sub;
}


// =====================================================
// 1. GET MARKETPLACE
// GET /api/trading/marketplace
// =====================================================

export async function getMarketplace(req, res) {
  try {
    const {
      search = "",
      category = "",
      listingStatus = "",
      page = 1,
      limit = 20,
    } = req.query;

    const result = await getMarketplaceListings({
      search: String(search),
      category: String(category),
      listingStatus: String(listingStatus),
      page,
      limit,
    });

    return res.status(200).json({
      success: true,
      message: "Trading marketplace retrieved successfully.",
      data: result.listings,
      pagination: result.pagination,
    });
  } catch (error) {
    console.error(
      "Get trading marketplace error:",
      error
    );

    return res.status(500).json({
      success: false,
      message: "Unable to retrieve the trading marketplace.",
    });
  }
}


// =====================================================
// 2. GET LISTING DETAILS
// GET /api/trading/listings/:id
// =====================================================

export async function getListingDetails(req, res) {
  try {
    const listingId = Number.parseInt(
      req.params.id,
      10
    );

    if (
      !Number.isSafeInteger(listingId) ||
      listingId <= 0
    ) {
      return res.status(400).json({
        success: false,
        message: "Invalid listing ID.",
      });
    }

    const listing =
      await getListingById(listingId);

    if (!listing) {
      return res.status(404).json({
        success: false,
        message: "Listing not found.",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Listing details retrieved successfully.",
      data: listing,
    });
  } catch (error) {
    console.error(
      "Get listing details error:",
      error
    );

    return res.status(500).json({
      success: false,
      message: "Unable to retrieve listing details.",
    });
  }
}


// =====================================================
// 3. CREATE LISTING
// POST /api/trading/listings
// =====================================================

export async function createTradingListing(
  req,
  res
) {
  try {
    const userId =
      getAuthenticatedUserId(req);

    if (!userId) {
      return res.status(401).json({
        success: false,
        message: "Authentication required.",
      });
    }

    const {
      tokenId,
      quantity,
      pricePerToken,
      currency,
      expiresAt,
    } = req.body;

    // -------------------------------------------------
    // TOKEN ID
    // -------------------------------------------------

    const parsedTokenId =
      Number.parseInt(tokenId, 10);

    if (
      !Number.isSafeInteger(parsedTokenId) ||
      parsedTokenId <= 0
    ) {
      return res.status(400).json({
        success: false,
        message: "A valid token ID is required.",
      });
    }

    // -------------------------------------------------
    // QUANTITY
    // -------------------------------------------------

    const parsedQuantity =
      Number(quantity);

    if (
      !Number.isFinite(parsedQuantity) ||
      parsedQuantity <= 0
    ) {
      return res.status(400).json({
        success: false,
        message:
          "Listing quantity must be greater than zero.",
      });
    }

    // -------------------------------------------------
    // PRICE
    // -------------------------------------------------

    const parsedPricePerToken =
      Number(pricePerToken);

    if (
      !Number.isFinite(parsedPricePerToken) ||
      parsedPricePerToken <= 0
    ) {
      return res.status(400).json({
        success: false,
        message:
          "Price per token must be greater than zero.",
      });
    }

    // -------------------------------------------------
    // CURRENCY
    // -------------------------------------------------

    const normalizedCurrency =
      currency == null || currency === ""
        ? "KES"
        : String(currency)
            .trim()
            .toUpperCase();

    if (
      !/^[A-Z]{3,10}$/.test(
        normalizedCurrency
      )
    ) {
      return res.status(400).json({
        success: false,
        message: "Invalid currency code.",
      });
    }

    // -------------------------------------------------
    // EXPIRATION
    // -------------------------------------------------

    let normalizedExpiresAt = null;

    if (
      expiresAt !== undefined &&
      expiresAt !== null &&
      String(expiresAt).trim() !== ""
    ) {
      const parsedDate =
        new Date(expiresAt);

      if (
        Number.isNaN(
          parsedDate.getTime()
        )
      ) {
        return res.status(400).json({
          success: false,
          message:
            "Invalid listing expiration date.",
        });
      }

      if (
        parsedDate.getTime() <=
        Date.now()
      ) {
        return res.status(400).json({
          success: false,
          message:
            "Listing expiration must be in the future.",
        });
      }

      normalizedExpiresAt = parsedDate;
    }

    // -------------------------------------------------
    // CREATE LISTING
    // -------------------------------------------------

    const listing =
      await createListing(
        userId,
        {
          tokenId: parsedTokenId,
          quantity: parsedQuantity,
          pricePerToken:
            parsedPricePerToken,
          currency:
            normalizedCurrency,
          expiresAt:
            normalizedExpiresAt,
        }
      );

    return res.status(201).json({
      success: true,
      message:
        "Trading listing created successfully.",
      data: listing,
    });
  } catch (error) {
    console.error(
      "Create trading listing error:",
      error
    );

    const businessMessages = [
      "Invalid token ID.",
      "Listing quantity must be greater than zero.",
      "Price per token must be greater than zero.",
      "Invalid currency code.",
      "Token not found.",
      "This asset has not been approved for tokenization and listing.",
      "This token is not currently active.",
      "You are not authorized to list this token.",
      "You do not own any quantity of this token.",
      "You do not have enough available tokens to create this listing.",
    ];

    if (
      businessMessages.includes(
        error.message
      )
    ) {
      return res.status(400).json({
        success: false,
        message: error.message,
      });
    }

    return res.status(500).json({
      success: false,
      message:
        "Unable to create trading listing.",
    });
  }
}


// =====================================================
// 4. BUY TOKEN
// POST /api/trading/orders/buy
// =====================================================

export async function buyTradingToken(
  req,
  res
) {
  try {
    const userId =
      getAuthenticatedUserId(req);

    if (!userId) {
      return res.status(401).json({
        success: false,
        message: "Authentication required.",
      });
    }

    const {
      listingId,
      quantity,
    } = req.body;

    // -------------------------------------------------
    // LISTING ID
    // -------------------------------------------------

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
      return res.status(400).json({
        success: false,
        message:
          "A valid listing ID is required.",
      });
    }

    // -------------------------------------------------
    // QUANTITY
    // -------------------------------------------------

    const parsedQuantity =
      Number(quantity);

    if (
      !Number.isFinite(
        parsedQuantity
      ) ||
      parsedQuantity <= 0
    ) {
      return res.status(400).json({
        success: false,
        message:
          "Purchase quantity must be greater than zero.",
      });
    }

    // -------------------------------------------------
    // EXECUTE PURCHASE
    // -------------------------------------------------

    const result =
      await buyToken(
        userId,
        {
          listingId:
            parsedListingId,
          quantity:
            parsedQuantity,
        }
      );

    return res.status(201).json({
      success: true,
      message:
        "Token purchase completed successfully.",
      data: result,
    });
  } catch (error) {
    console.error(
      "Buy token error:",
      error
    );

    const businessMessages = [
      "Authentication is required.",
      "A valid listing ID is required.",
      "Quantity must be greater than zero.",
      "Listing not found.",
      "You cannot buy your own listing.",
      "This listing is not available for purchase.",
      "This listing is no longer available.",
      "This token is not currently available for trading.",
      "The underlying asset is not currently available for trading.",
      "This listing has expired.",
      "Invalid transaction amount.",
      "Buyer wallet not found.",
      "Your wallet is not available for trading.",
      "Insufficient wallet balance.",
      "Seller wallet not found.",
      "Seller wallet is not available.",
      "Seller token holding not found.",
      "Seller no longer has enough available tokens to complete this purchase.",
    ];

    if (
      businessMessages.includes(
        error.message
      )
    ) {
      return res.status(400).json({
        success: false,
        message: error.message,
      });
    }

    return res.status(500).json({
      success: false,
      message:
        "Unable to complete token purchase.",
    });
  }
}

// =====================================================
// 6. GET USER ORDERS
// GET /api/trading/orders
// =====================================================

export async function getOrders(req, res) {
  try {
    const userId =
      getAuthenticatedUserId(req);

    if (!userId) {
      return res.status(401).json({
        success: false,
        message: "Authentication required.",
      });
    }

    const {
      status = "",
      orderType = "",
      page = 1,
      limit = 20,
    } = req.query;

    const result =
      await getUserOrders(
        userId,
        {
          status: String(status),
          orderType: String(orderType),
          page,
          limit,
        }
      );

    return res.status(200).json({
      success: true,
      message:
        "Your trading orders retrieved successfully.",
      data: result.orders,
      pagination: result.pagination,
    });
  } catch (error) {
    console.error(
      "Get trading orders error:",
      error
    );

    return res.status(500).json({
      success: false,
      message:
        "Unable to retrieve your trading orders.",
    });
  }
}


// =====================================================
// 7. GET ORDER DETAILS
// GET /api/trading/orders/:id
// =====================================================

export async function getOrderDetails(
  req,
  res
) {
  try {
    const userId =
      getAuthenticatedUserId(req);

    const orderId =
      Number.parseInt(
        req.params.id,
        10
      );

    if (!userId) {
      return res.status(401).json({
        success: false,
        message:
          "Authentication required.",
      });
    }

    if (
      !Number.isSafeInteger(orderId) ||
      orderId <= 0
    ) {
      return res.status(400).json({
        success: false,
        message:
          "Invalid order ID.",
      });
    }

    const order =
      await getUserOrderById(
        userId,
        orderId
      );

    if (!order) {
      return res.status(404).json({
        success: false,
        message:
          "Order not found.",
      });
    }

    return res.status(200).json({
      success: true,
      message:
        "Order details retrieved successfully.",
      data: order,
    });
  } catch (error) {
    console.error(
      "Get order details error:",
      error
    );

    return res.status(500).json({
      success: false,
      message:
        "Unable to retrieve order details.",
    });
  }
}


// =====================================================
// 8. CANCEL ORDER
// PATCH /api/trading/orders/:id/cancel
// =====================================================

export async function cancelTradingOrder(
  req,
  res
) {
  try {
    const userId =
      getAuthenticatedUserId(req);

    if (!userId) {
      return res.status(401).json({
        success: false,
        message:
          "Authentication required.",
      });
    }

    const orderId =
      Number.parseInt(
        req.params.id,
        10
      );

    if (
      !Number.isSafeInteger(orderId) ||
      orderId <= 0
    ) {
      return res.status(400).json({
        success: false,
        message:
          "Invalid order ID.",
      });
    }

    const result =
      await cancelOrder(
        userId,
        orderId
      );

    return res.status(200).json({
      success: true,
      message:
        "Trading order cancelled successfully.",
      data: result,
    });
  } catch (error) {
    console.error(
      "Cancel trading order error:",
      error
    );

    const businessMessages = [
      "Authentication is required.",
      "A valid order ID is required.",
      "Order not found.",
      "This order cannot be cancelled.",
    ];

    if (
      businessMessages.includes(
        error.message
      ) ||
      error.message?.startsWith(
        "This order cannot be cancelled because it is already "
      )
    ) {
      return res.status(400).json({
        success: false,
        message: error.message,
      });
    }

    return res.status(500).json({
      success: false,
      message:
        "Unable to cancel trading order.",
    });
  }
}


// =====================================================
// 9. GET TOKEN HOLDINGS
// GET /api/trading/holdings
// =====================================================

export async function getTokenHoldings(
  req,
  res
) {
  try {
    const userId =
      getAuthenticatedUserId(req);

    if (!userId) {
      return res.status(401).json({
        success: false,
        message:
          "Authentication required.",
      });
    }

    const {
      search = "",
      page = 1,
      limit = 20,
    } = req.query;

    const result =
      await getUserTokenHoldings(
        userId,
        {
          search: String(search),
          page,
          limit,
        }
      );

    return res.status(200).json({
      success: true,
      message:
        "Your token holdings retrieved successfully.",
      data: result.holdings,
      pagination: result.pagination,
    });
  } catch (error) {
    console.error(
      "Get token holdings error:",
      error
    );

    return res.status(500).json({
      success: false,
      message:
        "Unable to retrieve your token holdings.",
    });
  }
}


// =====================================================
// 10. GET TOKEN HOLDING DETAILS
// GET /api/trading/holdings/:tokenId
// =====================================================

export async function getTokenHoldingDetails(
  req,
  res
) {
  try {
    const userId =
      getAuthenticatedUserId(req);

    const tokenId =
      Number.parseInt(
        req.params.tokenId,
        10
      );

    if (!userId) {
      return res.status(401).json({
        success: false,
        message:
          "Authentication required.",
      });
    }

    if (
      !Number.isSafeInteger(tokenId) ||
      tokenId <= 0
    ) {
      return res.status(400).json({
        success: false,
        message:
          "Invalid token ID.",
      });
    }

    const holding =
      await getUserTokenHoldingByTokenId(
        userId,
        tokenId
      );

    if (!holding) {
      return res.status(404).json({
        success: false,
        message:
          "Token holding not found.",
      });
    }

    return res.status(200).json({
      success: true,
      message:
        "Token holding details retrieved successfully.",
      data: holding,
    });
  } catch (error) {
    console.error(
      "Get token holding details error:",
      error
    );

    return res.status(500).json({
      success: false,
      message:
        "Unable to retrieve token holding details.",
    });
  }
}
