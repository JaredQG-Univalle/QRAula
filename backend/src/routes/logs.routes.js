const express = require('express');
const router = express.Router();
const logsController = require('../controllers/logs.controller');
const { authMiddleware, adminMiddleware } = require('../middlewares/auth.middleware');

// Ruta pública para registrar escaneos (no requiere autenticación)
router.post('/aula/:id_aula', logsController.registrarEscaneo);

// Rutas protegidas para estadísticas (solo admin)
router.get('/estadisticas', authMiddleware, adminMiddleware, logsController.getEstadisticas);

module.exports = router;