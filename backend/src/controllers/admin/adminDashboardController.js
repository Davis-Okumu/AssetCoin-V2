import {
  getAdminDashboard,
} from "../../services/admin/adminDashboardService.js";

// =========================================================
// GET ADMIN DASHBOARD
// =========================================================

export async function getDashboard(req, res) {
  try {
    const dashboard = await getAdminDashboard();

    return res.status(200).json({
      success: true,
      data: dashboard,
    });
  } catch (error) {
    console.error(
      "Admin dashboard error:",
      error,
    );

    return res.status(500).json({
      success: false,
      message: "Unable to load administrator dashboard.",
    });
  }
}