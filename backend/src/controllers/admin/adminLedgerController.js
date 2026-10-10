
import {
    getLedgerOverview,
    getLedgerEntries,
    getLedgerEntryById,
    getLedgerHashInspection,
    getLedgerAuditOverview,
    getLedgerAuditLogs,
    getLedgerAuditLogById,
} from "../../services/admin/adminLedgerService.js";

function getFilters(req) {
    const {
        page,
        limit,
        search,
        entryType,
        assetType,
        userId,
        walletId,
        tokenId,
        transactionId,
        currency,
        startDate,
        endDate,
        entityType,
        action,
    } = req.query;

    return {
        page,
        limit,
        search,
        entryType,
        assetType,
        userId,
        walletId,
        tokenId,
        transactionId,
        currency,
        startDate,
        endDate,
        entityType,
        action,
    };
}

function parsePositiveId(value) {
    const id = Number(value);

    return Number.isSafeInteger(id) && id > 0
        ? id
        : null;
}

function sendError(res, error, logMessage, publicMessage) {
    console.error(`${logMessage}:`, error);

    return res.status(500).json({
        success: false,
        message: publicMessage,
    });
}

export async function getLedgerOverviewController(req, res) {
    try {
        const data = await getLedgerOverview();

        return res.status(200).json({
            success: true,
            message: "Ledger overview retrieved successfully.",
            data,
        });
    } catch (error) {
        return sendError(
            res,
            error,
            "Get admin ledger overview error",
            "Unable to retrieve the ledger overview."
        );
    }
}

export async function getLedgerEntriesController(req, res) {
    try {
        const data = await getLedgerEntries(getFilters(req));

        return res.status(200).json({
            success: true,
            message: "Ledger entries retrieved successfully.",
            data,
        });
    } catch (error) {
        return sendError(
            res,
            error,
            "Get admin ledger entries error",
            "Unable to retrieve ledger entries."
        );
    }
}

export async function getLedgerEntryDetailsController(req, res) {
    const entryId = parsePositiveId(req.params.id);

    if (!entryId) {
        return res.status(400).json({
            success: false,
            message: "A valid ledger entry ID is required.",
        });
    }

    try {
        const entry = await getLedgerEntryById(entryId);

        if (!entry) {
            return res.status(404).json({
                success: false,
                message: "Ledger entry not found.",
            });
        }

        return res.status(200).json({
            success: true,
            message: "Ledger entry details retrieved successfully.",
            data: entry,
        });
    } catch (error) {
        return sendError(
            res,
            error,
            "Get admin ledger entry details error",
            "Unable to retrieve ledger entry details."
        );
    }
}

export async function getLedgerHashInspectionController(req, res) {
    const entryId = parsePositiveId(req.params.id);

    if (!entryId) {
        return res.status(400).json({
            success: false,
            message: "A valid ledger entry ID is required.",
        });
    }

    try {
        const data = await getLedgerHashInspection(entryId);

        if (!data) {
            return res.status(404).json({
                success: false,
                message: "Ledger entry not found.",
            });
        }

        return res.status(200).json({
            success: true,
            message: "Stored ledger hash information retrieved.",
            data,
        });
    } catch (error) {
        return sendError(
            res,
            error,
            "Get admin ledger hash inspection error",
            "Unable to retrieve ledger hash information."
        );
    }
}

export async function getLedgerAuditOverviewController(req, res) {
    try {
        const data = await getLedgerAuditOverview();

        return res.status(200).json({
            success: true,
            message: "Audit overview retrieved successfully.",
            data,
        });
    } catch (error) {
        return sendError(
            res,
            error,
            "Get admin ledger audit overview error",
            "Unable to retrieve the audit overview."
        );
    }
}

export async function getLedgerAuditLogsController(req, res) {
    try {
        const data = await getLedgerAuditLogs(getFilters(req));

        return res.status(200).json({
            success: true,
            message: "Audit logs retrieved successfully.",
            data,
        });
    } catch (error) {
        return sendError(
            res,
            error,
            "Get admin ledger audit logs error",
            "Unable to retrieve audit logs."
        );
    }
}

export async function getLedgerAuditLogDetailsController(req, res) {
    const logId = parsePositiveId(req.params.id);

    if (!logId) {
        return res.status(400).json({
            success: false,
            message: "A valid audit log ID is required.",
        });
    }

    try {
        const log = await getLedgerAuditLogById(logId);

        if (!log) {
            return res.status(404).json({
                success: false,
                message: "Audit log not found.",
            });
        }

        return res.status(200).json({
            success: true,
            message: "Audit log details retrieved successfully.",
            data: log,
        });
    } catch (error) {
        return sendError(
            res,
            error,
            "Get admin ledger audit log details error",
            "Unable to retrieve audit log details."
        );
    }
}
