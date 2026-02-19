const express = require('express');
const router = express.Router();
const avisosController = require('../controllers/avisos.controller');
const { authMiddleware } = require('../middlewares/auth.middleware');

// Rutas públicas (no requieren autenticación)
router.get('/aula/:id_aula', avisosController.getByAula);

// Rutas protegidas (requieren token)
router.get('/', authMiddleware, avisosController.getAll);      // ← ESTA FALTA
router.post('/', authMiddleware, avisosController.create);
router.delete('/:id', authMiddleware, avisosController.delete);

module.exports = router;