const express = require('express');
const router = express.Router();
const usuariosController = require('../controllers/usuarios.controller');
const { authMiddleware, adminMiddleware } = require('../middlewares/auth.middleware');

router.get('/docentes', authMiddleware, usuariosController.getDocentes);
router.get('/', authMiddleware, adminMiddleware, usuariosController.getAll);
router.post('/', authMiddleware, adminMiddleware, usuariosController.create);
router.put('/:id', authMiddleware, adminMiddleware, usuariosController.update);
router.delete('/:id', authMiddleware, adminMiddleware, usuariosController.delete);

module.exports = router;