import express from "express";

import {
  createTicket,
  getMyTickets,
  getTicket,
  addMessage,
  closeTicket,
  getAllTickets,
  assignTicket,
  updateTicketStatus,
  downloadAttachment,
} from "../controllers/supportController.js";

import {
  authenticateToken,
} from "../middleware/authMiddleware.js";

import {
  uploadSupportAttachments,
} from "../middleware/uploadMiddleware.js";

const router = express.Router();

// =====================================================
// ALL SUPPORT ROUTES REQUIRE AUTHENTICATION
// =====================================================

router.use(authenticateToken);

// =====================================================
// USER SUPPORT TICKETS
// =====================================================

// CREATE SUPPORT TICKET
router.post(
  "/tickets",
  uploadSupportAttachments.array("attachments", 3),
  createTicket
);

// GET CURRENT USER'S SUPPORT TICKETS
router.get(
  "/tickets",
  getMyTickets
);

// GET SUPPORT TICKET DETAILS
router.get(
  "/tickets/:ticketId",
  getTicket
);

router.get(
  "/tickets/:ticketId/attachments/:attachmentId",
  downloadAttachment
);

// ADD MESSAGE TO SUPPORT TICKET
router.post(
  "/tickets/:ticketId/messages",
  uploadSupportAttachments.array("attachments", 3),
  addMessage
);

// CLOSE SUPPORT TICKET
router.post(
  "/tickets/:ticketId/close",
  closeTicket
);

// =====================================================
// ADMIN SUPPORT OPERATIONS
// =====================================================

// GET ALL SUPPORT TICKETS
router.get(
  "/admin/tickets",
  getAllTickets
);

// ASSIGN SUPPORT TICKET
router.patch(
  "/admin/tickets/:ticketId/assign",
  assignTicket
);

// UPDATE SUPPORT TICKET STATUS / PRIORITY
router.patch(
  "/admin/tickets/:ticketId/status",
  updateTicketStatus
);



export default router;