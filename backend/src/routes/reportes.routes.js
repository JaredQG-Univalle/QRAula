const express = require('express');
const router = express.Router();
const { authMiddleware } = require('../middlewares/auth.middleware');

// Temporalmente vacío - lo llenaremos después
router.get('/', (req, res) => {
  res.json({ message: 'Ruta de reportes - en construcción' });
});

module.exports = router;