import {
    listUsers,
    getUserById,
    getUserActivity,
    createUser,
    updateUser,
    changeUserStatus,
} from '../../services/admin/adminUserService.js';

function requestContext(req) {
    return {
        adminId: req.admin?.id ?? req.adminId,
        ipAddress:
            req.headers['x-forwarded-for']?.split(',')[0]?.trim() ??
            req.socket?.remoteAddress ??
            null,
        userAgent: req.headers['user-agent'] ?? null,
    };
}

function sendError(res, error) {
    const status = error.statusCode ?? 500;

    if (status >= 500) {
        console.error('Admin user controller error:', error);
    }

    return res.status(status).json({
        success: false,
        message: status >= 500
            ? 'An unexpected server error occurred.'
            : error.message,
    });
}

export async function getUsers(req, res) {
    try {
        const result = await listUsers(req.query);
        return res.status(200).json({ success: true, data: result });
    } catch (error) {
        return sendError(res, error);
    }
}

export async function getUser(req, res) {
    try {
        const result = await getUserById(req.params.id);
        return res.status(200).json({ success: true, data: result });
    } catch (error) {
        return sendError(res, error);
    }
}

export async function getUserActivityController(req, res) {
    try {
        const result = await getUserActivity(req.params.id, req.query);
        return res.status(200).json({ success: true, data: result });
    } catch (error) {
        return sendError(res, error);
    }
}

export async function createAdminUser(req, res) {
    try {
        const result = await createUser({
            payload: req.body,
            adminContext: requestContext(req),
        });

        return res.status(201).json({
            success: true,
            message: 'User created successfully.',
            data: result,
        });
    } catch (error) {
        return sendError(res, error);
    }
}

export async function updateAdminUser(req, res) {
    try {
        const result = await updateUser({
            userId: req.params.id,
            changes: req.body,
            adminContext: requestContext(req),
        });

        return res.status(200).json({
            success: true,
            message: 'User updated successfully.',
            data: result,
        });
    } catch (error) {
        return sendError(res, error);
    }
}

export async function updateAdminUserStatus(req, res) {
    try {
        const result = await changeUserStatus({
            userId: req.params.id,
            accountStatus: req.body.accountStatus,
            reason: req.body.reason,
            adminContext: requestContext(req),
        });

        return res.status(200).json({
            success: true,
            message: 'User account status updated successfully.',
            data: result,
        });
    } catch (error) {
        return sendError(res, error);
    }
}
