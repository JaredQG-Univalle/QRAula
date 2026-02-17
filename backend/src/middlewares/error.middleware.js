function errorHandler(err, req, res, next) {
  console.error("🔥 Error:", err);

  const status = err.statusCode || 500;
  return res.status(status).json({
    ok: false,
    message: err.message || "Error interno del servidor",
  });
}

module.exports = errorHandler;