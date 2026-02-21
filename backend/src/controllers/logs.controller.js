const db = require('../config/db');

// Función para detectar el dispositivo desde el User-Agent
const detectarDispositivo = (userAgent) => {
  let dispositivo = 'Desconocido';
  let sistemaOperativo = 'Desconocido';
  let modelo = 'Desconocido';

  // Detectar sistema operativo
  if (userAgent.includes('Windows NT')) {
    sistemaOperativo = 'Windows';
    const version = userAgent.match(/Windows NT (\d+\.\d+)/);
    if (version) sistemaOperativo += ` ${version[1]}`;
  } else if (userAgent.includes('Android')) {
    sistemaOperativo = 'Android';
    const version = userAgent.match(/Android (\d+)/);
    if (version) sistemaOperativo += ` ${version[1]}`;
    
    // Intentar detectar modelo específico de Android
    const modeloMatch = userAgent.match(/Android.*?; ([^;]+)/);
    if (modeloMatch) modelo = modeloMatch[1].trim();
  } else if (userAgent.includes('iPhone')) {
    sistemaOperativo = 'iOS';
    const version = userAgent.match(/iPhone OS (\d+_\d+)/);
    if (version) sistemaOperativo += ` ${version[1].replace('_', '.')}`;
    modelo = 'iPhone';
  } else if (userAgent.includes('iPad')) {
    sistemaOperativo = 'iOS';
    modelo = 'iPad';
  } else if (userAgent.includes('Mac OS X')) {
    sistemaOperativo = 'macOS';
  } else if (userAgent.includes('Linux')) {
    sistemaOperativo = 'Linux';
  }

  // Detectar tipo de dispositivo
  if (userAgent.includes('Mobile') || userAgent.includes('Android') && !userAgent.includes('Tablet')) {
    dispositivo = 'Móvil';
  } else if (userAgent.includes('Tablet') || userAgent.includes('iPad')) {
    dispositivo = 'Tablet';
  } else {
    dispositivo = 'Escritorio';
  }

  // Detectar si es la app de Flutter
  if (userAgent.includes('Dart')) {
    dispositivo = 'App Flutter';
    // Si es Dart, el sistema operativo ya se detectó arriba
  }

  // Detectar navegador si es web
  let navegador = 'Desconocido';
  if (userAgent.includes('Chrome') && !userAgent.includes('Edg')) {
    navegador = 'Chrome';
  } else if (userAgent.includes('Firefox')) {
    navegador = 'Firefox';
  } else if (userAgent.includes('Safari') && !userAgent.includes('Chrome')) {
    navegador = 'Safari';
  } else if (userAgent.includes('Edg')) {
    navegador = 'Edge';
  }

  return {
    completo: userAgent,
    tipo: dispositivo,
    so: sistemaOperativo,
    modelo: modelo,
    navegador: navegador
  };
};

const registrarEscaneo = async (req, res) => {
  try {
    const { id_aula } = req.params;
    const userAgent = req.headers['user-agent'] || 'Desconocido';
    
    // Detectar información detallada del dispositivo
    const info = detectarDispositivo(userAgent);
    
    // Crear un string descriptivo del dispositivo
    let descripcionDispositivo = info.tipo;
    
    if (info.modelo !== 'Desconocido') {
      descripcionDispositivo += ` - ${info.modelo}`;
    }
    
    descripcionDispositivo += ` (${info.so}`;
    
    if (info.navegador !== 'Desconocido' && info.tipo !== 'App Flutter') {
      descripcionDispositivo += `, ${info.navegador}`;
    }
    
    descripcionDispositivo += ')';

    console.log('📱 Información completa del dispositivo:');
    console.log(`   - User-Agent: ${userAgent.substring(0, 100)}...`);
    console.log(`   - Tipo: ${info.tipo}`);
    console.log(`   - SO: ${info.so}`);
    console.log(`   - Modelo: ${info.modelo}`);
    console.log(`   - Navegador: ${info.navegador}`);
    console.log(`   - Descripción: ${descripcionDispositivo}`);
    console.log(`   - Aula ID: ${id_aula}`);

    // Guardar en la base de datos
    const [result] = await db.query(
      'INSERT INTO logs_consulta (id_aula, dispositivo) VALUES (?, ?)',
      [id_aula, descripcionDispositivo]
    );

    res.status(201).json({ 
      message: 'Escaneo registrado exitosamente',
      id: result.insertId,
      dispositivo: descripcionDispositivo,
      info_detallada: info
    });
  } catch (error) {
    console.error('❌ Error registrando escaneo:', error);
    res.status(500).json({ error: 'Error al registrar escaneo' });
  }
};

const getEstadisticas = async (req, res) => {
  try {
    // Total de escaneos
    const [total] = await db.query('SELECT COUNT(*) as total FROM logs_consulta');
    
    // Escaneos por aula
    const [porAula] = await db.query(`
      SELECT a.nombre, COUNT(*) as cantidad
      FROM logs_consulta l
      LEFT JOIN aulas a ON l.id_aula = a.id_aula
      GROUP BY l.id_aula
      ORDER BY cantidad DESC
    `);
    
    // Escaneos por tipo de dispositivo
    const [porDispositivo] = await db.query(`
      SELECT 
        CASE 
          WHEN dispositivo LIKE '%App Flutter%' THEN 'App Flutter'
          WHEN dispositivo LIKE '%Móvil%' THEN 'Móvil'
          WHEN dispositivo LIKE '%Tablet%' THEN 'Tablet'
          WHEN dispositivo LIKE '%Escritorio%' THEN 'Escritorio'
          ELSE 'Otro'
        END as tipo,
        COUNT(*) as cantidad
      FROM logs_consulta
      GROUP BY tipo
      ORDER BY cantidad DESC
    `);
    
    // Escaneos por sistema operativo
    const [porSO] = await db.query(`
      SELECT 
        CASE 
          WHEN dispositivo LIKE '%Android%' THEN 'Android'
          WHEN dispositivo LIKE '%iOS%' THEN 'iOS'
          WHEN dispositivo LIKE '%Windows%' THEN 'Windows'
          WHEN dispositivo LIKE '%macOS%' THEN 'macOS'
          WHEN dispositivo LIKE '%Linux%' THEN 'Linux'
          ELSE 'Otro'
        END as so,
        COUNT(*) as cantidad
      FROM logs_consulta
      GROUP BY so
      ORDER BY cantidad DESC
    `);
    
    // Escaneos por día (últimos 30 días)
    const [porDia] = await db.query(`
      SELECT DATE(fecha_consulta) as fecha, COUNT(*) as cantidad
      FROM logs_consulta
      WHERE fecha_consulta >= DATE_SUB(NOW(), INTERVAL 30 DAY)
      GROUP BY DATE(fecha_consulta)
      ORDER BY fecha DESC
    `);

    // Últimos 10 escaneos con detalles
    const [ultimos] = await db.query(`
      SELECT l.*, a.nombre as aula_nombre
      FROM logs_consulta l
      LEFT JOIN aulas a ON l.id_aula = a.id_aula
      ORDER BY l.fecha_consulta DESC
      LIMIT 10
    `);

    res.json({
      total: total[0].total,
      porAula,
      porDispositivo,
      porSO,
      porDia,
      ultimos
    });
  } catch (error) {
    console.error('❌ Error obteniendo estadísticas:', error);
    res.status(500).json({ error: 'Error al obtener estadísticas' });
  }
};

module.exports = {
  registrarEscaneo,
  getEstadisticas
};
