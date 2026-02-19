const app = require('./app');
require('dotenv').config();

// Verificación de configuración
console.log('🔧 Iniciando servidor...');
console.log('📁 Entorno:', process.env.NODE_ENV || 'development');
console.log('🔌 Puerto:', process.env.PORT || 3000);

// Verificar variables de entorno importantes
if (!process.env.JWT_SECRET) {
  console.warn('⚠️  ADVERTENCIA: JWT_SECRET no está definido en .env');
}

if (!process.env.DB_HOST) {
  console.warn('⚠️  ADVERTENCIA: DB_HOST no está definido en .env');
}

// Manejo de errores no capturados
process.on('uncaughtException', (error) => {
  console.error('❌ Error no capturado:', error);
  process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('❌ Promesa rechazada no manejada:', reason);
});

const PORT = process.env.PORT || 3000;

const server = app.listen(PORT, () => {
  console.log('\n=================================');
  console.log('🚀 Servidor corriendo exitosamente');
  console.log(`📌 URL: http://localhost:${PORT}`);
  console.log(`📚 Base de datos: ${process.env.DB_NAME || 'aulaqr'}`);
  console.log(`🔐 JWT expires: ${process.env.JWT_EXPIRES_IN || '7d'}`);
  console.log('=================================\n');
});

// Manejo de cierre graceful
process.on('SIGTERM', () => {
  console.log('📥 Recibida señal SIGTERM, cerrando servidor...');
  server.close(() => {
    console.log('✅ Servidor cerrado');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  console.log('📥 Recibida señal SIGINT, cerrando servidor...');
  server.close(() => {
    console.log('✅ Servidor cerrado');
    process.exit(0);
  });
});