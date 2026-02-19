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
const usuariosRoutes = require('./usuarios.routes');  // ✅ NUEVA RUTA
const materiasRoutes = require('./materias.routes');  // ✅ NUEVA RUTA

// Verificar que todas las rutas son funciones válidas
console.log('🔍 Verificando rutas:');
console.log('  authRoutes:', typeof authRoutes);
console.log('  aulasRoutes:', typeof aulasRoutes);
console.log('  bloquesRoutes:', typeof bloquesRoutes);
console.log('  horariosRoutes:', typeof horariosRoutes);
console.log('  avisosRoutes:', typeof avisosRoutes);
console.log('  reportesRoutes:', typeof reportesRoutes);
console.log('  healthRoutes:', typeof healthRoutes);
console.log('  usuariosRoutes:', typeof usuariosRoutes);  // ✅ NUEVO LOG
console.log('  materiasRoutes:', typeof materiasRoutes);  // ✅ NUEVO LOG

// Registrar rutas - TODAS deben ser funciones (router)
router.use('/auth', authRoutes);
router.use('/aulas', aulasRoutes);
router.use('/bloques', bloquesRoutes);
router.use('/horarios', horariosRoutes);
router.use('/avisos', avisosRoutes);
router.use('/reportes', reportesRoutes);
router.use('/health', healthRoutes);
router.use('/usuarios', usuariosRoutes);  // ✅ NUEVA RUTA
router.use('/materias', materiasRoutes);  // ✅ NUEVA RUTA

// Ruta de información con TODOS los endpoints
router.get('/', (req, res) => {
  res.json({
    message: 'API AulaQR',
    version: '1.0.0',
    endpoints: {
      auth: {
        login: 'POST /api/auth/login'
      },
      aulas: {
        getAll: 'GET /api/aulas',
        getById: 'GET /api/aulas/:id',
        getByQR: 'GET /api/aulas/qr/:codigo',
        create: 'POST /api/aulas',
        update: 'PUT /api/aulas/:id',
        delete: 'DELETE /api/aulas/:id',
        updateEstado: 'PATCH /api/aulas/:id/estado'
      },
      bloques: {
        getAll: 'GET /api/bloques',
        getById: 'GET /api/bloques/:id',
        create: 'POST /api/bloques',
        update: 'PUT /api/bloques/:id',
        delete: 'DELETE /api/bloques/:id'
      },
      horarios: {
        getAll: 'GET /api/horarios',
        getByAula: 'GET /api/horarios/aula/:id_aula',
        create: 'POST /api/horarios',
        update: 'PUT /api/horarios/:id',
        delete: 'DELETE /api/horarios/:id'
      },
      avisos: {
        getByAula: 'GET /api/avisos/aula/:id_aula',
        create: 'POST /api/avisos'
      },
      reportes: {
        getAll: 'GET /api/reportes',
        updateEstado: 'PATCH /api/reportes/:id/estado'
      },
      usuarios: {  // ✅ NUEVA SECCIÓN
        getDocentes: 'GET /api/usuarios/docentes',
        getAll: 'GET /api/usuarios',
        create: 'POST /api/usuarios',
        update: 'PUT /api/usuarios/:id',
        delete: 'DELETE /api/usuarios/:id'
      },
      materias: {  // ✅ NUEVA SECCIÓN
        getAll: 'GET /api/materias',
        getById: 'GET /api/materias/:id',
        create: 'POST /api/materias',
        update: 'PUT /api/materias/:id',
        delete: 'DELETE /api/materias/:id'
      },
      health: 'GET /api/health'
    }
  });
});

module.exports = router;