import express from "express";

import {
  getWallet,
  getTransactions,
  getTransaction,
} from "../controllers/wallet_controller.js";

import { authenticateToken } from "../middleware/authMiddleware.js";

const router = express.Router();

router.get(
  "/",
  authenticateToken,
  getWallet,
);

router.get(
  "/transactions",
  authenticateToken,
  getTransactions,
);

router.get(
  "/transactions/:id",
  authenticateToken,
  getTransaction,
);

export default router;