const db = require('../config/db');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

class AuthService {
  async login(correo, password) {
    try {
      console.log('🔍 Buscando usuario:', correo);
      
      const [rows] = await db.query(
        'SELECT id_usuario, nombre, apellido, correo, password, rol, estado FROM usuarios WHERE correo = ?',
        [correo]
      );

      if (rows.length === 0) {
        return { error: 'Usuario no encontrado' };
      }

      const usuario = rows[0];
      
      // 🔴 COMPARACIÓN DIRECTA (SOLO PARA PRUEBAS)
      console.log('🔑 Contraseña en BD:', usuario.password);
      console.log('🔐 Contraseña ingresada:', password);
      
      let passwordValida = false;
      
      // Si la contraseña en BD es texto plano
      if (usuario.password === password) {
        console.log('✅ Coincidencia en texto plano');
        passwordValida = true;
      } else {
        // Intentar con bcrypt
        try {
          passwordValida = await bcrypt.compare(password, usuario.password);
          console.log('🔍 Bcrypt compare:', passwordValida);
        } catch (e) {
          console.log('❌ Error en bcrypt:', e.message);
        }
      }

      if (!passwordValida) {
        return { error: 'Credenciales incorrectas' };
      }

      const token = jwt.sign(
        { 
          id: usuario.id_usuario, 
          correo: usuario.correo, 
          rol: usuario.rol 
        },
        process.env.JWT_SECRET,
        { expiresIn: process.env.JWT_EXPIRES_IN }
      );

      const { password: _, ...usuarioSinPassword } = usuario;

      return {
        token,
        usuario: usuarioSinPassword
      };
    } catch (error) {
      console.error('❌ Error en login:', error);
      return { error: 'Error en el servidor' };
    }
  }
}

module.exports = new AuthService();