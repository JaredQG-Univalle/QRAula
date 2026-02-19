const express = require('express');
const router = express.Router();
const bloquesController = require('../controllers/bloques.controller');
const { authMiddleware, adminMiddleware } = require('../middlewares/auth.middleware');

// Verifica que bloquesController tiene todas las funciones
console.log('bloquesController:', Object.keys(bloquesController));

router.get('/', authMiddleware, bloquesController.getAll);
router.get('/:id', authMiddleware, bloquesController.getById);
router.post('/', authMiddleware, adminMiddleware, bloquesController.create);
router.put('/:id', authMiddleware, adminMiddleware, bloquesController.update);
router.delete('/:id', authMiddleware, adminMiddleware, bloquesController.delete);

module.exports = router;