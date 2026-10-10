
import {
    getAdminNotificationsOverview,
    getAdminNotifications,
    markAdminNotificationAsRead,
    archiveAdminNotification,
} from "../../services/admin/adminNotificationsService.js";

function getStaffId(request) {
    const staffId = Number(request.adminId);

    return Number.isSafeInteger(staffId) && staffId > 0
        ? staffId
        : null;
}

function handleError(response, error, operation) {
    console.error(`${operation} error:`, error);

    return response.status(500).json({
        success: false,
        message: "An error occurred while processing admin notifications.",
    });
}

/**
 * GET /api/admin/notifications/overview
 */
export async function getAdminNotificationsOverviewController(
    request,
    response,
) {
    try {
        const staffId = getStaffId(request);

        if (!staffId) {
            return response.status(401).json({
                success: false,
                message: "Authenticated admin staff ID is missing.",
            });
        }

        const data = await getAdminNotificationsOverview(staffId);

        return response.status(200).json({
            success: true,
            data,
        });
    } catch (error) {
        return handleError(
            response,
            error,
            "Get admin notifications overview",
        );
    }
}

/**
 * GET /api/admin/notifications
 */
export async function getAdminNotificationsController(
    request,
    response,
) {
    try {
        const staffId = getStaffId(request);

        if (!staffId) {
            return response.status(401).json({
                success: false,
                message: "Authenticated admin staff ID is missing.",
            });
        }

        const data = await getAdminNotifications(staffId, {
            page: request.query.page,
            limit: request.query.limit,
            type: request.query.type,
            status: request.query.status,
            search: request.query.search,
        });

        return response.status(200).json({
            success: true,
            data,
        });
    } catch (error) {
        return handleError(
            response,
            error,
            "Get admin notifications",
        );
    }
}

/**
 * PATCH /api/admin/notifications/:id/read
 */
export async function markAdminNotificationAsReadController(
    request,
    response,
) {
    try {
        const staffId = getStaffId(request);

        if (!staffId) {
            return response.status(401).json({
                success: false,
                message: "Authenticated admin staff ID is missing.",
            });
        }

        const data = await markAdminNotificationAsRead(
            request.params.id,
            staffId,
        );

        if (!data) {
            return response.status(404).json({
                success: false,
                message: "Notification not found.",
            });
        }

        if (data.conflict) {
            return response.status(409).json({
                success: false,
                message: data.message,
            });
        }

        return response.status(200).json({
            success: true,
            message: "Notification marked as read.",
            data,
        });
    } catch (error) {
        return handleError(
            response,
            error,
            "Mark admin notification as read",
        );
    }
}

/**
 * PATCH /api/admin/notifications/:id/archive
 */
export async function archiveAdminNotificationController(
    request,
    response,
) {
    try {
        const staffId = getStaffId(request);

        if (!staffId) {
            return response.status(401).json({
                success: false,
                message: "Authenticated admin staff ID is missing.",
            });
        }

        const data = await archiveAdminNotification(
            request.params.id,
            staffId,
        );

        if (!data) {
            return response.status(404).json({
                success: false,
                message: "Notification not found.",
            });
        }

        return response.status(200).json({
            success: true,
            message: "Notification archived successfully.",
            data,
        });
    } catch (error) {
        return handleError(
            response,
            error,
            "Archive admin notification",
        );
    }
}
