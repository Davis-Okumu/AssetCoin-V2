
import express from "express";

import {
  getMarketplace,
  getListingDetails,
  createTradingListing,
  buyTradingToken,
  getOrders,
  getOrderDetails,
  cancelTradingOrder,
  getTokenHoldings,
  getTokenHoldingDetails,
} from "../controllers/tradingController.js";

import { authenticateToken } from "../middleware/authMiddleware.js";

const router = express.Router();


// =====================================================
// MARKETPLACE
// =====================================================

// Public marketplace listings
router.get(
  "/marketplace",
  getMarketplace
);

// Public listing details
router.get(
  "/listings/:id",
  getListingDetails
);


// =====================================================
// SELL / CREATE LISTING
// =====================================================

// Selling tokens creates a marketplace listing.
// Tokens are reserved by the trading service until
// the listing is purchased or cancelled.
router.post(
  "/listings",
  authenticateToken,
  createTradingListing
);


// =====================================================
// BUY
// =====================================================

// Buying executes an actual marketplace transaction.
router.post(
  "/orders/buy",
  authenticateToken,
  buyTradingToken
);


// =====================================================
// ORDERS
// =====================================================

// Authenticated user's orders
router.get(
  "/orders",
  authenticateToken,
  getOrders
);

// Authenticated user's order details
router.get(
  "/orders/:id",
  authenticateToken,
  getOrderDetails
);

// Cancel an open/partially-filled order
router.patch(
  "/orders/:id/cancel",
  authenticateToken,
  cancelTradingOrder
);


// =====================================================
// TOKEN HOLDINGS
// =====================================================

// Authenticated user's token holdings
router.get(
  "/holdings",
  authenticateToken,
  getTokenHoldings
);

// Authenticated user's token holding details
router.get(
  "/holdings/:tokenId",
  authenticateToken,
  getTokenHoldingDetails
);


export default router;

