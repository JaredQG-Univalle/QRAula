const express = require('express');
const router = express.Router();
const materiasController = require('../controllers/materias.controller');
const { authMiddleware, adminMiddleware } = require('../middlewares/auth.middleware');

router.get('/', authMiddleware, materiasController.getAll);
router.get('/:id', authMiddleware, materiasController.getById);
router.post('/', authMiddleware, adminMiddleware, materiasController.create);
router.put('/:id', authMiddleware, adminMiddleware, materiasController.update);
router.delete('/:id', authMiddleware, adminMiddleware, materiasController.delete);

module.exports = router;