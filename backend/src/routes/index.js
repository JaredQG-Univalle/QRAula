const express = require('express');
const router = express.Router();

// Importar rutas
const authRoutes = require('./auth.routes');
const aulasRoutes = require('./aulas.routes');
const bloquesRoutes = require('./bloques.routes');
const horariosRoutes = require('./horarios.routes');
const avisosRoutes = require('./avisos.routes');
const reportesRoutes = require('./reportes.routes');
const healthRoutes = require('./health.routes');
const usuariosRoutes = require('./usuarios.routes');
const materiasRoutes = require('./materias.routes');
const logsRoutes = require('./logs.routes'); // ← NUEVA RUTA

console.log('🔍 Verificando rutas:');
console.log('  authRoutes:', typeof authRoutes);
console.log('  aulasRoutes:', typeof aulasRoutes);
console.log('  bloquesRoutes:', typeof bloquesRoutes);
console.log('  horariosRoutes:', typeof horariosRoutes);
console.log('  avisosRoutes:', typeof avisosRoutes);
console.log('  reportesRoutes:', typeof reportesRoutes);
console.log('  healthRoutes:', typeof healthRoutes);
console.log('  usuariosRoutes:', typeof usuariosRoutes);
console.log('  materiasRoutes:', typeof materiasRoutes);
console.log('  logsRoutes:', typeof logsRoutes); // ← NUEVO LOG

// Registrar rutas
router.use('/auth', authRoutes);
router.use('/aulas', aulasRoutes);
router.use('/bloques', bloquesRoutes);
router.use('/horarios', horariosRoutes);
router.use('/avisos', avisosRoutes);
router.use('/reportes', reportesRoutes);
router.use('/health', healthRoutes);
router.use('/usuarios', usuariosRoutes);
router.use('/materias', materiasRoutes);
router.use('/logs', logsRoutes); // ← NUEVA RUTA REGISTRADA

// Ruta de información
router.get('/', (req, res) => {
  res.json({
    message: 'API AulaQR',
    version: '1.0.0',
    endpoints: {
      auth: '/auth/login',
      aulas: '/aulas',
      bloques: '/bloques',
      horarios: '/horarios',
      avisos: '/avisos',
      reportes: '/reportes',
      usuarios: '/usuarios',
      materias: '/materias',
      logs: '/logs', // ← NUEVO ENDPOINT
      health: '/health'
    }
  });
});

module.exports = router;
