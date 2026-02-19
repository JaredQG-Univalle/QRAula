const db = require('../config/db');

class AulasService {
  async getAll() {
    try {
      const [rows] = await db.query(`
        SELECT a.*, b.nombre as bloque_nombre 
        FROM aulas a 
        LEFT JOIN bloques b ON a.id_bloque = b.id_bloque 
        ORDER BY a.nombre
      `);
      return rows;
    } catch (error) {
      console.error('❌ Error en getAll aulas:', error);
      throw error;
    }
  }

  async getById(id) {
    try {
      const [rows] = await db.query(
        `SELECT a.*, b.nombre as bloque_nombre 
         FROM aulas a 
         LEFT JOIN bloques b ON a.id_bloque = b.id_bloque 
         WHERE a.id_aula = ?`,
        [id]
      );
      return rows[0];
    } catch (error) {
      console.error('❌ Error en getById aula:', error);
      throw error;
    }
  }

  async getByQR(codigoQR) {
    try {
      const [rows] = await db.query(
        `SELECT a.*, b.nombre as bloque_nombre 
         FROM aulas a 
         LEFT JOIN bloques b ON a.id_bloque = b.id_bloque 
         WHERE a.codigo_qr = ?`,
        [codigoQR]
      );
      return rows[0];
    } catch (error) {
      console.error('❌ Error en getByQR aula:', error);
      throw error;
    }
  }

  // 🔴 CORREGIR CREATE
  async create(data) {
    try {
      console.log('📝 Service - Creando aula:', data);
      
      const { id_bloque, codigo_qr, nombre, capacidad, equipamiento, estado, latitud, longitud } = data;
      
      const [result] = await db.query(
        `INSERT INTO aulas 
         (id_bloque, codigo_qr, nombre, capacidad, equipamiento, estado, latitud, longitud) 
         VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          id_bloque, 
          codigo_qr, 
          nombre, 
          capacidad, 
          equipamiento || '', 
          estado || 'Disponible', 
          latitud || null, 
          longitud || null
        ]
      );
      
      console.log('✅ Aula creada con ID:', result.insertId);
      return result.insertId;
    } catch (error) {
      console.error('❌ Error en create aula:', error);
      throw error;
    }
  }

  // 🔴 CORREGIR UPDATE
  async update(id, data) {
    try {
      console.log('📝 Service - Actualizando aula ID:', id, 'con:', data);
      
      const { id_bloque, nombre, capacidad, equipamiento, estado, latitud, longitud } = data;
      
      const [result] = await db.query(
        `UPDATE aulas 
         SET id_bloque = ?, 
             nombre = ?, 
             capacidad = ?, 
             equipamiento = ?, 
             estado = ?, 
             latitud = ?, 
             longitud = ? 
         WHERE id_aula = ?`,
        [
          id_bloque, 
          nombre, 
          capacidad, 
          equipamiento || '', 
          estado || 'Disponible', 
          latitud || null, 
          longitud || null, 
          id
        ]
      );
      
      console.log('✅ Filas afectadas:', result.affectedRows);
      return result.affectedRows > 0;
    } catch (error) {
      console.error('❌ Error en update aula:', error);
      throw error;
    }
  }

  // 🔴 CORREGIR DELETE
  async delete(id) {
    try {
      console.log('🗑️ Service - Eliminando aula ID:', id);
      
      const [result] = await db.query('DELETE FROM aulas WHERE id_aula = ?', [id]);
      
      console.log('✅ Filas eliminadas:', result.affectedRows);
      return result.affectedRows > 0;
    } catch (error) {
      console.error('❌ Error en delete aula:', error);
      throw error;
    }
  }

  async updateEstado(id, estado) {
    try {
      const [result] = await db.query(
        'UPDATE aulas SET estado = ? WHERE id_aula = ?',
        [estado, id]
      );
      return result.affectedRows > 0;
    } catch (error) {
      console.error('❌ Error en updateEstado aula:', error);
      throw error;
    }
  }
}

module.exports = new AulasService();