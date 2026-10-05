import net from "net";

// =========================================================
// ADMIN REQUEST METADATA
// =========================================================

/**
 * Extract security-related metadata from
 * an Express request.
 *
 * Used for:
 *
 * - admin login activity
 * - audit logs
 * - session records
 * - security monitoring
 */
export function getRequestMetadata(
  request,
) {
  return {
    ipAddress:
      getClientIpAddress(request),

    userAgent:
      getUserAgent(request),

    deviceType:
      getDeviceType(request),
  };
}


// =========================================================
// GET CLIENT IP ADDRESS
// =========================================================

/**
 * Resolve the client IP address.
 *
 * Supports:
 *
 * - X-Forwarded-For
 * - X-Real-IP
 * - Express request.ip
 * - Express socket address
 *
 * X-Forwarded-For may contain:
 *
 * client, proxy1, proxy2
 *
 * The first valid address is normally treated
 * as the originating client.
 *
 * IMPORTANT:
 *
 * Forwarded headers should only be trusted when
 * the application is correctly configured behind
 * a trusted reverse proxy.
 */
export function getClientIpAddress(
  request,
) {
  if (!request) {
    return null;
  }

  // -------------------------------------------------------
  // X-FORWARDED-FOR
  // -------------------------------------------------------

  const forwardedFor =
    request?.headers?.[
    "x-forwarded-for"
    ];

  if (
    typeof forwardedFor === "string" &&
    forwardedFor.trim()
  ) {
    const addresses =
      forwardedFor
        .split(",")
        .map(
          (address) =>
            address.trim(),
        )
        .filter(Boolean);

    for (const address of addresses) {
      const normalized =
        normalizeIpAddress(address);

      if (normalized) {
        return normalized;
      }
    }
  }

  // -------------------------------------------------------
  // X-REAL-IP
  // -------------------------------------------------------

  const realIp =
    request?.headers?.[
    "x-real-ip"
    ];

  if (
    typeof realIp === "string" &&
    realIp.trim()
  ) {
    const normalized =
      normalizeIpAddress(realIp);

    if (normalized) {
      return normalized;
    }
  }

  // -------------------------------------------------------
  // EXPRESS REQUEST.IP
  // -------------------------------------------------------

  const requestIp =
    typeof request?.ip === "string"
      ? request.ip.trim()
      : "";

  if (requestIp) {
    const normalized =
      normalizeIpAddress(requestIp);

    if (normalized) {
      return normalized;
    }
  }

  // -------------------------------------------------------
  // SOCKET REMOTE ADDRESS
  // -------------------------------------------------------

  const socketAddress =
    request?.socket?.remoteAddress;

  if (
    typeof socketAddress === "string" &&
    socketAddress.trim()
  ) {
    return (
      normalizeIpAddress(
        socketAddress,
      ) ?? null
    );
  }

  return null;
}


// =========================================================
// GET CLIENT IP
// =========================================================
//
// Backward-compatible alias.
//
// Some existing services may use getClientIp()
// instead of getClientIpAddress().
//
// =========================================================

export function getClientIp(
  request,
) {
  return getClientIpAddress(
    request,
  );
}


// =========================================================
// GET USER AGENT
// =========================================================

/**
 * Extract the browser/device user-agent.
 *
 * User-agent values are limited before being
 * stored in audit or session records.
 */
export function getUserAgent(
  request,
) {
  const userAgent =
    request?.headers?.[
    "user-agent"
    ];

  if (
    typeof userAgent !== "string"
  ) {
    return null;
  }

  return (
    userAgent
      .trim()
      .slice(0, 1000) ||
    null
  );
}


// =========================================================
// GET DEVICE TYPE
// =========================================================

/**
 * Determine a broad device category.
 *
 * Possible values:
 *
 * - mobile
 * - tablet
 * - desktop
 * - unknown
 *
 * This is deliberately simple because
 * deviceType is metadata, not an authentication
 * or authorization mechanism.
 */
export function getDeviceType(
  request,
) {
  const userAgent =
    getUserAgent(request);

  if (!userAgent) {
    return "unknown";
  }

  const value =
    userAgent.toLowerCase();

  // -------------------------------------------------------
  // TABLETS
  // -------------------------------------------------------

  if (
    value.includes("ipad") ||
    value.includes("tablet") ||
    (
      value.includes("android") &&
      !value.includes("mobile")
    )
  ) {
    return "tablet";
  }

  // -------------------------------------------------------
  // MOBILE DEVICES
  // -------------------------------------------------------

  if (
    value.includes("mobile") ||
    value.includes("android") ||
    value.includes("iphone") ||
    value.includes("ipod")
  ) {
    return "mobile";
  }

  // -------------------------------------------------------
  // WEB / DESKTOP
  // -------------------------------------------------------

  return "desktop";
}


// =========================================================
// NORMALIZE IP ADDRESS
// =========================================================
//
// Validate and normalize an IP address before
// storing it in security/audit records.
//
// Supports:
//
// - IPv4
// - IPv6
// - IPv4-mapped IPv6
//
// =========================================================

function normalizeIpAddress(
  value,
) {
  if (
    typeof value !== "string"
  ) {
    return null;
  }

  let ip =
    value
      .trim()
      .slice(0, 255);

  if (!ip) {
    return null;
  }

  // -------------------------------------------------------
  // Remove IPv6 zone identifiers.
  //
  // Example:
  //
  // fe80::1%lo0
  // -------------------------------------------------------

  const zoneIndex =
    ip.indexOf("%");

  if (zoneIndex !== -1) {
    ip = ip.slice(
      0,
      zoneIndex,
    );
  }

  // -------------------------------------------------------
  // IPv4-MAPPED IPv6
  //
  // Example:
  //
  // ::ffff:192.168.1.10
  // -------------------------------------------------------

  const ipv4MappedPrefix =
    "::ffff:";

  if (
    ip
      .toLowerCase()
      .startsWith(
        ipv4MappedPrefix,
      )
  ) {
    const possibleIpv4 =
      ip.slice(
        ipv4MappedPrefix.length,
      );

    if (
      net.isIP(
        possibleIpv4,
      ) === 4
    ) {
      return possibleIpv4;
    }
  }

  // -------------------------------------------------------
  // Validate IPv4 / IPv6
  // -------------------------------------------------------

  if (
    net.isIP(ip) === 4 ||
    net.isIP(ip) === 6
  ) {
    return ip;
  }

  return null;
}