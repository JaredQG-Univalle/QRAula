const db = require('../config/db');

class HorariosService {
  async getAll() {
    try {
      const [rows] = await db.query(`
        SELECT h.*, 
               a.nombre as aula_nombre,
               m.nombre as materia_nombre,
               CONCAT(u.nombre, ' ', u.apellido) as docente_nombre
        FROM horarios h
        LEFT JOIN aulas a ON h.id_aula = a.id_aula
        LEFT JOIN materias m ON h.id_materia = m.id_materia
        LEFT JOIN usuarios u ON h.id_usuario = u.id_usuario
        ORDER BY FIELD(dia_semana, 'Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado'), 
                 h.hora_inicio
      `);
      return rows;
    } catch (error) {
      console.error('Error en getAll horarios:', error);
      throw error;
    }
  }

  async getByAula(id_aula) {
    try {
      const [rows] = await db.query(`
        SELECT h.*, 
               m.nombre as materia_nombre,
               CONCAT(u.nombre, ' ', u.apellido) as docente_nombre
        FROM horarios h
        LEFT JOIN materias m ON h.id_materia = m.id_materia
        LEFT JOIN usuarios u ON h.id_usuario = u.id_usuario
        WHERE h.id_aula = ?
        ORDER BY FIELD(dia_semana, 'Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado'), 
                 h.hora_inicio
      `, [id_aula]);
      return rows;
    } catch (error) {
      console.error('Error en getByAula horarios:', error);
      throw error;
    }
  }

  async create(data) {
    try {
      const { id_aula, id_materia, id_usuario, dia_semana, hora_inicio, hora_fin } = data;
      const [result] = await db.query(
        `INSERT INTO horarios (id_aula, id_materia, id_usuario, dia_semana, hora_inicio, hora_fin) 
         VALUES (?, ?, ?, ?, ?, ?)`,
        [id_aula, id_materia, id_usuario, dia_semana, hora_inicio, hora_fin]
      );
      return result.insertId;
    } catch (error) {
      console.error('Error en create horario:', error);
      throw error;
    }
  }

  async update(id, data) {
    try {
      const { id_aula, id_materia, id_usuario, dia_semana, hora_inicio, hora_fin } = data;
      const [result] = await db.query(
        `UPDATE horarios 
         SET id_aula = ?, id_materia = ?, id_usuario = ?, dia_semana = ?, hora_inicio = ?, hora_fin = ? 
         WHERE id_horario = ?`,
        [id_aula, id_materia, id_usuario, dia_semana, hora_inicio, hora_fin, id]
      );
      return result.affectedRows > 0;
    } catch (error) {
      console.error('Error en update horario:', error);
      throw error;
    }
  }

  async delete(id) {
    try {
      const [result] = await db.query('DELETE FROM horarios WHERE id_horario = ?', [id]);
      return result.affectedRows > 0;
    } catch (error) {
      console.error('Error en delete horario:', error);
      throw error;
    }
  }
}

module.exports = new HorariosService();