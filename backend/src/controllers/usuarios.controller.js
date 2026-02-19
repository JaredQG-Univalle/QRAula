const db = require('../config/db');
const bcrypt = require('bcryptjs');

const getDocentes = async (req, res) => {
  try {
    const [rows] = await db.query(
      'SELECT id_usuario, nombre, apellido, correo FROM usuarios WHERE rol = ? AND estado = ?',
      ['DOCENTE', 'Activo']
    );
    res.json(rows);
  } catch (error) {
    console.error('Error getDocentes:', error);
    res.status(500).json({ error: 'Error al obtener docentes' });
  }
};

const getAll = async (req, res) => {
  try {
    const [rows] = await db.query(
      'SELECT id_usuario, nombre, apellido, correo, rol, estado FROM usuarios ORDER BY nombre'
    );
    res.json(rows);
  } catch (error) {
    res.status(500).json({ error: 'Error al obtener usuarios' });
  }
};

const create = async (req, res) => {
  try {
    const { nombre, apellido, correo, password, rol } = req.body;
    
    // Verificar si el correo ya existe
    const [exist] = await db.query('SELECT id_usuario FROM usuarios WHERE correo = ?', [correo]);
    if (exist.length > 0) {
      return res.status(400).json({ error: 'El correo ya está registrado' });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    const [result] = await db.query(
      'INSERT INTO usuarios (nombre, apellido, correo, password, rol) VALUES (?, ?, ?, ?, ?)',
      [nombre, apellido, correo, hashedPassword, rol || 'DOCENTE']
    );

    res.status(201).json({ 
      id: result.insertId, 
      message: 'Usuario creado exitosamente' 
    });
  } catch (error) {
    console.error('Error create usuario:', error);
    res.status(500).json({ error: 'Error al crear usuario' });
  }
};

const update = async (req, res) => {
  try {
    const { id } = req.params;
    const { nombre, apellido, correo, rol, estado } = req.body;

    await db.query(
      'UPDATE usuarios SET nombre = ?, apellido = ?, correo = ?, rol = ?, estado = ? WHERE id_usuario = ?',
      [nombre, apellido, correo, rol, estado, id]
    );

    res.json({ message: 'Usuario actualizado' });
  } catch (error) {
    res.status(500).json({ error: 'Error al actualizar' });
  }
};

const delete_ = async (req, res) => {
  try {
    const { id } = req.params;
    await db.query('DELETE FROM usuarios WHERE id_usuario = ?', [id]);
    res.json({ message: 'Usuario eliminado' });
  } catch (error) {
    res.status(500).json({ error: 'Error al eliminar' });
  }
};

module.exports = {
  getDocentes,
  getAll,
  create,
  update,
  delete: delete_
};