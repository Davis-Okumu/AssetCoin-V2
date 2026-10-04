
import {
  getPublishedAssets,
  getAssetById,
  getAssetCategories,
  getAssetMarketStats,
  getUserAssetSubmissions,
  getUserAssetSubmissionById,
  createAssetSubmission,
} from "../services/assetService.js";

// =====================================================
// ASSET CONTROLLER
// =====================================================

function getAuthenticatedUserId(req) {
  return req.user?.id ?? req.user?.userId ?? req.user?.sub;
}

const VALID_ASSET_TYPES = [
  "land",
  "livestock",
  "produce",
  "vehicle",
  "property",
  "equipment",
  "other",
];


// =====================================================
// 1. GET PUBLISHED ASSETS
// GET /api/assets
// =====================================================

export async function getAssets(req, res) {
  try {
    const {
      search = "",
      category = "",
      page = 1,
      limit = 20,
    } = req.query;

    const result = await getPublishedAssets({
      search: String(search),
      category: String(category),
      page,
      limit,
    });

    return res.status(200).json({
      success: true,
      message: "Assets retrieved successfully.",
      data: result.assets,
      pagination: result.pagination,
    });
  } catch (error) {
    console.error("Get assets error:", error);

    return res.status(500).json({
      success: false,
      message: "Unable to retrieve assets.",
    });
  }
}


// =====================================================
// 2. GET ASSET DETAILS
// GET /api/assets/:id
// =====================================================

export async function getAssetDetails(req, res) {
  try {
    const assetId = Number.parseInt(req.params.id, 10);

    if (!Number.isSafeInteger(assetId) || assetId <= 0) {
      return res.status(400).json({
        success: false,
        message: "Invalid asset ID.",
      });
    }

    const asset = await getAssetById(assetId);

    if (!asset) {
      return res.status(404).json({
        success: false,
        message: "Asset not found.",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Asset details retrieved successfully.",
      data: asset,
    });
  } catch (error) {
    console.error("Get asset details error:", error);

    return res.status(500).json({
      success: false,
      message: "Unable to retrieve asset details.",
    });
  }
}


// =====================================================
// 3. GET ASSET CATEGORIES
// GET /api/assets/categories
// =====================================================

export async function getCategories(req, res) {
  try {
    const categories = await getAssetCategories();

    return res.status(200).json({
      success: true,
      message: "Asset categories retrieved successfully.",
      data: categories,
    });
  } catch (error) {
    console.error("Get asset categories error:", error);

    return res.status(500).json({
      success: false,
      message: "Unable to retrieve asset categories.",
    });
  }
}


// =====================================================
// 4. GET MARKETPLACE STATISTICS
// GET /api/assets/market-stats
// =====================================================

export async function getMarketStats(req, res) {
  try {
    const stats = await getAssetMarketStats();

    return res.status(200).json({
      success: true,
      message: "Marketplace statistics retrieved successfully.",
      data: stats,
    });
  } catch (error) {
    console.error("Get marketplace statistics error:", error);

    return res.status(500).json({
      success: false,
      message: "Unable to retrieve marketplace statistics.",
    });
  }
}


// =====================================================
// 5. GET USER SUBMISSIONS
// GET /api/assets/my-submissions
// =====================================================

export async function getMySubmissions(req, res) {
  try {
    const userId = getAuthenticatedUserId(req);

    if (!userId) {
      return res.status(401).json({
        success: false,
        message: "Authentication required.",
      });
    }

    const assets = await getUserAssetSubmissions(userId);

    return res.status(200).json({
      success: true,
      message: "Your asset submissions retrieved successfully.",
      data: assets,
    });
  } catch (error) {
    console.error("Get user asset submissions error:", error);

    return res.status(500).json({
      success: false,
      message: "Unable to retrieve your asset submissions.",
    });
  }
}


// =====================================================
// 6. GET USER SUBMISSION DETAILS
// GET /api/assets/my-submissions/:id
// =====================================================

export async function getMySubmissionDetails(req, res) {
  try {
    const userId = getAuthenticatedUserId(req);
    const assetId = Number.parseInt(req.params.id, 10);

    if (!userId) {
      return res.status(401).json({
        success: false,
        message: "Authentication required.",
      });
    }

    if (!Number.isSafeInteger(assetId) || assetId <= 0) {
      return res.status(400).json({
        success: false,
        message: "Invalid asset ID.",
      });
    }

    const asset = await getUserAssetSubmissionById(userId, assetId);

    if (!asset) {
      return res.status(404).json({
        success: false,
        message: "Asset submission not found.",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Asset submission retrieved successfully.",
      data: asset,
    });
  } catch (error) {
    console.error("Get user submission details error:", error);

    return res.status(500).json({
      success: false,
      message: "Unable to retrieve asset submission.",
    });
  }
}


// =====================================================
// 7. CREATE ASSET SUBMISSION
// POST /api/assets/submit
// =====================================================

export async function createAsset(req, res) {
  try {
    const userId = getAuthenticatedUserId(req);

    if (!userId) {
      return res.status(401).json({
        success: false,
        message: "Authentication required.",
      });
    }

    const {
      assetType,
      name,
      description,
      location,
      latitude,
      longitude,
      registrationNumber,
      estimatedValue,
      currency,
    } = req.body;

    // Validate required fields.

    if (!assetType || !name) {
      return res.status(400).json({
        success: false,
        message: "Asset type and asset name are required.",
      });
    }

    if (!VALID_ASSET_TYPES.includes(assetType)) {
      return res.status(400).json({
        success: false,
        message: "Invalid asset type.",
      });
    }

    if (
      typeof name !== "string" ||
      !name.trim() ||
      name.trim().length > 150
    ) {
      return res.status(400).json({
        success: false,
        message: "Asset name must be between 1 and 150 characters.",
      });
    }

    if (
      description != null &&
      typeof description !== "string"
    ) {
      return res.status(400).json({
        success: false,
        message: "Invalid asset description.",
      });
    }

    if (
      location != null &&
      typeof location !== "string"
    ) {
      return res.status(400).json({
        success: false,
        message: "Invalid asset location.",
      });
    }

    if (
      registrationNumber != null &&
      typeof registrationNumber !== "string"
    ) {
      return res.status(400).json({
        success: false,
        message: "Invalid registration number.",
      });
    }

    // Validate optional coordinates.

    const parsedLatitude =
      latitude == null || latitude === ""
        ? null
        : Number(latitude);

    const parsedLongitude =
      longitude == null || longitude === ""
        ? null
        : Number(longitude);

    if (
      parsedLatitude !== null &&
      (
        !Number.isFinite(parsedLatitude) ||
        parsedLatitude < -90 ||
        parsedLatitude > 90
      )
    ) {
      return res.status(400).json({
        success: false,
        message: "Latitude must be between -90 and 90.",
      });
    }

    if (
      parsedLongitude !== null &&
      (
        !Number.isFinite(parsedLongitude) ||
        parsedLongitude < -180 ||
        parsedLongitude > 180
      )
    ) {
      return res.status(400).json({
        success: false,
        message: "Longitude must be between -180 and 180.",
      });
    }

    // Validate optional estimated value.

    const parsedEstimatedValue =
      estimatedValue == null || estimatedValue === ""
        ? null
        : Number(estimatedValue);

    if (
      parsedEstimatedValue !== null &&
      (
        !Number.isFinite(parsedEstimatedValue) ||
        parsedEstimatedValue < 0
      )
    ) {
      return res.status(400).json({
        success: false,
        message: "Estimated value must be a valid non-negative number.",
      });
    }

    const normalizedCurrency =
      currency == null || currency === ""
        ? "KES"
        : String(currency).trim().toUpperCase();

    if (!/^[A-Z]{3,10}$/.test(normalizedCurrency)) {
      return res.status(400).json({
        success: false,
        message: "Invalid currency code.",
      });
    }

    const asset = await createAssetSubmission(userId, {
      assetType,
      name: name.trim(),
      description: description?.trim() || null,
      location: location?.trim() || null,
      latitude: parsedLatitude,
      longitude: parsedLongitude,
      registrationNumber: registrationNumber?.trim() || null,
      estimatedValue: parsedEstimatedValue,
      currency: normalizedCurrency,
    });

    return res.status(201).json({
      success: true,
      message: "Asset submitted successfully.",
      data: asset,
    });
  } catch (error) {
    console.error("Create asset submission error:", error);

    return res.status(500).json({
      success: false,
      message: "Unable to submit your asset.",
    });
  }
}