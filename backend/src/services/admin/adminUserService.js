import bcrypt from 'bcryptjs';
import pool from '../../config/database.js';
import { writeAdminAuditLog } from './adminAuditService.js';

const SORT_COLUMNS = Object.freeze({
    id: 'u.id',
    firstName: 'u.firstName',
    lastName: 'u.lastName',
    email: 'u.email',
    phone: 'u.phone',
    kycStatus: 'u.kycStatus',
    accountStatus: 'u.accountStatus',
    lastLoginAt: 'u.lastLoginAt',
    createdAt: 'u.createdAt',
    updatedAt: 'u.updatedAt',
});

const ALLOWED_ACCOUNT_STATUSES = new Set([
    'active',
    'suspended',
    'deactivated',
    'deleted',
]);

const ALLOWED_KYC_STATUSES = new Set([
    'pending',
    'verified',
    'rejected',
]);

function toPositiveInt(value, fallback, max = Number.MAX_SAFE_INTEGER) {
    const parsed = Number.parseInt(value, 10);
    if (!Number.isFinite(parsed) || parsed < 1) return fallback;
    return Math.min(parsed, max);
}

function cleanString(value) {
    if (value === undefined || value === null) return null;
    const trimmed = String(value).trim();
    return trimmed.length ? trimmed : null;
}

function maskNationalId(value) {
    if (!value) return null;
    const text = String(value);
    if (text.length <= 4) return '••••';
    return `${'•'.repeat(Math.max(0, text.length - 4))}${text.slice(-4)}`;
}

function serializeUser(row) {
    return {
        id: Number(row.id),
        firstName: row.firstName,
        lastName: row.lastName,
        fullName: `${row.firstName} ${row.lastName}`.trim(),
        email: row.email,
        phone: row.phone,
        profilePhotoUrl: row.profilePhotoUrl,
        kycStatus: row.kycStatus,
        role: row.role,
        accountStatus: row.accountStatus,
        lastLoginAt: row.lastLoginAt,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
    };
}

export async function listUsers(filters = {}) {
    const page = toPositiveInt(filters.page, 1);
    const limit = toPositiveInt(filters.limit, 20, 100);
    const offset = (page - 1) * limit;

    const search = cleanString(filters.search);
    const accountStatus = cleanString(filters.accountStatus);
    const kycStatus = cleanString(filters.kycStatus);
    const role = cleanString(filters.role);
    const createdFrom = cleanString(filters.createdFrom);
    const createdTo = cleanString(filters.createdTo);

    if (accountStatus && !ALLOWED_ACCOUNT_STATUSES.has(accountStatus)) {
        throw new Error('Invalid accountStatus filter.');
    }

    if (kycStatus && !ALLOWED_KYC_STATUSES.has(kycStatus)) {
        throw new Error('Invalid kycStatus filter.');
    }

    const sortBy = cleanString(filters.sortBy) || 'createdAt';
    const sortColumn = SORT_COLUMNS[sortBy] ?? SORT_COLUMNS.createdAt;
    const sortOrder = String(filters.sortOrder).toUpperCase() === 'ASC'
        ? 'ASC'
        : 'DESC';

    const conditions = [];
    const params = [];

    if (search) {
        const numericId = /^\d+$/.test(search) ? Number(search) : null;

        conditions.push(`
      (
        u.firstName LIKE ?
        OR u.lastName LIKE ?
        OR CONCAT(u.firstName, ' ', u.lastName) LIKE ?
        OR u.email LIKE ?
        OR u.phone LIKE ?
        ${numericId !== null ? 'OR u.id = ?' : ''}
      )
    `);

        const term = `%${search}%`;
        params.push(term, term, term, term, term);
        if (numericId !== null) params.push(numericId);
    }

    if (accountStatus) {
        conditions.push('u.accountStatus = ?');
        params.push(accountStatus);
    }

    if (kycStatus) {
        conditions.push('u.kycStatus = ?');
        params.push(kycStatus);
    }

    if (role) {
        conditions.push('u.role = ?');
        params.push(role);
    }

    if (createdFrom) {
        conditions.push('u.createdAt >= ?');
        params.push(createdFrom);
    }

    if (createdTo) {
        conditions.push('u.createdAt <= ?');
        params.push(createdTo);
    }

    const where = conditions.length
        ? `WHERE ${conditions.join(' AND ')}`
        : '';

    const [[countRow], [rows]] = await Promise.all([
        pool.query(
            `SELECT COUNT(*) AS total FROM users u ${where}`,
            params,
        ),
        pool.query(
            `
      SELECT
        u.id,
        u.firstName,
        u.lastName,
        u.email,
        u.phone,
        u.profilePhotoUrl,
        u.kycStatus,
        u.role,
        u.accountStatus,
        u.lastLoginAt,
        u.createdAt,
        u.updatedAt
      FROM users u
      ${where}
      ORDER BY ${sortColumn} ${sortOrder}
      LIMIT ? OFFSET ?
      `,
            [...params, limit, offset],
        ),
    ]);

    const total = Number(countRow[0]?.total ?? 0);
    const totalPages = Math.ceil(total / limit);

    return {
        items: rows.map(serializeUser),
        pagination: {
            page,
            limit,
            total,
            totalPages,
            hasNextPage: page < totalPages,
            hasPreviousPage: page > 1,
        },
        filters: {
            search,
            accountStatus,
            kycStatus,
            role,
            createdFrom,
            createdTo,
            sortBy,
            sortOrder,
        },
    };
}

export async function getUserById(userId) {
    const id = Number(userId);

    if (!Number.isInteger(id) || id < 1) {
        const error = new Error('Invalid user ID.');
        error.statusCode = 400;
        throw error;
    }

    const [[userRows], [assetRows], [holdingRows], [walletRows], [ticketRows]] =
        await Promise.all([
            pool.query(
                `
        SELECT
          u.id,
          u.firstName,
          u.lastName,
          u.email,
          u.phone,
          u.nationalId,
          u.idDocumentUrl,
          u.profilePhotoUrl,
          u.kycStatus,
          u.role,
          u.accountStatus,
          u.lastLoginAt,
          u.createdAt,
          u.updatedAt
        FROM users u
        WHERE u.id = ?
        LIMIT 1
        `,
                [id],
            ),
            pool.query(
                `
        SELECT
          COUNT(*) AS total,
          SUM(status IN ('pending','under_review','changes_required')) AS pending,
          SUM(status = 'approved') AS approved,
          SUM(status = 'tokenized') AS tokenized
        FROM assets
        WHERE ownerId = ?
        `,
                [id],
            ),
            pool.query(
                `
        SELECT
          COUNT(*) AS total,
          COALESCE(SUM(quantity), 0) AS quantity,
          COALESCE(SUM(totalInvested), 0) AS totalInvested
        FROM token_holdings
        WHERE userId = ?
        `,
                [id],
            ),
            pool.query(
                `
        SELECT
          id,
          walletAddress,
          fiatBalance,
          lockedFiatBalance,
          currency,
          status,
          createdAt,
          updatedAt
        FROM wallets
        WHERE userId = ?
        LIMIT 1
        `,
                [id],
            ),
            pool.query(
                `
        SELECT
          COUNT(*) AS total,
          SUM(status IN ('open','in_progress','waiting_for_user')) AS openTickets
        FROM support_tickets
        WHERE userId = ?
        `,
                [id],
            ),
        ]);

    if (!userRows.length) {
        const error = new Error('User not found.');
        error.statusCode = 404;
        throw error;
    }

    const user = userRows[0];
    const assets = assetRows[0] ?? {};
    const holdings = holdingRows[0] ?? {};
    const tickets = ticketRows[0] ?? {};
    const wallet = walletRows[0] ?? null;

    return {
        id: Number(user.id),
        firstName: user.firstName,
        lastName: user.lastName,
        fullName: `${user.firstName} ${user.lastName}`.trim(),
        email: user.email,
        phone: user.phone,
        nationalId: maskNationalId(user.nationalId),
        idDocumentUrl: user.idDocumentUrl,
        profilePhotoUrl: user.profilePhotoUrl,
        kycStatus: user.kycStatus,
        role: user.role,
        accountStatus: user.accountStatus,
        lastLoginAt: user.lastLoginAt,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
        wallet: wallet
            ? {
                id: Number(wallet.id),
                walletAddress: wallet.walletAddress,
                fiatBalance: wallet.fiatBalance,
                lockedFiatBalance: wallet.lockedFiatBalance,
                currency: wallet.currency,
                status: wallet.status,
                createdAt: wallet.createdAt,
                updatedAt: wallet.updatedAt,
            }
            : null,
        summary: {
            assets: {
                total: Number(assets.total ?? 0),
                pending: Number(assets.pending ?? 0),
                approved: Number(assets.approved ?? 0),
                tokenized: Number(assets.tokenized ?? 0),
            },
            holdings: {
                totalTokens: Number(holdings.total ?? 0),
                quantity: holdings.quantity ?? '0',
                totalInvested: holdings.totalInvested ?? '0',
            },
            support: {
                totalTickets: Number(tickets.total ?? 0),
                openTickets: Number(tickets.openTickets ?? 0),
            },
        },
    };
}

export async function getUserActivity(userId, options = {}) {
    const id = Number(userId);
    if (!Number.isInteger(id) || id < 1) {
        const error = new Error('Invalid user ID.');
        error.statusCode = 400;
        throw error;
    }

    const limit = toPositiveInt(options.limit, 20, 100);

    const [[userRows], [loginRows], [walletRows], [assetRows], [auditRows]] =
        await Promise.all([
            pool.query('SELECT id FROM users WHERE id = ? LIMIT 1', [id]),
            pool.query(
                `
        SELECT
          id,
          eventType,
          deviceName,
          deviceType,
          ipAddress,
          userAgent,
          description,
          createdAt
        FROM login_activity
        WHERE userId = ?
        ORDER BY createdAt DESC
        LIMIT ?
        `,
                [id, limit],
            ),
            pool.query(
                `
        SELECT
          id,
          transactionReference,
          transactionType,
          amount,
          currency,
          balanceBefore,
          balanceAfter,
          status,
          description,
          transactionHash,
          createdAt
        FROM wallet_transactions
        WHERE userId = ?
        ORDER BY createdAt DESC
        LIMIT ?
        `,
                [id, limit],
            ),
            pool.query(
                `
        SELECT
          id,
          assetCode,
          assetType,
          name,
          estimatedValue,
          currency,
          status,
          createdAt,
          updatedAt
        FROM assets
        WHERE ownerId = ?
        ORDER BY createdAt DESC
        LIMIT ?
        `,
                [id, limit],
            ),
            pool.query(
                `
        SELECT
          id,
          action,
          module,
          entityType,
          entityId,
          oldValues,
          newValues,
          createdAt
        FROM admin_audit_logs
        WHERE entityType = 'user'
          AND entityId = ?
        ORDER BY createdAt DESC
        LIMIT ?
        `,
                [id, limit],
            ),
        ]);

    if (!userRows.length) {
        const error = new Error('User not found.');
        error.statusCode = 404;
        throw error;
    }

    return {
        loginActivity: loginRows,
        walletTransactions: walletRows,
        assets: assetRows,
        adminAudit: auditRows,
    };
}

export async function updateUser({
    userId,
    changes,
    adminContext,
}) {
    const id = Number(userId);
    if (!Number.isInteger(id) || id < 1) {
        const error = new Error('Invalid user ID.');
        error.statusCode = 400;
        throw error;
    }

    const allowedFields = ['firstName', 'lastName', 'email', 'phone'];
    const updateData = {};

    for (const field of allowedFields) {
        if (Object.prototype.hasOwnProperty.call(changes, field)) {
            const value = cleanString(changes[field]);
            if (!value) {
                const error = new Error(`${field} cannot be empty.`);
                error.statusCode = 400;
                throw error;
            }
            updateData[field] = value;
        }
    }

    if (!Object.keys(updateData).length) {
        const error = new Error('No editable fields were supplied.');
        error.statusCode = 400;
        throw error;
    }

    const connection = await pool.getConnection();

    try {
        await connection.beginTransaction();

        const [rows] = await connection.query(
            `
      SELECT
        id, firstName, lastName, email, phone,
        kycStatus, role, accountStatus, profilePhotoUrl,
        createdAt, updatedAt
      FROM users
      WHERE id = ?
      FOR UPDATE
      `,
            [id],
        );

        if (!rows.length) {
            const error = new Error('User not found.');
            error.statusCode = 404;
            throw error;
        }

        const oldUser = rows[0];
        const fields = Object.keys(updateData);
        const assignments = fields.map((field) => `\`${field}\` = ?`).join(', ');
        const values = fields.map((field) => updateData[field]);

        await connection.query(
            `UPDATE users SET ${assignments} WHERE id = ?`,
            [...values, id],
        );

        const [updatedRows] = await connection.query(
            `
      SELECT
        id, firstName, lastName, email, phone,
        profilePhotoUrl, kycStatus, role, accountStatus,
        lastLoginAt, createdAt, updatedAt
      FROM users
      WHERE id = ?
      LIMIT 1
      `,
            [id],
        );

        await writeAdminAuditLog({
            connection,
            staffId: adminContext.adminId,
            action: 'user.updated',
            module: 'users',
            entityType: 'user',
            entityId: id,
            oldValues: oldUser,
            newValues: updatedRows[0],
            ipAddress: adminContext.ipAddress,
            userAgent: adminContext.userAgent,
        });

        await connection.commit();
        return serializeUser(updatedRows[0]);
    } catch (error) {
        await connection.rollback();
        if (error?.code === 'ER_DUP_ENTRY') {
            error.statusCode = 409;
            error.message = 'Email or phone number is already in use.';
        }
        throw error;
    } finally {
        connection.release();
    }
}

export async function createUser({
    payload,
    adminContext,
}) {
    const firstName = cleanString(payload.firstName);
    const lastName = cleanString(payload.lastName);
    const phone = cleanString(payload.phone);
    const email = cleanString(payload.email);
    const nationalId = cleanString(payload.nationalId);
    const password = String(payload.password ?? '');

    if (!firstName || !lastName || !phone || !nationalId || password.length < 8) {
        const error = new Error(
            'firstName, lastName, phone, nationalId and a password of at least 8 characters are required.',
        );
        error.statusCode = 400;
        throw error;
    }

    const passwordHash = await bcrypt.hash(password, 12);
    const connection = await pool.getConnection();

    try {
        await connection.beginTransaction();

        const [result] = await connection.query(
            `
      INSERT INTO users (
        firstName,
        lastName,
        phone,
        email,
        nationalId,
        passwordHash,
        kycStatus,
        role,
        accountStatus
      ) VALUES (?, ?, ?, ?, ?, ?, 'pending', 'user', 'active')
      `,
            [firstName, lastName, phone, email, nationalId, passwordHash],
        );

        const [rows] = await connection.query(
            `
      SELECT
        id, firstName, lastName, email, phone,
        profilePhotoUrl, kycStatus, role, accountStatus,
        lastLoginAt, createdAt, updatedAt
      FROM users
      WHERE id = ?
      LIMIT 1
      `,
            [result.insertId],
        );

        await writeAdminAuditLog({
            connection,
            staffId: adminContext.adminId,
            action: 'user.created',
            module: 'users',
            entityType: 'user',
            entityId: result.insertId,
            oldValues: null,
            newValues: rows[0],
            ipAddress: adminContext.ipAddress,
            userAgent: adminContext.userAgent,
        });

        await connection.commit();
        return serializeUser(rows[0]);
    } catch (error) {
        await connection.rollback();
        if (error?.code === 'ER_DUP_ENTRY') {
            error.statusCode = 409;
            error.message = 'Phone, email, or national ID is already registered.';
        }
        throw error;
    } finally {
        connection.release();
    }
}

export async function changeUserStatus({
    userId,
    accountStatus,
    reason,
    adminContext,
}) {
    const id = Number(userId);

    if (!Number.isInteger(id) || id < 1) {
        const error = new Error('Invalid user ID.');
        error.statusCode = 400;
        throw error;
    }

    if (!ALLOWED_ACCOUNT_STATUSES.has(accountStatus)) {
        const error = new Error('Invalid account status.');
        error.statusCode = 400;
        throw error;
    }

    if (accountStatus === 'deleted') {
        const error = new Error(
            'Permanent deletion is not supported through the user-management API.',
        );
        error.statusCode = 400;
        throw error;
    }

    const cleanReason = cleanString(reason);
    if (['suspended', 'deactivated'].includes(accountStatus) && !cleanReason) {
        const error = new Error('A reason is required when suspending or deactivating an account.');
        error.statusCode = 400;
        throw error;
    }

    const connection = await pool.getConnection();

    try {
        await connection.beginTransaction();

        const [rows] = await connection.query(
            `
      SELECT
        id, firstName, lastName, email, phone,
        profilePhotoUrl, kycStatus, role, accountStatus,
        lastLoginAt, createdAt, updatedAt
      FROM users
      WHERE id = ?
      FOR UPDATE
      `,
            [id],
        );

        if (!rows.length) {
            const error = new Error('User not found.');
            error.statusCode = 404;
            throw error;
        }

        const oldUser = rows[0];

        if (oldUser.accountStatus === accountStatus) {
            await connection.rollback();
            return serializeUser(oldUser);
        }

        await connection.query(
            `UPDATE users SET accountStatus = ? WHERE id = ?`,
            [accountStatus, id],
        );

        // Revoking active sessions is safer than leaving a suspended account logged in.
        if (['suspended', 'deactivated'].includes(accountStatus)) {
            await connection.query(
                `UPDATE user_sessions SET revokedAt = NOW() WHERE userId = ? AND revokedAt IS NULL`,
                [id],
            );
        }

        const [updatedRows] = await connection.query(
            `
      SELECT
        id, firstName, lastName, email, phone,
        profilePhotoUrl, kycStatus, role, accountStatus,
        lastLoginAt, createdAt, updatedAt
      FROM users
      WHERE id = ?
      LIMIT 1
      `,
            [id],
        );

        await writeAdminAuditLog({
            connection,
            staffId: adminContext.adminId,
            action: 'user.status_changed',
            module: 'users',
            entityType: 'user',
            entityId: id,
            oldValues: oldUser,
            newValues: {
                ...updatedRows[0],
                reason: cleanReason,
            },
            ipAddress: adminContext.ipAddress,
            userAgent: adminContext.userAgent,
        });

        await connection.commit();
        return serializeUser(updatedRows[0]);
    } catch (error) {
        await connection.rollback();
        throw error;
    } finally {
        connection.release();
    }
}
