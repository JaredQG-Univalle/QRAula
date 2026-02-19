const db = require('../config/db');

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

    // Usar texto plano por ahora (luego implementar bcrypt)
    const [result] = await db.query(
      'INSERT INTO usuarios (nombre, apellido, correo, password, rol) VALUES (?, ?, ?, ?, ?)',
      [nombre, apellido, correo, password, rol || 'DOCENTE']
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
    const { nombre, apellido, correo, rol } = req.body;

    const [result] = await db.query(
      'UPDATE usuarios SET nombre = ?, apellido = ?, correo = ?, rol = ? WHERE id_usuario = ?',
      [nombre, apellido, correo, rol, id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Usuario no encontrado' });
    }

    res.json({ message: 'Usuario actualizado' });
  } catch (error) {
    console.error('Error update usuario:', error);
    res.status(500).json({ error: 'Error al actualizar' });
  }
};

const delete_ = async (req, res) => {
  try {
    const { id } = req.params;
    
    // Verificar si el usuario tiene horarios asociados
    const [horarios] = await db.query('SELECT id_horario FROM horarios WHERE id_usuario = ?', [id]);
    if (horarios.length > 0) {
      return res.status(400).json({ 
        error: 'No se puede eliminar porque tiene horarios asignados',
        count: horarios.length
      });
    }

    const [result] = await db.query('DELETE FROM usuarios WHERE id_usuario = ?', [id]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Usuario no encontrado' });
    }

    res.json({ message: 'Usuario eliminado' });
  } catch (error) {
    console.error('Error delete usuario:', error);
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