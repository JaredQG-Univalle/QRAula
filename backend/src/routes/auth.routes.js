const express = require('express');
const router = express.Router();
const { login } = require('../controllers/auth.controller');

// Verificar que login existe
console.log('📌 auth.routes: login function:', typeof login);

router.post('/login', login);

module.exports = router;