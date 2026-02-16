const express = require("express");
const cors = require("cors");
const morgan = require("morgan");

const app = express();

app.use(cors());
app.use(express.json());
app.use(morgan("dev"));

app.get("/", (req, res) => {
  res.send("🚀 Backend activo correctamente");
});

app.get("/health", (req, res) => {
  res.json({ ok: true, message: "Backend funcionando" });
});

module.exports = app;
