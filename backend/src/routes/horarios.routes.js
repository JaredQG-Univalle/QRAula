const express = require('express');
const router = express.Router();
const horariosController = require('../controllers/horarios.controller');
const { authMiddleware, adminMiddleware } = require('../middlewares/auth.middleware');

// Rutas públicas
router.get('/aula/:id_aula', horariosController.getByAula);

// Ruta para verificar disponibilidad (útil para el frontend)
router.post('/verificar-disponibilidad', authMiddleware, horariosController.verificarDisponibilidad);

// Rutas protegidas (requieren token)
router.get('/', authMiddleware, horariosController.getAll);
router.post('/', authMiddleware, adminMiddleware, horariosController.create);
router.put('/:id', authMiddleware, adminMiddleware, horariosController.update);
router.delete('/:id', authMiddleware, adminMiddleware, horariosController.delete);

module.exports = router;