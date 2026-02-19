const db = require('../config/db');

const getAll = async (req, res) => {
  try {
    const [rows] = await db.query('SELECT * FROM bloques ORDER BY nombre');
    res.json(rows);
  } catch (error) {
    console.error('Error en getAll bloques:', error);
    res.status(500).json({ error: 'Error al obtener bloques' });
  }
};

const getById = async (req, res) => {
  try {
    const [rows] = await db.query('SELECT * FROM bloques WHERE id_bloque = ?', [req.params.id]);
    if (rows.length === 0) {
      return res.status(404).json({ error: 'Bloque no encontrado' });
    }
    res.json(rows[0]);
  } catch (error) {
    res.status(500).json({ error: 'Error al obtener bloque' });
  }
};

const create = async (req, res) => {
  try {
    const { nombre, descripcion } = req.body;
    
    if (!nombre) {
      return res.status(400).json({ error: 'Nombre es requerido' });
    }

    const [result] = await db.query(
      'INSERT INTO bloques (nombre, descripcion) VALUES (?, ?)',
      [nombre, descripcion || '']
    );

    res.status(201).json({ 
      id: result.insertId, 
      nombre,
      descripcion,
      message: 'Bloque creado exitosamente' 
    });
  } catch (error) {
    console.error('Error en create bloque:', error);
    res.status(500).json({ error: 'Error al crear bloque' });
  }
};

const update = async (req, res) => {
  try {
    const { nombre, descripcion } = req.body;
    
    const [result] = await db.query(
      'UPDATE bloques SET nombre = ?, descripcion = ? WHERE id_bloque = ?',
      [nombre, descripcion || '', req.params.id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Bloque no encontrado' });
    }

    res.json({ message: 'Bloque actualizado exitosamente' });
  } catch (error) {
    console.error('Error en update bloque:', error);
    res.status(500).json({ error: 'Error al actualizar bloque' });
  }
};

const delete_ = async (req, res) => {
  try {
    // Verificar si hay aulas usando este bloque
    const [aulas] = await db.query('SELECT id_aula FROM aulas WHERE id_bloque = ?', [req.params.id]);
    
    if (aulas.length > 0) {
      return res.status(400).json({ 
        error: 'No se puede eliminar porque tiene aulas asociadas',
        count: aulas.length
      });
    }

    const [result] = await db.query('DELETE FROM bloques WHERE id_bloque = ?', [req.params.id]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Bloque no encontrado' });
    }

    res.json({ message: 'Bloque eliminado exitosamente' });
  } catch (error) {
    console.error('Error en delete bloque:', error);
    res.status(500).json({ error: 'Error al eliminar bloque' });
  }
};

module.exports = {
  getAll,
  getById,
  create,
  update,
  delete: delete_
};