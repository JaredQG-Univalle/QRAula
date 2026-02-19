const jwt = require('jsonwebtoken');

const authMiddleware = (req, res, next) => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', '');
    
    if (!token) {
      return res.status(401).json({ error: 'No autorizado - Token no proporcionado' });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.usuario = decoded;
    next();
  } catch (error) {
    res.status(401).json({ error: 'No autorizado - Token inválido' });
  }
};

const adminMiddleware = (req, res, next) => {
  if (req.usuario?.rol !== 'ADMIN') {
    return res.status(403).json({ error: 'Acceso denegado - Se requiere rol ADMIN' });
  }
  next();
};

module.exports = { authMiddleware, adminMiddleware };