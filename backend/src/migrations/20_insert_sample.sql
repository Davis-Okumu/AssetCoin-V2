-- =========================================================
-- SAMPLE DATA for CENTRALIZED ASSET TOKENIZATION PLATFORM
-- Fully consistent with the schema (FK order, enums, balances, hash chains).
-- All user passwords: Password@123   (bcrypt hashed)
-- Run AFTER creating the schema.
-- =========================================================
START TRANSACTION;

-- users
INSERT INTO `users` (`id`, `firstName`, `lastName`, `phone`, `email`, `nationalId`, `idDocumentUrl`, `profilePhotoUrl`, `passwordHash`, `kycStatus`, `role`, `accountStatus`, `lastLoginAt`, `createdAt`, `updatedAt`) VALUES
  (1, 'Amina', 'Wanjiru', '+254700000001', 'amina.wanjiru@tokenhub.co.ke', '10000001', '/uploads/ids/10000001.jpg', '/uploads/profiles/user_1.jpg', '$2b$10$16v09QRdF4k/aPXNTldrWO7bo4zCKxY9mna1amuF42TbGkPyvhAb6', 'verified', 'admin', 'active', '2026-09-28 08:30:00', '2026-06-01 08:00:00', '2026-06-01 08:00:00'),
  (2, 'Brian', 'Kiplagat', '+254700000002', 'brian.kiplagat@tokenhub.co.ke', '10000002', '/uploads/ids/10000002.jpg', '/uploads/profiles/user_2.jpg', '$2b$10$16v09QRdF4k/aPXNTldrWO7bo4zCKxY9mna1amuF42TbGkPyvhAb6', 'verified', 'admin', 'active', '2026-09-28 08:30:00', '2026-06-01 08:05:00', '2026-06-01 08:05:00'),
  (3, 'John', 'Kamau', '+254712000003', 'john.kamau@example.com', '21345603', '/uploads/ids/21345603.jpg', '/uploads/profiles/user_3.jpg', '$2b$10$16v09QRdF4k/aPXNTldrWO7bo4zCKxY9mna1amuF42TbGkPyvhAb6', 'verified', 'user', 'active', '2026-09-28 08:30:00', '2026-07-02 09:00:00', '2026-07-02 09:00:00'),
  (4, 'Grace', 'Achieng', '+254722000004', 'grace.achieng@example.com', '22456704', '/uploads/ids/22456704.jpg', '/uploads/profiles/user_4.jpg', '$2b$10$16v09QRdF4k/aPXNTldrWO7bo4zCKxY9mna1amuF42TbGkPyvhAb6', 'verified', 'user', 'active', '2026-09-28 08:30:00', '2026-07-03 10:30:00', '2026-07-03 10:30:00'),
  (5, 'Peter', 'Otieno', '+254733000005', 'peter.otieno@example.com', '23567805', '/uploads/ids/23567805.jpg', '/uploads/profiles/user_5.jpg', '$2b$10$16v09QRdF4k/aPXNTldrWO7bo4zCKxY9mna1amuF42TbGkPyvhAb6', 'verified', 'user', 'active', '2026-09-28 08:30:00', '2026-07-05 11:15:00', '2026-07-05 11:15:00'),
  (6, 'Mary', 'Njeri', '+254744000006', 'mary.njeri@example.com', '24678906', '/uploads/ids/24678906.jpg', '/uploads/profiles/user_6.jpg', '$2b$10$16v09QRdF4k/aPXNTldrWO7bo4zCKxY9mna1amuF42TbGkPyvhAb6', 'verified', 'user', 'active', '2026-09-28 08:30:00', '2026-07-06 14:20:00', '2026-07-06 14:20:00'),
  (7, 'David', 'Mwangi', '+254755000007', 'david.mwangi@example.com', '25789007', '/uploads/ids/25789007.jpg', '/uploads/profiles/user_7.jpg', '$2b$10$16v09QRdF4k/aPXNTldrWO7bo4zCKxY9mna1amuF42TbGkPyvhAb6', 'verified', 'user', 'active', '2026-09-28 08:30:00', '2026-07-08 16:45:00', '2026-07-08 16:45:00'),
  (8, 'Faith', 'Chebet', '+254766000008', 'faith.chebet@example.com', '26890108', '/uploads/ids/26890108.jpg', '/uploads/profiles/user_8.jpg', '$2b$10$16v09QRdF4k/aPXNTldrWO7bo4zCKxY9mna1amuF42TbGkPyvhAb6', 'pending', 'user', 'active', NULL, '2026-09-01 12:00:00', '2026-09-01 12:00:00'),
  (9, 'Samuel', 'Kiprop', '+254777000009', NULL, '27901209', '/uploads/ids/27901209.jpg', '/uploads/profiles/user_9.jpg', '$2b$10$16v09QRdF4k/aPXNTldrWO7bo4zCKxY9mna1amuF42TbGkPyvhAb6', 'rejected', 'user', 'suspended', NULL, '2026-07-10 13:00:00', '2026-07-10 13:00:00');

-- kyc_records
INSERT INTO `kyc_records` (`id`, `userId`, `nationalId`, `idDocumentUrl`, `selfieUrl`, `verificationMethod`, `status`, `rejectionReason`, `verifiedBy`, `verifiedAt`, `submittedAt`, `createdAt`, `updatedAt`) VALUES
  (1, 3, '21345603', '/uploads/ids/21345603.jpg', '/uploads/selfies/3.jpg', 'manual', 'verified', NULL, 1, '2026-07-03 10:00:00', '2026-07-02 09:10:00', '2026-07-02 09:10:00', '2026-07-02 09:10:00'),
  (2, 4, '22456704', '/uploads/ids/22456704.jpg', '/uploads/selfies/4.jpg', 'manual', 'verified', NULL, 1, '2026-07-04 09:30:00', '2026-07-03 10:40:00', '2026-07-03 10:40:00', '2026-07-03 10:40:00'),
  (3, 5, '23567805', '/uploads/ids/23567805.jpg', '/uploads/selfies/5.jpg', 'automated', 'verified', NULL, 2, '2026-07-05 11:20:00', '2026-07-05 11:16:00', '2026-07-05 11:16:00', '2026-07-05 11:16:00'),
  (4, 6, '24678906', '/uploads/ids/24678906.jpg', '/uploads/selfies/6.jpg', 'automated', 'verified', NULL, 2, '2026-07-06 14:25:00', '2026-07-06 14:21:00', '2026-07-06 14:21:00', '2026-07-06 14:21:00'),
  (5, 7, '25789007', '/uploads/ids/25789007.jpg', '/uploads/selfies/7.jpg', 'manual', 'verified', NULL, 1, '2026-07-09 10:00:00', '2026-07-08 16:50:00', '2026-07-08 16:50:00', '2026-07-08 16:50:00'),
  (6, 8, '26890108', '/uploads/ids/26890108.jpg', '/uploads/selfies/8.jpg', 'manual', 'under_review', NULL, NULL, NULL, '2026-09-01 12:10:00', '2026-09-01 12:10:00', '2026-09-01 12:10:00'),
  (7, 9, '27901209', '/uploads/ids/27901209.jpg', '/uploads/selfies/9.jpg', 'manual', 'rejected', 'ID photo is blurred and selfie does not match the ID document.', 2, '2026-07-11 09:00:00', '2026-07-10 13:10:00', '2026-07-10 13:10:00', '2026-07-10 13:10:00');

-- assets
INSERT INTO `assets` (`id`, `ownerId`, `assetCode`, `assetType`, `name`, `description`, `location`, `latitude`, `longitude`, `registrationNumber`, `estimatedValue`, `currency`, `status`, `rejectionReason`, `approvedBy`, `approvedAt`, `createdAt`, `updatedAt`) VALUES
  (1, 3, 'AST-LND-0001', 'land', '5-Acre Prime Farmland, Kiambu', 'Fertile freehold land with water access near Ruiru, suitable for horticulture.', 'Ruiru, Kiambu County', '-1.14610000', '36.96100000', 'KIAMBU/RUIRU/12345', 12000000.00, 'KES', 'tokenized', NULL, 1, '2026-08-15 10:00:00', '2026-08-01 09:00:00', '2026-08-01 09:00:00'),
  (2, 4, 'AST-LVS-0001', 'livestock', '50 Friesian Dairy Cattle Herd', 'Healthy dairy herd with vaccination and milk-yield records.', 'Njoro, Nakuru County', '-0.33030000', '35.94400000', 'KLB-NKR-2026-0087', 4000000.00, 'KES', 'tokenized', NULL, 2, '2026-08-16 11:30:00', '2026-08-02 10:00:00', '2026-08-02 10:00:00'),
  (3, 3, 'AST-PRD-0001', 'produce', 'Maize Harvest 2026 (500 bags)', '500 x 90kg bags of dry maize stored in a certified warehouse.', 'Kitale, Trans Nzoia County', '1.01570000', '35.00620000', NULL, 1500000.00, 'KES', 'approved', NULL, 1, '2026-09-05 15:00:00', '2026-08-28 08:30:00', '2026-08-28 08:30:00'),
  (4, 7, 'AST-VEH-0001', 'vehicle', 'Isuzu FRR Delivery Truck', '2022 Isuzu FRR, 5-ton delivery truck with valid insurance.', 'Industrial Area, Nairobi', '-1.30830000', '36.84850000', 'KDH 482M', 3500000.00, 'KES', 'under_review', NULL, NULL, NULL, '2026-09-10 09:45:00', '2026-09-10 09:45:00'),
  (5, 7, 'AST-PRP-0001', 'property', '3-Bedroom Apartment, Milimani', 'Modern apartment in a gated community with title deed.', 'Milimani, Kisumu', '-0.09170000', '34.76800000', 'KISUMU/MUNICIPALITY/BLOCK5/210', 8000000.00, 'KES', 'pending', NULL, NULL, NULL, '2026-09-18 14:10:00', '2026-09-18 14:10:00'),
  (6, 4, 'AST-EQP-0001', 'equipment', 'Massey Ferguson 385 Tractor', '4WD tractor with ploughing and planting attachments.', 'Njoro, Nakuru County', '-0.33030000', '35.94400000', NULL, 2800000.00, 'KES', 'draft', NULL, NULL, NULL, '2026-09-22 16:00:00', '2026-09-22 16:00:00'),
  (7, 7, 'AST-LND-0002', 'land', '1-Acre Plot, Kitengela', 'Residential plot along Namanga road.', 'Kitengela, Kajiado County', '-1.47320000', '36.95900000', 'KAJIADO/KITENGELA/7788', 1800000.00, 'KES', 'rejected', 'Title deed could not be verified against Ministry of Lands records.', 2, '2026-08-25 12:00:00', '2026-08-20 11:00:00', '2026-08-20 11:00:00');

-- asset_photos
INSERT INTO `asset_photos` (`id`, `assetId`, `photoUrl`, `isPrimary`, `displayOrder`, `createdAt`) VALUES
  (1, 1, '/uploads/assets/1/front.jpg', 1, 0, '2026-08-01 09:30:00'),
  (2, 1, '/uploads/assets/1/aerial.jpg', 0, 1, '2026-08-01 09:30:00'),
  (3, 1, '/uploads/assets/1/boundary.jpg', 0, 2, '2026-08-01 09:30:00'),
  (4, 2, '/uploads/assets/2/herd.jpg', 1, 0, '2026-08-01 09:30:00'),
  (5, 2, '/uploads/assets/2/milking.jpg', 0, 1, '2026-08-01 09:30:00'),
  (6, 3, '/uploads/assets/3/warehouse.jpg', 1, 0, '2026-08-01 09:30:00'),
  (7, 4, '/uploads/assets/4/exterior.jpg', 1, 0, '2026-08-01 09:30:00'),
  (8, 4, '/uploads/assets/4/interior.jpg', 0, 1, '2026-08-01 09:30:00'),
  (9, 5, '/uploads/assets/5/living_room.jpg', 1, 0, '2026-08-01 09:30:00'),
  (10, 5, '/uploads/assets/5/exterior.jpg', 0, 1, '2026-08-01 09:30:00');

-- asset_documents
INSERT INTO `asset_documents` (`id`, `assetId`, `documentType`, `documentName`, `documentUrl`, `documentHash`, `status`, `verifiedBy`, `verifiedAt`, `createdAt`) VALUES
  (1, 1, 'ownership', 'Title Deed - Kiambu/Ruiru/12345', '/uploads/docs/1.pdf', '96248eef9b81bca5a8db86d5d7b7e47d7d835c88123471c63d64d4bbf0380c4d', 'verified', 1, '2026-08-10 10:00:00', '2026-08-05 09:00:00'),
  (2, 1, 'valuation', 'Professional Valuation Report - Pacific Valuers', '/uploads/docs/2.pdf', '99826eadeadf6c47c143e37ec3b831136933c627d13a2231c0430f6e8f1581fa', 'verified', 1, '2026-08-11 10:00:00', '2026-08-05 09:00:00'),
  (3, 1, 'legal', 'Official Land Search Certificate', '/uploads/docs/3.pdf', '77e5b580209165f3cd8a69be0ca3acbc0856e99f7840ac75161e64fc0a01fa01', 'verified', 1, '2026-08-11 11:00:00', '2026-08-05 09:00:00'),
  (4, 2, 'ownership', 'Livestock Ownership Certificate', '/uploads/docs/4.pdf', '9955cf507bcf48a93d89cc3e6ce278a747e578e2a144bcba6f4d019ed48e144e', 'verified', 2, '2026-08-12 09:00:00', '2026-08-05 09:00:00'),
  (5, 2, 'valuation', 'Herd Valuation Report - AgriVal Kenya', '/uploads/docs/5.pdf', 'aa1b54682ab15a5f8d6d58d30e2c7d53de18b01af5caa398662ce72574343b01', 'verified', 2, '2026-08-13 09:00:00', '2026-08-05 09:00:00'),
  (6, 2, 'inspection', 'Veterinary Inspection Report', '/uploads/docs/6.pdf', '12a033c98ca5ea89bdd11b8fc3413650911be266dfb8acbaad2cfddd964e343c', 'verified', 2, '2026-08-13 10:00:00', '2026-08-05 09:00:00'),
  (7, 3, 'inspection', 'Warehouse Stock Receipt', '/uploads/docs/7.pdf', '19033ba68c5262a0e09ae1a7fea1e659a7732d586b5b4c4029a91f40b0f47565', 'verified', 1, '2026-09-03 10:00:00', '2026-08-05 09:00:00'),
  (8, 4, 'registration', 'Vehicle Logbook - KDH 482M', '/uploads/docs/8.pdf', 'aea09bf53173eda75910a186870f34d650e859b1f84e2dd03592185e6e5bba5b', 'pending', NULL, NULL, '2026-08-05 09:00:00'),
  (9, 5, 'ownership', 'Title Deed - Kisumu Apartment', '/uploads/docs/9.pdf', '11b2e4a884397102a20ecab7846be02cc77dc0ad272888a907a73993374be0a7', 'pending', NULL, NULL, '2026-08-05 09:00:00'),
  (10, 7, 'ownership', 'Title Deed - Kajiado/Kitengela/7788', '/uploads/docs/10.pdf', '5c7f5cfc311b32c1427818f359cf3be366ba703e35ea216a000c02daef7b6560', 'rejected', 2, '2026-08-24 10:00:00', '2026-08-05 09:00:00');

-- asset_valuations
INSERT INTO `asset_valuations` (`id`, `assetId`, `valuationAmount`, `currency`, `valuationMethod`, `valuerName`, `valuationDocumentId`, `notes`, `status`, `valuedAt`, `createdAt`) VALUES
  (1, 1, 11500000.00, 'KES', 'market', 'Kenya Land Index', NULL, 'Earlier market-based estimate.', 'verified', '2026-02-10 09:00:00', '2026-02-10 09:00:00'),
  (2, 1, 12000000.00, 'KES', 'professional', 'Pacific Valuers Ltd', 2, 'Current professional valuation.', 'verified', '2026-08-11 10:00:00', '2026-08-11 10:00:00'),
  (3, 2, 4000000.00, 'KES', 'professional', 'AgriVal Kenya', 5, 'Valuation of 50 head of dairy cattle.', 'verified', '2026-08-13 09:00:00', '2026-08-13 09:00:00'),
  (4, 3, 1500000.00, 'KES', 'market', NULL, NULL, 'Based on NCPB maize price of KES 3,000 per bag.', 'verified', '2026-09-03 10:00:00', '2026-09-03 10:00:00'),
  (5, 4, 3500000.00, 'KES', 'manual', NULL, NULL, 'Owner estimate, awaiting professional valuation.', 'pending', '2026-09-10 09:45:00', '2026-09-10 09:45:00');

-- tokens
INSERT INTO `tokens` (`id`, `assetId`, `tokenCode`, `tokenName`, `description`, `totalSupply`, `availableSupply`, `tokenPrice`, `currency`, `decimals`, `status`, `mintedAt`, `createdAt`, `updatedAt`) VALUES
  (1, 1, 'TKN-LAND-001', 'Kiambu Farmland Token', 'Fractional ownership of the 5-acre Kiambu farmland. 1 token = KES 1,000 of asset value.', 12000.00000000, 10500.00000000, 1000.00000000, 'KES', 8, 'active', '2026-08-20 09:00:00', '2026-08-20 09:00:00', '2026-09-08 10:30:00'),
  (2, 2, 'TKN-CATL-001', 'Nakuru Dairy Herd Token', 'Fractional ownership of the Nakuru dairy herd. 1 token = KES 1,000 of asset value.', 4000.00000000, 3300.00000000, 1000.00000000, 'KES', 8, 'active', '2026-08-20 09:30:00', '2026-08-20 09:30:00', '2026-09-08 10:30:00');

-- token_holdings
INSERT INTO `token_holdings` (`id`, `userId`, `tokenId`, `quantity`, `lockedQuantity`, `averageBuyPrice`, `totalInvested`, `createdAt`, `updatedAt`) VALUES
  (1, 5, 1, 800.00000000, 0.00000000, 1000.00000000, 800000.00, '2026-08-26 09:15:00', '2026-09-08 10:30:00'),
  (2, 6, 1, 700.00000000, 0.00000000, 1028.57142857, 720000.00, '2026-08-26 14:40:00', '2026-09-08 10:30:00'),
  (3, 5, 2, 400.00000000, 0.00000000, 1000.00000000, 400000.00, '2026-08-28 11:05:00', '2026-09-08 10:30:00'),
  (4, 6, 2, 300.00000000, 100.00000000, 1000.00000000, 300000.00, '2026-08-29 16:20:00', '2026-09-08 10:30:00');

-- wallets
INSERT INTO `wallets` (`id`, `userId`, `walletAddress`, `fiatBalance`, `lockedFiatBalance`, `currency`, `status`, `createdAt`, `updatedAt`) VALUES
  (1, 3, 'WLT-0A6032BE550D2AE6', 1785000.00, 0.00, 'KES', 'active', '2026-07-03 09:00:00', '2026-09-08 10:30:00'),
  (2, 4, 'WLT-7547397DC9FAF1B0', 893000.00, 0.00, 'KES', 'active', '2026-07-04 09:00:00', '2026-09-08 10:30:00'),
  (3, 5, 'WLT-F938FB3DF149A9DA', 817800.00, 49000.00, 'KES', 'active', '2026-07-05 09:00:00', '2026-09-08 10:30:00'),
  (4, 6, 'WLT-22A175A7F88AA748', 480000.00, 0.00, 'KES', 'active', '2026-07-06 09:00:00', '2026-09-08 10:30:00'),
  (5, 7, 'WLT-F2FDCCC0F287B781', 400000.00, 0.00, 'KES', 'active', '2026-07-07 09:00:00', '2026-09-08 10:30:00'),
  (6, 8, 'WLT-3093DA36700E5486', 0.00, 0.00, 'KES', 'active', '2026-09-01 12:05:00', '2026-09-08 10:30:00');

-- listings
INSERT INTO `listings` (`id`, `sellerId`, `tokenId`, `quantity`, `remainingQuantity`, `pricePerToken`, `currency`, `listingType`, `status`, `expiresAt`, `createdAt`, `updatedAt`) VALUES
  (1, 5, 1, 200.00000000, 0.00000000, 1100.00000000, 'KES', 'sell', 'filled', NULL, '2026-09-08 09:00:00', '2026-09-08 10:30:00'),
  (2, 6, 2, 100.00000000, 100.00000000, 1050.00000000, 'KES', 'sell', 'active', '2026-10-09 00:00:00', '2026-09-09 10:00:00', '2026-09-09 10:00:00'),
  (3, 5, 2, 50.00000000, 50.00000000, 980.00000000, 'KES', 'buy', 'active', '2026-10-10 00:00:00', '2026-09-10 11:00:00', '2026-09-10 11:00:00');

-- orders
INSERT INTO `orders` (`id`, `orderReference`, `userId`, `tokenId`, `listingId`, `orderType`, `quantity`, `filledQuantity`, `pricePerToken`, `totalAmount`, `currency`, `status`, `createdAt`, `updatedAt`) VALUES
  (1, 'ORD-2026-000001', 5, 1, NULL, 'buy', 1000.00000000, 1000.00000000, 1000.00000000, 1000000.00, 'KES', 'filled', '2026-08-26 09:14:00', '2026-08-26 09:15:00'),
  (2, 'ORD-2026-000002', 6, 1, NULL, 'buy', 500.00000000, 500.00000000, 1000.00000000, 500000.00, 'KES', 'filled', '2026-08-26 14:39:00', '2026-08-26 14:40:00'),
  (3, 'ORD-2026-000003', 5, 2, NULL, 'buy', 400.00000000, 400.00000000, 1000.00000000, 400000.00, 'KES', 'filled', '2026-08-28 11:04:00', '2026-08-28 11:05:00'),
  (4, 'ORD-2026-000004', 6, 2, NULL, 'buy', 300.00000000, 300.00000000, 1000.00000000, 300000.00, 'KES', 'filled', '2026-08-29 16:19:00', '2026-08-29 16:20:00'),
  (5, 'ORD-2026-000005', 5, 1, 1, 'sell', 200.00000000, 200.00000000, 1100.00000000, 220000.00, 'KES', 'filled', '2026-09-08 09:00:00', '2026-09-08 10:30:00'),
  (6, 'ORD-2026-000006', 6, 1, 1, 'buy', 200.00000000, 200.00000000, 1100.00000000, 220000.00, 'KES', 'filled', '2026-09-08 10:29:00', '2026-09-08 10:30:00'),
  (7, 'ORD-2026-000007', 5, 2, NULL, 'buy', 100.00000000, 0.00000000, 900.00000000, 90000.00, 'KES', 'cancelled', '2026-09-01 10:00:00', '2026-09-02 08:00:00'),
  (8, 'ORD-2026-000008', 6, 2, 2, 'sell', 100.00000000, 0.00000000, 1050.00000000, 105000.00, 'KES', 'open', '2026-09-09 10:00:00', '2026-09-09 10:00:00'),
  (9, 'ORD-2026-000009', 5, 2, 3, 'buy', 50.00000000, 0.00000000, 980.00000000, 49000.00, 'KES', 'open', '2026-09-10 11:00:00', '2026-09-10 11:00:00');

-- transactions
INSERT INTO `transactions` (`id`, `transactionReference`, `buyerId`, `sellerId`, `tokenId`, `listingId`, `buyOrderId`, `sellOrderId`, `quantity`, `pricePerToken`, `totalAmount`, `feeAmount`, `currency`, `status`, `previousHash`, `transactionHash`, `createdAt`) VALUES
  (1, 'TXN-000001', 5, 3, 1, NULL, 1, NULL, 1000.00000000, 1000.00000000, 1000000.00, 10000.00, 'KES', 'completed', NULL, '3dce448e929405d31f8139b01dea43302d0508f965edb8aff70b1d176d4af31c', '2026-08-26 09:15:00'),
  (2, 'TXN-000002', 6, 3, 1, NULL, 2, NULL, 500.00000000, 1000.00000000, 500000.00, 5000.00, 'KES', 'completed', '3dce448e929405d31f8139b01dea43302d0508f965edb8aff70b1d176d4af31c', 'c53e2c5eabcbff2d35d88baf382922aa2d53cbdf5fffefc9f9473019f9aa506a', '2026-08-26 14:40:00'),
  (3, 'TXN-000003', 5, 4, 2, NULL, 3, NULL, 400.00000000, 1000.00000000, 400000.00, 4000.00, 'KES', 'completed', 'c53e2c5eabcbff2d35d88baf382922aa2d53cbdf5fffefc9f9473019f9aa506a', 'c312886b32ff6319885dcd565d65f9385867bf370c9685e0000cca74f3d3a1a4', '2026-08-28 11:05:00'),
  (4, 'TXN-000004', 6, 4, 2, NULL, 4, NULL, 300.00000000, 1000.00000000, 300000.00, 3000.00, 'KES', 'completed', 'c312886b32ff6319885dcd565d65f9385867bf370c9685e0000cca74f3d3a1a4', 'ad5cfa0d2e38d6d492766872f43fa95fbe9f9ab1d79d6685d9d97e5d40b41db9', '2026-08-29 16:20:00'),
  (5, 'TXN-000005', 6, 5, 1, 1, 6, 5, 200.00000000, 1100.00000000, 220000.00, 2200.00, 'KES', 'completed', 'ad5cfa0d2e38d6d492766872f43fa95fbe9f9ab1d79d6685d9d97e5d40b41db9', 'f48f0724059fc5737ee54c28c49ed528a40106d4a49b85c95fcadccecee6f746', '2026-09-08 10:30:00');

-- wallet_transactions
INSERT INTO `wallet_transactions` (`id`, `walletId`, `userId`, `transactionReference`, `transactionType`, `amount`, `currency`, `balanceBefore`, `balanceAfter`, `status`, `description`, `previousHash`, `transactionHash`, `createdAt`) VALUES
  (1, 3, 5, 'WTX-000001', 'deposit', 2000000.00, 'KES', 0.00, 2000000.00, 'completed', 'Wallet top-up via M-Pesa', NULL, '5522ed8398c7e918098ad4364cde42dbae2f161248787b660da6afe506e19a2b', '2026-08-25 10:00:00'),
  (2, 4, 6, 'WTX-000002', 'deposit', 1500000.00, 'KES', 0.00, 1500000.00, 'completed', 'Wallet top-up via M-Pesa', '5522ed8398c7e918098ad4364cde42dbae2f161248787b660da6afe506e19a2b', '79a0e9da2774e897fc0031f0cf36397c6b087c9aa01f3c5b7a58e8451c90b876', '2026-08-25 10:20:00'),
  (3, 5, 7, 'WTX-000003', 'deposit', 500000.00, 'KES', 0.00, 500000.00, 'completed', 'Wallet top-up via M-Pesa', '79a0e9da2774e897fc0031f0cf36397c6b087c9aa01f3c5b7a58e8451c90b876', '20f250ca431e94fec3db0d3aab6452b4d261545ec8fafbc39900ff6ef5c139f1', '2026-08-25 11:00:00'),
  (4, 1, 3, 'WTX-000004', 'deposit', 300000.00, 'KES', 0.00, 300000.00, 'completed', 'Wallet top-up via M-Pesa', '20f250ca431e94fec3db0d3aab6452b4d261545ec8fafbc39900ff6ef5c139f1', '7ac293bb36d2ff2b827f71020f76871bb7ce2674c4b7235736f9ded7f8e836ee', '2026-08-25 11:30:00'),
  (5, 2, 4, 'WTX-000005', 'deposit', 200000.00, 'KES', 0.00, 200000.00, 'completed', 'Wallet top-up via M-Pesa', '7ac293bb36d2ff2b827f71020f76871bb7ce2674c4b7235736f9ded7f8e836ee', '6bc1cd22c96af50bc9e35ac8c71cf2f00d98b299640e8c4cfd47503c0697616f', '2026-08-25 12:00:00'),
  (6, 3, 5, 'WTX-000006', 'token_purchase', 1000000.00, 'KES', 2000000.00, 1000000.00, 'completed', 'Purchase of 1000 TKN-LAND-001 @ KES 1000', '6bc1cd22c96af50bc9e35ac8c71cf2f00d98b299640e8c4cfd47503c0697616f', '09f2518836b640effca978abdc833892292ea532a1f5c6f31ac3b9bccdb3b45c', '2026-08-26 09:15:00'),
  (7, 1, 3, 'WTX-000007', 'token_sale', 1000000.00, 'KES', 300000.00, 1300000.00, 'completed', 'Sale of 1000 TKN-LAND-001 @ KES 1000', '09f2518836b640effca978abdc833892292ea532a1f5c6f31ac3b9bccdb3b45c', '941a7f454fc6e1888f93010bfec1129764862c1f8dcc6966ad3d103ada7cff09', '2026-08-26 09:15:00'),
  (8, 1, 3, 'WTX-000008', 'fee', 10000.00, 'KES', 1300000.00, 1290000.00, 'completed', '1% platform fee on TXN-000001', '941a7f454fc6e1888f93010bfec1129764862c1f8dcc6966ad3d103ada7cff09', '289d00a9c60e5583dbdcfcf962e74771131666eee9461811d5f25496e8e6b623', '2026-08-26 09:15:00'),
  (9, 4, 6, 'WTX-000009', 'token_purchase', 500000.00, 'KES', 1500000.00, 1000000.00, 'completed', 'Purchase of 500 TKN-LAND-001 @ KES 1000', '289d00a9c60e5583dbdcfcf962e74771131666eee9461811d5f25496e8e6b623', '58834d338527e405a14f7057b88338e9543d74c26a671a90f9adf95e5436f9c7', '2026-08-26 14:40:00'),
  (10, 1, 3, 'WTX-000010', 'token_sale', 500000.00, 'KES', 1290000.00, 1790000.00, 'completed', 'Sale of 500 TKN-LAND-001 @ KES 1000', '58834d338527e405a14f7057b88338e9543d74c26a671a90f9adf95e5436f9c7', '40d04197a93d9003d27c5abde35dc4d7a95e80f3a1af33545561e13ea607b1bf', '2026-08-26 14:40:00'),
  (11, 1, 3, 'WTX-000011', 'fee', 5000.00, 'KES', 1790000.00, 1785000.00, 'completed', '1% platform fee on TXN-000002', '40d04197a93d9003d27c5abde35dc4d7a95e80f3a1af33545561e13ea607b1bf', '906f3f1a90202de31b77ad3ac2032603c57d733a99a49a60ddd092de6f36b311', '2026-08-26 14:40:00'),
  (12, 3, 5, 'WTX-000012', 'token_purchase', 400000.00, 'KES', 1000000.00, 600000.00, 'completed', 'Purchase of 400 TKN-CATL-001 @ KES 1000', '906f3f1a90202de31b77ad3ac2032603c57d733a99a49a60ddd092de6f36b311', 'a5042dcaa68cae5fca7354fd87d08d432a496516cec1b6f462ffbf9194caf3fd', '2026-08-28 11:05:00'),
  (13, 2, 4, 'WTX-000013', 'token_sale', 400000.00, 'KES', 200000.00, 600000.00, 'completed', 'Sale of 400 TKN-CATL-001 @ KES 1000', 'a5042dcaa68cae5fca7354fd87d08d432a496516cec1b6f462ffbf9194caf3fd', '460789bd7f8070d43243433f8e92c94f79b6138dcbe6b645f89562a03bc82c09', '2026-08-28 11:05:00'),
  (14, 2, 4, 'WTX-000014', 'fee', 4000.00, 'KES', 600000.00, 596000.00, 'completed', '1% platform fee on TXN-000003', '460789bd7f8070d43243433f8e92c94f79b6138dcbe6b645f89562a03bc82c09', 'e9abfdc22b26222f13d523018e143b4f7442c4d81c1401b39886f9ba1190c6f2', '2026-08-28 11:05:00'),
  (15, 4, 6, 'WTX-000015', 'token_purchase', 300000.00, 'KES', 1000000.00, 700000.00, 'completed', 'Purchase of 300 TKN-CATL-001 @ KES 1000', 'e9abfdc22b26222f13d523018e143b4f7442c4d81c1401b39886f9ba1190c6f2', '92c2cab305e4d3277076043aa0da05b591854c4aeb2aadc5f5179a24e345a5a9', '2026-08-29 16:20:00'),
  (16, 2, 4, 'WTX-000016', 'token_sale', 300000.00, 'KES', 596000.00, 896000.00, 'completed', 'Sale of 300 TKN-CATL-001 @ KES 1000', '92c2cab305e4d3277076043aa0da05b591854c4aeb2aadc5f5179a24e345a5a9', 'eeb72c3fdd07179278c27c5e788d37be6a69fe64f047fed953fae002cd71bfe6', '2026-08-29 16:20:00'),
  (17, 2, 4, 'WTX-000017', 'fee', 3000.00, 'KES', 896000.00, 893000.00, 'completed', '1% platform fee on TXN-000004', 'eeb72c3fdd07179278c27c5e788d37be6a69fe64f047fed953fae002cd71bfe6', '2bee34d3bfb6fa58eebdf2a65bed8937d690c0e10349096435b3af4722370cf3', '2026-08-29 16:20:00'),
  (18, 5, 7, 'WTX-000018', 'withdrawal', 100000.00, 'KES', 500000.00, 400000.00, 'completed', 'Withdrawal to M-Pesa +254755000007', '2bee34d3bfb6fa58eebdf2a65bed8937d690c0e10349096435b3af4722370cf3', '16202536a9fb6e4172f5136c03e012e98ba5992780ce3fde8bd94144a1f88faa', '2026-09-03 12:00:00'),
  (19, 6, 8, 'WTX-000019', 'deposit', 50000.00, 'KES', 0.00, 0.00, 'failed', 'M-Pesa payment was not completed', '16202536a9fb6e4172f5136c03e012e98ba5992780ce3fde8bd94144a1f88faa', '378955946c25b26af3a85b2e46a9925ef1c1ac991767aa08f37081b4ffccf572', '2026-09-04 08:30:00'),
  (20, 4, 6, 'WTX-000020', 'token_purchase', 220000.00, 'KES', 700000.00, 480000.00, 'completed', 'Purchase of 200 TKN-LAND-001 @ KES 1100', '378955946c25b26af3a85b2e46a9925ef1c1ac991767aa08f37081b4ffccf572', '2ee631eabdf96be410845d2f56f7657b942f447ce6730bcdb9380a78c8a3217b', '2026-09-08 10:30:00'),
  (21, 3, 5, 'WTX-000021', 'token_sale', 220000.00, 'KES', 600000.00, 820000.00, 'completed', 'Sale of 200 TKN-LAND-001 @ KES 1100', '2ee631eabdf96be410845d2f56f7657b942f447ce6730bcdb9380a78c8a3217b', 'c8a829096d758a326a4e3fbccde462502c75b09d0f6154373b7f23bed0428d7e', '2026-09-08 10:30:00'),
  (22, 3, 5, 'WTX-000022', 'fee', 2200.00, 'KES', 820000.00, 817800.00, 'completed', '1% platform fee on TXN-000005', 'c8a829096d758a326a4e3fbccde462502c75b09d0f6154373b7f23bed0428d7e', '07ef229b1cf0bb7345fddf0fa90334ffa0397012998fc4fd99fea12fc9866536', '2026-09-08 10:30:00');

-- token_price_history
INSERT INTO `token_price_history` (`id`, `tokenId`, `price`, `currency`, `source`, `referenceId`, `recordedAt`) VALUES
  (1, 1, 1000.00000000, 'KES', 'valuation', 2, '2026-08-20 09:00:00'),
  (2, 2, 1000.00000000, 'KES', 'valuation', 3, '2026-08-20 09:30:00'),
  (3, 1, 1000.00000000, 'KES', 'transaction', 1, '2026-08-26 09:15:00'),
  (4, 1, 1000.00000000, 'KES', 'transaction', 2, '2026-08-26 14:40:00'),
  (5, 2, 1000.00000000, 'KES', 'transaction', 3, '2026-08-28 11:05:00'),
  (6, 2, 1000.00000000, 'KES', 'transaction', 4, '2026-08-29 16:20:00'),
  (7, 1, 1100.00000000, 'KES', 'transaction', 5, '2026-09-08 10:30:00');

-- ledger_entries
INSERT INTO `ledger_entries` (`id`, `entryReference`, `userId`, `walletId`, `tokenId`, `transactionId`, `entryType`, `assetType`, `amount`, `currency`, `balanceBefore`, `balanceAfter`, `description`, `previousHash`, `entryHash`, `createdAt`) VALUES
  (1, 'LDG-000001', 5, 3, NULL, NULL, 'credit', 'fiat', 2000000.00000000, 'KES', 0.00000000, 2000000.00000000, 'Wallet top-up via M-Pesa', NULL, '0ce6b7631a81e7271a12a95c3982ae8b28f74f34fa5eff3d952cb8938807373c', '2026-08-25 10:00:00'),
  (2, 'LDG-000002', 6, 4, NULL, NULL, 'credit', 'fiat', 1500000.00000000, 'KES', 0.00000000, 1500000.00000000, 'Wallet top-up via M-Pesa', '0ce6b7631a81e7271a12a95c3982ae8b28f74f34fa5eff3d952cb8938807373c', '60dc5a71da13731508d904827cb8c4893d8a981c5181fd1cc3c8d381e1067e24', '2026-08-25 10:20:00'),
  (3, 'LDG-000003', 7, 5, NULL, NULL, 'credit', 'fiat', 500000.00000000, 'KES', 0.00000000, 500000.00000000, 'Wallet top-up via M-Pesa', '60dc5a71da13731508d904827cb8c4893d8a981c5181fd1cc3c8d381e1067e24', '27b5678ce02996ce9f856f0cc9b250793a48f310939e8753bc4c7ee886f75d07', '2026-08-25 11:00:00'),
  (4, 'LDG-000004', 3, 1, NULL, NULL, 'credit', 'fiat', 300000.00000000, 'KES', 0.00000000, 300000.00000000, 'Wallet top-up via M-Pesa', '27b5678ce02996ce9f856f0cc9b250793a48f310939e8753bc4c7ee886f75d07', '2f446a82dfc930b4451e7be01c8b87b91717988c016179f5b554f5c1b491b957', '2026-08-25 11:30:00'),
  (5, 'LDG-000005', 4, 2, NULL, NULL, 'credit', 'fiat', 200000.00000000, 'KES', 0.00000000, 200000.00000000, 'Wallet top-up via M-Pesa', '2f446a82dfc930b4451e7be01c8b87b91717988c016179f5b554f5c1b491b957', 'b7c4c17c2188305bb79f3ca056e95dfd1268b9a37d1c86413da46d8cd2b76b16', '2026-08-25 12:00:00'),
  (6, 'LDG-000006', 5, 3, NULL, 1, 'debit', 'fiat', 1000000.00000000, 'KES', 2000000.00000000, 1000000.00000000, 'Purchase of 1000 TKN-LAND-001 @ KES 1000', 'b7c4c17c2188305bb79f3ca056e95dfd1268b9a37d1c86413da46d8cd2b76b16', '02f9226267bb1603dd1cf688d214e83f244ed96148b6e75dcc6914c1db2567e8', '2026-08-26 09:15:00'),
  (7, 'LDG-000007', 3, 1, NULL, 1, 'credit', 'fiat', 1000000.00000000, 'KES', 300000.00000000, 1300000.00000000, 'Sale of 1000 TKN-LAND-001 @ KES 1000', '02f9226267bb1603dd1cf688d214e83f244ed96148b6e75dcc6914c1db2567e8', 'd9b56f555555c9b70252ad0b670064690d3aa0c8adf94f62144e0caa4d9462e1', '2026-08-26 09:15:00'),
  (8, 'LDG-000008', 3, 1, NULL, 1, 'debit', 'fiat', 10000.00000000, 'KES', 1300000.00000000, 1290000.00000000, '1% platform fee on TXN-000001', 'd9b56f555555c9b70252ad0b670064690d3aa0c8adf94f62144e0caa4d9462e1', '4ca4df6a6acba0c1af05d2adb5af9d0c6142d1c04c9fe10b45960389711f60c4', '2026-08-26 09:15:00'),
  (9, 'LDG-000009', NULL, NULL, 1, 1, 'debit', 'token', 1000.00000000, NULL, 12000.00000000, 11000.00000000, 'Primary issuance of TKN-LAND-001 from supply pool', '4ca4df6a6acba0c1af05d2adb5af9d0c6142d1c04c9fe10b45960389711f60c4', '503a87a712e736cca8b585f89a205946dd63720d3f2f82ee06572949e8abc6f0', '2026-08-26 09:15:00'),
  (10, 'LDG-000010', 5, NULL, 1, 1, 'credit', 'token', 1000.00000000, NULL, 0.00000000, 1000.00000000, 'Received 1000 TKN-LAND-001', '503a87a712e736cca8b585f89a205946dd63720d3f2f82ee06572949e8abc6f0', '0252b99356911156f56dbfcbc3c035ca157243a8d73c4f7d64cfcca3be31c6aa', '2026-08-26 09:15:00'),
  (11, 'LDG-000011', 6, 4, NULL, 2, 'debit', 'fiat', 500000.00000000, 'KES', 1500000.00000000, 1000000.00000000, 'Purchase of 500 TKN-LAND-001 @ KES 1000', '0252b99356911156f56dbfcbc3c035ca157243a8d73c4f7d64cfcca3be31c6aa', '846bc24772e94414197b64e4364743b1cd7a42f8b84f928b934a21c5cd26c6a1', '2026-08-26 14:40:00'),
  (12, 'LDG-000012', 3, 1, NULL, 2, 'credit', 'fiat', 500000.00000000, 'KES', 1290000.00000000, 1790000.00000000, 'Sale of 500 TKN-LAND-001 @ KES 1000', '846bc24772e94414197b64e4364743b1cd7a42f8b84f928b934a21c5cd26c6a1', '04c078a488082d1ae309f3f80d92def5187a049c7b70bd4fb2ba4267f9615298', '2026-08-26 14:40:00'),
  (13, 'LDG-000013', 3, 1, NULL, 2, 'debit', 'fiat', 5000.00000000, 'KES', 1790000.00000000, 1785000.00000000, '1% platform fee on TXN-000002', '04c078a488082d1ae309f3f80d92def5187a049c7b70bd4fb2ba4267f9615298', '35fbcfd0331838c814fecb82c177afb62ee8a327e7b3c8928064059763a18fcc', '2026-08-26 14:40:00'),
  (14, 'LDG-000014', NULL, NULL, 1, 2, 'debit', 'token', 500.00000000, NULL, 11000.00000000, 10500.00000000, 'Primary issuance of TKN-LAND-001 from supply pool', '35fbcfd0331838c814fecb82c177afb62ee8a327e7b3c8928064059763a18fcc', '0fe09985c14b232e116611e0d2871f0accbe475caa6178033dbbb4298147f981', '2026-08-26 14:40:00'),
  (15, 'LDG-000015', 6, NULL, 1, 2, 'credit', 'token', 500.00000000, NULL, 0.00000000, 500.00000000, 'Received 500 TKN-LAND-001', '0fe09985c14b232e116611e0d2871f0accbe475caa6178033dbbb4298147f981', 'cea6a24957e8c303bf58e93cf493a33c37a8f360f2bf141cab26c42a5d105808', '2026-08-26 14:40:00'),
  (16, 'LDG-000016', 5, 3, NULL, 3, 'debit', 'fiat', 400000.00000000, 'KES', 1000000.00000000, 600000.00000000, 'Purchase of 400 TKN-CATL-001 @ KES 1000', 'cea6a24957e8c303bf58e93cf493a33c37a8f360f2bf141cab26c42a5d105808', 'a323c9f1d45a0bf4e60326fdcbcd4b0007e30ebf5b9f8d33a80425fe478d6422', '2026-08-28 11:05:00'),
  (17, 'LDG-000017', 4, 2, NULL, 3, 'credit', 'fiat', 400000.00000000, 'KES', 200000.00000000, 600000.00000000, 'Sale of 400 TKN-CATL-001 @ KES 1000', 'a323c9f1d45a0bf4e60326fdcbcd4b0007e30ebf5b9f8d33a80425fe478d6422', 'a1ab9b45e7626f3fe1cbd8c2528205614252828a521853d4bd1f27f50e77b426', '2026-08-28 11:05:00'),
  (18, 'LDG-000018', 4, 2, NULL, 3, 'debit', 'fiat', 4000.00000000, 'KES', 600000.00000000, 596000.00000000, '1% platform fee on TXN-000003', 'a1ab9b45e7626f3fe1cbd8c2528205614252828a521853d4bd1f27f50e77b426', '598de003b18a103d7ec4990f5001fc65e4e416357c72ffcae91a06fec2cac6bb', '2026-08-28 11:05:00'),
  (19, 'LDG-000019', NULL, NULL, 2, 3, 'debit', 'token', 400.00000000, NULL, 4000.00000000, 3600.00000000, 'Primary issuance of TKN-CATL-001 from supply pool', '598de003b18a103d7ec4990f5001fc65e4e416357c72ffcae91a06fec2cac6bb', '8a4ceb7645731216101634212828069f9d25637b5ab6c89214347c381a0498d3', '2026-08-28 11:05:00'),
  (20, 'LDG-000020', 5, NULL, 2, 3, 'credit', 'token', 400.00000000, NULL, 0.00000000, 400.00000000, 'Received 400 TKN-CATL-001', '8a4ceb7645731216101634212828069f9d25637b5ab6c89214347c381a0498d3', '3218f0a8a2ae98a9431b25b9770af3d2b5c502acfdd98d6a5659afc8f2133ca5', '2026-08-28 11:05:00'),
  (21, 'LDG-000021', 6, 4, NULL, 4, 'debit', 'fiat', 300000.00000000, 'KES', 1000000.00000000, 700000.00000000, 'Purchase of 300 TKN-CATL-001 @ KES 1000', '3218f0a8a2ae98a9431b25b9770af3d2b5c502acfdd98d6a5659afc8f2133ca5', 'f81b909869cb06d7d900278666a32f4b5d4efa212b4c6b4eeb559f2c58562c8e', '2026-08-29 16:20:00'),
  (22, 'LDG-000022', 4, 2, NULL, 4, 'credit', 'fiat', 300000.00000000, 'KES', 596000.00000000, 896000.00000000, 'Sale of 300 TKN-CATL-001 @ KES 1000', 'f81b909869cb06d7d900278666a32f4b5d4efa212b4c6b4eeb559f2c58562c8e', '1b394537f3e2e3694fafdd057c6c16e097593e8c8039065ef29b31a159c3cba1', '2026-08-29 16:20:00'),
  (23, 'LDG-000023', 4, 2, NULL, 4, 'debit', 'fiat', 3000.00000000, 'KES', 896000.00000000, 893000.00000000, '1% platform fee on TXN-000004', '1b394537f3e2e3694fafdd057c6c16e097593e8c8039065ef29b31a159c3cba1', '135bc371f805eaf514816695edad07baec42ecfbbd189371250b38544ecebabe', '2026-08-29 16:20:00'),
  (24, 'LDG-000024', NULL, NULL, 2, 4, 'debit', 'token', 300.00000000, NULL, 3600.00000000, 3300.00000000, 'Primary issuance of TKN-CATL-001 from supply pool', '135bc371f805eaf514816695edad07baec42ecfbbd189371250b38544ecebabe', '82ef07b0a4627895c2a00ab6ccdc910eff3f9d042cd14ede04fc13b75db70297', '2026-08-29 16:20:00'),
  (25, 'LDG-000025', 6, NULL, 2, 4, 'credit', 'token', 300.00000000, NULL, 0.00000000, 300.00000000, 'Received 300 TKN-CATL-001', '82ef07b0a4627895c2a00ab6ccdc910eff3f9d042cd14ede04fc13b75db70297', '7afb2b8afa11b02fd04b081f99a642fece61761601b89f2bd735399f2b28e780', '2026-08-29 16:20:00'),
  (26, 'LDG-000026', 7, 5, NULL, NULL, 'debit', 'fiat', 100000.00000000, 'KES', 500000.00000000, 400000.00000000, 'Withdrawal to M-Pesa +254755000007', '7afb2b8afa11b02fd04b081f99a642fece61761601b89f2bd735399f2b28e780', 'dbbda1e3f7da1210cf495d508a820ab204973f7735531f865f3974bef114498a', '2026-09-03 12:00:00'),
  (27, 'LDG-000027', 6, 4, NULL, 5, 'debit', 'fiat', 220000.00000000, 'KES', 700000.00000000, 480000.00000000, 'Purchase of 200 TKN-LAND-001 @ KES 1100', 'dbbda1e3f7da1210cf495d508a820ab204973f7735531f865f3974bef114498a', '937a4f36092d756bd6b490b133a64377f169b2ed12da739fe5837575e2f5375f', '2026-09-08 10:30:00'),
  (28, 'LDG-000028', 5, 3, NULL, 5, 'credit', 'fiat', 220000.00000000, 'KES', 600000.00000000, 820000.00000000, 'Sale of 200 TKN-LAND-001 @ KES 1100', '937a4f36092d756bd6b490b133a64377f169b2ed12da739fe5837575e2f5375f', '8a25804b40dd9135e9f2d934638d89054da60f68ff7e923f4ed7fcca3496e20f', '2026-09-08 10:30:00'),
  (29, 'LDG-000029', 5, 3, NULL, 5, 'debit', 'fiat', 2200.00000000, 'KES', 820000.00000000, 817800.00000000, '1% platform fee on TXN-000005', '8a25804b40dd9135e9f2d934638d89054da60f68ff7e923f4ed7fcca3496e20f', '74f0ecf232b6caa37a091d9296b0c7a0f1bc824e7e599868951683f7a872a7e7', '2026-09-08 10:30:00'),
  (30, 'LDG-000030', 5, NULL, 1, 5, 'debit', 'token', 200.00000000, NULL, 1000.00000000, 800.00000000, 'Transferred 200 TKN-LAND-001 to buyer', '74f0ecf232b6caa37a091d9296b0c7a0f1bc824e7e599868951683f7a872a7e7', '91b3626f85865cc0a121eff585d1074ecbbcaccee0579af0b1814ae9b79cecb1', '2026-09-08 10:30:00'),
  (31, 'LDG-000031', 6, NULL, 1, 5, 'credit', 'token', 200.00000000, NULL, 500.00000000, 700.00000000, 'Received 200 TKN-LAND-001', '91b3626f85865cc0a121eff585d1074ecbbcaccee0579af0b1814ae9b79cecb1', '1f32c0c7091111caed60ff0a513bae7027ce27c0c6ce099ed1f9f0bd00cdfd18', '2026-09-08 10:30:00');

-- audit_logs
INSERT INTO `audit_logs` (`id`, `userId`, `action`, `entityType`, `entityId`, `oldValues`, `newValues`, `ipAddress`, `userAgent`, `previousHash`, `logHash`, `createdAt`) VALUES
  (1, 3, 'USER_REGISTERED', 'user', 3, NULL, '{"kycStatus": "pending"}', '41.90.10.11', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/126.0', NULL, '26ef7a5dda0c246434902273d815d9dc88ccd1dd76d29a9280ef3e299377b880', '2026-07-02 09:00:00'),
  (2, 1, 'KYC_VERIFIED', 'kyc_record', 1, '{"status": "pending"}', '{"status": "verified"}', '41.90.10.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/126.0', '26ef7a5dda0c246434902273d815d9dc88ccd1dd76d29a9280ef3e299377b880', '322200e34d9e0216da67194feecb35c8e14333fbb14bd47cb7c6aab43aba3fa6', '2026-07-03 10:00:00'),
  (3, 2, 'KYC_REJECTED', 'kyc_record', 7, '{"status": "pending"}', '{"status": "rejected"}', '41.90.10.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/126.0', '322200e34d9e0216da67194feecb35c8e14333fbb14bd47cb7c6aab43aba3fa6', '16b7e9f53e33406f8d5adbe7c2fd9a31639ee9c44a6011ebf541837f18540eba', '2026-07-11 09:00:00'),
  (4, 3, 'ASSET_SUBMITTED', 'asset', 1, NULL, '{"status": "pending"}', '41.90.10.11', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/126.0', '16b7e9f53e33406f8d5adbe7c2fd9a31639ee9c44a6011ebf541837f18540eba', '74c3d79be18ec53767d25b8bed1ec9d80bce1c3a6c82b1bd42a23d81acf2ed93', '2026-08-01 09:00:00'),
  (5, 1, 'ASSET_APPROVED', 'asset', 1, '{"status": "under_review"}', '{"status": "approved"}', '41.90.10.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/126.0', '74c3d79be18ec53767d25b8bed1ec9d80bce1c3a6c82b1bd42a23d81acf2ed93', 'a6eba652d360e1ca1d6875ec264712582902b4cc0e089c431f9e5fe1507d5863', '2026-08-15 10:00:00'),
  (6, 1, 'TOKEN_MINTED', 'token', 1, NULL, '{"tokenCode": "TKN-LAND-001", "totalSupply": 12000}', '41.90.10.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/126.0', 'a6eba652d360e1ca1d6875ec264712582902b4cc0e089c431f9e5fe1507d5863', 'fae36d41d76748812885a67d4d0269a31d06ea776c51fde51015c8db9c8d0d88', '2026-08-20 09:00:00'),
  (7, 2, 'TOKEN_MINTED', 'token', 2, NULL, '{"tokenCode": "TKN-CATL-001", "totalSupply": 4000}', '41.90.10.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/126.0', 'fae36d41d76748812885a67d4d0269a31d06ea776c51fde51015c8db9c8d0d88', 'bc0babc882cc1b59c642341b8d5d29269282e65e5b7256157a600458c2f5cb3d', '2026-08-20 09:30:00'),
  (8, 5, 'TRADE_EXECUTED', 'transaction', 1, NULL, '{"quantity": 1000, "price": 1000}', '105.160.22.5', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/126.0', 'bc0babc882cc1b59c642341b8d5d29269282e65e5b7256157a600458c2f5cb3d', 'aa0360ee63fe68f82d2bae9541d736b806dbb389aed781b784d303a6aceb2e15', '2026-08-26 09:15:00'),
  (9, 5, 'ORDER_CANCELLED', 'order', 7, '{"status": "open"}', '{"status": "cancelled"}', '105.160.22.5', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/126.0', 'aa0360ee63fe68f82d2bae9541d736b806dbb389aed781b784d303a6aceb2e15', 'de273eb62ab98de92a908b91fb24e5e94c1557ad049dcfe283a1fa56d540f404', '2026-09-02 08:00:00'),
  (10, 6, 'TRADE_EXECUTED', 'transaction', 5, NULL, '{"quantity": 200, "price": 1100}', '105.160.22.9', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/126.0', 'de273eb62ab98de92a908b91fb24e5e94c1557ad049dcfe283a1fa56d540f404', '235fdc4d486cc498e3b9f458409899c8c93b6b4f8ede04d00368f9084e91b24a', '2026-09-08 10:30:00');

-- notifications
INSERT INTO `notifications` (`id`, `userId`, `type`, `title`, `message`, `referenceType`, `referenceId`, `deliveryMethod`, `status`, `readAt`, `createdAt`) VALUES
  (1, 3, 'kyc', 'KYC verified', 'Your identity verification was successful.', 'kyc_record', 1, 'email', 'sent', '2026-07-03 10:01:00', '2026-07-03 10:00:00'),
  (2, 3, 'asset', 'Asset approved', 'Your asset "5-Acre Prime Farmland, Kiambu" has been approved and tokenized.', 'asset', 1, 'in_app', 'viewed', '2026-08-20 10:00:00', '2026-08-20 09:05:00'),
  (3, 5, 'wallet', 'Deposit received', 'KES 2,000,000.00 has been added to your wallet.', 'wallet_transaction', 1, 'sms', 'sent', NULL, '2026-08-25 10:00:00'),
  (4, 5, 'trading', 'Purchase completed', 'You bought 1,000 TKN-LAND-001 for KES 1,000,000.00.', 'transaction', 1, 'in_app', 'viewed', '2026-08-26 09:20:00', '2026-08-26 09:15:00'),
  (5, 6, 'trading', 'Purchase completed', 'You bought 200 TKN-LAND-001 at KES 1,100.00.', 'transaction', 5, 'in_app', 'new', NULL, '2026-09-08 10:30:00'),
  (6, 5, 'trading', 'Tokens sold', 'You sold 200 TKN-LAND-001. Proceeds: KES 217,800.00 after fees.', 'transaction', 5, 'email', 'sent', NULL, '2026-09-08 10:30:00'),
  (7, 8, 'wallet', 'Deposit failed', 'Your deposit of KES 50,000.00 could not be completed.', 'wallet_transaction', 6, 'sms', 'failed', NULL, '2026-09-04 08:30:00'),
  (8, 9, 'kyc', 'KYC rejected', 'Your KYC was rejected. Please resubmit a clear ID photo and selfie.', 'kyc_record', 7, 'email', 'sent', NULL, '2026-07-11 09:00:00'),
  (9, 7, 'asset', 'Asset rejected', 'Title deed could not be verified for "1-Acre Plot, Kitengela".', 'asset', 7, 'in_app', 'viewed', '2026-08-25 13:00:00', '2026-08-25 12:00:00'),
  (10, 1, 'security', 'New admin login', 'A new login was detected on your admin account.', NULL, NULL, 'in_app', 'new', NULL, '2026-09-28 08:30:00');

-- announcements
INSERT INTO `announcements` (`id`, `title`, `content`, `imageUrl`, `status`, `publishedBy`, `publishedAt`, `expiresAt`, `createdAt`, `updatedAt`) VALUES
  (1, 'Platform Launch', 'We are live! Tokenize your assets or invest from as little as KES 1,000.', NULL, 'published', 1, '2026-08-01 08:00:00', '2026-12-31 23:59:59', '2026-07-28 10:00:00', '2026-07-28 10:00:00'),
  (2, 'Scheduled Maintenance', 'The platform will be unavailable on 5 October 2026 from 01:00 to 03:00 EAT.', NULL, 'published', 1, '2026-09-28 09:00:00', '2026-10-05 03:00:00', '2026-09-27 15:00:00', '2026-09-27 15:00:00'),
  (3, 'Holiday Trading Hours', 'Trading hours for the festive season will be published soon.', NULL, 'draft', NULL, NULL, NULL, '2026-09-29 11:00:00', '2026-09-29 11:00:00');

-- news
INSERT INTO `news` (`id`, `title`, `summary`, `content`, `imageUrl`, `category`, `status`, `authorId`, `publishedAt`, `createdAt`, `updatedAt`) VALUES
  (1, 'Kenya Explores Tokenization of Agricultural Assets', 'Regulators and startups discuss how tokenization can unlock rural capital.', 'Full article content on agricultural asset tokenization in Kenya...', NULL, 'tokenization', 'published', 1, '2026-08-05 09:00:00', '2026-08-04 15:00:00', '2026-08-04 15:00:00'),
  (2, 'Kiambu Farmland Token Now Trading', 'TKN-LAND-001 is now open for investment with 12,000 tokens issued.', 'TKN-LAND-001 represents fractional ownership of a verified 5-acre farm in Kiambu County...', '/uploads/news/kiambu.jpg', 'asset', 'published', 1, '2026-08-20 12:00:00', '2026-08-20 10:00:00', '2026-08-20 10:00:00'),
  (3, 'Understanding Token Risk', 'A beginner guide to how asset-backed tokens work and their risks.', 'Tokens are digital units representing ownership in real assets. Prices may go up or down...', NULL, 'education', 'published', 2, '2026-09-01 08:00:00', '2026-08-30 14:00:00', '2026-08-30 14:00:00'),
  (4, 'Q3 Market Update (Draft)', 'Draft summary of Q3 trading activity.', 'Draft content...', NULL, 'market', 'draft', 2, NULL, '2026-09-29 16:00:00', '2026-09-29 16:00:00');

COMMIT;