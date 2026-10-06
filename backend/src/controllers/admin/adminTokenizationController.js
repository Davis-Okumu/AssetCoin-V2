import {
    getTokenizationOverview,
    getEligibleTokenizationAssets,
    listTokenizationProposals,
    getTokenizationProposal,
    createTokenizationProposal,
    submitTokenizationProposal,
    reviewTokenizationProposal,
    approveTokenizationProposal,
    rejectTokenizationProposal,
    listTokenOfferings,
    getTokenOffering,
    activateTokenOffering,
    pauseTokenOffering,
    suspendTokenOffering,
    resumeTokenOffering,
} from "../../services/admin/adminTokenizationService.js";

import {
    assignTokenizationProposal,
    listAssignableTokenizationOfficers,
    listTokenizationAssignments,
    getTokenizationAssignment,
    startTokenizationAssignment,
    completeTokenizationAssignment,
} from "../../services/admin/adminTokenizationAssignmentService.js";

// =========================================================
// HELPERS
// =========================================================

function getRequestContext(request) {
    return {
        ipAddress:
            request.ip ??
            request.socket?.remoteAddress ??
            null,

        userAgent:
            request.get("user-agent") ??
            null,
    };
}

// =========================================================
// TOKENIZATION OVERVIEW
// =========================================================

export async function getOverview(request, response, next) {
    try {
        const overview = await getTokenizationOverview();

        return response.status(200).json({
            success: true,
            data: overview,
        });
    } catch (error) {
        next(error);
    }
}

// =========================================================
// ELIGIBLE ASSETS
// =========================================================

export async function getEligibleAssets(request, response, next) {
    try {
        const result =
            await getEligibleTokenizationAssets({
                search: request.query.search ?? null,
                page: request.query.page ?? 1,
                limit: request.query.limit ?? 20,
            });

        return response.status(200).json({
            success: true,
            data: result,
        });
    } catch (error) {
        next(error);
    }
}

// =========================================================
// LIST PROPOSALS
// =========================================================

export async function getProposals(request, response, next) {
    try {
        const result =
            await listTokenizationProposals({
                status: request.query.status ?? null,
                search: request.query.search ?? null,
                page: request.query.page ?? 1,
                limit: request.query.limit ?? 20,
            });

        return response.status(200).json({
            success: true,
            data: result,
        });
    } catch (error) {
        next(error);
    }
}

// =========================================================
// GET PROPOSAL
// =========================================================

export async function getProposal(request, response, next) {
    try {
        const proposal =
            await getTokenizationProposal(
                request.params.id,
            );

        if (!proposal) {
            return response.status(404).json({
                success: false,
                message: "Tokenization proposal not found.",
                code: "PROPOSAL_NOT_FOUND",
            });
        }

        return response.status(200).json({
            success: true,
            data: proposal,
        });
    } catch (error) {
        next(error);
    }
}

// =========================================================
// CREATE PROPOSAL
// =========================================================

export async function createProposal(
    request,
    response,
    next,
) {
    try {
        const context = getRequestContext(request);

        const proposal =
            await createTokenizationProposal({
                adminId: request.adminId,

                assetId: request.body.assetId,
                valuationId:
                    request.body.valuationId,

                proposedTokenName:
                    request.body.proposedTokenName,

                proposedTokenCode:
                    request.body.proposedTokenCode,

                totalSupply:
                    request.body.totalSupply,

                offeringSupply:
                    request.body.offeringSupply,

                initialTokenPrice:
                    request.body.initialTokenPrice,

                currency:
                    request.body.currency ?? "KES",

                minimumPurchaseQuantity:
                    request.body.minimumPurchaseQuantity,

                maximumPurchaseQuantity:
                    request.body.maximumPurchaseQuantity,

                offeringStartAt:
                    request.body.offeringStartAt,

                offeringEndAt:
                    request.body.offeringEndAt,

                economicRights:
                    request.body.economicRights,

                distributionPolicy:
                    request.body.distributionPolicy,

                termsAndConditions:
                    request.body.termsAndConditions,

                description:
                    request.body.description,

                ...context,
            });

        return response.status(201).json({
            success: true,
            message:
                "Tokenization proposal created successfully.",
            data: proposal,
        });
    } catch (error) {
        next(error);
    }
}

// =========================================================
// SUBMIT PROPOSAL
// =========================================================

export async function submitProposal(
    request,
    response,
    next,
) {
    try {
        const context = getRequestContext(request);

        const proposal =
            await submitTokenizationProposal({
                adminId: request.adminId,
                proposalId: request.params.id,
                ...context,
            });

        return response.status(200).json({
            success: true,
            message:
                "Tokenization proposal submitted for review.",
            data: proposal,
        });
    } catch (error) {
        next(error);
    }
}

// =========================================================
// REVIEW PROPOSAL
// =========================================================

export async function reviewProposal(
    request,
    response,
    next,
) {
    try {
        const context = getRequestContext(request);

        const proposal =
            await reviewTokenizationProposal({
                adminId: request.adminId,
                proposalId: request.params.id,

                decision:
                    request.body.decision,

                comments:
                    request.body.comments,

                ...context,
            });

        return response.status(200).json({
            success: true,
            message:
                "Tokenization proposal review completed.",
            data: proposal,
        });
    } catch (error) {
        next(error);
    }
}

// =========================================================
// APPROVE PROPOSAL
// =========================================================

export async function approveProposal(
    request,
    response,
    next,
) {
    try {
        const context = getRequestContext(request);

        const proposal =
            await approveTokenizationProposal({
                adminId: request.adminId,
                proposalId: request.params.id,

                comments:
                    request.body.comments,

                ...context,
            });

        return response.status(200).json({
            success: true,
            message:
                "Tokenization proposal approved and token created successfully.",
            data: proposal,
        });
    } catch (error) {
        next(error);
    }
}

// =========================================================
// REJECT PROPOSAL
// =========================================================

export async function rejectProposal(
    request,
    response,
    next,
) {
    try {
        const context = getRequestContext(request);

        const proposal =
            await rejectTokenizationProposal({
                adminId: request.adminId,
                proposalId: request.params.id,

                reason:
                    request.body.reason,

                ...context,
            });

        return response.status(200).json({
            success: true,
            message:
                "Tokenization proposal rejected.",
            data: proposal,
        });
    } catch (error) {
        next(error);
    }
}

// =========================================================
// LIST OFFERINGS
// =========================================================

export async function getOfferings(
    request,
    response,
    next,
) {
    try {
        const result =
            await listTokenOfferings({
                status: request.query.status ?? null,
                search: request.query.search ?? null,
                page: request.query.page ?? 1,
                limit: request.query.limit ?? 20,
            });

        return response.status(200).json({
            success: true,
            data: result,
        });
    } catch (error) {
        next(error);
    }
}

// =========================================================
// GET OFFERING
// =========================================================

export async function getOffering(
    request,
    response,
    next,
) {
    try {
        const offering =
            await getTokenOffering(
                request.params.id,
            );

        if (!offering) {
            return response.status(404).json({
                success: false,
                message: "Token offering not found.",
                code: "OFFERING_NOT_FOUND",
            });
        }

        return response.status(200).json({
            success: true,
            data: offering,
        });
    } catch (error) {
        next(error);
    }
}

// =========================================================
// ACTIVATE OFFERING
// =========================================================

export async function activateOffering(
    request,
    response,
    next,
) {
    try {
        const context = getRequestContext(request);

        const offering =
            await activateTokenOffering({
                adminId: request.adminId,
                offeringId: request.params.id,
                ...context,
            });

        return response.status(200).json({
            success: true,
            message:
                "Token offering activated successfully.",
            data: offering,
        });
    } catch (error) {
        next(error);
    }
}

// =========================================================
// PAUSE OFFERING
// =========================================================

export async function pauseOffering(
    request,
    response,
    next,
) {
    try {
        const context = getRequestContext(request);

        const offering =
            await pauseTokenOffering({
                adminId: request.adminId,
                offeringId: request.params.id,

                reason:
                    request.body.reason,

                ...context,
            });

        return response.status(200).json({
            success: true,
            message:
                "Token offering paused successfully.",
            data: offering,
        });
    } catch (error) {
        next(error);
    }
}

// =========================================================
// SUSPEND OFFERING
// =========================================================

export async function suspendOffering(
    request,
    response,
    next,
) {
    try {
        const context = getRequestContext(request);

        const offering =
            await suspendTokenOffering({
                adminId: request.adminId,
                offeringId: request.params.id,

                reason:
                    request.body.reason,

                ...context,
            });

        return response.status(200).json({
            success: true,
            message:
                "Token offering suspended successfully.",
            data: offering,
        });
    } catch (error) {
        next(error);
    }
}

// =========================================================
// TOKENIZATION ASSIGNMENTS
// =========================================================

export async function getAssignments(
    request,
    response,
    next,
) {
    try {
        const result =
            await listTokenizationAssignments({
                proposalId:
                    request.query.proposalId ?? null,

                assignedTo:
                    request.query.assignedTo ?? null,

                status:
                    request.query.status ?? null,

                mine:
                    request.query.mine === "true",

                adminId:
                    request.adminId,

                page:
                    request.query.page ?? 1,

                limit:
                    request.query.limit ?? 20,
            });

        return response.status(200).json({
            success: true,
            message:
                "Tokenization assignments retrieved successfully.",
            data: result.assignments,
            pagination: result.pagination,
        });
    } catch (error) {
        next(error);
    }
}



export async function completeAssignment(
    request,
    response,
    next,
) {
    try {
        const result =
            await completeTokenizationAssignment({
                assignmentId:
                    request.params.assignmentId,
                staffId:
                    request.adminId,
                notes:
                    request.body?.notes ??
                    null,
            });

        return response.status(200).json({
            success: true,
            message:
                "Tokenization assignment completed successfully.",
            data: result,
        });
    } catch (error) {
        next(error);
    }
}

export async function resumeOffering(
    request,
    response,
    next,
) {
    try {
        const offering =
            await resumeTokenOffering({
                offeringId: request.params.id,
                adminId: request.adminId,
                ...getRequestContext(request),
            });

        return response.status(200).json({
            success: true,
            message:
                "Token offering resumed successfully.",
            data: offering,
        });
    } catch (error) {
        next(error);
    }
}

// =========================================================
// ASSIGNMENT OFFICERS
// =========================================================

export async function getAssignableOfficers(
    request,
    response,
    next,
) {
    try {
        const officers =
            await listAssignableTokenizationOfficers();

        return response.status(200).json({
            success: true,
            message:
                "Assignable tokenization officers retrieved successfully.",
            data: officers,
        });
    } catch (error) {
        next(error);
    }
}

// =========================================================
// ASSIGNMENTS
// =========================================================



export async function assignProposal(
    request,
    response,
    next,
) {
    try {
        const proposalId =
            Number.parseInt(
                request.params.id,
                10,
            );

        const assignedTo =
            Number.parseInt(
                request.body.assignedTo,
                10,
            );

        const assignment =
            await assignTokenizationProposal({
                proposalId,
                assignedTo,
                assignedBy: request.adminId,
                priority:
                    request.body.priority ??
                    "normal",
                notes:
                    request.body.notes ??
                    null,
                ...getRequestContext(request),
            });

        return response.status(201).json({
            success: true,
            message:
                "Tokenization proposal assigned successfully.",
            data: assignment,
        });
    } catch (error) {
        next(error);
    }
}

export async function startAssignment(
    request,
    response,
    next,
) {
    try {
        const assignmentId =
            Number.parseInt(
                request.params.assignmentId,
                10,
            );

        const assignment =
            await startTokenizationAssignment({
                assignmentId,
                adminId: request.adminId,
                ...getRequestContext(request),
            });

        return response.status(200).json({
            success: true,
            message:
                "Tokenization assignment started successfully.",
            data: assignment,
        });
    } catch (error) {
        next(error);
    }
}

// =========================================================
// GET ASSIGNMENT
// =========================================================

export async function getAssignment(
    request,
    response,
    next,
) {
    try {
        const assignment =
            await getTokenizationAssignment(
                request.params.id,
            );

        if (!assignment) {
            return response.status(404).json({
                success: false,
                message:
                    "Tokenization assignment not found.",
                code:
                    "ASSIGNMENT_NOT_FOUND",
            });
        }

        return response.status(200).json({
            success: true,
            data: assignment,
        });
    } catch (error) {
        next(error);
    }
}