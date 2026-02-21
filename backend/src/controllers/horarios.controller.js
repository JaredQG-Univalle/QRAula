const db = require('../config/db');

// Función para verificar si hay cruce de horarios
const verificarCruceHorarios = async (id_aula, dia_semana, hora_inicio, hora_fin, id_horario_excluir = null) => {
  console.log('🔍 Verificando cruce de horarios:', { id_aula, dia_semana, hora_inicio, hora_fin });

  // Validar formato de hora (HH:MM)
  const horaRegex = /^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/;
  if (!horaRegex.test(hora_inicio) || !horaRegex.test(hora_fin)) {
    return {
      hayCruce: true,
      error: 'Formato de hora inválido. Use HH:MM (ej: 08:30)'
    };
  }

  // Convertir horas a minutos para comparar
  const [horaInicioH, horaInicioM] = hora_inicio.split(':').map(Number);
  const [horaFinH, horaFinM] = hora_fin.split(':').map(Number);
  
  const inicioMinutos = horaInicioH * 60 + horaInicioM;
  const finMinutos = horaFinH * 60 + horaFinM;

  // Verificar que hora fin sea mayor que hora inicio
  if (finMinutos <= inicioMinutos) {
    return {
      hayCruce: true,
      error: '⏰ La hora de fin debe ser mayor a la hora de inicio'
    };
  }

  // Consultar horarios existentes en la misma aula y día
  let query = `
    SELECT h.*, 
           m.nombre as materia_nombre,
           CONCAT(u.nombre, ' ', u.apellido) as docente_nombre
    FROM horarios h
    LEFT JOIN materias m ON h.id_materia = m.id_materia
    LEFT JOIN usuarios u ON h.id_usuario = u.id_usuario
    WHERE h.id_aula = ? AND h.dia_semana = ?
  `;
  const params = [id_aula, dia_semana];

  // Excluir el horario actual si estamos actualizando
  if (id_horario_excluir) {
    query += ' AND h.id_horario != ?';
    params.push(id_horario_excluir);
  }

  const [horariosExistentes] = await db.query(query, params);

  // Verificar cada horario existente
  for (const horario of horariosExistentes) {
    const [existenteH, existenteM] = horario.hora_inicio.split(':').map(Number);
    const [existenteFinH, existenteFinM] = horario.hora_fin.split(':').map(Number);
    
    const existenteInicioMinutos = existenteH * 60 + existenteM;
    const existenteFinMinutos = existenteFinH * 60 + existenteFinM;

    // Caso 1: El nuevo horario empieza durante uno existente
    if (inicioMinutos >= existenteInicioMinutos && inicioMinutos < existenteFinMinutos) {
      return {
        hayCruce: true,
        error: `❌ CRUCE DETECTADO: El horario (${hora_inicio} - ${hora_fin}) se cruza con ${horario.materia_nombre || 'clase'} (${horario.hora_inicio} - ${horario.hora_fin}) en la misma aula`,
        horarioConflicto: horario
      };
    }

    // Caso 2: El nuevo horario termina durante uno existente
    if (finMinutos > existenteInicioMinutos && finMinutos <= existenteFinMinutos) {
      return {
        hayCruce: true,
        error: `❌ CRUCE DETECTADO: El horario (${hora_inicio} - ${hora_fin}) se cruza con ${horario.materia_nombre || 'clase'} (${horario.hora_inicio} - ${horario.hora_fin})`,
        horarioConflicto: horario
      };
    }

    // Caso 3: El nuevo horario contiene completamente a uno existente
    if (inicioMinutos <= existenteInicioMinutos && finMinutos >= existenteFinMinutos) {
      return {
        hayCruce: true,
        error: `❌ CRUCE DETECTADO: El horario (${hora_inicio} - ${hora_fin}) cubre completamente ${horario.materia_nombre || 'clase'} (${horario.hora_inicio} - ${horario.hora_fin})`,
        horarioConflicto: horario
      };
    }
  }

  return { hayCruce: false };
};

const getAll = async (req, res) => {
  try {
    console.log('🔍 Obteniendo todos los horarios');
    
    const [rows] = await db.query(`
      SELECT h.*, 
             a.nombre as aula_nombre,
             a.codigo_qr as aula_codigo,
             m.nombre as materia_nombre,
             CONCAT(u.nombre, ' ', u.apellido) as docente_nombre,
             u.id_usuario as docente_id
      FROM horarios h
      LEFT JOIN aulas a ON h.id_aula = a.id_aula
      LEFT JOIN materias m ON h.id_materia = m.id_materia
      LEFT JOIN usuarios u ON h.id_usuario = u.id_usuario
      ORDER BY FIELD(dia_semana, 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'), 
               h.hora_inicio
    `);
    
    console.log('📊 Horarios encontrados:', rows.length);
    res.json(rows);
  } catch (error) {
    console.error('❌ Error en getAll horarios:', error);
    res.status(500).json({ 
      error: 'Error al obtener horarios',
      details: error.message 
    });
  }
};

const getByAula = async (req, res) => {
  try {
    console.log('🔍 Buscando horarios para aula ID:', req.params.id_aula);
    
    const [rows] = await db.query(`
      SELECT h.*, 
             m.nombre as materia_nombre,
             CONCAT(u.nombre, ' ', u.apellido) as docente_nombre
      FROM horarios h
      LEFT JOIN materias m ON h.id_materia = m.id_materia
      LEFT JOIN usuarios u ON h.id_usuario = u.id_usuario
      WHERE h.id_aula = ?
      ORDER BY FIELD(dia_semana, 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'), 
               h.hora_inicio
    `, [req.params.id_aula]);
    
    console.log('📊 Horarios encontrados:', rows.length);
    res.json(rows);
  } catch (error) {
    console.error('❌ Error en getByAula:', error);
    res.status(500).json({ 
      error: 'Error al obtener horarios',
      details: error.message 
    });
  }
};

const create = async (req, res) => {
  try {
    console.log('📝 Creando horario con datos:', req.body);
    
    const { id_aula, id_materia, id_usuario, dia_semana, hora_inicio, hora_fin } = req.body;
    
    // Validar campos requeridos
    if (!id_aula || !id_materia || !id_usuario || !dia_semana || !hora_inicio || !hora_fin) {
      return res.status(400).json({ 
        error: 'Faltan campos requeridos',
        required: ['id_aula', 'id_materia', 'id_usuario', 'dia_semana', 'hora_inicio', 'hora_fin']
      });
    }

    // Validar que el día sea válido
    const diasValidos = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'];
    if (!diasValidos.includes(dia_semana)) {
      return res.status(400).json({ 
        error: 'Día no válido',
        validos: diasValidos
      });
    }

    // 🔴 VALIDACIÓN DE CRUCE DE HORARIOS
    const validacion = await verificarCruceHorarios(id_aula, dia_semana, hora_inicio, hora_fin);
    
    if (validacion.hayCruce) {
      return res.status(409).json({ // 409 = Conflict
        error: 'Conflicto de horarios',
        message: validacion.error,
        conflicto: validacion.horarioConflicto
      });
    }

    // Si no hay cruce, proceder a crear
    const [result] = await db.query(
      `INSERT INTO horarios (id_aula, id_materia, id_usuario, dia_semana, hora_inicio, hora_fin) 
       VALUES (?, ?, ?, ?, ?, ?)`,
      [id_aula, id_materia, id_usuario, dia_semana, hora_inicio, hora_fin]
    );

    // Obtener el horario creado con sus relaciones
    const [nuevoHorario] = await db.query(`
      SELECT h.*, 
             a.nombre as aula_nombre,
             m.nombre as materia_nombre,
             CONCAT(u.nombre, ' ', u.apellido) as docente_nombre
      FROM horarios h
      LEFT JOIN aulas a ON h.id_aula = a.id_aula
      LEFT JOIN materias m ON h.id_materia = m.id_materia
      LEFT JOIN usuarios u ON h.id_usuario = u.id_usuario
      WHERE h.id_horario = ?
    `, [result.insertId]);

    res.status(201).json({ 
      id: result.insertId, 
      message: 'Horario creado exitosamente',
      horario: nuevoHorario[0]
    });
  } catch (error) {
    console.error('❌ Error en create horario:', error);
    res.status(500).json({ 
      error: 'Error al crear horario',
      details: error.message 
    });
  }
};

const update = async (req, res) => {
  try {
    console.log('📝 Actualizando horario ID:', req.params.id, 'con:', req.body);
    
    const { id_aula, id_materia, id_usuario, dia_semana, hora_inicio, hora_fin } = req.body;
    
    // Validar que el horario existe
    const [horarioExistente] = await db.query(
      'SELECT * FROM horarios WHERE id_horario = ?',
      [req.params.id]
    );

    if (horarioExistente.length === 0) {
      return res.status(404).json({ error: 'Horario no encontrado' });
    }

    // 🔴 VALIDACIÓN DE CRUCE DE HORARIOS (excluyendo el horario actual)
    const validacion = await verificarCruceHorarios(
      id_aula, 
      dia_semana, 
      hora_inicio, 
      hora_fin, 
      req.params.id  // Excluir el horario actual
    );
    
    if (validacion.hayCruce) {
      return res.status(409).json({
        error: 'Conflicto de horarios',
        message: validacion.error,
        conflicto: validacion.horarioConflicto
      });
    }

    // Si no hay cruce, proceder a actualizar
    const [result] = await db.query(
      `UPDATE horarios 
       SET id_aula = ?, id_materia = ?, id_usuario = ?, dia_semana = ?, hora_inicio = ?, hora_fin = ? 
       WHERE id_horario = ?`,
      [id_aula, id_materia, id_usuario, dia_semana, hora_inicio, hora_fin, req.params.id]
    );
    
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Horario no encontrado' });
    }

    // Obtener el horario actualizado
    const [horarioActualizado] = await db.query(`
      SELECT h.*, 
             a.nombre as aula_nombre,
             m.nombre as materia_nombre,
             CONCAT(u.nombre, ' ', u.apellido) as docente_nombre
      FROM horarios h
      LEFT JOIN aulas a ON h.id_aula = a.id_aula
      LEFT JOIN materias m ON h.id_materia = m.id_materia
      LEFT JOIN usuarios u ON h.id_usuario = u.id_usuario
      WHERE h.id_horario = ?
    `, [req.params.id]);
    
    res.json({ 
      message: 'Horario actualizado exitosamente',
      horario: horarioActualizado[0]
    });
  } catch (error) {
    console.error('❌ Error en update horario:', error);
    res.status(500).json({ 
      error: 'Error al actualizar horario',
      details: error.message 
    });
  }
};

const delete_ = async (req, res) => {
  try {
    console.log('🗑️ Eliminando horario ID:', req.params.id);
    
    const [result] = await db.query('DELETE FROM horarios WHERE id_horario = ?', [req.params.id]);
    
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Horario no encontrado' });
    }
    
    res.json({ message: 'Horario eliminado exitosamente' });
  } catch (error) {
    console.error('❌ Error en delete horario:', error);
    res.status(500).json({ 
      error: 'Error al eliminar horario',
      details: error.message 
    });
  }
};

// Endpoint para verificar disponibilidad (útil para el frontend)
const verificarDisponibilidad = async (req, res) => {
  try {
    const { id_aula, dia_semana, hora_inicio, hora_fin, id_horario_excluir } = req.body;
    
    const validacion = await verificarCruceHorarios(
      id_aula, 
      dia_semana, 
      hora_inicio, 
      hora_fin, 
      id_horario_excluir
    );
    
    res.json({
      disponible: !validacion.hayCruce,
      mensaje: validacion.error || '✅ Horario disponible',
      conflicto: validacion.horarioConflicto
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

module.exports = {
  getAll,
  getByAula,
  create,
  update,
  delete: delete_,
  verificarDisponibilidad
};
