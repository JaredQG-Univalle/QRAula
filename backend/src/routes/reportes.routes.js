const express = require('express');
const router = express.Router();
const reportesController = require('../controllers/reportes.controller');
const { authMiddleware, adminMiddleware } = require('../middlewares/auth.middleware');

// Rutas protegidas
router.get('/', authMiddleware, adminMiddleware, reportesController.getAll);
router.get('/mis-reportes', authMiddleware, reportesController.getByUsuario);
router.post('/', authMiddleware, reportesController.create);
router.patch('/:id/estado', authMiddleware, adminMiddleware, reportesController.updateEstado);
router.delete('/:id', authMiddleware, adminMiddleware, reportesController.delete);

module.exports = router;