/**
 * AssetCoin
 * Migration 044
 *
 * Admin Tokenization Management Workflow
 *
 * Purpose:
 * - Create the administrative tokenization proposal workflow.
 * - Track tokenization reviews and decisions.
 * - Track token offerings separately from the live token record.
 * - Maintain status history for proposals and offerings.
 * - Support maker-checker authorization.
 *
 * Important:
 * - assets.status must already be "approved" before a proposal can be created.
 * - tokens remains the live token table.
 * - token_offerings represents the marketplace offering.
 * - High-risk changes must be handled through authorized services,
 *   never by directly editing database records.
 */

-- =========================================================
-- 1. TOKENIZATION PROPOSALS
-- =========================================================

CREATE TABLE IF NOT EXISTS tokenization_proposals (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,

    proposalReference VARCHAR(100) NOT NULL,

    assetId INT UNSIGNED NOT NULL,

    valuationId INT UNSIGNED NULL,

    createdBy INT UNSIGNED NOT NULL,

    status ENUM(
        'draft',
        'pending_review',
        'changes_required',
        'pending_approval',
        'approved',
        'rejected',
        'cancelled',
        'activated'
    ) NOT NULL DEFAULT 'draft',

    proposedTokenName VARCHAR(150) NULL,

    proposedTokenCode VARCHAR(50) NULL,

    totalSupply DECIMAL(30,8) NULL,

    offeringSupply DECIMAL(30,8) NULL,

    initialTokenPrice DECIMAL(20,8) NULL,

    currency VARCHAR(10) NOT NULL DEFAULT 'KES',

    minimumPurchaseQuantity DECIMAL(30,8) NULL,

    maximumPurchaseQuantity DECIMAL(30,8) NULL,

    offeringStartAt DATETIME NULL,

    offeringEndAt DATETIME NULL,

    /*
     * Snapshot of the valuation used when the proposal
     * was prepared. This protects the proposal from later
     * changes to the underlying valuation record.
     */
    valuationAmountSnapshot DECIMAL(20,2) NULL,

    valuationCurrencySnapshot VARCHAR(10) NULL,

    /*
     * Structured description of the economic rights
     * attached to the proposed token.
     *
     * Example structure:
     *
     * {
     *   "ownershipRights": "...",
     *   "incomeRights": "...",
     *   "votingRights": "...",
     *   "redemptionRights": "..."
     * }
     */
    economicRights JSON NULL,

    /*
     * Structured distribution arrangement.
     *
     * Example:
     *
     * {
     *   "distributionType": "periodic",
     *   "frequency": "quarterly",
     *   "method": "proRata"
     * }
     */
    distributionPolicy JSON NULL,

    termsAndConditions TEXT NULL,

    description TEXT NULL,

    reviewNotes TEXT NULL,

    rejectionReason TEXT NULL,

    approvedBy INT UNSIGNED NULL,

    submittedAt DATETIME NULL,

    approvedAt DATETIME NULL,

    activatedAt DATETIME NULL,

    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    updatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (id),

    UNIQUE KEY uq_tokenization_proposal_reference (
        proposalReference
    ),

    KEY idx_tokenization_proposals_asset (
        assetId
    ),

    KEY idx_tokenization_proposals_valuation (
        valuationId
    ),

    KEY idx_tokenization_proposals_created_by (
        createdBy
    ),

    KEY idx_tokenization_proposals_status (
        status
    ),

    KEY idx_tokenization_proposals_created_at (
        createdAt
    ),

    KEY idx_tokenization_proposals_approved_by (
        approvedBy
    ),

    CONSTRAINT fk_tokenization_proposals_asset
        FOREIGN KEY (assetId)
        REFERENCES assets(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_tokenization_proposals_valuation
        FOREIGN KEY (valuationId)
        REFERENCES asset_valuations(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_tokenization_proposals_created_by
        FOREIGN KEY (createdBy)
        REFERENCES admin_staff(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_tokenization_proposals_approved_by
        FOREIGN KEY (approvedBy)
        REFERENCES admin_staff(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_tokenization_total_supply
        CHECK (
            totalSupply IS NULL
            OR totalSupply > 0
        ),

    CONSTRAINT chk_tokenization_offering_supply
        CHECK (
            offeringSupply IS NULL
            OR offeringSupply > 0
        ),

    CONSTRAINT chk_tokenization_price
        CHECK (
            initialTokenPrice IS NULL
            OR initialTokenPrice > 0
        ),

    CONSTRAINT chk_tokenization_purchase_minimum
        CHECK (
            minimumPurchaseQuantity IS NULL
            OR minimumPurchaseQuantity > 0
        ),

    CONSTRAINT chk_tokenization_purchase_maximum
        CHECK (
            maximumPurchaseQuantity IS NULL
            OR maximumPurchaseQuantity > 0
        ),

    CONSTRAINT chk_tokenization_offering_supply_limit
        CHECK (
            totalSupply IS NULL
            OR offeringSupply IS NULL
            OR offeringSupply <= totalSupply
        ),

    CONSTRAINT chk_tokenization_purchase_limits
        CHECK (
            minimumPurchaseQuantity IS NULL
            OR maximumPurchaseQuantity IS NULL
            OR minimumPurchaseQuantity <= maximumPurchaseQuantity
        ),

    CONSTRAINT chk_tokenization_offering_dates
        CHECK (
            offeringStartAt IS NULL
            OR offeringEndAt IS NULL
            OR offeringEndAt > offeringStartAt
        )
);


-- =========================================================
-- 2. TOKENIZATION PROPOSAL STATUS HISTORY
-- =========================================================

CREATE TABLE IF NOT EXISTS tokenization_proposal_status_history (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,

    proposalId BIGINT UNSIGNED NOT NULL,

    previousStatus ENUM(
        'draft',
        'pending_review',
        'changes_required',
        'pending_approval',
        'approved',
        'rejected',
        'cancelled',
        'activated'
    ) NULL,

    newStatus ENUM(
        'draft',
        'pending_review',
        'changes_required',
        'pending_approval',
        'approved',
        'rejected',
        'cancelled',
        'activated'
    ) NOT NULL,

    changedBy INT UNSIGNED NULL,

    reason TEXT NULL,

    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id),

    KEY idx_tokenization_proposal_history_proposal (
        proposalId
    ),

    KEY idx_tokenization_proposal_history_changed_by (
        changedBy
    ),

    KEY idx_tokenization_proposal_history_created_at (
        createdAt
    ),

    CONSTRAINT fk_tokenization_proposal_history_proposal
        FOREIGN KEY (proposalId)
        REFERENCES tokenization_proposals(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_tokenization_proposal_history_changed_by
        FOREIGN KEY (changedBy)
        REFERENCES admin_staff(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
);


-- =========================================================
-- 3. TOKENIZATION REVIEWS
-- =========================================================

CREATE TABLE IF NOT EXISTS tokenization_reviews (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,

    proposalId BIGINT UNSIGNED NOT NULL,

    reviewerId INT UNSIGNED NOT NULL,

    reviewType ENUM(
        'review',
        'change_request',
        'approval',
        'rejection'
    ) NOT NULL,

    decision ENUM(
        'under_review',
        'changes_required',
        'approved',
        'rejected'
    ) NOT NULL,

    comments TEXT NULL,

    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id),

    KEY idx_tokenization_reviews_proposal (
        proposalId
    ),

    KEY idx_tokenization_reviews_reviewer (
        reviewerId
    ),

    KEY idx_tokenization_reviews_type (
        reviewType
    ),

    KEY idx_tokenization_reviews_decision (
        decision
    ),

    KEY idx_tokenization_reviews_created_at (
        createdAt
    ),

    CONSTRAINT fk_tokenization_reviews_proposal
        FOREIGN KEY (proposalId)
        REFERENCES tokenization_proposals(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_tokenization_reviews_reviewer
        FOREIGN KEY (reviewerId)
        REFERENCES admin_staff(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);


-- =========================================================
-- 4. TOKEN OFFERINGS
-- =========================================================
--
-- This table represents the actual marketplace offering.
--
-- It is intentionally separate from:
--
--     tokenization_proposals
--     tokens
--
-- Proposal = administrative preparation
-- Token     = actual token
-- Offering  = what customers can purchase
--

CREATE TABLE IF NOT EXISTS token_offerings (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,

    offeringReference VARCHAR(100) NOT NULL,

    proposalId BIGINT UNSIGNED NOT NULL,

    tokenId INT UNSIGNED NOT NULL,

    createdBy INT UNSIGNED NOT NULL,

    activatedBy INT UNSIGNED NULL,

    status ENUM(
        'draft',
        'scheduled',
        'active',
        'paused',
        'completed',
        'cancelled',
        'suspended'
    ) NOT NULL DEFAULT 'draft',

    offeringSupply DECIMAL(30,8) NOT NULL,

    pricePerToken DECIMAL(20,8) NOT NULL,

    currency VARCHAR(10) NOT NULL DEFAULT 'KES',

    minimumPurchaseQuantity DECIMAL(30,8) NULL,

    maximumPurchaseQuantity DECIMAL(30,8) NULL,

    offeringStartAt DATETIME NOT NULL,

    offeringEndAt DATETIME NOT NULL,

    tokensSold DECIMAL(30,8) NOT NULL DEFAULT 0,

    totalRaised DECIMAL(20,2) NOT NULL DEFAULT 0,

    activatedAt DATETIME NULL,

    completedAt DATETIME NULL,

    cancelledAt DATETIME NULL,

    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    updatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (id),

    UNIQUE KEY uq_token_offerings_reference (
        offeringReference
    ),

    UNIQUE KEY uq_token_offerings_proposal (
        proposalId
    ),

    KEY idx_token_offerings_token (
        tokenId
    ),

    KEY idx_token_offerings_created_by (
        createdBy
    ),

    KEY idx_token_offerings_activated_by (
        activatedBy
    ),

    KEY idx_token_offerings_status (
        status
    ),

    KEY idx_token_offerings_start (
        offeringStartAt
    ),

    KEY idx_token_offerings_end (
        offeringEndAt
    ),

    CONSTRAINT fk_token_offerings_proposal
        FOREIGN KEY (proposalId)
        REFERENCES tokenization_proposals(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_token_offerings_token
        FOREIGN KEY (tokenId)
        REFERENCES tokens(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_token_offerings_created_by
        FOREIGN KEY (createdBy)
        REFERENCES admin_staff(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_token_offerings_activated_by
        FOREIGN KEY (activatedBy)
        REFERENCES admin_staff(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_token_offering_supply
        CHECK (
            offeringSupply > 0
        ),

    CONSTRAINT chk_token_offering_price
        CHECK (
            pricePerToken > 0
        ),

    CONSTRAINT chk_token_offering_sold
        CHECK (
            tokensSold >= 0
            AND tokensSold <= offeringSupply
        ),

    CONSTRAINT chk_token_offering_raised
        CHECK (
            totalRaised >= 0
        ),

    CONSTRAINT chk_token_offering_dates
        CHECK (
            offeringEndAt > offeringStartAt
        ),

    CONSTRAINT chk_token_offering_minimum
        CHECK (
            minimumPurchaseQuantity IS NULL
            OR minimumPurchaseQuantity > 0
        ),

    CONSTRAINT chk_token_offering_maximum
        CHECK (
            maximumPurchaseQuantity IS NULL
            OR maximumPurchaseQuantity > 0
        ),

    CONSTRAINT chk_token_offering_purchase_limits
        CHECK (
            minimumPurchaseQuantity IS NULL
            OR maximumPurchaseQuantity IS NULL
            OR minimumPurchaseQuantity <= maximumPurchaseQuantity
        )
);


-- =========================================================
-- 5. TOKEN OFFERING STATUS HISTORY
-- =========================================================

CREATE TABLE IF NOT EXISTS token_offering_status_history (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,

    offeringId BIGINT UNSIGNED NOT NULL,

    previousStatus ENUM(
        'draft',
        'scheduled',
        'active',
        'paused',
        'completed',
        'cancelled',
        'suspended'
    ) NULL,

    newStatus ENUM(
        'draft',
        'scheduled',
        'active',
        'paused',
        'completed',
        'cancelled',
        'suspended'
    ) NOT NULL,

    changedBy INT UNSIGNED NULL,

    reason TEXT NULL,

    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id),

    KEY idx_token_offering_history_offering (
        offeringId
    ),

    KEY idx_token_offering_history_changed_by (
        changedBy
    ),

    KEY idx_token_offering_history_created_at (
        createdAt
    ),

    CONSTRAINT fk_token_offering_history_offering
        FOREIGN KEY (offeringId)
        REFERENCES token_offerings(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_token_offering_history_changed_by
        FOREIGN KEY (changedBy)
        REFERENCES admin_staff(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
);


-- =========================================================
-- 6. ADD TOKENIZATION-SPECIFIC PERMISSIONS
-- =========================================================

INSERT INTO admin_permissions (
    module,
    action,
    name,
    code,
    description
)
SELECT
    'tokenization',
    'request_changes',
    'Request Tokenization Changes',
    'tokenization.request_changes',
    'Request changes to a tokenization proposal'
WHERE NOT EXISTS (
    SELECT 1
    FROM admin_permissions
    WHERE code = 'tokenization.request_changes'
);


INSERT INTO admin_permissions (
    module,
    action,
    name,
    code,
    description
)
SELECT
    'tokenization',
    'review',
    'Review Tokenization',
    'tokenization.review',
    'Review tokenization proposals and submit review decisions.'
WHERE NOT EXISTS (
    SELECT 1
    FROM admin_permissions
    WHERE code = 'tokenization.review'
);


-- =========================================================
-- 6. ADD TOKENIZATION-SPECIFIC PERMISSIONS
-- =========================================================

INSERT INTO admin_permissions (
    module,
    action,
    name,
    code,
    description
)
VALUES
(
    'tokenization',
    'request_changes',
    'Request Tokenization Changes',
    'tokenization.request_changes',
    'Request changes to a tokenization proposal'
),
(
    'tokenization',
    'review',
    'Review Tokenization',
    'tokenization.review',
    'Review tokenization proposals and submit review decisions.'
),
(
    'tokenization',
    'assign',
    'Assign Tokenization',
    'tokenization.assign',
    'Assign tokenization proposals to tokenization officers and manage assignments.'
),
(
    'tokenization',
    'activate',
    'Activate Token Offering',
    'tokenization.activate',
    'Activate an authorized token offering'
),
(
    'tokenization',
    'manage_offerings',
    'Manage Token Offerings',
    'tokenization.offerings.manage',
    'Manage the token offering lifecycle'
)
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    description = VALUES(description);


-- =========================================================
-- 7. GRANT TOKENIZATION PERMISSIONS
-- =========================================================

INSERT INTO admin_role_permissions (
    roleId,
    permissionId
)
SELECT
    r.id,
    p.id
FROM admin_roles r
CROSS JOIN admin_permissions p
WHERE
    r.code = 'tokenization_officer'
    AND p.code IN (
        'tokenization.view',
        'tokenization.create',
        'tokenization.request_changes',
        'tokenization.review',
        'tokenization.assign',
        'tokenization.approve',
        'tokenization.reject',
        'tokenization.activate',
        'tokenization.suspend',
        'tokenization.offerings.manage'
    )
ON DUPLICATE KEY UPDATE
    roleId = VALUES(roleId),
    permissionId = VALUES(permissionId);


-- =========================================================
-- 8. MIGRATION COMPLETE
-- =========================================================