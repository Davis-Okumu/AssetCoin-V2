
import multer from "multer";
import crypto from "crypto";
import path from "path";
import fs from "fs";
import { fileTypeFromFile } from "file-type";

const uploadDirectory = path.resolve("uploads");

const imageDirectory = path.join(
  uploadDirectory,
  "assets",
  "photos"
);

const documentDirectory = path.join(
  uploadDirectory,
  "assets",
  "documents"
);

const profilePhotoDirectory = path.join(
  uploadDirectory,
  "profile",
  "photos"
);

// =====================================================
// SUPPORT ATTACHMENT DIRECTORY
// =====================================================

const supportAttachmentDirectory = path.join(
  uploadDirectory,
  "support",
  "attachments"
);

// Ensure upload directories exist.
fs.mkdirSync(imageDirectory, { recursive: true });
fs.mkdirSync(documentDirectory, { recursive: true });
fs.mkdirSync(profilePhotoDirectory, { recursive: true });

fs.mkdirSync(supportAttachmentDirectory, {
  recursive: true,
});

// =====================================================
// ALLOWED FILE TYPES
// =====================================================

export const allowedImages = {
  "image/jpeg": [".jpg", ".jpeg"],
  "image/png": [".png"],
  "image/webp": [".webp"],
};

const allowedDocuments = {
  "application/pdf": [".pdf"],
};

// =====================================================
// STORAGE CONFIGURATION
// =====================================================

function createStorage(destination) {
  return multer.diskStorage({
    destination(req, file, callback) {
      callback(null, destination);
    },

    filename(req, file, callback) {
      const extension = path.extname(
        file.originalname
      ).toLowerCase();

      const filename = `${crypto.randomUUID()}${extension}`;

      callback(null, filename);
    },
  });
}

// =====================================================
// FILE FILTER
// =====================================================

function createFileFilter(allowedTypes) {
  return (req, file, callback) => {
    const extension = path.extname(
      file.originalname
    ).toLowerCase();

    const validExtensions = allowedTypes[file.mimetype];

    if (
      !validExtensions ||
      !validExtensions.includes(extension)
    ) {
      return callback(
        new Error("Unsupported file type.")
      );
    }

    callback(null, true);
  };
}

// =====================================================
// VERIFY ACTUAL FILE CONTENTS
// =====================================================

export async function verifyUploadedFiles(
  files,
  allowedTypes
) {
  for (const file of files) {
    const detectedType = await fileTypeFromFile(
      file.path
    );

    const extension = path.extname(
      file.originalname
    ).toLowerCase();

    if (!detectedType) {
      console.error(
        `File type detection failed: ${file.originalname}`
      );

      return false;
    }

    const allowedExtensions =
      allowedTypes[detectedType.mime];

    if (
      !allowedExtensions ||
      !allowedExtensions.includes(extension)
    ) {
      console.error("Uploaded file validation failed:", {
        originalName: file.originalname,
        detectedMime: detectedType.mime,
        extension,
      });

      return false;
    }
  }

  return true;
}

// =====================================================
// ASSET PHOTO UPLOADS
// =====================================================

export const uploadAssetPhotos = multer({
  storage: createStorage(imageDirectory),
  fileFilter: createFileFilter(allowedImages),
  limits: {
    fileSize: 5 * 1024 * 1024,
    files: 5,
  },
});

// =====================================================
// ASSET SUPPORTING DOCUMENT UPLOADS
// =====================================================

export const uploadAssetDocuments = multer({
  storage: createStorage(documentDirectory),
  fileFilter: createFileFilter(allowedDocuments),
  limits: {
    fileSize: 10 * 1024 * 1024,
    files: 5,
  },
});

// =====================================================
// PROFILE PHOTO UPLOADS
// =====================================================

export const uploadProfilePhoto = multer({
  storage: createStorage(profilePhotoDirectory),
  fileFilter: createFileFilter(allowedImages),
  limits: {
    fileSize: 5 * 1024 * 1024,
    files: 1,
  },
});

// =====================================================
// KYC DOCUMENT UPLOADS
// =====================================================

const kycDocumentDirectory = path.join(
  uploadDirectory,
  "kyc",
  "documents"
);

const kycSelfieDirectory = path.join(
  uploadDirectory,
  "kyc",
  "selfies"
);

fs.mkdirSync(kycDocumentDirectory, { recursive: true });
fs.mkdirSync(kycSelfieDirectory, { recursive: true });

export const allowedKycDocuments = {
  ...allowedImages,
  "application/pdf": [".pdf"],
};

export const allowedKycSelfies = {
  ...allowedImages,
};

const kycStorage = multer.diskStorage({
  destination(req, file, callback) {
    const destination =
      file.fieldname === "idDocument"
        ? kycDocumentDirectory
        : kycSelfieDirectory;

    callback(null, destination);
  },

  filename(req, file, callback) {
    const extension = path.extname(
      file.originalname
    ).toLowerCase();

    callback(
      null,
      `${crypto.randomUUID()}${extension}`
    );
  },
});

const kycFileFilter = (req, file, callback) => {
  const allowedTypes =
    file.fieldname === "idDocument"
      ? allowedKycDocuments
      : file.fieldname === "selfie"
        ? allowedKycSelfies
        : null;

  if (!allowedTypes) {
    return callback(
      new Error("Unsupported file type.")
    );
  }

  const extension = path.extname(
    file.originalname
  ).toLowerCase();

  const validExtensions = allowedTypes[file.mimetype];

  if (
    !validExtensions ||
    !validExtensions.includes(extension)
  ) {
    return callback(
      new Error("Unsupported file type.")
    );
  }

  callback(null, true);
};

export const uploadKycDocuments = multer({
  storage: kycStorage,
  fileFilter: kycFileFilter,
  limits: {
    fileSize: 10 * 1024 * 1024,
    files: 2,
  },
}).fields([
  {
    name: "idDocument",
    maxCount: 1,
  },
  {
    name: "selfie",
    maxCount: 1,
  },
]);

// =====================================================
// SUPPORT TICKET ATTACHMENTS
// =====================================================

export const allowedSupportAttachments = {
  ...allowedImages,
  "application/pdf": [".pdf"],
};

export const uploadSupportAttachments = multer({
  storage: createStorage(supportAttachmentDirectory),

  fileFilter: createFileFilter(
    allowedSupportAttachments
  ),

  limits: {
    fileSize: 10 * 1024 * 1024,
    files: 3,
  },
});