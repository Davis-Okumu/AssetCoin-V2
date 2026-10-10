import {
    getContentOverview,
    listContent,
    getContentDetails,
    createContent,
    updateContent,
    publishContent,
    archiveContent,
    deleteContent,
} from "../../services/admin/adminContentService.js";

/**
- ============================================================
- ADMIN CONTENT MANAGEMENT CONTROLLER
- ============================================================
  */
function getStaffId(request) {
    const staffId = Number(
        request.adminAuth?.staffId ??
        request.admin?.id ??
        request.admin?.staffId ??
        request.adminId,
    );
    if (!Number.isSafeInteger(staffId) || staffId <= 0) {
        const error = new Error("Authenticated admin staff ID is missing.");
        error.statusCode = 401;
        throw error;
    }
    return staffId;
}
function getRequestContext(request) {
    return {
        ipAddress:
            request.ip ??
            request.socket?.remoteAddress ??
            null,
        userAgent: request.get("user-agent") ?? null,
    };
}
function sendError(response, error) {
    const statusCode = Number(error.statusCode) || 500;
    if (statusCode >= 500) {
        console.error("Admin content error:", error);
    }
    return response.status(statusCode).json({
        success: false,
        message:
            statusCode >= 500
                ? "An error occurred while processing content."
                : error.message,
    });
}
/**
* GET /api/admin/content/overview
*/
export async function getContentOverviewController(request, response) {
    try {
        const data = await getContentOverview();
        return response.status(200).json({
            success: true,
            data,
        });
    } catch (error) {
        return sendError(response, error);
    }
}
/**
* GET /api/admin/content/:type
*/
export async function listContentController(request, response) {
    try {
        const result = await listContent(
            request.params.type,
            request.query,
        );
        return response.status(200).json({
            success: true,
            data: result.items,
            pagination: result.pagination,
        });
    } catch (error) {
        return sendError(response, error);
    }
}
/**
* GET /api/admin/content/:type/:id
*/
export async function getContentDetailsController(request, response) {
    try {
        const item = await getContentDetails(
            request.params.type,
            request.params.id,
        );
        return response.status(200).json({
            success: true,
            data: item,
        });
    } catch (error) {
        return sendError(response, error);
    }
}
/**
* POST /api/admin/content/:type
*/
export async function createContentController(request, response) {
    try {
        const item = await createContent(
            request.params.type,
            request.body,
            getStaffId(request),
            getRequestContext(request),
        );
        return response.status(201).json({
            success: true,
            message: "Content created successfully.",
            data: item,
        });
    } catch (error) {
        return sendError(response, error);
    }
}
/**
* PATCH /api/admin/content/:type/:id
*/
export async function updateContentController(request, response) {
    try {
        const item = await updateContent(
            request.params.type,
            request.params.id,
            request.body,
            getStaffId(request),
            getRequestContext(request),
        );
        return response.status(200).json({
            success: true,
            message: "Content updated successfully.",
            data: item,
        });
    } catch (error) {
        return sendError(response, error);
    }
}
/**
* POST /api/admin/content/:type/:id/publish
*/
export async function publishContentController(request, response) {
    try {
        const item = await publishContent(
            request.params.type,
            request.params.id,
            getStaffId(request),
            getRequestContext(request),
        );
        return response.status(200).json({
            success: true,
            message: "Content published successfully.",
            data: item,
        });
    } catch (error) {
        return sendError(response, error);
    }
}
/**
* POST /api/admin/content/:type/:id/archive
*/
export async function archiveContentController(request, response) {
    try {
        const item = await archiveContent(
            request.params.type,
            request.params.id,
            getStaffId(request),
            getRequestContext(request),
        );
        return response.status(200).json({
            success: true,
            message: "Content archived successfully.",
            data: item,
        });
    } catch (error) {
        return sendError(response, error);
    }
}
/**
* DELETE /api/admin/content/:type/:id
*/
export async function deleteContentController(request, response) {
    try {
        const result = await deleteContent(
            request.params.type,
            request.params.id,
            getStaffId(request),
            getRequestContext(request),
        );
        return response.status(200).json({
            success: true,
            message: "Content deleted successfully.",
            data: result,
        });
    } catch (error) {
        return sendError(response, error);
    }
}