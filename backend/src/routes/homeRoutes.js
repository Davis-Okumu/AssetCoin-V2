
import express from "express";

import { getHome } from "../controllers/homeController.js";
import { authenticateToken } from "../middleware/authMiddleware.js";

const router = express.Router();

// GET /api/home
// Returns Home data for the authenticated user.
router.get("/", authenticateToken, getHome);

export default router;