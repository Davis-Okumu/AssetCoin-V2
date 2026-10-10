
import express from "express";
import cors from "cors";
import "dotenv/config";
import path from "path";
import { fileURLToPath } from "url";

import pool from "./config/database.js";

import authRoutes from "./routes/authRoutes.js";
import homeRoutes from "./routes/homeRoutes.js";
import walletRoutes from "./routes/walletRoutes.js";
import notificationRoutes from "./routes/notificationRoutes.js";
import assetRoutes from "./routes/assetRoutes.js";
import tradingRoutes from "./routes/tradingRoutes.js";
import profileRoutes from "./routes/profileRoutes.js";
import kycRoutes from "./routes/kycRoutes.js";
import securityRoutes from "./routes/securityRoutes.js";
import supportRoutes from "./routes/supportRoutes.js";
import adminAuthRoutes from "./routes/adminAuthRoutes.js";
import adminDashboardRoutes from "./routes/admin/adminDashboardRoutes.js";
import adminUsersRoutes from "./routes/admin/adminUsersRoutes.js";
import adminAssetsRoutes from "./routes/admin/adminAssetsRoutes.js";
import adminKycRoutes from "./routes/admin/adminKycRoutes.js";
import adminTokenizationRoutes from "./routes/admin/adminTokenizationRoutes.js";
import adminTradingRoutes from "./routes/admin/adminTradingRoutes.js";
import adminFinanceRoutes from "./routes/admin/adminFinanceRoutes.js";
import adminLedgerRoutes from "./routes/admin/adminLedgerRoutes.js";
import adminNotificationsRoutes from "./routes/admin/adminNotificationsRoutes.js";
import adminContentRoutes from "./routes/admin/adminContentRoutes.js";
import adminStaffRoutes from "./routes/admin/adminStaffRoutes.js";

const app = express();

// Resolve the backend directory independently of the terminal's working directory.
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const assetPhotoDirectory = path.resolve(
  __dirname,
  "../uploads/assets/photos"
);

const profilePhotoDirectory = path.resolve(
  __dirname,
  "../uploads/profile/photos"
);

// =========================
// MIDDLEWARE
// =========================

app.use(cors());
app.use(express.json());

// =========================
// PUBLIC ASSET PHOTO ACCESS
// =========================

app.use(
  "/uploads/assets/photos",
  express.static(assetPhotoDirectory, {
    dotfiles: "deny",
    index: false,
    fallthrough: false,
    maxAge: "1d",
  })
);

// =========================
// PROFILE PHOTO ACCESS
// =========================

// Profile photo URLs are publicly accessible.
// Never expose private identity documents through this route.
app.use(
  "/uploads/profile/photos",
  express.static(profilePhotoDirectory, {
    dotfiles: "deny",
    index: false,
    fallthrough: false,
    maxAge: "1d",
  })
);

// =========================
// API ROUTES
// =========================

app.use("/api/auth", authRoutes);
app.use("/api/home", homeRoutes);
app.use("/api/wallet", walletRoutes);
app.use("/api/notifications", notificationRoutes);
app.use("/api/assets", assetRoutes);
app.use("/api/trading", tradingRoutes);
app.use("/api/profile", profileRoutes);
app.use("/api/kyc", kycRoutes);
app.use("/api/security", securityRoutes);
app.use("/api/support", supportRoutes);

// =========================================================
// ADMIN ROUTES
// =========================================================
app.use("/api/admin/auth", adminAuthRoutes,);
app.use("/api/admin/dashboard", adminDashboardRoutes,);
app.use("/api/admin/users", adminUsersRoutes);
app.use("/api/admin/assets", adminAssetsRoutes);
app.use("/api/admin/kyc", adminKycRoutes);
app.use("/api/admin/tokenization", adminTokenizationRoutes,);
app.use("/api/admin/trading", adminTradingRoutes);
app.use("/api/admin/finance", adminFinanceRoutes);
app.use("/api/admin/ledger", adminLedgerRoutes);
app.use("/api/admin/notifications", adminNotificationsRoutes);
app.use("/api/admin/content", adminContentRoutes);
app.use("/api/admin/staff", adminStaffRoutes);

// =========================
// ROOT ROUTE
// =========================

app.get("/", (req, res) => {
  res.json({
    success: true,
    message: "AssetCoin API is running",
  });
});

// =========================
// DATABASE HEALTH CHECK
// =========================

app.get("/api/health", async (req, res) => {
  try {
    await pool.query("SELECT 1");

    res.status(200).json({
      success: true,
      message: "AssetCoin API and database are running",
    });
  } catch (error) {
    console.error(
      "Database health check failed:",
      error.message
    );

    res.status(503).json({
      success: false,
      message: "Database connection unavailable",
    });
  }
});

// =========================
// NOT FOUND HANDLER
// =========================

app.use((req, res, next) => {
  res.status(404).json({
    success: false,
    message: "The requested API endpoint was not found.",
  });
});

// =========================
// CENTRAL ERROR HANDLER
// =========================

app.use((err, req, res, next) => {
  console.error("API Error:", err.message);

  // Multer upload errors
  if (err.name === "MulterError") {
    return res.status(400).json({
      success: false,
      message: err.message,
    });
  }

  // Unsupported file types
  if (err.message === "Unsupported file type.") {
    return res.status(400).json({
      success: false,
      message: err.message,
    });
  }

  // Static file errors
  if (err.status === 404 || err.statusCode === 404) {
    return res.status(404).json({
      success: false,
      message: "Requested file not found.",
    });
  }

  // Other unexpected errors
  return res.status(500).json({
    success: false,
    message: "An unexpected server error occurred.",
  });
});


// =========================
// SERVER CONFIGURATION
// =========================

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});