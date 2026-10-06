import {
    getAdminKycApplications,
    getAdminKycStats,
    getAdminKycApplication,
    assignKycApplication,
    startKycReview,
    requestKycInformation,
    approveKyc,
    rejectKyc,
} from "../../services/admin/adminKycService.js";

// =========================================================
// ADMIN KYC CONTROLLER
// =========================================================
//
// Responsibilities:
//
// - Receive administrator HTTP requests.
// - Validate request input.
// - Pass authenticated administrator identity to the service.
// - Return consistent API responses.
// - Keep business logic inside adminKycService.js.
//
// IMPORTANT:
//
// This controller does NOT upload KYC documents.
//
// Customers submit their KYC through the AssetCoin
// mobile application.
//
// Administrators use these endpoints to review,
// verify, request additional information, or reject
// submitted KYC applications.
//
// =========================================================


// =========================================================
// GET KYC APPLICATIONS
// =========================================================

export async function getKycApplications(
    request,
    response,
    next,
) {
    try {
        const {
            status = null,
            search = null,
            assignedTo = null,
            page = 1,
            limit = 20,
        } = request.query;

        const result =
            await getAdminKycApplications({
                status,
                search,
                assignedTo,
                page,
                limit,
            });

        return response.status(200).json({
            success: true,
            data: result,
        });
    } catch (error) {
        console.error(
            "Admin KYC applications error:",
            error,
        );

        return next(error);
    }
}


// =========================================================
// GET KYC STATISTICS
// =========================================================

export async function getKycStats(
    request,
    response,
    next,
) {
    try {
        const stats =
            await getAdminKycStats();

        return response.status(200).json({
            success: true,
            data: stats,
        });
    } catch (error) {
        console.error(
            "Admin KYC statistics error:",
            error,
        );

        return next(error);
    }
}


// =========================================================
// GET KYC APPLICATION DETAILS
// =========================================================

export async function getKycApplication(
    request,
    response,
    next,
) {
    try {
        const {
            id,
        } = request.params;

        const application =
            await getAdminKycApplication(id);

        if (!application) {
            return response.status(404).json({
                success: false,
                message:
                    "KYC application not found.",
            });
        }

        return response.status(200).json({
            success: true,
            data: application,
        });
    } catch (error) {
        console.error(
            "Admin KYC application details error:",
            error,
        );

        return next(error);
    }
}


// =========================================================
// ASSIGN KYC APPLICATION
// =========================================================

export async function assignKyc(
    request,
    response,
    next,
) {
    try {
        const {
            id,
        } = request.params;

        const {
            assignedTo,
            priority = "normal",
            notes = null,
        } = request.body ?? {};

        // -------------------------------------------------------
        // Validate assigned administrator
        // -------------------------------------------------------

        if (
            assignedTo === undefined ||
            assignedTo === null ||
            assignedTo === ""
        ) {
            return response.status(400).json({
                success: false,
                message:
                    "assignedTo is required.",
            });
        }

        const result =
            await assignKycApplication({
                kycId: id,
                assignedTo,
                assignedBy:
                    request.adminId,
                priority,
                notes,
                ipAddress:
                    request.ip ??
                    request.socket?.remoteAddress ??
                    null,
                userAgent:
                    request.get("user-agent") ??
                    null,
            });

        return response.status(200).json({
            success: true,
            message:
                "KYC application assigned successfully.",
            data: result,
        });
    } catch (error) {
        console.error(
            "Admin KYC assignment error:",
            error,
        );

        return next(error);
    }
}


// =========================================================
// START KYC REVIEW
// =========================================================

export async function startReview(
    request,
    response,
    next,
) {
    try {
        const {
            id,
        } = request.params;

        const result =
            await startKycReview({
                kycId: id,
                adminId:
                    request.adminId,
                ipAddress:
                    request.ip ??
                    request.socket?.remoteAddress ??
                    null,
                userAgent:
                    request.get("user-agent") ??
                    null,
            });

        return response.status(200).json({
            success: true,
            message:
                "KYC review started successfully.",
            data: result,
        });
    } catch (error) {
        console.error(
            "Admin KYC start review error:",
            error,
        );

        return next(error);
    }
}


// =========================================================
// REQUEST ADDITIONAL INFORMATION
// =========================================================

export async function requestInformation(
    request,
    response,
    next,
) {
    try {
        const {
            id,
        } = request.params;

        const {
            comments,
        } = request.body ?? {};

        // -------------------------------------------------------
        // Validate comments
        // -------------------------------------------------------

        if (
            typeof comments !== "string" ||
            !comments.trim()
        ) {
            return response.status(400).json({
                success: false,
                message:
                    "Comments are required when requesting additional information.",
            });
        }

        const result =
            await requestKycInformation({
                kycId: id,
                adminId:
                    request.adminId,
                comments,
                ipAddress:
                    request.ip ??
                    request.socket?.remoteAddress ??
                    null,
                userAgent:
                    request.get("user-agent") ??
                    null,
            });

        return response.status(200).json({
            success: true,
            message:
                "Additional KYC information has been requested.",
            data: result,
        });
    } catch (error) {
        console.error(
            "Admin KYC information request error:",
            error,
        );

        return next(error);
    }
}


// =========================================================
// APPROVE KYC APPLICATION
// =========================================================

export async function approveKycApplication(
    request,
    response,
    next,
) {
    try {
        const {
            id,
        } = request.params;

        const {
            comments = null,
        } = request.body ?? {};

        const result =
            await approveKyc({
                kycId: id,
                adminId:
                    request.adminId,
                comments,
                ipAddress:
                    request.ip ??
                    request.socket?.remoteAddress ??
                    null,
                userAgent:
                    request.get("user-agent") ??
                    null,
            });

        return response.status(200).json({
            success: true,
            message:
                "KYC application approved successfully.",
            data: result,
        });
    } catch (error) {
        console.error(
            "Admin KYC approval error:",
            error,
        );

        return next(error);
    }
}


// =========================================================
// REJECT KYC APPLICATION
// =========================================================

export async function rejectKycApplication(
    request,
    response,
    next,
) {
    try {
        const {
            id,
        } = request.params;

        const {
            rejectionReason,
            comments = null,
        } = request.body ?? {};

        // -------------------------------------------------------
        // Validate rejection reason
        // -------------------------------------------------------

        if (
            typeof rejectionReason !== "string" ||
            !rejectionReason.trim()
        ) {
            return response.status(400).json({
                success: false,
                message:
                    "A rejection reason is required.",
            });
        }

        const result =
            await rejectKyc({
                kycId: id,
                adminId:
                    request.adminId,
                rejectionReason,
                comments,
                ipAddress:
                    request.ip ??
                    request.socket?.remoteAddress ??
                    null,
                userAgent:
                    request.get("user-agent") ??
                    null,
            });

        return response.status(200).json({
            success: true,
            message:
                "KYC application rejected successfully.",
            data: result,
        });
    } catch (error) {
        console.error(
            "Admin KYC rejection error:",
            error,
        );

        return next(error);
    }
}