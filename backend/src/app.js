const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
require('dotenv').config();

// Importar rutas
const routes = require('./routes');

// Importar middlewares de error
const { errorMiddleware } = require('./middlewares/error.middleware');
const { notFoundMiddleware } = require('./middlewares/notfound.middleware');

const app = express();

// Middlewares básicos - TODOS deben ser funciones
app.use(cors()); // cors() es una función que retorna un middleware
app.use(morgan('dev')); // morgan('dev') retorna un middleware
app.use(express.json()); // express.json() retorna un middleware
app.use(express.urlencoded({ extended: true })); // esto también retorna un middleware

// Ruta de prueba (opcional, pero útil)
app.get('/', (req, res) => {
  res.json({
    message: 'AulaQR API',
    version: '1.0.0',
    status: 'online'
  });
});

// Rutas API - routes DEBE ser un middleware/router válido
console.log('🔍 Tipo de routes:', typeof routes);
console.log('🔍 routes es función?', typeof routes === 'function');
console.log('🔍 routes tiene use?', routes && typeof routes.use === 'function');

app.use('/api', routes);

// Middleware para rutas no encontradas (404)
app.use('*', notFoundMiddleware);

// Middleware de errores (DEBE tener 4 parámetros)
app.use(errorMiddleware);

module.exports = app;