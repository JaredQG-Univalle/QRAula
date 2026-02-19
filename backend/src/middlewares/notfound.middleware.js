// MIDDLEWARE 404 - DEBE TENER 3 PARÁMETROS
const notFoundMiddleware = (req, res, next) => {
  res.status(404).json({
    error: 'Ruta no encontrada',
    message: `No se encontró ${req.method} ${req.originalUrl}`,
    availableEndpoints: {
      auth: '/api/auth/login',
      aulas: '/api/aulas',
      horarios: '/api/horarios',
      bloques: '/api/bloques',
      health: '/api/health'
    }
  });
};

module.exports = { notFoundMiddleware };