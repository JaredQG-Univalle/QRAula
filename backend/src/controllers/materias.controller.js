const db = require('../config/db');

const getAll = async (req, res) => {
  try {
    const [rows] = await db.query('SELECT * FROM materias ORDER BY nombre');
    res.json(rows);
  } catch (error) {
    console.error('Error getMaterias:', error);
    res.status(500).json({ error: 'Error al obtener materias' });
  }
};

const getById = async (req, res) => {
  try {
    const [rows] = await db.query('SELECT * FROM materias WHERE id_materia = ?', [req.params.id]);
    if (rows.length === 0) {
      return res.status(404).json({ error: 'Materia no encontrada' });
    }
    res.json(rows[0]);
  } catch (error) {
    res.status(500).json({ error: 'Error al obtener materia' });
  }
};

const create = async (req, res) => {
  try {
    const { nombre, descripcion } = req.body;
    const [result] = await db.query(
      'INSERT INTO materias (nombre, descripcion) VALUES (?, ?)',
      [nombre, descripcion]
    );
    res.status(201).json({ 
      id: result.insertId, 
      message: 'Materia creada exitosamente' 
    });
  } catch (error) {
    console.error('Error create materia:', error);
    res.status(500).json({ error: 'Error al crear materia' });
  }
};

const update = async (req, res) => {
  try {
    const { nombre, descripcion } = req.body;
    await db.query(
      'UPDATE materias SET nombre = ?, descripcion = ? WHERE id_materia = ?',
      [nombre, descripcion, req.params.id]
    );
    res.json({ message: 'Materia actualizada' });
  } catch (error) {
    res.status(500).json({ error: 'Error al actualizar' });
  }
};

const delete_ = async (req, res) => {
  try {
    await db.query('DELETE FROM materias WHERE id_materia = ?', [req.params.id]);
    res.json({ message: 'Materia eliminada' });
  } catch (error) {
    res.status(500).json({ error: 'Error al eliminar' });
  }
};

module.exports = {
  getAll,
  getById,
  create,
  update,
  delete: delete_
};