
import pool from "./database.js";

async function testDatabaseConnection() {
  try {
    const [rows] = await pool.query(
      "SELECT DATABASE() AS databaseName, COUNT(*) AS tableCount FROM information_schema.tables WHERE table_schema = DATABASE()"
    );

    console.log("MySQL connected successfully!");
    console.log("Database:", rows[0].databaseName);
    console.log("Tables:", rows[0].tableCount);
  } catch (error) {
    console.error("MySQL connection failed:", error.message);
    process.exitCode = 1;
  } finally {
    await pool.end();
  }
}

testDatabaseConnection();