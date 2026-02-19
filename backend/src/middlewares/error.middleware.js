// MIDDLEWARE DE ERRORES - DEBE TENER 4 PARÁMETROS
const errorMiddleware = (err, req, res, next) => {
  console.error('❌ Error:', err);

  // Error por defecto
  const status = err.status || 500;
  const message = err.message || 'Error interno del servidor';

  res.status(status).json({
    error: message,
    timestamp: new Date().toISOString()
  });
};

module.exports = { errorMiddleware };