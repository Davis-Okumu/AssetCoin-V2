import {
    getTradingOverview,
    getAdminListings,
    getAdminListingById,
    suspendListing,
    reactivateListing,
    getAdminOrders,
    getAdminOrderById,
    getAdminTrades,
    getAdminTradeById,
    getAdminDisputes,
    getAdminDisputeById,
    createTradingDispute,
    assignTradingDispute,
    updateTradingDispute,
} from "../../services/admin/adminTradingService.js";

function getAdminId(req) {
    return (
        req.admin?.id ??
        req.admin?.staffId ??
        req.adminId ??
        req.adminAuth?.staffId
    );
}

function parseId(value) {
    const id = Number.parseInt(value, 10);

    return Number.isInteger(id) && id > 0
        ? id
        : null;
}

/**
 * ============================================================
 * OVERVIEW
 * ============================================================
 */

export async function getTradingOverviewController(
    req,
    res
) {
    try {
        const data = await getTradingOverview();

        return res.status(200).json({
            success: true,
            message:
                "Admin trading overview retrieved successfully.",
            data,
        });
    } catch (error) {
        console.error(
            "Get admin trading overview error:",
            error
        );

        return res.status(500).json({
            success: false,
            message:
                "Unable to retrieve the trading overview.",
        });
    }
}

/**
 * ============================================================
 * LISTINGS
 * ============================================================
 */

export async function getListingsController(
    req,
    res
) {
    try {
        const {
            search = "",
            status = "",
            listingType = "",
            page = 1,
            limit = 20,
        } = req.query;

        const result = await getAdminListings({
            search,
            status,
            listingType,
            page,
            limit,
        });

        return res.status(200).json({
            success: true,
            message:
                "Admin trading listings retrieved successfully.",
            data: {
                listings: result.listings,
                pagination: result.pagination,
            },
        });
    } catch (error) {
        console.error(
            "Get admin trading listings error:",
            error
        );

        return res.status(500).json({
            success: false,
            message:
                "Unable to retrieve trading listings.",
        });
    }
}

export async function getListingController(
    req,
    res
) {
    try {
        const listingId = parseId(req.params.id);

        if (!listingId) {
            return res.status(400).json({
                success: false,
                message: "Invalid listing ID.",
            });
        }

        const listing =
            await getAdminListingById(listingId);

        if (!listing) {
            return res.status(404).json({
                success: false,
                message: "Listing not found.",
            });
        }

        return res.status(200).json({
            success: true,
            message:
                "Admin trading listing retrieved successfully.",
            data: listing,
        });
    } catch (error) {
        console.error(
            "Get admin trading listing error:",
            error
        );

        return res.status(500).json({
            success: false,
            message:
                "Unable to retrieve the trading listing.",
        });
    }
}

export async function suspendListingController(
    req,
    res
) {
    try {
        const listingId = parseId(req.params.id);
        const adminId = getAdminId(req);

        if (!listingId) {
            return res.status(400).json({
                success: false,
                message: "Invalid listing ID.",
            });
        }

        if (!adminId) {
            return res.status(401).json({
                success: false,
                message:
                    "Unable to identify the authenticated administrator.",
            });
        }

        const reason =
            typeof req.body?.reason === "string"
                ? req.body.reason.trim()
                : "";

        if (!reason) {
            return res.status(400).json({
                success: false,
                message:
                    "A reason is required when suspending a listing.",
            });
        }

        const listing = await suspendListing(
            listingId,
            adminId,
            reason
        );

        return res.status(200).json({
            success: true,
            message: "Listing suspended successfully.",
            data: listing,
        });
    } catch (error) {
        console.error(
            "Suspend admin trading listing error:",
            error
        );

        if (
            error.code === "LISTING_NOT_FOUND"
        ) {
            return res.status(404).json({
                success: false,
                message: "Listing not found.",
            });
        }

        if (
            error.code ===
            "LISTING_ALREADY_SUSPENDED"
        ) {
            return res.status(409).json({
                success: false,
                message: error.message,
            });
        }

        return res.status(500).json({
            success: false,
            message:
                "Unable to suspend the listing.",
        });
    }
}

export async function reactivateListingController(
    req,
    res
) {
    try {
        const listingId = parseId(req.params.id);
        const adminId = getAdminId(req);

        if (!listingId) {
            return res.status(400).json({
                success: false,
                message: "Invalid listing ID.",
            });
        }

        if (!adminId) {
            return res.status(401).json({
                success: false,
                message:
                    "Unable to identify the authenticated administrator.",
            });
        }

        const reason =
            typeof req.body?.reason === "string"
                ? req.body.reason.trim()
                : "";

        if (!reason) {
            return res.status(400).json({
                success: false,
                message:
                    "A reason is required when reactivating a listing.",
            });
        }

        const listing = await reactivateListing(
            listingId,
            adminId,
            reason
        );

        return res.status(200).json({
            success: true,
            message:
                "Listing reactivated successfully.",
            data: listing,
        });
    } catch (error) {
        console.error(
            "Reactivate admin trading listing error:",
            error
        );

        if (
            error.code === "LISTING_NOT_FOUND"
        ) {
            return res.status(404).json({
                success: false,
                message: "Listing not found.",
            });
        }

        if (
            error.code === "LISTING_NOT_SUSPENDED" ||
            error.code === "LISTING_EMPTY" ||
            error.code === "LISTING_EXPIRED"
        ) {
            return res.status(409).json({
                success: false,
                message: error.message,
            });
        }

        return res.status(500).json({
            success: false,
            message:
                "Unable to reactivate the listing.",
        });
    }
}

/**
 * ============================================================
 * ORDERS
 * ============================================================
 */

export async function getOrdersController(
    req,
    res
) {
    try {
        const {
            search = "",
            status = "",
            orderType = "",
            page = 1,
            limit = 20,
        } = req.query;

        const result = await getAdminOrders({
            search,
            status,
            orderType,
            page,
            limit,
        });

        return res.status(200).json({
            success: true,
            message:
                "Admin trading orders retrieved successfully.",
            data: {
                orders: result.orders,
                pagination: result.pagination,
            },
        });
    } catch (error) {
        console.error(
            "Get admin trading orders error:",
            error
        );

        return res.status(500).json({
            success: false,
            message:
                "Unable to retrieve trading orders.",
        });
    }
}

export async function getOrderController(
    req,
    res
) {
    try {
        const orderId = parseId(req.params.id);

        if (!orderId) {
            return res.status(400).json({
                success: false,
                message: "Invalid order ID.",
            });
        }

        const order =
            await getAdminOrderById(orderId);

        if (!order) {
            return res.status(404).json({
                success: false,
                message: "Order not found.",
            });
        }

        return res.status(200).json({
            success: true,
            message:
                "Admin trading order retrieved successfully.",
            data: order,
        });
    } catch (error) {
        console.error(
            "Get admin trading order error:",
            error
        );

        return res.status(500).json({
            success: false,
            message:
                "Unable to retrieve the trading order.",
        });
    }
}

/**
 * ============================================================
 * COMPLETED TRADES
 * ============================================================
 */

export async function getTradesController(
    req,
    res
) {
    try {
        const {
            search = "",
            status = "completed",
            page = 1,
            limit = 20,
        } = req.query;

        const result = await getAdminTrades({
            search,
            status,
            page,
            limit,
        });

        return res.status(200).json({
            success: true,
            message:
                "Admin trading transactions retrieved successfully.",
            data: {
                trades: result.trades,
                pagination: result.pagination,
            },
        });
    } catch (error) {
        console.error(
            "Get admin trading transactions error:",
            error
        );

        return res.status(500).json({
            success: false,
            message:
                "Unable to retrieve trading transactions.",
        });
    }
}

export async function getTradeController(
    req,
    res
) {
    try {
        const transactionId =
            parseId(req.params.id);

        if (!transactionId) {
            return res.status(400).json({
                success: false,
                message:
                    "Invalid transaction ID.",
            });
        }

        const trade =
            await getAdminTradeById(transactionId);

        if (!trade) {
            return res.status(404).json({
                success: false,
                message:
                    "Trading transaction not found.",
            });
        }

        return res.status(200).json({
            success: true,
            message:
                "Admin trading transaction retrieved successfully.",
            data: trade,
        });
    } catch (error) {
        console.error(
            "Get admin trading transaction error:",
            error
        );

        return res.status(500).json({
            success: false,
            message:
                "Unable to retrieve the trading transaction.",
        });
    }
}

/**
 * ============================================================
 * DISPUTES
 * ============================================================
 */

export async function getDisputesController(
    req,
    res
) {
    try {
        const {
            search = "",
            status = "",
            priority = "",
            page = 1,
            limit = 20,
        } = req.query;

        const result = await getAdminDisputes({
            search,
            status,
            priority,
            page,
            limit,
        });

        return res.status(200).json({
            success: true,
            message:
                "Trading disputes retrieved successfully.",
            data: {
                disputes: result.disputes,
                pagination: result.pagination,
            },
        });
    } catch (error) {
        console.error(
            "Get trading disputes error:",
            error
        );

        return res.status(500).json({
            success: false,
            message:
                "Unable to retrieve trading disputes.",
        });
    }
}

export async function getDisputeController(
    req,
    res
) {
    try {
        const disputeId =
            parseId(req.params.id);

        if (!disputeId) {
            return res.status(400).json({
                success: false,
                message:
                    "Invalid dispute ID.",
            });
        }

        const dispute =
            await getAdminDisputeById(disputeId);

        if (!dispute) {
            return res.status(404).json({
                success: false,
                message:
                    "Trading dispute not found.",
            });
        }

        return res.status(200).json({
            success: true,
            message:
                "Trading dispute retrieved successfully.",
            data: dispute,
        });
    } catch (error) {
        console.error(
            "Get trading dispute error:",
            error
        );

        return res.status(500).json({
            success: false,
            message:
                "Unable to retrieve the trading dispute.",
        });
    }
}

export async function createDisputeController(
    req,
    res
) {
    try {
        const adminId = getAdminId(req);

        const {
            transactionId = null,
            orderId = null,
            listingId = null,
            raisedBy,
            againstUserId = null,
            disputeType = "trade",
            priority = "normal",
            reason,
            description = null,
        } = req.body ?? {};

        if (!adminId) {
            return res.status(401).json({
                success: false,
                message:
                    "Unable to identify the authenticated administrator.",
            });
        }

        const normalizedRaisedBy =
            parseId(raisedBy);

        if (!normalizedRaisedBy) {
            return res.status(400).json({
                success: false,
                message:
                    "A valid user who raised the dispute is required.",
            });
        }

        if (
            typeof reason !== "string" ||
            !reason.trim()
        ) {
            return res.status(400).json({
                success: false,
                message:
                    "A dispute reason is required.",
            });
        }

        const dispute =
            await createTradingDispute({
                adminId,
                transactionId:
                    transactionId === null
                        ? null
                        : parseId(transactionId),
                orderId:
                    orderId === null
                        ? null
                        : parseId(orderId),
                listingId:
                    listingId === null
                        ? null
                        : parseId(listingId),
                raisedBy: normalizedRaisedBy,
                againstUserId:
                    againstUserId === null
                        ? null
                        : parseId(againstUserId),
                disputeType,
                priority,
                reason: reason.trim(),
                description,
            });

        return res.status(201).json({
            success: true,
            message:
                "Trading dispute created successfully.",
            data: dispute,
        });
    } catch (error) {
        console.error(
            "Create trading dispute error:",
            error
        );

        return res.status(500).json({
            success: false,
            message:
                "Unable to create the trading dispute.",
        });
    }
}

export async function assignDisputeController(
    req,
    res
) {
    try {
        const disputeId =
            parseId(req.params.id);

        const adminId = getAdminId(req);

        const assignedTo =
            parseId(req.body?.assignedTo);

        if (!disputeId) {
            return res.status(400).json({
                success: false,
                message:
                    "Invalid dispute ID.",
            });
        }

        if (!assignedTo) {
            return res.status(400).json({
                success: false,
                message:
                    "A valid administrator ID is required.",
            });
        }

        const dispute =
            await assignTradingDispute(
                disputeId,
                assignedTo,
                adminId
            );

        return res.status(200).json({
            success: true,
            message:
                "Trading dispute assigned successfully.",
            data: dispute,
        });
    } catch (error) {
        console.error(
            "Assign trading dispute error:",
            error
        );

        if (
            error.code === "DISPUTE_NOT_FOUND"
        ) {
            return res.status(404).json({
                success: false,
                message:
                    "Trading dispute not found.",
            });
        }

        return res.status(500).json({
            success: false,
            message:
                "Unable to assign the trading dispute.",
        });
    }
}

export async function updateDisputeController(
    req,
    res
) {
    try {
        const disputeId =
            parseId(req.params.id);

        const adminId = getAdminId(req);

        if (!disputeId) {
            return res.status(400).json({
                success: false,
                message:
                    "Invalid dispute ID.",
            });
        }

        const {
            status,
            priority,
            resolutionNotes,
        } = req.body ?? {};

        const dispute =
            await updateTradingDispute(
                disputeId,
                {
                    status,
                    priority,
                    resolutionNotes,
                },
                adminId
            );

        return res.status(200).json({
            success: true,
            message:
                "Trading dispute updated successfully.",
            data: dispute,
        });
    } catch (error) {
        console.error(
            "Update trading dispute error:",
            error
        );

        if (
            error.code === "DISPUTE_NOT_FOUND"
        ) {
            return res.status(404).json({
                success: false,
                message:
                    "Trading dispute not found.",
            });
        }

        if (
            error.code ===
            "INVALID_DISPUTE_STATUS" ||
            error.code ===
            "INVALID_DISPUTE_PRIORITY"
        ) {
            return res.status(400).json({
                success: false,
                message: error.message,
            });
        }

        return res.status(500).json({
            success: false,
            message:
                "Unable to update the trading dispute.",
        });
    }
}