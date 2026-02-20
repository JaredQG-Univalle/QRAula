const app = require('./app');
require('dotenv').config();
const https = require('https');

// ===============================
// 🔧 VERIFICACIÓN INICIAL
// ===============================
console.log('🔧 Iniciando servidor...');
console.log('📁 Entorno:', process.env.NODE_ENV || 'development');
console.log('🔌 Puerto:', process.env.PORT || 3000);

// Verificar variables importantes
if (!process.env.JWT_SECRET) {
  console.warn('⚠️  ADVERTENCIA: JWT_SECRET no está definido en .env');
}

if (!process.env.DB_HOST) {
  console.warn('⚠️  ADVERTENCIA: DB_HOST no está definido en .env');
}

// ===============================
// 🚨 MANEJO DE ERRORES GLOBALES
// ===============================
process.on('uncaughtException', (error) => {
  console.error('❌ Error no capturado:', error);
  process.exit(1);
});

process.on('unhandledRejection', (reason) => {
  console.error('❌ Promesa rechazada no manejada:', reason);
});

// ===============================
// 🚀 INICIAR SERVIDOR
// ===============================
const PORT = process.env.PORT || 3000;

const server = app.listen(PORT, () => {
  console.log('\n=================================');
  console.log('🚀 Servidor corriendo exitosamente');

  if (process.env.RENDER) {
    console.log(`🌍 URL: ${process.env.RENDER_EXTERNAL_URL}`);
  } else {
    console.log(`📌 URL: http://localhost:${PORT}`);
  }

  console.log(`📚 Base de datos: ${process.env.DB_NAME || 'aulaqr'}`);
  console.log(`🔐 JWT expires: ${process.env.JWT_EXPIRES_IN || '7d'}`);
  console.log('=================================\n');

  // ===============================
  // 🔥 AUTO PING (ANTI SLEEP RENDER)
  // ===============================
  if (process.env.RENDER) {
    const url = process.env.RENDER_EXTERNAL_URL;

    setInterval(() => {
      https.get(url, (res) => {
        console.log('🔄 Auto-ping enviado:', res.statusCode);
      }).on('error', (err) => {
        console.log('⚠️ Error en auto-ping:', err.message);
      });
    }, 14 * 60 * 1000); // cada 14 minutos

    console.log('🛡️ Auto-ping activado para evitar suspensión (Render Free)');
  }
});

// ===============================
// 📴 CIERRE GRACEFUL
// ===============================
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
