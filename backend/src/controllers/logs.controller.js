const db = require('../config/db');

const registrarEscaneo = async (req, res) => {
  try {
    const { id_aula } = req.params;
    const dispositivo = req.headers['user-agent'] || 'Desconocido';

    console.log(`📱 Escaneo registrado - Aula ID: ${id_aula}, Dispositivo: ${dispositivo}`);

    const [result] = await db.query(
      'INSERT INTO logs_consulta (id_aula, dispositivo) VALUES (?, ?)',
      [id_aula, dispositivo]
    );

    res.status(201).json({ 
      message: 'Escaneo registrado',
      id: result.insertId 
    });
  } catch (error) {
    console.error('Error registrando escaneo:', error);
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
    
    // Escaneos por día (últimos 7 días)
    const [porDia] = await db.query(`
      SELECT DATE(fecha_consulta) as fecha, COUNT(*) as cantidad
      FROM logs_consulta
      WHERE fecha_consulta >= DATE_SUB(NOW(), INTERVAL 7 DAY)
      GROUP BY DATE(fecha_consulta)
      ORDER BY fecha DESC
    `);

    res.json({
      total: total[0].total,
      porAula,
      porDia
    });
  } catch (error) {
    console.error('Error obteniendo estadísticas:', error);
    res.status(500).json({ error: 'Error al obtener estadísticas' });
  }
};

module.exports = {
  registrarEscaneo,
  getEstadisticas
};
