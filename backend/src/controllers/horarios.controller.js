const db = require('../config/db');

// Función para verificar si hay cruce de horarios
const verificarCruceHorarios = async (id_aula, dia_semana, hora_inicio, hora_fin, id_horario_excluir = null) => {
  console.log('🔍 Verificando cruce de horarios:', { id_aula, dia_semana, hora_inicio, hora_fin });

  // Validar formato de hora (HH:MM o HH:MM:SS)
  const horaRegex = /^([0-1]?[0-9]|2[0-3]):[0-5][0-9](:[0-5][0-9])?$/;
  if (!horaRegex.test(hora_inicio) || !horaRegex.test(hora_fin)) {
    return {
      hayCruce: true,
      error: 'Formato de hora inválido. Use HH:MM (ej: 08:30)'
    };
  }

  // Normalizar horas a formato HH:MM (sin segundos) para comparación
  const normalizarHora = (hora) => {
    return hora.length >= 5 ? hora.substring(0, 5) : hora;
  };

  const horaInicioNorm = normalizarHora(hora_inicio);
  const horaFinNorm = normalizarHora(hora_fin);

  // Convertir horas a minutos para comparar
  const [horaInicioH, horaInicioM] = horaInicioNorm.split(':').map(Number);
  const [horaFinH, horaFinM] = horaFinNorm.split(':').map(Number);
  
  const inicioMinutos = horaInicioH * 60 + horaInicioM;
  const finMinutos = horaFinH * 60 + horaFinM;

  // Verificar que hora fin sea mayor que hora inicio
  if (finMinutos <= inicioMinutos) {
    return {
      hayCruce: true,
      error: '⏰ La hora de fin debe ser mayor a la hora de inicio'
    };
  }

  // Verificar que el bloque horario sea válido (opcional - puedes comentar si quieres permitir cualquier hora)
  const bloquesValidos = [
    '08:35-09:25', '09:25-10:15', '10:25-11:15', '11:15-12:05',
    '12:15-13:05', '13:05-13:55', '14:05-14:55', '14:55-15:45',
    '15:45-16:35', '16:45-17:35', '17:35-18:25', '18:30-19:20',
    '19:20-20:10', '20:10-21:00', '21:00-21:50'
  ];
  
  const bloqueActual = `${horaInicioNorm}-${horaFinNorm}`;
  if (!bloquesValidos.includes(bloqueActual)) {
    console.log('⚠️ Bloque horario no estándar:', bloqueActual);
    // Comentado para permitir cualquier bloque - descomenta si quieres restringir
    // return {
    //   hayCruce: true,
    //   error: 'El bloque horario no es válido. Use los horarios predefinidos'
    // };
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

  console.log(`📊 Horarios existentes en aula ${id_aula} el ${dia_semana}: ${horariosExistentes.length}`);

  // Si no hay horarios existentes, está libre
  if (horariosExistentes.length === 0) {
    console.log('✅ No hay horarios en este día - completamente libre');
    return { hayCruce: false };
  }

  // Verificar cada horario existente
  for (const horario of horariosExistentes) {
    const horaExistenteInicio = horario.hora_inicio.substring(0, 5);
    const horaExistenteFin = horario.hora_fin.substring(0, 5);
    
    const [existenteInicioH, existenteInicioM] = horaExistenteInicio.split(':').map(Number);
    const [existenteFinH, existenteFinM] = horaExistenteFin.split(':').map(Number);
    
    const existenteInicioMinutos = existenteInicioH * 60 + existenteInicioM;
    const existenteFinMinutos = existenteFinH * 60 + existenteFinM;

    console.log(`   Comparando con: ${horaExistenteInicio} - ${horaExistenteFin}`);

    // 🔴 CASO 1: Mismo horario exacto
    if (horaExistenteInicio === horaInicioNorm && horaExistenteFin === horaFinNorm) {
      console.log(`❌ Conflicto: Mismo horario exacto`);
      return {
        hayCruce: true,
        error: `❌ Ya existe un horario exactamente igual (${horaInicioNorm} - ${horaFinNorm}) en este día`,
        horarioConflicto: horario
      };
    }

    // Caso 2: El nuevo horario empieza durante uno existente
    if (inicioMinutos >= existenteInicioMinutos && inicioMinutos < existenteFinMinutos) {
      console.log(`❌ Conflicto: Empieza durante clase existente`);
      return {
        hayCruce: true,
        error: `❌ El horario (${horaInicioNorm} - ${horaFinNorm}) se cruza con ${horario.materia_nombre || 'clase'} (${horaExistenteInicio} - ${horaExistenteFin})`,
        horarioConflicto: horario
      };
    }

    // Caso 3: El nuevo horario termina durante uno existente
    if (finMinutos > existenteInicioMinutos && finMinutos <= existenteFinMinutos) {
      console.log(`❌ Conflicto: Termina durante clase existente`);
      return {
        hayCruce: true,
        error: `❌ El horario (${horaInicioNorm} - ${horaFinNorm}) se cruza con ${horario.materia_nombre || 'clase'} (${horaExistenteInicio} - ${horaExistenteFin})`,
        horarioConflicto: horario
      };
    }

    // Caso 4: El nuevo horario contiene completamente a uno existente
    if (inicioMinutos <= existenteInicioMinutos && finMinutos >= existenteFinMinutos) {
      console.log(`❌ Conflicto: Cubre completamente clase existente`);
      return {
        hayCruce: true,
        error: `❌ El horario (${horaInicioNorm} - ${horaFinNorm}) cubre completamente ${horario.materia_nombre || 'clase'} (${horaExistenteInicio} - ${horaExistenteFin})`,
        horarioConflicto: horario
      };
    }
  }

  console.log('✅ Horario disponible - sin conflictos');
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
      console.log('❌ Conflicto detectado:', validacion.error);
      return res.status(409).json({
        error: 'Conflicto de horarios',
        message: validacion.error,
        conflicto: validacion.horarioConflicto
      });
    }

    // Si no hay cruce, proceder a crear
    // Asegurar formato de hora con segundos para la BD
    const formatearHoraParaBD = (hora) => {
      if (hora.length === 5) return `${hora}:00`;
      return hora;
    };

    const [result] = await db.query(
      `INSERT INTO horarios (id_aula, id_materia, id_usuario, dia_semana, hora_inicio, hora_fin) 
       VALUES (?, ?, ?, ?, ?, ?)`,
      [
        id_aula, 
        id_materia, 
        id_usuario, 
        dia_semana, 
        formatearHoraParaBD(hora_inicio), 
        formatearHoraParaBD(hora_fin)
      ]
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

    console.log('✅ Horario creado exitosamente con ID:', result.insertId);
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
      req.params.id
    );
    
    if (validacion.hayCruce) {
      return res.status(409).json({
        error: 'Conflicto de horarios',
        message: validacion.error,
        conflicto: validacion.horarioConflicto
      });
    }

    // Si no hay cruce, proceder a actualizar
    const formatearHoraParaBD = (hora) => {
      if (hora.length === 5) return `${hora}:00`;
      return hora;
    };

    const [result] = await db.query(
      `UPDATE horarios 
       SET id_aula = ?, id_materia = ?, id_usuario = ?, dia_semana = ?, hora_inicio = ?, hora_fin = ? 
       WHERE id_horario = ?`,
      [
        id_aula, 
        id_materia, 
        id_usuario, 
        dia_semana, 
        formatearHoraParaBD(hora_inicio), 
        formatearHoraParaBD(hora_fin), 
        req.params.id
      ]
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

// Endpoint para verificar disponibilidad
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
    console.error('❌ Error en verificarDisponibilidad:', error);
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
