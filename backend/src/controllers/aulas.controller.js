const aulasService = require('../services/aulas.service');

const getAll = async (req, res) => {
  try {
    const aulas = await aulasService.getAll();
    res.json(aulas);
  } catch (error) {
    console.error('❌ Error en getAll:', error);
    res.status(500).json({ error: 'Error al obtener aulas: ' + error.message });
  }
};

const getById = async (req, res) => {
  try {
    const aula = await aulasService.getById(req.params.id);
    if (!aula) {
      return res.status(404).json({ error: 'Aula no encontrada' });
    }
    res.json(aula);
  } catch (error) {
    console.error('❌ Error en getById:', error);
    res.status(500).json({ error: 'Error al obtener aula' });
  }
};

const getByQR = async (req, res) => {
  try {
    console.log('🔍 Buscando aula por QR:', req.params.codigo);
    const aula = await aulasService.getByQR(req.params.codigo);
    
    if (!aula) {
      return res.status(404).json({ error: 'Aula no encontrada' });
    }
    
    res.json(aula);
  } catch (error) {
    console.error('❌ Error en getByQR:', error);
    res.status(500).json({ error: 'Error al obtener aula' });
  }
};

// 🔴 CORREGIR CREATE
const create = async (req, res) => {
  try {
    console.log('📝 Creando aula con datos:', req.body);
    
    const { id_bloque, codigo_qr, nombre, capacidad, equipamiento, estado, latitud, longitud } = req.body;
    
    // Validar campos requeridos
    if (!id_bloque || !codigo_qr || !nombre || !capacidad) {
      return res.status(400).json({ 
        error: 'Faltan campos requeridos',
        required: ['id_bloque', 'codigo_qr', 'nombre', 'capacidad']
      });
    }

    const id = await aulasService.create({
      id_bloque,
      codigo_qr,
      nombre,
      capacidad,
      equipamiento: equipamiento || '',
      estado: estado || 'Disponible',
      latitud: latitud || null,
      longitud: longitud || null
    });
    
    res.status(201).json({ 
      id, 
      message: 'Aula creada exitosamente' 
    });
  } catch (error) {
    console.error('❌ Error en create:', error);
    res.status(500).json({ 
      error: 'Error al crear aula',
      details: error.message 
    });
  }
};

// 🔴 CORREGIR UPDATE
const update = async (req, res) => {
  try {
    console.log('📝 Actualizando aula ID:', req.params.id, 'con datos:', req.body);
    
    const { id_bloque, nombre, capacidad, equipamiento, estado, latitud, longitud } = req.body;
    
    const updated = await aulasService.update(req.params.id, {
      id_bloque,
      nombre,
      capacidad,
      equipamiento,
      estado,
      latitud,
      longitud
    });
    
    if (!updated) {
      return res.status(404).json({ error: 'Aula no encontrada' });
    }
    
    res.json({ message: 'Aula actualizada exitosamente' });
  } catch (error) {
    console.error('❌ Error en update:', error);
    res.status(500).json({ 
      error: 'Error al actualizar aula',
      details: error.message 
    });
  }
};

// 🔴 CORREGIR DELETE
const delete_ = async (req, res) => {
  try {
    console.log('🗑️ Eliminando aula ID:', req.params.id);
    
    // Verificar si el aula existe
    const aula = await aulasService.getById(req.params.id);
    if (!aula) {
      return res.status(404).json({ error: 'Aula no encontrada' });
    }

    const deleted = await aulasService.delete(req.params.id);
    
    if (!deleted) {
      return res.status(404).json({ error: 'No se pudo eliminar el aula' });
    }
    
    res.json({ message: 'Aula eliminada exitosamente' });
  } catch (error) {
    console.error('❌ Error en delete:', error);
    
    // Si es error de clave foránea
    if (error.code === 'ER_ROW_IS_REFERENCED_2') {
      return res.status(400).json({ 
        error: 'No se puede eliminar porque tiene horarios o reportes asociados' 
      });
    }
    
    res.status(500).json({ 
      error: 'Error al eliminar aula',
      details: error.message 
    });
  }
};

const updateEstado = async (req, res) => {
  try {
    const { estado } = req.body;
    if (!['Disponible', 'Mantenimiento', 'Cerrada'].includes(estado)) {
      return res.status(400).json({ error: 'Estado inválido' });
    }

    const updated = await aulasService.updateEstado(req.params.id, estado);
    if (!updated) {
      return res.status(404).json({ error: 'Aula no encontrada' });
    }
    res.json({ message: 'Estado actualizado exitosamente' });
  } catch (error) {
    console.error('❌ Error en updateEstado:', error);
    res.status(500).json({ error: 'Error al actualizar estado' });
  }
};

module.exports = {
  getAll,
  getById,
  getByQR,
  create,
  update,
  delete: delete_,
  updateEstado
};