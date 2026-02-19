// 🔴 CAMBIAR DE ESTO:
// const mysql = require("mysql2");

// ✅ A ESTO:
const mysql = require("mysql2/promise");  // ← AGREGAR /promise

require("dotenv").config();

// Crear pool de conexiones (mejor que connection simple)
const pool = mysql.createPool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  ssl: process.env.DB_SSL === "true" ? {
    rejectUnauthorized: false
  } : undefined
});

// Probar conexión
(async () => {
  try {
    const connection = await pool.getConnection();
    console.log("✅ Conectado a MySQL (Aiven) - Modo Promise");
    connection.release();
  } catch (err) {
    console.error("❌ Error conectando a MySQL:", err);
  }
})();

module.exports = pool;