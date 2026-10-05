import "dotenv/config";

import readline from "readline";

import pool from "../config/database.js";

import {
  hashAdminPassword,
} from "../utils/adminSecurity.js";

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
});

function question(prompt) {
  return new Promise((resolve) => {
    rl.question(
      prompt,
      resolve,
    );
  });
}

async function main() {
  let connection;

  try {
    console.log("");
    console.log(
      "==============================================",
    );
    console.log(
      " AssetCoin Administrator Bootstrap",
    );
    console.log(
      "==============================================",
    );
    console.log("");

    const firstName =
      await question(
        "First name: ",
      );

    const lastName =
      await question(
        "Last name: ",
      );

    const email =
      await question(
        "Email: ",
      );

    const phone =
      await question(
        "Phone (optional): ",
      );

    const password =
      await question(
        "Temporary password: ",
      );

    if (
      !firstName.trim() ||
      !lastName.trim() ||
      !email.trim() ||
      !password
    ) {
      throw new Error(
        "First name, last name, email and password are required.",
      );
    }

    if (password.length < 8) {
      throw new Error(
        "Administrator password must contain at least 8 characters.",
      );
    }

    connection =
      await pool.getConnection();

    await connection.beginTransaction();

    const [roles] =
      await connection.execute(
        `
          SELECT id
          FROM admin_roles
          WHERE code = 'super_admin'
            AND isActive = TRUE
          LIMIT 1
        `,
      );

    if (!roles[0]) {
      throw new Error(
        "super_admin role does not exist. Run migrations 030-032 first.",
      );
    }

    const roleId =
      roles[0].id;

    const [existing] =
      await connection.execute(
        `
          SELECT id
          FROM admin_staff
          WHERE LOWER(email) = LOWER(?)
          LIMIT 1
        `,
        [email.trim()],
      );

    if (existing[0]) {
      throw new Error(
        `An administrator with email ${email.trim()} already exists.`,
      );
    }

    const passwordHash =
      await hashAdminPassword(
        password,
      );

    const [result] =
      await connection.execute(
        `
          INSERT INTO admin_staff (
            firstName,
            lastName,
            email,
            phone,
            passwordHash,
            roleId,
            accountStatus,
            passwordChangedAt
          )
          VALUES (?, ?, ?, ?, ?, ?, 'active', NOW())
        `,
        [
          firstName.trim(),
          lastName.trim(),
          email.trim().toLowerCase(),
          phone.trim() || null,
          passwordHash,
          roleId,
        ],
      );

    await connection.commit();

    console.log("");
    console.log(
      "Administrator created successfully.",
    );
    console.log(
      `Administrator ID: ${result.insertId}`,
    );
    console.log(
      `Email: ${email.trim().toLowerCase()}`,
    );
    console.log(
      "Role: Super Administrator",
    );
    console.log("");
  } catch (error) {
    if (connection) {
      await connection.rollback();
    }

    console.error("");
    console.error(
      "Failed to create administrator:",
    );
    console.error(error.message);
    console.error("");
    process.exitCode = 1;
  } finally {
    rl.close();

    if (connection) {
      connection.release();
    }

    await pool.end();
  }
}

main();