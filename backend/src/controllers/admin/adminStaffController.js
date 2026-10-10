
import * as adminStaffService from "../../services/admin/adminStaffService.js";

/**
 * ============================================================
 * ADMIN STAFF CONTROLLER
 * ============================================================
 *
 * Handles HTTP requests for:
 * - Staff overview and directory
 * - Staff creation and profile updates
 * - Staff account status
 * - Roles and permissions
 * - Individual permission overrides
 * - Staff activity and sessions
 *
 * All authorization decisions are enforced by the route
 * middleware. Service operations handle business rules and
 * audit logging.
 * ============================================================
 */

function getRequestContext(req) {
    return {
        ipAddress: req.ip ?? null,
        userAgent: req.get("user-agent") ?? null,
    };
}

function getActor(req) {
    return req.admin?.role ?? null;
}

function getActorStaffId(req) {
    return req.admin?.id ?? null;
}

function sendSuccess(res, data, statusCode = 200) {
    return res.status(statusCode).json({
        success: true,
        data,
    });
}

function handleControllerError(res, error) {
    const statusCode =
        Number.isInteger(error?.statusCode) &&
            error.statusCode >= 400 &&
            error.statusCode <= 599
            ? error.statusCode
            : 500;

    return res.status(statusCode).json({
        success: false,
        code: error?.code ?? "ADMIN_STAFF_ERROR",
        message:
            statusCode >= 500
                ? "An unexpected error occurred while processing the staff request."
                : error.message,
    });
}

function asyncHandler(handler) {
    return async (req, res, next) => {
        try {
            await handler(req, res, next);
        } catch (error) {
            if (res.headersSent) {
                return next(error);
            }

            return handleControllerError(res, error);
        }
    };
}

/**
 * GET /overview
 */
export const getStaffOverview = asyncHandler(
    async (req, res) => {
        const data = await adminStaffService.getStaffOverview();

        return sendSuccess(res, data);
    },
);

/**
 * GET /
 *
 * Supports filters and pagination through query parameters.
 */
export const listStaff = asyncHandler(async (req, res) => {
    const data = await adminStaffService.listStaff(req.query);

    return sendSuccess(res, data);
});

/**
 * GET /roles
 */
export const listStaffRoles = asyncHandler(
    async (req, res) => {
        const data = await adminStaffService.listStaffRoles();

        return sendSuccess(res, data);
    },
);

/**
 * GET /permissions
 */
export const listStaffPermissions = asyncHandler(
    async (req, res) => {
        const data = await adminStaffService.listStaffPermissions();

        return sendSuccess(res, data);
    },
);

/**
 * GET /:staffId
 */
export const getStaffDetails = asyncHandler(
    async (req, res) => {
        const data = await adminStaffService.getStaffDetails(
            req.params.staffId,
        );

        return sendSuccess(res, data);
    },
);

/**
 * POST /
 */
export const createStaff = asyncHandler(async (req, res) => {
    const data = await adminStaffService.createStaff(
        req.body,
        getActor(req),
        getActorStaffId(req),
        getRequestContext(req),
    );

    return sendSuccess(res, data, 201);
});

/**
 * PATCH /:staffId
 */
export const updateStaff = asyncHandler(
    async (req, res) => {
        const data = await adminStaffService.updateStaff(
            req.params.staffId,
            req.body,
            getActor(req),
            getActorStaffId(req),
            getRequestContext(req),
        );

        return sendSuccess(res, data);
    },
);

/**
 * PATCH /:staffId/status
 *
 * Expected body:
 * { "status": "active" }
 *
 * Supported status values depend on the service and schema:
 * active, suspended, deactivated, locked.
 */
export const updateStaffStatus = asyncHandler(
    async (req, res) => {
        const data = await adminStaffService.updateStaffStatus(
            req.params.staffId,
            req.body.status,
            getActor(req),
            getActorStaffId(req),
            getRequestContext(req),
        );

        return sendSuccess(res, data);
    },
);

/**
 * PUT /:staffId/permissions
 *
 * Expected body:
 * {
 *   "overrides": [
 *     { "permissionId": 1, "accessType": "grant" },
 *     { "permissionId": 2, "accessType": "deny" }
 *   ]
 * }
 */
export const updateStaffPermissions = asyncHandler(
    async (req, res) => {
        const data =
            await adminStaffService.updateStaffPermissions(
                req.params.staffId,
                req.body.overrides,
                getActor(req),
                getActorStaffId(req),
                getRequestContext(req),
            );

        return sendSuccess(res, data);
    },
);

/**
 * DELETE /:staffId/permissions/:permissionId
 */
export const removeStaffPermissionOverride =
    asyncHandler(async (req, res) => {
        const data =
            await adminStaffService.removeStaffPermissionOverride(
                req.params.staffId,
                req.params.permissionId,
                getActor(req),
                getActorStaffId(req),
                getRequestContext(req),
            );

        return sendSuccess(res, data);
    });

/**
 * GET /:staffId/activity
 */
export const getStaffActivity = asyncHandler(
    async (req, res) => {
        const data = await adminStaffService.getStaffActivity(
            req.params.staffId,
            req.query,
        );

        return sendSuccess(res, data);
    },
);

/**
 * GET /:staffId/sessions
 */
export const getStaffSessions = asyncHandler(
    async (req, res) => {
        const data = await adminStaffService.getStaffSessions(
            req.params.staffId,
            req.query,
        );

        return sendSuccess(res, data);
    },
);

/**
 * POST /:staffId/sessions/:sessionId/revoke
 */
export const revokeStaffSession = asyncHandler(
    async (req, res) => {
        const data = await adminStaffService.revokeStaffSession(
            req.params.staffId,
            req.params.sessionId,
            getActor(req),
            getActorStaffId(req),
            getRequestContext(req),
        );

        return sendSuccess(res, data);
    },
);
