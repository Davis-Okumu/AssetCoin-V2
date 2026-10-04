import fs from "fs/promises";
import path from "path";

import {
  createSupportTicket,
  getUserSupportTickets,
  getAllSupportTickets,
  getSupportTicketDetails,
  addSupportTicketMessage,
  closeUserSupportTicket,
  assignSupportTicket,
  updateSupportTicketStatus,
  getSupportAttachment,
} from "../services/supportService.js";

import {
  verifyUploadedFiles,
  allowedSupportAttachments,
} from "../middleware/uploadMiddleware.js";

// =====================================================
// HELPER: REMOVE UPLOADED FILES
// =====================================================

async function deleteUploadedFiles(files = []) {
  if (!Array.isArray(files) || files.length === 0) {
    return;
  }

  for (const file of files) {
    if (!file?.path) {
      continue;
    }

    try {
      await fs.unlink(file.path);
    } catch (error) {
      if (error.code !== "ENOENT") {
        console.error(
          "Support attachment cleanup error:",
          error.message
        );
      }
    }
  }
}

async function validateSupportAttachments(files) {
  if (!files || files.length === 0) {
    return;
  }

  const valid = await verifyUploadedFiles(
    files,
    allowedSupportAttachments
  );

  if (!valid) {
    const error = new Error(
      "One or more support attachments contain an invalid file type."
    );
    error.statusCode = 400;
    throw error;
  }
}
// =====================================================
// HELPER: PARSE BOOLEAN
// =====================================================

function parseBoolean(value) {
  if (value === true || value === "true" || value === "1") {
    return true;
  }

  if (value === false || value === "false" || value === "0") {
    return false;
  }

  return Boolean(value);
}

// =====================================================
// CREATE SUPPORT TICKET
// =====================================================

export async function createTicket(req, res) {
  try {
    await validateSupportAttachments(req.files);

    const ticket = await createSupportTicket(
      req.user.id,
      req.body,
      req.files || []
    );

    return res.status(201).json({
      success: true,
      message: "Support ticket created successfully.",
      data: ticket,
    });
  } catch (error) {
    await deleteUploadedFiles(req.files);

    console.error("Create support ticket error:", error);

    return res.status(error.statusCode || 500).json({
      success: false,
      message:
        error.message || "Unable to create support ticket.",
    });
  }
}

// =====================================================
// GET MY SUPPORT TICKETS
// =====================================================

export async function getMyTickets(req, res) {
  try {
    const result = await getUserSupportTickets(
      req.user.id,
      req.query.limit,
      req.query.offset
    );

    return res.status(200).json({
      success: true,
      message: "Support tickets retrieved successfully.",
      data: result,
    });
  } catch (error) {
    console.error(
      "Get support tickets error:",
      error.message
    );

    return res.status(error.statusCode || 500).json({
      success: false,
      message: error.statusCode
        ? error.message
        : "Unable to retrieve your support tickets.",
    });
  }
}

// =====================================================
// GET SUPPORT TICKET DETAILS
// =====================================================

export async function getTicket(req, res) {
  try {
    const ticket = await getSupportTicketDetails(
      req.params.ticketId,
      req.user.id,
      req.user.role
    );

    return res.status(200).json({
      success: true,
      message: "Support ticket retrieved successfully.",
      data: {
        ticket,
      },
    });
  } catch (error) {
    console.error(
      "Get support ticket error:",
      error.message
    );

    return res.status(error.statusCode || 500).json({
      success: false,
      message: error.statusCode
        ? error.message
        : "Unable to retrieve the support ticket.",
    });
  }
}

// =====================================================
// ADD MESSAGE TO SUPPORT TICKET
// =====================================================

export async function addMessage(req, res) {
  try {
    await validateSupportAttachments(req.files);

    const senderType =
      req.user.role === "admin" ? "admin" : "user";

    const isInternal =
      req.user.role === "admin"
        ? parseBoolean(req.body.isInternal)
        : false;

    const result = await addSupportTicketMessage(
      req.params.ticketId,
      req.user.id,
      senderType,
      req.body.message,
      req.files || [],
      isInternal
    );

    return res.status(201).json({
      success: true,
      message: "Support message added successfully.",
      data: result,
    });
  } catch (error) {
    await deleteUploadedFiles(req.files);

    console.error("Add support message error:", error);

    return res.status(error.statusCode || 500).json({
      success: false,
      message:
        error.message || "Unable to add support message.",
    });
  }
}

// =====================================================
// CLOSE MY SUPPORT TICKET
// =====================================================

export async function closeTicket(req, res) {
  try {
    const result = await closeUserSupportTicket(
      req.params.ticketId,
      req.user.id
    );

    return res.status(200).json({
      success: true,
      message: "Support ticket closed successfully.",
      data: {
        ticket: result,
      },
    });
  } catch (error) {
    console.error(
      "Close support ticket error:",
      error.message
    );

    return res.status(error.statusCode || 500).json({
      success: false,
      message: error.statusCode
        ? error.message
        : "Unable to close the support ticket.",
    });
  }
};

// =====================================================
// ADMIN: GET ALL SUPPORT TICKETS
// =====================================================

export async function getAllTickets(req, res) {
  try {
    if (req.user.role !== "admin") {
      return res.status(403).json({
        success: false,
        message: "Administrator access is required.",
      });
    }

    const result = await getAllSupportTickets(
      {
        status: req.query.status,
        category: req.query.category,
        priority: req.query.priority,
      },
      req.query.limit,
      req.query.offset
    );

    return res.status(200).json({
      success: true,
      message: "Support tickets retrieved successfully.",
      data: result,
    });
  } catch (error) {
    console.error(
      "Get all support tickets error:",
      error.message
    );

    return res.status(error.statusCode || 500).json({
      success: false,
      message: error.statusCode
        ? error.message
        : "Unable to retrieve support tickets.",
    });
  }
}

// =====================================================
// ADMIN: ASSIGN SUPPORT TICKET
// =====================================================

export async function assignTicket(req, res) {
  try {
    if (req.user.role !== "admin") {
      return res.status(403).json({
        success: false,
        message: "Administrator access is required.",
      });
    }

    const assignedTo = Number(req.body.assignedTo);

    if (
      !Number.isSafeInteger(assignedTo) ||
      assignedTo <= 0
    ) {
      return res.status(400).json({
        success: false,
        message: "A valid administrator ID is required.",
      });
    }

    const result = await assignSupportTicket(
      req.params.ticketId,
      req.user.id,
      assignedTo
    );

    return res.status(200).json({
      success: true,
      message: "Support ticket assigned successfully.",
      data: {
        ticket: result,
      },
    });
  } catch (error) {
    console.error(
      "Assign support ticket error:",
      error.message
    );

    return res.status(error.statusCode || 500).json({
      success: false,
      message: error.statusCode
        ? error.message
        : "Unable to assign the support ticket.",
    });
  }
}

// =====================================================
// ADMIN: UPDATE SUPPORT TICKET STATUS
// =====================================================

export async function updateTicketStatus(req, res) {
  try {
    if (req.user.role !== "admin") {
      return res.status(403).json({
        success: false,
        message: "Administrator access is required.",
      });
    }

    const result = await updateSupportTicketStatus(
      req.params.ticketId,
      req.user.id,
      req.body.status,
      req.body.priority
    );

    return res.status(200).json({
      success: true,
      message: "Support ticket updated successfully.",
      data: {
        ticket: result,
      },
    });
  } catch (error) {
    console.error(
      "Update support ticket error:",
      error.message
    );

    return res.status(error.statusCode || 500).json({
      success: false,
      message: error.statusCode
        ? error.message
        : "Unable to update the support ticket.",
    });
  }
}


export async function downloadAttachment(req, res) {
  try {
    const attachment = await getSupportAttachment(
      req.params.ticketId,
      req.params.attachmentId,
      req.user.id,
      req.user.role
    );

    const uploadDirectory = path.resolve("uploads");
    const supportAttachmentDirectory = path.join(
      uploadDirectory,
      "support",
      "attachments"
    );

    const storedFileName = path.basename(
      attachment.fileUrl
    );

    const filePath = path.join(
      supportAttachmentDirectory,
      storedFileName
    );

    const resolvedBaseDirectory = path.resolve(
      supportAttachmentDirectory
    );

    const resolvedFilePath = path.resolve(filePath);

    const relativePath = path.relative(
      resolvedBaseDirectory,
      resolvedFilePath
    );

    if (
      relativePath.startsWith("..") ||
      path.isAbsolute(relativePath)
    ) {
      return res.status(400).json({
        success: false,
        message: "Invalid attachment path.",
      });
    }

    try {
      await fs.access(resolvedFilePath);
    } catch {
      return res.status(404).json({
        success: false,
        message: "Attachment file is no longer available.",
      });
    }

    return res.download(
      resolvedFilePath,
      attachment.fileName,
      (error) => {
        if (error && !res.headersSent) {
          console.error(
            "Support attachment download error:",
            error
          );

          return res.status(500).json({
            success: false,
            message: "Unable to download attachment.",
          });
        }
      }
    );
  } catch (error) {
    console.error(
      "Download support attachment error:",
      error
    );

    return res.status(error.statusCode || 500).json({
      success: false,
      message:
        error.message ||
        "Unable to retrieve support attachment.",
    });
  }
}