const db = require('../config/db');

class BloquesService {
  async getAll() {
    try {
      const [rows] = await db.query('SELECT * FROM bloques ORDER BY nombre');
      return rows;
    } catch (error) {
      console.error('Error en getAll bloques:', error);
      throw error;
    }
  }

  async getById(id) {
    try {
      const [rows] = await db.query('SELECT * FROM bloques WHERE id_bloque = ?', [id]);
      return rows[0];
    } catch (error) {
      console.error('Error en getById bloque:', error);
      throw error;
    }
  }

  async create(data) {
    try {
      const { nombre, descripcion } = data;
      const [result] = await db.query(
        'INSERT INTO bloques (nombre, descripcion) VALUES (?, ?)',
        [nombre, descripcion]
      );
      return result.insertId;
    } catch (error) {
      console.error('Error en create bloque:', error);
      throw error;
    }
  }

  async update(id, data) {
    try {
      const { nombre, descripcion } = data;
      const [result] = await db.query(
        'UPDATE bloques SET nombre = ?, descripcion = ? WHERE id_bloque = ?',
        [nombre, descripcion, id]
      );
      return result.affectedRows > 0;
    } catch (error) {
      console.error('Error en update bloque:', error);
      throw error;
    }
  }

  async delete(id) {
    try {
      const [result] = await db.query('DELETE FROM bloques WHERE id_bloque = ?', [id]);
      return result.affectedRows > 0;
    } catch (error) {
      console.error('Error en delete bloque:', error);
      throw error;
    }
  }
}

module.exports = new BloquesService();