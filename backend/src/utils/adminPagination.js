// =========================================================
// ADMIN PAGINATION UTILITIES
// =========================================================

const DEFAULT_PAGE = 1;

const DEFAULT_LIMIT = 20;

const MAX_LIMIT = 100;

// =========================================================
// NORMALIZE PAGINATION
// =========================================================

/**
 * Normalize pagination query parameters.
 *
 * Example:
 *
 * ?page=2&limit=25
 *
 * becomes:
 *
 * {
 *   page: 2,
 *   limit: 25,
 *   offset: 25
 * }
 */
export function normalizeAdminPagination(
    query = {},
) {
    const page =
        parsePositiveInteger(
            query.page,
            DEFAULT_PAGE,
        );

    let limit =
        parsePositiveInteger(
            query.limit,
            DEFAULT_LIMIT,
        );

    if (limit > MAX_LIMIT) {
        limit = MAX_LIMIT;
    }

    const offset =
        (page - 1) * limit;

    return {
        page,
        limit,
        offset,
    };
}

// =========================================================
// CREATE PAGINATION META
// =========================================================

/**
 * Create standardized pagination metadata.
 */
export function createAdminPaginationMeta({
    page,
    limit,
    total,
}) {
    const normalizedPage =
        Math.max(
            1,
            Number(page) || 1,
        );

    const normalizedLimit =
        Math.max(
            1,
            Number(limit) || DEFAULT_LIMIT,
        );

    const normalizedTotal =
        Math.max(
            0,
            Number(total) || 0,
        );

    const totalPages =
        normalizedTotal === 0
            ? 0
            : Math.ceil(
                normalizedTotal /
                normalizedLimit,
            );

    return {
        page: normalizedPage,
        limit: normalizedLimit,
        total: normalizedTotal,
        totalPages,
        hasNextPage:
            totalPages > 0 &&
            normalizedPage < totalPages,
        hasPreviousPage:
            normalizedPage > 1,
    };
}

// =========================================================
// PAGINATED RESPONSE DATA
// =========================================================

/**
 * Build a standard paginated data structure.
 */
export function buildAdminPaginatedResult({
    items = [],
    page,
    limit,
    total,
}) {
    return {
        items,
        pagination:
            createAdminPaginationMeta({
                page,
                limit,
                total,
            }),
    };
}

// =========================================================
// PARSE INTEGER
// =========================================================

function parsePositiveInteger(
    value,
    fallback,
) {
    const parsed =
        Number.parseInt(
            value,
            10,
        );

    if (
        !Number.isInteger(parsed) ||
        parsed < 1
    ) {
        return fallback;
    }

    return parsed;
}

// =========================================================
// CONSTANTS
// =========================================================

export {
    DEFAULT_PAGE,
    DEFAULT_LIMIT,
    MAX_LIMIT,
};