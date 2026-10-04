::: {align="center"}
# 🪙 AssetCoin

### Centralized Asset Tokenization Platform

**Unlock the value of your assets securely.**

A controlled digital platform for registering, verifying, tokenizing,
managing, and trading real-world asset-backed tokens.

![Platform](https://img.shields.io/badge/Platform-AssetCoin-2563EB?style=for-the-badge)
![Architecture](https://img.shields.io/badge/Architecture-Centralized%20Ledger-0F766E?style=for-the-badge)
![Database](https://img.shields.io/badge/Database-MySQL-4479A1?style=for-the-badge)
:::

------------------------------------------------------------------------

## 📚 Table of Contents

1.  [Project Overview](#1-project-overview)
2.  [Core Architecture: Blockchain Logic in
    SQL](#2-core-architecture-blockchain-logic-in-sql)
3.  [User Experience](#3-user-experience)
4.  [Authentication](#4-authentication)
5.  [Homepage](#5-homepage)
6.  [Notifications](#6-notifications)
7.  [Wallet](#7-wallet)
8.  [Assets](#8-assets)
9.  [Asset Submission and Approval](#9-asset-submission-and-approval)
10. [Tokenization](#10-tokenization)
11. [Trading Marketplace](#11-trading-marketplace)
12. [Marketplace Transaction
    Architecture](#12-marketplace-transaction-architecture)
13. [Profile](#13-profile)
14. [Settings](#14-settings)
15. [Help and Education](#15-help-and-education)
16. [Security and Audit
    Architecture](#16-security-and-audit-architecture)
17. [Core Database Model](#17-core-database-model)
18. [Centralized Ledger Philosophy](#18-centralized-ledger-philosophy)

------------------------------------------------------------------------

## 1. Project Overview

AssetCoin is a centralized digital asset tokenization platform that
allows users to register, verify their identity, submit real-world
assets for approval, tokenize approved assets, manage token ownership,
and participate in a controlled marketplace.

The platform is designed to make real-world assets easier to represent,
manage, trade, and track digitally. Supported asset categories include:

-   Land
-   Livestock
-   Agricultural produce
-   Vehicles
-   Property
-   Equipment
-   Other platform-approved asset categories

### Architecture at a glance

AssetCoin uses a **centralized, database-backed ledger architecture**
rather than a public blockchain. It provides blockchain-inspired
properties:

  -----------------------------------------------------------------------
  Capability                          Purpose
  ----------------------------------- -----------------------------------
  Immutable financial records         Preserve historical financial and
                                      ownership events

  Hash-linked records                 Make unauthorized record changes
                                      detectable

  Unique identifiers                  Identify users, assets, tokens, and
                                      transactions

  Ownership tracking                  Maintain traceable asset and token
                                      ownership

  Audit trails                        Record important user and
                                      administrative actions

  Timestamped records                 Establish when events occurred

  Controlled token issuance           Restrict token creation to approved
                                      workflows

  Centralized authorization           Control access, compliance, and
                                      administration
  -----------------------------------------------------------------------

> **Architecture note:** AssetCoin is not a decentralized blockchain. It
> is a centralized asset-tokenization platform that applies
> blockchain-inspired ledger and audit mechanisms.

------------------------------------------------------------------------

## 2. Core Architecture: Blockchain Logic in SQL

AssetCoin does not require a public blockchain to maintain a structured
history of platform ownership and transactions. Instead, it implements
blockchain-inspired ledger logic directly within MySQL.

### 2.1 Immutable records

Financial and ownership events are recorded as historical events rather
than silently overwritten or deleted.

``` text
Deposit
   |
   v
Wallet Transaction
   |
   v
Ledger Entry
   |
   v
Audit Record
```

If a correction is required, the system creates an adjustment or
reversal record instead of rewriting the original financial event.

### 2.2 Hash chaining

Important records can contain hashes linking each record to its
predecessor.

``` text
+----------+       +----------+       +----------+
| Record A | ----> | Record B | ----> | Record C |
+----------+       +----------+       +----------+
   Hash A             Hash B             Hash C
```

Each record stores its own hash and the hash of the preceding record.
This creates a tamper-evident sequence: changing an earlier record
causes subsequent links to fail validation.

### 2.3 Unique identifiers

The platform uses unique identifiers for users, wallets, assets, tokens,
listings, orders, transactions, ledger entries, and audit records.

### 2.4 Ownership tracking

``` text
User
 |
 +---- Wallet
 |
 +---- Assets
 |
 +---- Token Holdings
          |
          v
         Token
          |
          v
         Asset
```

This enables the platform to determine who owns an asset, who holds
tokens representing an asset, and how recorded ownership changes over
time.

------------------------------------------------------------------------

## 3. User Experience

### 3.1 Welcome and loading screen

The application opens with:

-   AssetCoin logo
-   Tagline: **"Unlock the value of your assets securely."**
-   Loading animation

The application checks whether a valid authenticated session exists.

  Session state          Destination
  ---------------------- -------------
  Authenticated user     Homepage
  Unauthenticated user   Login page

------------------------------------------------------------------------

## 4. Authentication

Authentication provides controlled access to the platform. The backend
remains authoritative for user identity, account status, and
authorization.

### 4.1 Login page

The login screen contains:

-   AssetCoin logo
-   Welcome message: "Welcome back, please log in."
-   Email address or phone number
-   Password

**Actions:** Log in, Forgot password, and Navigate to sign up.

**Potential future enhancement:** Fingerprint, Face ID, or other device
biometrics.

Authentication uses secure session and token management. The backend
validates credentials and determines whether an account is permitted to
access the platform.

### 4.2 Sign-up page

New users register with:

  Field                Description
  -------------------- ----------------------------------
  First name           User's first name
  Last name            User's last name
  National ID number   Identity and KYC verification
  Phone number         Contact and account verification
  Email address        Contact and account verification
  Password             Secure account credential
  Confirm password     Password confirmation

#### Identity verification and KYC

The registration and KYC process may include:

-   Email OTP verification
-   Phone OTP verification
-   Identity verification
-   Identity document submission
-   Selfie verification, where required

The application should explain why National ID information is collected,
particularly for identity verification and KYC compliance.

#### Registration initialization

When registration succeeds, the backend initializes the required
records:

``` text
User
 |
 +---- Wallet
 |
 +---- Registration Audit Record
 |
 +---- Welcome Notification
```

These related records should be created transactionally so registration
does not leave the database partially initialized.

------------------------------------------------------------------------

## 5. Homepage

The Homepage is the user's primary dashboard and provides an overview of
platform activity and financial information.

**Content and information:**

-   News and announcements
-   Platform updates
-   Educational content
-   Financial overview
-   Fiat wallet balance
-   Token holdings
-   Total asset value

Financial values are retrieved from the backend rather than
independently calculated by the Flutter application. This helps maintain
consistency between the user interface and authoritative platform
records.

A notification icon appears in the top-right corner and opens the
Notification page.

------------------------------------------------------------------------

## 6. Notifications

The Notification page displays messages and updates associated with the
authenticated user.

**Notification categories:**

-   System messages
-   Trading events
-   Wallet events
-   KYC updates
-   Asset status updates
-   Security notifications

**Notification states:**

-   **New** --- The notification has not yet been viewed.
-   **Viewed** --- The user has opened or acknowledged the notification.

**Filters:** System, Trading, and Wallet.

**Supported delivery methods:**

-   In-app
-   Email
-   SMS

Notification preferences determine which supported delivery methods are
used for applicable messages.

------------------------------------------------------------------------

## 7. Wallet

The Wallet is the user's centralized financial account. It manages fiat
balances and records wallet-related financial activity.

### 7.1 Wallet overview

The wallet dashboard displays fiat balance, locked fiat balance, token
value, total asset value, and token holdings.

Token holding information can include:

  Field                 Description
  --------------------- --------------------------------------
  Token name            Display name of the token
  Token code            Unique token identifier
  Quantity              Number of tokens held
  Locked quantity       Tokens unavailable for immediate use
  Current token price   Latest applicable token price
  Current value         Value of the user's holding

### 7.2 Wallet actions

-   Deposit
-   Withdraw
-   Convert

### 7.3 Wallet transaction history

Wallet activity can include deposits, withdrawals, token purchases,
token sales, conversions, refunds, fees, and adjustments.

Each transaction should retain:

-   Transaction reference
-   Transaction type
-   Amount and currency
-   Balance before and balance after
-   Status
-   Description
-   Timestamp

Financial records form part of the platform's accounting and audit
trail, not merely ordinary application history.

------------------------------------------------------------------------

## 8. Assets

The Assets section allows users to submit and manage real-world assets.

**Supported categories:**

-   Land
-   Livestock
-   Agricultural produce
-   Vehicles
-   Property
-   Equipment
-   Other approved asset categories

Users can view submitted assets, inspect their details, and follow each
asset's current approval status.

------------------------------------------------------------------------

## 9. Asset Submission and Approval

### 9.1 Add a new asset

Users provide asset information and supporting documentation.

**Asset information:**

-   Asset type and name
-   Description and location
-   Registration information
-   Estimated value and currency

**Supporting material:**

-   Asset photographs
-   Ownership documents
-   Registration documents
-   Valuation documents
-   Legal documents
-   Identification documents
-   Inspection documents

Users can save incomplete submissions as drafts and return to complete
them later.

### 9.2 Asset approval lifecycle

``` text
+-------+
| Draft |
+---+---+
    |
    v
+---------+
| Pending |
+----+----+
     |
     v
+--------------+
| Under Review |
+------+-------+
       |
       v
+----------+
| Approved |
+----+-----+
     |
     v
+------------+
| Tokenized  |
+------------+
```

An asset may also become:

-   **Rejected** --- The asset does not meet approval requirements. A
    rejection reason should be provided.
-   **Suspended** --- The asset is temporarily restricted from further
    platform activity.

Administrative approval is required before an asset can proceed to
tokenization.

------------------------------------------------------------------------

## 10. Tokenization

Once an asset has been approved, the platform can create a digital token
representation of that asset.

**Token information:**

-   Token code and name
-   Description
-   Total supply and available supply
-   Token price and currency
-   Decimal precision
-   Token status
-   Associated asset

### Tokenization lifecycle

``` text
+------------------+
| Real-World Asset |
+--------+---------+
         |
         v
+------------------+
| Approved Asset   |
+--------+---------+
         |
         v
+------------------+
| Token Created    |
+--------+---------+
         |
         v
+------------------+
| Token Supply     |
+--------+---------+
         |
         v
+------------------+
| User Holdings    |
+------------------+
```

Token ownership is recorded and managed through the `token_holdings`
system. The relationship between an asset and its token representation
should remain traceable throughout the asset's lifecycle.

------------------------------------------------------------------------

## 11. Trading Marketplace

The Trading section provides a controlled marketplace for tokenized
assets.

Users can browse tokenized assets and view asset information, token
information, token price, available quantity, and listing information.

**Trading actions:**

-   Buy orders
-   Sell orders

**Marketplace capabilities:**

-   Search and filtering
-   Asset categories
-   Listing status
-   Order status
-   Transaction history

Supported categories include land, livestock, agricultural produce,
property, vehicles, equipment, and other platform-approved assets.

------------------------------------------------------------------------

## 12. Marketplace Transaction Architecture

Trading is logically separated from ordinary wallet activity. This
distinction helps maintain clear financial accounting and marketplace
execution records.

**Wallet transactions include:**

-   Deposits and withdrawals
-   Conversions
-   Fees and refunds
-   Token purchases and sales

**Marketplace execution:**

``` text
+--------+
| Buyer  |
+---+----+
    |
    v
+-----------+
| Buy Order |
+-----+-----+
      |
      v
+-----------+
| Listing   |
+-----+-----+
      |
      v
+-----------+
| Seller    |
+-----+-----+
      |
      v
+------------------------+
| Marketplace Transaction|
+------------------------+
```

Separating these responsibilities keeps wallet accounting and
marketplace execution logically distinct while allowing the systems to
interact through controlled transaction workflows.

------------------------------------------------------------------------

## 13. Profile

The Profile page allows users to view and manage their account
information.

**Profile information:**

-   Profile picture
-   Name
-   Contact information
-   Verification status
-   Account information

**Profile actions:**

-   Upload a profile picture
-   Change a profile picture
-   Remove a profile picture

A Settings icon provides access to account configuration and
preferences.

------------------------------------------------------------------------

## 14. Settings

### 14.1 Your account

Users can access:

-   Account information
-   Change password
-   Download account data
-   Deactivate account
-   Delete account

Account deactivation and deletion must respect the platform's financial,
legal, and audit requirements. Historical financial records should not
simply disappear when an account is deactivated or removed from normal
access.

### 14.2 Notification preferences

Users can select supported delivery methods:

-   Email
-   SMS
-   In-app

Preferences control how applicable notifications are delivered, subject
to supported services and operational policies.

------------------------------------------------------------------------

## 15. Help and Education

AssetCoin includes educational material to help users understand the
platform and its services.

### What is tokenization?

Explains how a real-world asset can be represented digitally through
tokens.

### How can I use my assets for liquidity?

Explains the platform's asset and token marketplace concepts without
implying that liquidity, buyers, or financial returns are guaranteed.

### Frequently asked questions

FAQs cover accounts, KYC, wallets, assets, tokenization, trading,
security, and transactions.

Users can also contact platform support for assistance.

------------------------------------------------------------------------

## 16. Security and Audit Architecture

Security is built into the platform rather than treated as a separate
feature.

### 16.1 Security controls

The system maintains or supports:

-   Authentication
-   Password hashing
-   JWT-based authentication
-   Account status checks
-   Secure token storage
-   Session restoration
-   Audit trails

### 16.2 Audit logging

Important user and administrative actions can be recorded in
`audit_logs`.

Examples:

``` text
USER_REGISTERED
LOGIN
PASSWORD_CHANGED
KYC_SUBMITTED
ASSET_CREATED
ASSET_APPROVED
TOKEN_CREATED
ORDER_CREATED
TRANSACTION_COMPLETED
```

Audit records should capture sufficient context to support
accountability, investigation, and operational monitoring.

### 16.3 Financial integrity

Financial operations should use transactional database operations so
related records are committed together.

``` text
+----------------------+
| Wallet Balance Update|
+----------+-----------+
           |
           v
+----------------------+
| Wallet Transaction   |
+----------+-----------+
           |
           v
+----------------------+
| Ledger Entry         |
+----------+-----------+
           |
           v
+----------------------+
| Audit Record         |
+----------+-----------+
           |
           v
      +---------+
      | COMMIT  |
      +---------+
```

If a critical operation fails, the database transaction should be rolled
back so incomplete financial operations are not committed.

------------------------------------------------------------------------

## 17. Core Database Model

The database is organized around users, wallets, assets, tokens,
holdings, marketplace activity, notifications, and audit records.

### 17.1 High-level relationship diagram

``` text
                         +--------------+
                         |    USERS     |
                         +------+-------+
                                |
              +-----------------+-----------------+
              |                 |                 |
              v                 v                 v
        +-----------+      +-----------+    +----------------+
        |  WALLETS  |      |  ASSETS   |    | NOTIFICATIONS  |
        +-----+-----+      +-----+-----+    +----------------+
              |                  |
              v                  v
    +--------------------+  +-----------+
    | WALLET_TRANSACTIONS|  |   TOKENS  |
    +---------+----------+  +-----+-----+
              |                   |
              v                   v
       +--------------+   +----------------+
       |LEDGER_ENTRIES|   | TOKEN_HOLDINGS |
       +--------------+   +-------+--------+
                                  |
                                  v
                           +--------------+
                           | ORDERS /     |
                           | LISTINGS     |
                           +------+-------+
                                  |
                                  v
                           +--------------+
                           | TRANSACTIONS |
                           +--------------+

                         +--------------+
                         |  AUDIT_LOGS  |
                         +--------------+
```

### 17.2 Major database entities

  Entity                  Responsibility
  ----------------------- ---------------------------------------------------
  `users`                 User accounts and identity information
  `kyc_records`           Identity verification and KYC records
  `assets`                Submitted real-world assets
  `asset_photos`          Asset photographs
  `asset_documents`       Asset-related documentation
  `asset_valuations`      Asset valuation records
  `tokens`                Digital token representations of approved assets
  `token_holdings`        User token ownership records
  `wallets`               User fiat wallet accounts
  `wallet_transactions`   Wallet financial activity
  `listings`              Marketplace token listings
  `orders`                Buy and sell orders
  `transactions`          Executed marketplace transactions
  `token_price_history`   Historical token pricing
  `ledger_entries`        Structured financial and ownership ledger records
  `audit_logs`            User and administrative activity history
  `notifications`         User notification records
  `announcements`         Platform announcements
  `news`                  Platform news and educational updates

The diagram is conceptual. Exact foreign keys, cardinalities,
constraints, and transaction boundaries are defined by the database
schema and application implementation.

------------------------------------------------------------------------

## 18. Centralized Ledger Philosophy

AssetCoin is a centralized asset-tokenization and ledger platform with
blockchain-inspired accounting and audit mechanisms.

Rather than relying on a public blockchain for every operation, the
platform maintains its own controlled ledger using:

``` text
MySQL Database
      +
Database Transactions
      +
Ledger Entries
      +
Hash Chains
      +
Audit Logs
      +
Ownership Records
```

This provides a structured and traceable record of platform activity
while allowing AssetCoin to control:

-   User accounts
-   KYC and identity verification
-   Asset approval
-   Token issuance
-   Wallet operations
-   Marketplace operations
-   Transaction processing
-   Compliance
-   Administrative controls

### Key architectural distinction

AssetCoin's records are centrally managed rather than independently
validated by a decentralized blockchain network.

The platform can provide blockchain-inspired auditability, traceability,
and ownership tracking without claiming to be a decentralized
blockchain.

------------------------------------------------------------------------

::: {align="center"}
**AssetCoin**

*Unlock the value of your assets securely.*

A centralized approach to real-world asset representation, ownership
management, and controlled digital trading.
:::
