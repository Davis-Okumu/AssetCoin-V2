
import crypto from "crypto";
import path from "path";

import pool from "../config/database.js";

// =====================================================
// CONSTANTS
// =====================================================

const TICKET_CATEGORIES = [
  "account",
  "kyc",
  "wallet",
  "trading",
  "assets",
  "payments",
  "technical",
  "security",
  "other",
];

const TICKET_PRIORITIES = [
  "low",
  "normal",
  "high",
  "urgent",
];

const TICKET_STATUSES = [
  "open",
  "in_progress",
  "waiting_for_user",
  "resolved",
  "closed",
];

// =====================================================
// ERROR HELPER
// =====================================================

function createError(message, statusCode = 400) {
  const error = new Error(message);
  error.statusCode = statusCode;
  return error;
}

// =====================================================
// VALIDATION HELPERS
// =====================================================

function validateUserId(userId) {
  if (
    !Number.isSafeInteger(Number(userId)) ||
    Number(userId) <= 0
  ) {
    throw createError("Invalid user account.", 400);
  }
}

function validateTicketId(ticketId) {
  if (
    !/^[1-9]\d*$/.test(String(ticketId)) ||
    !Number.isSafeInteger(Number(ticketId))
  ) {
    throw createError("Invalid support ticket ID.", 400);
  }

  return Number(ticketId);
}

function validatePagination(limit = 20, offset = 0) {
  const parsedLimit = Number(limit);
  const parsedOffset = Number(offset);

  return {
    limit: Number.isInteger(parsedLimit)
      ? Math.min(Math.max(parsedLimit, 1), 100)
      : 20,

    offset: Number.isInteger(parsedOffset)
      ? Math.max(parsedOffset, 0)
      : 0,
  };
}

function generateTicketReference() {
  const date = new Date()
    .toISOString()
    .slice(0, 10)
    .replace(/-/g, "");

  const randomPart = crypto
    .randomBytes(4)
    .toString("hex")
    .toUpperCase();

  return `AC-${date}-${randomPart}`;
}

function validateTicketInput(data) {
  if (!data || typeof data !== "object" || Array.isArray(data)) {
    throw createError("Invalid support ticket information.");
  }

  const category = data.category;
  const subject =
    typeof data.subject === "string"
      ? data.subject.trim()
      : "";

  const description =
    typeof data.description === "string"
      ? data.description.trim()
      : "";

  if (!TICKET_CATEGORIES.includes(category)) {
    throw createError("Select a valid support category.");
  }

  if (!subject || subject.length > 200) {
    throw createError(
      "Subject is required and cannot exceed 200 characters."
    );
  }

  if (!description || description.length > 10000) {
    throw createError(
      "Description is required and cannot exceed 10,000 characters."
    );
  }

  return {
    category,
    subject,
    description,
  };
}

function validateMessage(message) {
  if (typeof message !== "string") {
    throw createError("Message must be valid text.");
  }

  const normalizedMessage = message.trim();

  if (!normalizedMessage || normalizedMessage.length > 10000) {
    throw createError(
      "Message is required and cannot exceed 10,000 characters."
    );
  }

  return normalizedMessage;
}

// =====================================================
// DATABASE HELPERS
// =====================================================

async function notifyUser(
  connection,
  userId,
  title,
  message,
  referenceId
) {
  await connection.execute(
    `INSERT INTO notifications (
      userId,
      type,
      title,
      message,
      referenceType,
      referenceId,
      deliveryMethod,
      status
    ) VALUES (?, 'system', ?, ?, 'support_ticket', ?, 'in_app', 'new')`,
    [
      userId,
      title,
      message,
      referenceId,
    ]
  );
}

async function notifyAdministrators(
  connection,
  title,
  message,
  referenceId
) {
  const [admins] = await connection.execute(
    `SELECT id
     FROM users
     WHERE role = 'admin'
       AND accountStatus = 'active'`
  );

  for (const admin of admins) {
    await notifyUser(
      connection,
      admin.id,
      title,
      message,
      referenceId
    );
  }
}

async function insertAttachments(
  connection,
  ticketId,
  messageId,
  uploadedBy,
  files = []
) {
  for (const file of files) {
    await connection.execute(
      `INSERT INTO support_ticket_attachments (
        ticketId,
        messageId,
        uploadedBy,
        fileName,
        fileUrl,
        fileType,
        fileSize
      ) VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [
        ticketId,
        messageId,
        uploadedBy,
        path.basename(file.originalname),
        `/uploads/support/attachments/${file.filename}`,
        file.mimetype,
        file.size,
      ]
    );
  }
}

async function getTicketForUser(
  connection,
  ticketId,
  userId,
  role,
  lock = false
) {
  const admin = role === "admin";

  const [tickets] = await connection.execute(
    `SELECT
      t.id,
      t.ticketReference,
      t.userId,
      t.category,
      t.subject,
      t.description,
      t.priority,
      t.status,
      t.assignedTo,
      t.resolvedAt,
      t.closedAt,
      t.createdAt,
      t.updatedAt
    FROM support_tickets t
    WHERE t.id = ?
      ${admin ? "" : "AND t.userId = ?"}
    LIMIT 1
    ${lock ? "FOR UPDATE" : ""}`,
    admin ? [ticketId] : [ticketId, userId]
  );

  if (tickets.length === 0) {
    throw createError("Support ticket not found.", 404);
  }

  return tickets[0];
}

// =====================================================
// CREATE SUPPORT TICKET
// =====================================================

export async function createSupportTicket(
  userId,
  data,
  files = []
) {
  validateUserId(Number(userId));

  const ticketData = validateTicketInput(data);

  if (!Array.isArray(files) || files.length > 3) {
    throw createError("You can upload a maximum of 3 attachments.");
  }

  const connection = await pool.getConnection();

  try {
    await connection.beginTransaction();

    let ticketReference;
    let ticketId;

    // Protect against an unlikely reference collision.
    for (let attempt = 0; attempt < 3; attempt++) {
      ticketReference = generateTicketReference();

      try {
        const [result] = await connection.execute(
          `INSERT INTO support_tickets (
            ticketReference,
            userId,
            category,
            subject,
            description,
            priority,
            status
          ) VALUES (?, ?, ?, ?, ?, 'normal', 'open')`,
          [
            ticketReference,
            userId,
            ticketData.category,
            ticketData.subject,
            ticketData.description,
          ]
        );

        ticketId = result.insertId;
        break;
      } catch (error) {
        if (error.code !== "ER_DUP_ENTRY" || attempt === 2) {
          throw error;
        }
      }
    }

    if (!ticketId) {
      throw createError(
        "Unable to generate a support ticket reference.",
        500
      );
    }

    await insertAttachments(
      connection,
      ticketId,
      null,
      userId,
      files
    );

    await notifyAdministrators(
      connection,
      "New Support Ticket",
      `A new support ticket has been submitted: ${ticketReference}.`,
      ticketId
    );

    await connection.commit();

    return {
      id: ticketId,
      ticketReference,
      category: ticketData.category,
      subject: ticketData.subject,
      description: ticketData.description,
      priority: "normal",
      status: "open",
    };
  } catch (error) {
    try {
      await connection.rollback();
    } catch (rollbackError) {
      console.error(
        "Support ticket rollback error:",
        rollbackError.message
      );
    }

    throw error;
  } finally {
    connection.release();
  }
}

// =====================================================
// LIST USER SUPPORT TICKETS
// =====================================================

export async function getUserSupportTickets(
  userId,
  limit = 20,
  offset = 0
) {
  validateUserId(Number(userId));

  const pagination = validatePagination(limit, offset);

  const [tickets] = await pool.execute(
    `SELECT
      t.id,
      t.ticketReference,
      t.category,
      t.subject,
      t.priority,
      t.status,
      t.assignedTo,
      t.resolvedAt,
      t.closedAt,
      t.createdAt,
      t.updatedAt,
      (
        SELECT COUNT(*)
        FROM support_ticket_messages m
        WHERE m.ticketId = t.id
          AND m.isInternal = FALSE
      ) AS messageCount
    FROM support_tickets t
    WHERE t.userId = ?
    ORDER BY t.createdAt DESC
    LIMIT ? OFFSET ?`,
    [
      userId,
      pagination.limit,
      pagination.offset,
    ]
  );

  const [[countResult]] = await pool.execute(
    `SELECT COUNT(*) AS total
     FROM support_tickets
     WHERE userId = ?`,
    [userId]
  );

  return {
    tickets,
    pagination: {
      limit: pagination.limit,
      offset: pagination.offset,
      total: Number(countResult.total),
    },
  };
}

// =====================================================
// ADMIN: LIST ALL SUPPORT TICKETS
// =====================================================

export async function getAllSupportTickets(
  filters = {},
  limit = 20,
  offset = 0
) {
  const pagination = validatePagination(limit, offset);

  const conditions = [];
  const values = [];

  if (filters.status) {
    if (!TICKET_STATUSES.includes(filters.status)) {
      throw createError("Invalid ticket status.");
    }

    conditions.push("t.status = ?");
    values.push(filters.status);
  }

  if (filters.category) {
    if (!TICKET_CATEGORIES.includes(filters.category)) {
      throw createError("Invalid ticket category.");
    }

    conditions.push("t.category = ?");
    values.push(filters.category);
  }

  if (filters.priority) {
    if (!TICKET_PRIORITIES.includes(filters.priority)) {
      throw createError("Invalid ticket priority.");
    }

    conditions.push("t.priority = ?");
    values.push(filters.priority);
  }

  const whereClause = conditions.length
    ? `WHERE ${conditions.join(" AND ")}`
    : "";

  const [tickets] = await pool.execute(
    `SELECT
      t.id,
      t.ticketReference,
      t.userId,
      u.firstName,
      u.lastName,
      u.email,
      t.category,
      t.subject,
      t.priority,
      t.status,
      t.assignedTo,
      t.createdAt,
      t.updatedAt
    FROM support_tickets t
    INNER JOIN users u ON u.id = t.userId
    ${whereClause}
    ORDER BY
      FIELD(t.priority, 'urgent', 'high', 'normal', 'low'),
      t.createdAt ASC
    LIMIT ? OFFSET ?`,
    [
      ...values,
      pagination.limit,
      pagination.offset,
    ]
  );

  const [[countResult]] = await pool.execute(
    `SELECT COUNT(*) AS total
     FROM support_tickets t
     ${whereClause}`,
    values
  );

  return {
    tickets,
    pagination: {
      limit: pagination.limit,
      offset: pagination.offset,
      total: Number(countResult.total),
    },
  };
}

// =====================================================
// GET SUPPORT TICKET DETAILS
// =====================================================

export async function getSupportTicketDetails(
  ticketId,
  userId,
  role = "user"
) {
  const id = validateTicketId(ticketId);
  validateUserId(Number(userId));

  const connection = await pool.getConnection();

  try {
    const ticket = await getTicketForUser(
      connection,
      id,
      userId,
      role
    );

    const [messages] = await connection.execute(
      `SELECT
        m.id,
        m.ticketId,
        m.senderId,
        m.senderType,
        m.message,
        m.isInternal,
        m.createdAt,
        u.firstName,
        u.lastName
      FROM support_ticket_messages m
      INNER JOIN users u ON u.id = m.senderId
      WHERE m.ticketId = ?
        ${role === "admin" ? "" : "AND m.isInternal = FALSE"}
      ORDER BY m.createdAt ASC`,
      [id]
    );

    const [attachments] = await connection.execute(
      `SELECT
        id,
        ticketId,
        messageId,
        uploadedBy,
        fileName,
        fileType,
        fileSize,
        createdAt
      FROM support_ticket_attachments
      WHERE ticketId = ?
      ORDER BY createdAt ASC`,
      [id]
    );

    return {
      ...ticket,
      messages,
      attachments,
    };
  } finally {
    connection.release();
  }
}

// =====================================================
// ADD SUPPORT TICKET MESSAGE
// =====================================================

export async function addSupportTicketMessage(
  ticketId,
  senderId,
  senderType,
  message,
  files = [],
  isInternal = false
) {
  const id = validateTicketId(ticketId);
  validateUserId(Number(senderId));

  if (!["user", "admin"].includes(senderType)) {
    throw createError("Invalid message sender.");
  }

  if (senderType === "user" && isInternal) {
    throw createError(
      "Users cannot submit internal messages.",
      403
    );
  }

  const normalizedMessage = validateMessage(message);

  if (!Array.isArray(files) || files.length > 3) {
    throw createError("You can upload a maximum of 3 attachments.");
  }

  const connection = await pool.getConnection();

  try {
    await connection.beginTransaction();

    const ticket = await getTicketForUser(
      connection,
      id,
      senderId,
      senderType,
      true
    );

    if (
      ticket.status === "closed" ||
      ticket.status === "resolved"
    ) {
      throw createError(
        "This ticket is no longer accepting messages.",
        409
      );
    }

    const [result] = await connection.execute(
      `INSERT INTO support_ticket_messages (
        ticketId,
        senderId,
        senderType,
        message,
        isInternal
      ) VALUES (?, ?, ?, ?, ?)`,
      [
        id,
        senderId,
        senderType,
        normalizedMessage,
        senderType === "admin" && isInternal ? 1 : 0,
      ]
    );

    const messageId = result.insertId;

    await insertAttachments(
      connection,
      id,
      messageId,
      senderId,
      files
    );

    if (senderType === "admin") {
      if (!isInternal) {
        await notifyUser(
          connection,
          ticket.userId,
          "Support Team Replied",
          `The support team has replied to ticket ${ticket.ticketReference}.`,
          id
        );

        await connection.execute(
          `UPDATE support_tickets
           SET status = 'waiting_for_user',
               updatedAt = CURRENT_TIMESTAMP
           WHERE id = ?`,
          [id]
        );
      }
    } else {
      await notifyAdministrators(
        connection,
        "New Support Message",
        `A user has replied to ticket ${ticket.ticketReference}.`,
        id
      );

      await connection.execute(
        `UPDATE support_tickets
         SET status = 'in_progress',
             updatedAt = CURRENT_TIMESTAMP
         WHERE id = ?`,
        [id]
      );
    }

    await connection.commit();

    return {
      id: messageId,
      ticketId: id,
      senderId,
      senderType,
      message: normalizedMessage,
      isInternal: senderType === "admin" && isInternal,
    };
  } catch (error) {
    try {
      await connection.rollback();
    } catch (rollbackError) {
      console.error(
        "Support message rollback error:",
        rollbackError.message
      );
    }

    throw error;
  } finally {
    connection.release();
  }
}

// =====================================================
// CLOSE USER SUPPORT TICKET
// =====================================================

export async function closeUserSupportTicket(
  ticketId,
  userId
) {
  const id = validateTicketId(ticketId);
  validateUserId(Number(userId));

  const connection = await pool.getConnection();

  try {
    await connection.beginTransaction();

    const ticket = await getTicketForUser(
      connection,
      id,
      userId,
      "user",
      true
    );

    if (ticket.status === "closed") {
      throw createError("This ticket is already closed.", 409);
    }

    await connection.execute(
      `UPDATE support_tickets
       SET status = 'closed',
           closedAt = CURRENT_TIMESTAMP,
           updatedAt = CURRENT_TIMESTAMP
       WHERE id = ?
         AND userId = ?`,
      [id, userId]
    );

    await notifyAdministrators(
      connection,
      "Support Ticket Closed",
      `Ticket ${ticket.ticketReference} has been closed by the user.`,
      id
    );

    await connection.commit();

    return {
      id,
      ticketReference: ticket.ticketReference,
      status: "closed",
    };
  } catch (error) {
    try {
      await connection.rollback();
    } catch (rollbackError) {
      console.error(
        "Close ticket rollback error:",
        rollbackError.message
      );
    }

    throw error;
  } finally {
    connection.release();
  }
}

// =====================================================
// ADMIN: ASSIGN SUPPORT TICKET
// =====================================================

export async function assignSupportTicket(
  ticketId,
  adminId,
  assignedTo
) {
  const id = validateTicketId(ticketId);
  validateUserId(Number(adminId));
  validateUserId(Number(assignedTo));

  const connection = await pool.getConnection();

  try {
    await connection.beginTransaction();

    const ticket = await getTicketForUser(
      connection,
      id,
      adminId,
      "admin",
      true
    );

    const [admins] = await connection.execute(
      `SELECT id
       FROM users
       WHERE id = ?
         AND role = 'admin'
         AND accountStatus = 'active'
       LIMIT 1`,
      [assignedTo]
    );

    if (admins.length === 0) {
      throw createError(
        "The selected administrator does not exist or is inactive.",
        404
      );
    }

    await connection.execute(
      `UPDATE support_tickets
       SET assignedTo = ?,
           status = CASE
             WHEN status = 'open' THEN 'in_progress'
             ELSE status
           END,
           updatedAt = CURRENT_TIMESTAMP
       WHERE id = ?`,
      [assignedTo, id]
    );

    await notifyUser(
      connection,
      assignedTo,
      "Support Ticket Assigned",
      `Ticket ${ticket.ticketReference} has been assigned to you.`,
      id
    );

    await connection.commit();

    return {
      id,
      ticketReference: ticket.ticketReference,
      assignedTo,
    };
  } catch (error) {
    try {
      await connection.rollback();
    } catch (rollbackError) {
      console.error(
        "Ticket assignment rollback error:",
        rollbackError.message
      );
    }

    throw error;
  } finally {
    connection.release();
  }
}

// =====================================================
// ADMIN: UPDATE SUPPORT TICKET STATUS
// =====================================================

export async function updateSupportTicketStatus(
  ticketId,
  adminId,
  status,
  priority
) {
  const id = validateTicketId(ticketId);
  validateUserId(Number(adminId));

  if (!TICKET_STATUSES.includes(status)) {
    throw createError("Select a valid ticket status.");
  }

  if (
    priority !== undefined &&
    !TICKET_PRIORITIES.includes(priority)
  ) {
    throw createError("Select a valid ticket priority.");
  }

  const connection = await pool.getConnection();

  try {
    await connection.beginTransaction();

    const ticket = await getTicketForUser(
      connection,
      id,
      adminId,
      "admin",
      true
    );

    const resolvedAt =
      status === "resolved"
        ? "CURRENT_TIMESTAMP"
        : "NULL";

    const closedAt =
      status === "closed"
        ? "CURRENT_TIMESTAMP"
        : "NULL";

    await connection.execute(
      `UPDATE support_tickets
       SET status = ?,
           priority = COALESCE(?, priority),
           resolvedAt = ${resolvedAt},
           closedAt = ${closedAt},
           updatedAt = CURRENT_TIMESTAMP
       WHERE id = ?`,
      [
        status,
        priority ?? null,
        id,
      ]
    );

    if (
      status === "resolved" ||
      status === "closed"
    ) {
      await notifyUser(
        connection,
        ticket.userId,
        status === "resolved"
          ? "Support Ticket Resolved"
          : "Support Ticket Closed",
        `Your support ticket ${ticket.ticketReference} has been ${status}.`,
        id
      );
    }

    await connection.commit();

    return {
      id,
      ticketReference: ticket.ticketReference,
      status,
      priority: priority ?? ticket.priority,
    };
  } catch (error) {
    try {
      await connection.rollback();
    } catch (rollbackError) {
      console.error(
        "Ticket status rollback error:",
        rollbackError.message
      );
    }

    throw error;
  } finally {
    connection.release();
  }
}

export async function getSupportAttachment(
  ticketId,
  attachmentId,
  userId,
  role
) {
  const validTicketId = validateTicketId(ticketId);
  const validAttachmentId = validateTicketId(attachmentId);
  const validUserId = validateUserId(userId);

  const [rows] = await pool.execute(
    `SELECT
      sta.id,
      sta.ticketId,
      sta.messageId,
      sta.uploadedBy,
      sta.fileName,
      sta.fileUrl,
      sta.fileType,
      sta.fileSize,
      sta.createdAt,
      st.userId AS ticketOwnerId
    FROM support_ticket_attachments sta
    INNER JOIN support_tickets st
      ON st.id = sta.ticketId
    WHERE sta.id = ?
      AND sta.ticketId = ?
    LIMIT 1`,
    [
      validAttachmentId,
      validTicketId,
    ]
  );

  if (rows.length === 0) {
    throw createError(
      "Support attachment not found.",
      404
    );
  }

  const attachment = rows[0];

  if (
    role !== "admin" &&
    Number(attachment.ticketOwnerId) !== validUserId
  ) {
    throw createError(
      "You are not authorized to access this attachment.",
      403
    );
  }

  return attachment;
}