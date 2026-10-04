
import { getHomeSummary } from "../services/homeService.js";

export async function getHome(req, res) {
  try {
    const homeSummary = await getHomeSummary(req.user.id);

    // Add the authenticated user's first name.
    homeSummary.user.firstName = req.user.firstName;

    return res.status(200).json({
      success: true,
      data: homeSummary,
    });
  } catch (error) {
    console.error("Get home summary error:", error);

    return res.status(500).json({
      success: false,
      message: "Unable to retrieve Home data.",
    });
  }
}