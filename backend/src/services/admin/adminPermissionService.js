import pool from "../../config/database.js";

/**
 * Get all effective permissions for an administrator.
 *
 * Permission resolution:
 *
 * 1. Start with role permissions.
 * 2. Apply staff-specific overrides.
 * 3. A staff "deny" overrides a role "grant".
 */
export async function getAdminPermissions(
  staffId,
  roleId,
) {
  const [rows] = await pool.execute(
    `
      SELECT
        p.code AS permissionCode,
        p.name AS permissionName,
        p.module,
        p.action,
        COALESCE(
          sp.accessType,
          'grant'
        ) AS accessType
      FROM admin_permissions p

      INNER JOIN admin_role_permissions rp
        ON rp.permissionId = p.id

      LEFT JOIN admin_staff_permissions sp
        ON sp.permissionId = p.id
        AND sp.staffId = ?

      WHERE rp.roleId = ?
    `,
    [staffId, roleId],
  );

  return rows
    .filter(
      (permission) =>
        permission.accessType === "grant",
    )
    .map(
      (permission) =>
        permission.permissionCode,
    );
}

/**
 * Check whether an administrator has a permission.
 */
export async function hasAdminPermission(
  staffId,
  roleId,
  permissionCode,
) {
  const permissions =
    await getAdminPermissions(
      staffId,
      roleId,
    );

  return permissions.includes(
    permissionCode,
  );
}

/**
 * Get administrator role information.
 */
export async function getAdminRoleById(
  roleId,
) {
  const [rows] = await pool.execute(
    `
      SELECT
        id,
        name,
        code,
        description,
        isSystemRole,
        isActive
      FROM admin_roles
      WHERE id = ?
      LIMIT 1
    `,
    [roleId],
  );

  return rows[0] || null;
}