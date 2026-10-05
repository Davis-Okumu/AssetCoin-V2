// =========================================================
// ASSETCOIN ADMIN PERMISSIONS
// =========================================================
//
// Central permission definitions.
//
// These values MUST match the `code` column
// in the `admin_permissions` database table.
//
// =========================================================

// =========================================================
// DASHBOARD
// =========================================================

export const ADMIN_PERMISSIONS = Object.freeze({
    DASHBOARD_VIEW:
        "dashboard.view",

    // -------------------------------------------------------
    // USERS
    // -------------------------------------------------------

    USERS_VIEW:
        "users.view",

    USERS_CREATE:
        "users.create",

    USERS_UPDATE:
        "users.update",

    USERS_SUSPEND:
        "users.suspend",

    USERS_DEACTIVATE:
        "users.deactivate",

    // -------------------------------------------------------
    // KYC
    // -------------------------------------------------------

    KYC_VIEW:
        "kyc.view",

    KYC_REVIEW:
        "kyc.review",

    KYC_APPROVE:
        "kyc.approve",

    KYC_REJECT:
        "kyc.reject",

    // -------------------------------------------------------
    // ASSETS
    // -------------------------------------------------------

    ASSETS_VIEW:
        "assets.view",

    ASSETS_REVIEW:
        "assets.review",

    ASSETS_APPROVE:
        "assets.approve",

    ASSETS_REJECT:
        "assets.reject",

    ASSETS_ASSIGN:
        "assets.assign",

    ASSETS_SUSPEND:
        "assets.suspend",

    // -------------------------------------------------------
    // TOKENIZATION
    // -------------------------------------------------------

    TOKENIZATION_VIEW:
        "tokenization.view",

    TOKENIZATION_CREATE:
        "tokenization.create",

    TOKENIZATION_APPROVE:
        "tokenization.approve",

    TOKENIZATION_REJECT:
        "tokenization.reject",

    TOKENIZATION_SUSPEND:
        "tokenization.suspend",

    // -------------------------------------------------------
    // TRADING
    // -------------------------------------------------------

    TRADING_VIEW:
        "trading.view",

    TRADING_MANAGE:
        "trading.manage",

    TRADING_SUSPEND_LISTINGS:
        "trading.suspend_listings",

    TRADING_MANAGE_ORDERS:
        "trading.manage_orders",

    // -------------------------------------------------------
    // FINANCE
    // -------------------------------------------------------

    FINANCE_VIEW:
        "finance.view",

    FINANCE_MANAGE:
        "finance.manage",

    FINANCE_APPROVE:
        "finance.approve",

    // -------------------------------------------------------
    // WALLETS
    // -------------------------------------------------------

    WALLETS_VIEW:
        "wallets.view",

    WALLETS_MANAGE:
        "wallets.manage",

    // -------------------------------------------------------
    // LEDGER
    // -------------------------------------------------------

    LEDGER_VIEW:
        "ledger.view",

    LEDGER_EXPORT:
        "ledger.export",

    // -------------------------------------------------------
    // SUPPORT
    // -------------------------------------------------------

    SUPPORT_VIEW:
        "support.view",

    SUPPORT_MANAGE:
        "support.manage",

    SUPPORT_ASSIGN:
        "support.assign",

    // -------------------------------------------------------
    // NOTIFICATIONS
    // -------------------------------------------------------

    NOTIFICATIONS_VIEW:
        "notifications.view",

    NOTIFICATIONS_CREATE:
        "notifications.create",

    NOTIFICATIONS_SEND:
        "notifications.send",

    // -------------------------------------------------------
    // CONTENT
    // -------------------------------------------------------

    CONTENT_VIEW:
        "content.view",

    CONTENT_CREATE:
        "content.create",

    CONTENT_UPDATE:
        "content.update",

    CONTENT_PUBLISH:
        "content.publish",

    // -------------------------------------------------------
    // STAFF
    // -------------------------------------------------------

    STAFF_VIEW:
        "staff.view",

    STAFF_CREATE:
        "staff.create",

    STAFF_UPDATE:
        "staff.update",

    STAFF_SUSPEND:
        "staff.suspend",

    STAFF_PERMISSIONS:
        "staff.permissions",

    // -------------------------------------------------------
    // SETTINGS
    // -------------------------------------------------------

    SETTINGS_VIEW:
        "settings.view",

    SETTINGS_UPDATE:
        "settings.update",

    // -------------------------------------------------------
    // AUDIT
    // -------------------------------------------------------

    AUDIT_VIEW:
        "audit.view",

    AUDIT_EXPORT:
        "audit.export",
});

// =========================================================
// PERMISSION GROUPS
// =========================================================

export const ADMIN_PERMISSION_GROUPS =
    Object.freeze({
        DASHBOARD: [
            ADMIN_PERMISSIONS.DASHBOARD_VIEW,
        ],

        USERS: [
            ADMIN_PERMISSIONS.USERS_VIEW,
            ADMIN_PERMISSIONS.USERS_CREATE,
            ADMIN_PERMISSIONS.USERS_UPDATE,
            ADMIN_PERMISSIONS.USERS_SUSPEND,
            ADMIN_PERMISSIONS.USERS_DEACTIVATE,
        ],

        KYC: [
            ADMIN_PERMISSIONS.KYC_VIEW,
            ADMIN_PERMISSIONS.KYC_REVIEW,
            ADMIN_PERMISSIONS.KYC_APPROVE,
            ADMIN_PERMISSIONS.KYC_REJECT,
        ],

        ASSETS: [
            ADMIN_PERMISSIONS.ASSETS_VIEW,
            ADMIN_PERMISSIONS.ASSETS_REVIEW,
            ADMIN_PERMISSIONS.ASSETS_APPROVE,
            ADMIN_PERMISSIONS.ASSETS_REJECT,
            ADMIN_PERMISSIONS.ASSETS_ASSIGN,
            ADMIN_PERMISSIONS.ASSETS_SUSPEND,
        ],

        TOKENIZATION: [
            ADMIN_PERMISSIONS.TOKENIZATION_VIEW,
            ADMIN_PERMISSIONS.TOKENIZATION_CREATE,
            ADMIN_PERMISSIONS.TOKENIZATION_APPROVE,
            ADMIN_PERMISSIONS.TOKENIZATION_REJECT,
            ADMIN_PERMISSIONS.TOKENIZATION_SUSPEND,
        ],

        TRADING: [
            ADMIN_PERMISSIONS.TRADING_VIEW,
            ADMIN_PERMISSIONS.TRADING_MANAGE,
            ADMIN_PERMISSIONS.TRADING_SUSPEND_LISTINGS,
            ADMIN_PERMISSIONS.TRADING_MANAGE_ORDERS,
        ],

        FINANCE: [
            ADMIN_PERMISSIONS.FINANCE_VIEW,
            ADMIN_PERMISSIONS.FINANCE_MANAGE,
            ADMIN_PERMISSIONS.FINANCE_APPROVE,
        ],

        WALLETS: [
            ADMIN_PERMISSIONS.WALLETS_VIEW,
            ADMIN_PERMISSIONS.WALLETS_MANAGE,
        ],

        LEDGER: [
            ADMIN_PERMISSIONS.LEDGER_VIEW,
            ADMIN_PERMISSIONS.LEDGER_EXPORT,
        ],

        SUPPORT: [
            ADMIN_PERMISSIONS.SUPPORT_VIEW,
            ADMIN_PERMISSIONS.SUPPORT_MANAGE,
            ADMIN_PERMISSIONS.SUPPORT_ASSIGN,
        ],

        NOTIFICATIONS: [
            ADMIN_PERMISSIONS.NOTIFICATIONS_VIEW,
            ADMIN_PERMISSIONS.NOTIFICATIONS_CREATE,
            ADMIN_PERMISSIONS.NOTIFICATIONS_SEND,
        ],

        CONTENT: [
            ADMIN_PERMISSIONS.CONTENT_VIEW,
            ADMIN_PERMISSIONS.CONTENT_CREATE,
            ADMIN_PERMISSIONS.CONTENT_UPDATE,
            ADMIN_PERMISSIONS.CONTENT_PUBLISH,
        ],

        STAFF: [
            ADMIN_PERMISSIONS.STAFF_VIEW,
            ADMIN_PERMISSIONS.STAFF_CREATE,
            ADMIN_PERMISSIONS.STAFF_UPDATE,
            ADMIN_PERMISSIONS.STAFF_SUSPEND,
            ADMIN_PERMISSIONS.STAFF_PERMISSIONS,
        ],

        SETTINGS: [
            ADMIN_PERMISSIONS.SETTINGS_VIEW,
            ADMIN_PERMISSIONS.SETTINGS_UPDATE,
        ],

        AUDIT: [
            ADMIN_PERMISSIONS.AUDIT_VIEW,
            ADMIN_PERMISSIONS.AUDIT_EXPORT,
        ],
    });

// =========================================================
// ADMIN ROLES
// =========================================================

export const ADMIN_ROLES =
    Object.freeze({
        SUPER_ADMIN:
            "super_admin",

        ASSET_OFFICER:
            "asset_officer",

        KYC_OFFICER:
            "kyc_officer",

        TOKENIZATION_OFFICER:
            "tokenization_officer",

        FINANCE_OFFICER:
            "finance_officer",

        TRADING_OFFICER:
            "trading_officer",

        SUPPORT_OFFICER:
            "support_officer",

        AUDITOR:
            "auditor",
    });

// =========================================================
// PERMISSION CHECK
// =========================================================

/**
 * Check whether a permission exists
 * in a permission array.
 */
export function hasPermission(
    permissions,
    permission,
) {
    if (
        !Array.isArray(permissions) ||
        typeof permission !== "string"
    ) {
        return false;
    }

    return permissions.includes(
        permission,
    );
}

// =========================================================
// ANY PERMISSION
// =========================================================

export function hasAnyPermission(
    permissions,
    requiredPermissions,
) {
    if (
        !Array.isArray(permissions) ||
        !Array.isArray(requiredPermissions)
    ) {
        return false;
    }

    return requiredPermissions.some(
        (permission) =>
            permissions.includes(permission),
    );
}

// =========================================================
// ALL PERMISSIONS
// =========================================================

export function hasAllPermissions(
    permissions,
    requiredPermissions,
) {
    if (
        !Array.isArray(permissions) ||
        !Array.isArray(requiredPermissions)
    ) {
        return false;
    }

    return requiredPermissions.every(
        (permission) =>
            permissions.includes(permission),
    );
}

// =========================================================
// SUPER ADMIN CHECK
// =========================================================

export function isSuperAdmin(
    admin,
) {
    if (!admin) {
        return false;
    }

    const role =
        admin.roleCode ??
        admin.role_code ??
        admin.role ??
        null;

    return role ===
        ADMIN_ROLES.SUPER_ADMIN;
}