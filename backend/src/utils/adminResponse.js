// =========================================================
// ADMIN RESPONSE UTILITIES
// =========================================================

// =========================================================
// SUCCESS RESPONSE
// =========================================================

/**
 * Send a successful administrator API response.
 */
export function sendAdminSuccess(
    response,
    {
        statusCode = 200,
        message = null,
        data = null,
        meta = null,
    } = {},
) {
    const body = {
        success: true,
    };

    if (message) {
        body.message = message;
    }

    if (data !== null) {
        body.data = data;
    }

    if (meta !== null) {
        body.meta = meta;
    }

    return response
        .status(statusCode)
        .json(body);
}

// =========================================================
// ERROR RESPONSE
// =========================================================

/**
 * Send a standardized administrator API error.
 */
export function sendAdminError(
    response,
    {
        statusCode = 500,
        message = "An unexpected error occurred.",
        code = "ADMIN_INTERNAL_ERROR",
        details = undefined,
    } = {},
) {
    const body = {
        success: false,
        code,
        message,
    };

    if (
        details !== undefined &&
        details !== null
    ) {
        body.details = details;
    }

    return response
        .status(statusCode)
        .json(body);
}

// =========================================================
// VALIDATION ERROR
// =========================================================

export function sendAdminValidationError(
    response,
    message = "The submitted data is invalid.",
    details = undefined,
) {
    return sendAdminError(
        response,
        {
            statusCode: 400,
            code: "VALIDATION_ERROR",
            message,
            details,
        },
    );
}

// =========================================================
// UNAUTHORIZED
// =========================================================

export function sendAdminUnauthorized(
    response,
    message =
        "Administrator authentication is required.",
) {
    return sendAdminError(
        response,
        {
            statusCode: 401,
            code: "ADMIN_UNAUTHORIZED",
            message,
        },
    );
}

// =========================================================
// FORBIDDEN
// =========================================================

export function sendAdminForbidden(
    response,
    message =
        "You do not have permission to perform this action.",
) {
    return sendAdminError(
        response,
        {
            statusCode: 403,
            code: "INSUFFICIENT_PERMISSION",
            message,
        },
    );
}

// =========================================================
// NOT FOUND
// =========================================================

export function sendAdminNotFound(
    response,
    message =
        "The requested resource was not found.",
) {
    return sendAdminError(
        response,
        {
            statusCode: 404,
            code: "RESOURCE_NOT_FOUND",
            message,
        },
    );
}

// =========================================================
// CONFLICT
// =========================================================

export function sendAdminConflict(
    response,
    message =
        "The requested operation conflicts with existing data.",
    details = undefined,
) {
    return sendAdminError(
        response,
        {
            statusCode: 409,
            code: "RESOURCE_CONFLICT",
            message,
            details,
        },
    );
}

// =========================================================
// TOO MANY REQUESTS
// =========================================================

export function sendAdminRateLimited(
    response,
    message =
        "Too many requests. Please try again later.",
) {
    return sendAdminError(
        response,
        {
            statusCode: 429,
            code: "RATE_LIMITED",
            message,
        },
    );
}