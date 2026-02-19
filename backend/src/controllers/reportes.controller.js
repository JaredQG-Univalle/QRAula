const db = require('../config/db');

// Obtener todos los reportes (admin)
const getAll = async (req, res) => {
  try {
    console.log('🔍 Obteniendo todos los reportes');
    
    const [rows] = await db.query(`
      SELECT r.*, 
             a.nombre as aula_nombre,
             CONCAT(u.nombre, ' ', u.apellido) as usuario_nombre
      FROM reportes_tecnicos r
      LEFT JOIN aulas a ON r.id_aula = a.id_aula
      LEFT JOIN usuarios u ON r.id_usuario = u.id_usuario
      ORDER BY r.fecha_reporte DESC
    `);
    
    console.log('📊 Reportes encontrados:', rows.length);
    res.json(rows);
  } catch (error) {
    console.error('❌ Error en getAll reportes:', error);
    res.status(500).json({ error: 'Error al obtener reportes' });
  }
};

// Obtener reportes por usuario (docente)
const getByUsuario = async (req, res) => {
  try {
    const id_usuario = req.usuario.id;
    
    const [rows] = await db.query(`
      SELECT r.*, 
             a.nombre as aula_nombre
      FROM reportes_tecnicos r
      LEFT JOIN aulas a ON r.id_aula = a.id_aula
      WHERE r.id_usuario = ?
      ORDER BY r.fecha_reporte DESC
    `, [id_usuario]);
    
    res.json(rows);
  } catch (error) {
    console.error('Error en getByUsuario reportes:', error);
    res.status(500).json({ error: 'Error al obtener reportes' });
  }
};

// Crear nuevo reporte (docente)
const create = async (req, res) => {
  try {
    const { id_aula, descripcion } = req.body;
    const id_usuario = req.usuario.id;

    console.log('📝 Creando reporte:', { id_aula, id_usuario, descripcion });

    // Validar campos requeridos
    if (!id_aula || !descripcion) {
      return res.status(400).json({ 
        error: 'Faltan campos requeridos',
        required: ['id_aula', 'descripcion']
      });
    }

    const [result] = await db.query(
      `INSERT INTO reportes_tecnicos (id_aula, id_usuario, descripcion, estado) 
       VALUES (?, ?, ?, ?)`,
      [id_aula, id_usuario, descripcion, 'Pendiente']
    );

    console.log('✅ Reporte creado con ID:', result.insertId);

    // Obtener el reporte creado con relaciones
    const [nuevoReporte] = await db.query(`
      SELECT r.*, 
             a.nombre as aula_nombre,
             CONCAT(u.nombre, ' ', u.apellido) as usuario_nombre
      FROM reportes_tecnicos r
      LEFT JOIN aulas a ON r.id_aula = a.id_aula
      LEFT JOIN usuarios u ON r.id_usuario = u.id_usuario
      WHERE r.id_reporte = ?
    `, [result.insertId]);

    res.status(201).json({ 
      id: result.insertId, 
      message: 'Reporte creado exitosamente',
      reporte: nuevoReporte[0]
    });
  } catch (error) {
    console.error('❌ Error en create reporte:', error);
    res.status(500).json({ error: 'Error al crear reporte' });
  }
};

// Actualizar estado del reporte (admin)
const updateEstado = async (req, res) => {
  try {
    const { id } = req.params;
    const { estado } = req.body;

    // Validar estado
    const estadosValidos = ['Pendiente', 'En Proceso', 'Resuelto'];
    if (!estadosValidos.includes(estado)) {
      return res.status(400).json({ 
        error: 'Estado no válido',
        validos: estadosValidos
      });
    }

    const [result] = await db.query(
      'UPDATE reportes_tecnicos SET estado = ? WHERE id_reporte = ?',
      [estado, id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Reporte no encontrado' });
    }

    res.json({ message: 'Estado actualizado exitosamente' });
  } catch (error) {
    console.error('Error en updateEstado reporte:', error);
    res.status(500).json({ error: 'Error al actualizar estado' });
  }
};

// Eliminar reporte (admin)
const delete_ = async (req, res) => {
  try {
    const { id } = req.params;

    const [result] = await db.query('DELETE FROM reportes_tecnicos WHERE id_reporte = ?', [id]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Reporte no encontrado' });
    }

    res.json({ message: 'Reporte eliminado exitosamente' });
  } catch (error) {
    console.error('Error en delete reporte:', error);
    res.status(500).json({ error: 'Error al eliminar reporte' });
  }
};

module.exports = {
  getAll,
  getByUsuario,
  create,
  updateEstado,
  delete: delete_
};