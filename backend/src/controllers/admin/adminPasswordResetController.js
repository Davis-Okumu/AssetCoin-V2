import {
    requestAdminPasswordReset,
    resetAdminPassword,
} from "../../services/admin/adminPasswordResetService.js";

import {
    getRequestMetadata,
} from "../../utils/adminRequest.js";

// =========================================================
// FORGOT PASSWORD
// =========================================================

/**
 * POST /api/admin/auth/forgot-password
 *
 * Request body:
 *
 * {
 *   "identifier": "admin@example.com"
 * }
 *
 * The identifier may be either:
 *
 * - email
 * - phone number
 */
export async function adminForgotPassword(
    request,
    response,
    next,
) {
    try {
        const {
            identifier,
        } = request.body;

        if (
            !identifier ||
            typeof identifier !== "string"
        ) {
            return response.status(400).json({
                success: false,
                code: "INVALID_IDENTIFIER",
                message:
                    "Email or phone number is required.",
            });
        }

        const metadata =
            getRequestMetadata(request);

        const result =
            await requestAdminPasswordReset({
                identifier,
                ...metadata,
            });

        /*
         * IMPORTANT:
         *
         * Always return the same public response.
         *
         * This prevents attackers from determining whether
         * a particular email or phone belongs to an admin.
         */

        const responseBody = {
            success: true,
            message:
                "If an administrator account exists for the supplied identifier, a password reset request has been created.",
        };

        /*
         * DEVELOPMENT ONLY
         *
         * This allows you to test the reset flow locally
         * before an email/SMS delivery provider is connected.
         *
         * NEVER expose the reset token in production.
         */
        if (
            process.env.NODE_ENV !== "production" &&
            result.accountFound &&
            result.resetToken
        ) {
            responseBody.resetToken =
                result.resetToken;

            responseBody.expiresAt =
                result.expiresAt;
        }

        return response.status(200).json(
            responseBody,
        );
    } catch (error) {
        return next(error);
    }
}

// =========================================================
// RESET PASSWORD
// =========================================================

/**
 * POST /api/admin/auth/reset-password
 *
 * Request body:
 *
 * {
 *   "token": "...",
 *   "newPassword": "..."
 * }
 */
export async function adminResetPassword(
    request,
    response,
    next,
) {
    try {
        const {
            token,
            resetToken,
            newPassword,
        } = request.body;

        /*
         * Support both:
         *
         * {
         *   token: "..."
         * }
         *
         * and:
         *
         * {
         *   resetToken: "..."
         * }
         *
         * The frontend can therefore use either naming
         * convention without changing the backend.
         */
        const suppliedToken =
            token || resetToken;

        if (
            !suppliedToken ||
            typeof suppliedToken !== "string"
        ) {
            return response.status(400).json({
                success: false,
                code: "INVALID_RESET_TOKEN",
                message:
                    "Password reset token is required.",
            });
        }

        if (
            !newPassword ||
            typeof newPassword !== "string"
        ) {
            return response.status(400).json({
                success: false,
                code: "INVALID_PASSWORD",
                message:
                    "New password is required.",
            });
        }

        const metadata =
            getRequestMetadata(request);

        const result =
            await resetAdminPassword({
                resetToken: suppliedToken,
                newPassword,
                ...metadata,
            });

        if (!result.success) {
            let statusCode = 400;

            if (
                result.code ===
                "ACCOUNT_INACTIVE"
            ) {
                statusCode = 403;
            }

            return response.status(
                statusCode,
            ).json({
                success: false,
                code: result.code,
                message: result.message,
            });
        }

        return response.status(200).json({
            success: true,
            code:
                "PASSWORD_RESET_SUCCESS",
            message:
                "Administrator password has been reset successfully. Please sign in using your new password.",
        });
    } catch (error) {
        return next(error);
    }
}