// =========================================================
// ADMIN AUDIT UTILITIES
// =========================================================

import crypto from "crypto";

// =========================================================
// SAFE JSON VALUE
// =========================================================

/**
 * Convert a value into something safe to
 * store inside an audit record.
 *
 * Passwords, tokens and other sensitive
 * fields must never enter the audit log.
 */
export function sanitizeAuditValue(
    value,
) {
    if (
        value === null ||
        value === undefined
    ) {
        return value;
    }

    if (
        typeof value !== "object"
    ) {
        return value;
    }

    if (Array.isArray(value)) {
        return value.map(
            sanitizeAuditValue,
        );
    }

    const sanitized = {};

    for (
        const [key, currentValue]
        of Object.entries(value)
    ) {
        const normalizedKey =
            key.toLowerCase();

        if (
            normalizedKey.includes(
                "password",
            ) ||
            normalizedKey.includes(
                "passwordhash",
            ) ||
            normalizedKey.includes(
                "token",
            ) ||
            normalizedKey.includes(
                "secret",
            ) ||
            normalizedKey.includes(
                "authorization",
            ) ||
            normalizedKey.includes(
                "sessiontokenhash",
            )
        ) {
            sanitized[key] =
                "[REDACTED]";

            continue;
        }

        sanitized[key] =
            sanitizeAuditValue(
                currentValue,
            );
    }

    return sanitized;
}

// =========================================================
// NORMALIZE AUDIT VALUES
// =========================================================

export function normalizeAuditValue(
    value,
) {
    if (
        value === undefined
    ) {
        return null;
    }

    return sanitizeAuditValue(
        value,
    );
}

// =========================================================
// CREATE AUDIT PAYLOAD
// =========================================================

export function createAuditPayload({
    staffId,
    action,
    module,
    entityType,
    entityId = null,
    oldValues = null,
    newValues = null,
    ipAddress = null,
    userAgent = null,
}) {
    return {
        staffId:
            normalizePositiveInteger(
                staffId,
            ),

        action:
            normalizeText(action),

        module:
            normalizeText(module),

        entityType:
            normalizeText(entityType),

        entityId:
            entityId === null ||
                entityId === undefined
                ? null
                : normalizePositiveInteger(
                    entityId,
                ),

        oldValues:
            normalizeAuditValue(
                oldValues,
            ),

        newValues:
            normalizeAuditValue(
                newValues,
            ),

        ipAddress:
            normalizeIpAddress(
                ipAddress,
            ),

        userAgent:
            normalizeUserAgent(
                userAgent,
            ),
    };
}

// =========================================================
// AUDIT HASH
// =========================================================

/**
 * Create a deterministic SHA-256 hash
 * for an audit payload.
 *
 * The database audit service can combine
 * this with the previous audit hash to
 * create a hash-linked audit chain.
 */
export function hashAuditPayload(
    payload,
) {
    const normalized =
        JSON.stringify(
            payload,
        );

    return crypto
        .createHash("sha256")
        .update(
            normalized,
            "utf8",
        )
        .digest("hex");
}

// =========================================================
// INTEGER
// =========================================================

function normalizePositiveInteger(
    value,
) {
    const parsed =
        Number(value);

    if (
        !Number.isInteger(parsed) ||
        parsed <= 0
    ) {
        return null;
    }

    return parsed;
}

// =========================================================
// TEXT
// =========================================================

function normalizeText(
    value,
) {
    if (
        typeof value !== "string"
    ) {
        return null;
    }

    const normalized =
        value.trim();

    return normalized || null;
}

// =========================================================
// IP ADDRESS
// =========================================================

function normalizeIpAddress(
    value,
) {
    if (
        typeof value !== "string"
    ) {
        return null;
    }

    return value
        .trim()
        .slice(0, 255) || null;
}

// =========================================================
// USER AGENT
// =========================================================

function normalizeUserAgent(
    value,
) {
    if (
        typeof value !== "string"
    ) {
        return null;
    }

    return value
        .trim()
        .slice(0, 1000) || null;
}