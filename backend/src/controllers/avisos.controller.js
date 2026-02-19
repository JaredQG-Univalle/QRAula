const db = require('../config/db');

const getAll = async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT a.*, 
             u.nombre as usuario_nombre,
             au.nombre as aula_nombre
      FROM avisos a
      LEFT JOIN usuarios u ON a.id_usuario = u.id_usuario
      LEFT JOIN aulas au ON a.id_aula = au.id_aula
      ORDER BY a.fecha_publicacion DESC
    `);
    res.json(rows);
  } catch (error) {
    console.error('Error get all avisos:', error);
    res.status(500).json({ error: 'Error al obtener avisos' });
  }
};

const getByAula = async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT a.*, u.nombre as usuario_nombre 
       FROM avisos a 
       LEFT JOIN usuarios u ON a.id_usuario = u.id_usuario 
       WHERE a.id_aula = ? AND (a.fecha_expiracion IS NULL OR a.fecha_expiracion > NOW())
       ORDER BY a.fecha_publicacion DESC`,
      [req.params.id_aula]
    );
    res.json(rows);
  } catch (error) {
    console.error('Error getByAula avisos:', error);
    res.status(500).json({ error: 'Error al obtener avisos' });
  }
};

const create = async (req, res) => {
  try {
    const { id_aula, titulo, contenido, fecha_expiracion } = req.body;
    const id_usuario = req.usuario.id; // Del token JWT

    const [result] = await db.query(
      'INSERT INTO avisos (id_aula, id_usuario, titulo, contenido, fecha_expiracion) VALUES (?, ?, ?, ?, ?)',
      [id_aula, id_usuario, titulo, contenido, fecha_expiracion || null]
    );

    res.status(201).json({ 
      id: result.insertId, 
      message: 'Aviso creado exitosamente' 
    });
  } catch (error) {
    console.error('Error create aviso:', error);
    res.status(500).json({ error: 'Error al crear aviso' });
  }
};

const delete_ = async (req, res) => {
  try {
    const { id } = req.params;
    
    // Verificar que el aviso pertenece al usuario (o es admin)
    const [result] = await db.query('DELETE FROM avisos WHERE id_aviso = ?', [id]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Aviso no encontrado' });
    }

    res.json({ message: 'Aviso eliminado exitosamente' });
  } catch (error) {
    console.error('Error delete aviso:', error);
    res.status(500).json({ error: 'Error al eliminar aviso' });
  }
};

module.exports = {
  getAll,
  getByAula,
  create,
  delete: delete_
};