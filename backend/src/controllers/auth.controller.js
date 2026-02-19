const authService = require('../services/auth.service');

const login = async (req, res) => {
  try {
    const { correo, password } = req.body;

    console.log('📨 Login request para:', correo);

    if (!correo || !password) {
      return res.status(400).json({ error: 'Correo y contraseña son requeridos' });
    }

    const result = await authService.login(correo, password);

    if (result.error) {
      console.log('❌ Login fallido:', result.error);
      return res.status(401).json({ error: result.error });
    }

    console.log('✅ Login exitoso para:', correo);
    res.json(result);
  } catch (error) {
    console.error('❌ Error en login controller:', error);
    res.status(500).json({ error: 'Error en el servidor' });
  }
};

module.exports = { login };