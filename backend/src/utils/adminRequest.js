/**
 * Get the client's IP address.
 */
export function getClientIp(request) {
  const forwardedFor =
    request.headers["x-forwarded-for"];

  if (forwardedFor) {
    return forwardedFor
      .split(",")[0]
      .trim();
  }

  return (
    request.ip ||
    request.socket?.remoteAddress ||
    null
  );
}

/**
 * Get browser/device user-agent.
 */
export function getUserAgent(request) {
  return request.headers["user-agent"] || null;
}

/**
 * Determine a broad device category.
 */
export function getDeviceType(request) {
  const userAgent =
    getUserAgent(request)?.toLowerCase() || "";

  if (
    userAgent.includes("ipad") ||
    userAgent.includes("tablet")
  ) {
    return "tablet";
  }

  if (
    userAgent.includes("mobile") ||
    userAgent.includes("android") ||
    userAgent.includes("iphone")
  ) {
    return "mobile";
  }

  if (userAgent.length > 0) {
    return "desktop";
  }

  return "unknown";
}

/**
 * Create request metadata used by security/audit records.
 */
export function getRequestMetadata(request) {
  return {
    ipAddress: getClientIp(request),
    userAgent: getUserAgent(request),
    deviceType: getDeviceType(request),
  };
}