
import { verifyAssetOwnership } from "../services/assetService.js";

export async function requireAssetOwnership(req, res, next) {
  try {
    const userId =
      req.user?.id ??
      req.user?.userId ??
      req.user?.sub;

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

    const ownsAsset = await verifyAssetOwnership(
      userId,
      assetId
    );

    if (!ownsAsset) {
      return res.status(404).json({
        success: false,
        message: "Asset submission not found.",
      });
    }

    req.assetId = assetId;

    next();
  } catch (error) {
    console.error("Asset ownership verification error:", error);

    return res.status(500).json({
      success: false,
      message: "Unable to verify asset ownership.",
    });
  }
}