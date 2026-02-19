const express = require('express');
const router = express.Router();
const aulasController = require('../controllers/aulas.controller');
const { authMiddleware, adminMiddleware } = require('../middlewares/auth.middleware');

// Rutas públicas
router.get('/qr/:codigo', aulasController.getByQR);
router.get('/:id', aulasController.getById);

// Rutas protegidas
router.get('/', authMiddleware, aulasController.getAll);
router.post('/', authMiddleware, adminMiddleware, aulasController.create);
router.put('/:id', authMiddleware, adminMiddleware, aulasController.update);
router.delete('/:id', authMiddleware, adminMiddleware, aulasController.delete);
router.patch('/:id/estado', authMiddleware, aulasController.updateEstado);

module.exports = router;