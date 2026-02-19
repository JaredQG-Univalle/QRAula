import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AdminHorariosScreen extends StatefulWidget {
  const AdminHorariosScreen({super.key});

  @override
  State<AdminHorariosScreen> createState() => _AdminHorariosScreenState();
}

class _AdminHorariosScreenState extends State<AdminHorariosScreen> {
  List<dynamic> horarios = [];
  List<dynamic> aulas = [];
  List<dynamic> materias = [];
  List<dynamic> docentes = [];
  bool isLoading = true;
  String? errorMessage;

  final List<String> dias = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    
    try {
      final results = await Future.wait([
        ApiService.getHorarios(),
        ApiService.getAulas(),
        ApiService.getMaterias(),
        ApiService.getDocentes(),
      ]);

      if (mounted) {
        setState(() {
          horarios = results[0];
          aulas = results[1];
          materias = results[2];
          docentes = results[3];
          isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error cargando datos: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'Error al cargar datos: $e';
        });
      }
    }
  }

  String _getNombreAula(int? id) {
    try {
      final aula = aulas.firstWhere((a) => a['id_aula'] == id, orElse: () => null);
      return aula?['nombre'] ?? 'N/A';
    } catch (e) {
      return 'N/A';
    }
  }

  String _formatHora(String? hora) {
    if (hora == null || hora.isEmpty) return '--:--';
    return hora.length >= 5 ? hora.substring(0, 5) : hora;
  }

  Color _getDiaColor(String dia) {
    switch (dia) {
      case 'Lunes': return Colors.blue;
      case 'Martes': return Colors.green;
      case 'Miércoles': return Colors.orange;
      case 'Jueves': return Colors.purple;
      case 'Viernes': return Colors.teal;
      case 'Sábado': return Colors.brown;
      default: return Colors.grey;
    }
  }

  Future<void> _showCrearHorarioDialog() async {
    final formKey = GlobalKey<FormState>();
    
    String? idAulaSeleccionada;
    String? idMateriaSeleccionada;
    String? idDocenteSeleccionado;
    String? diaSeleccionado;
    TimeOfDay? horaInicio;
    TimeOfDay? horaFin;
    bool verificando = false;

    if (aulas.isEmpty || materias.isEmpty || docentes.isEmpty) {
      await _cargarDatos();
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Nuevo Horario'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Aula *',
                      border: OutlineInputBorder(),
                    ),
                    value: idAulaSeleccionada,
                    items: aulas.map((aula) {
                      return DropdownMenuItem(
                        value: aula['id_aula'].toString(),
                        child: Text('${aula['nombre']} (Cap. ${aula['capacidad']})'),
                      );
                    }).toList(),
                    onChanged: (value) => idAulaSeleccionada = value,
                    validator: (value) => value == null ? 'Selecciona un aula' : null,
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Materia *',
                      border: OutlineInputBorder(),
                    ),
                    value: idMateriaSeleccionada,
                    items: materias.map((materia) {
                      return DropdownMenuItem(
                        value: materia['id_materia'].toString(),
                        child: Text(materia['nombre']),
                      );
                    }).toList(),
                    onChanged: (value) => idMateriaSeleccionada = value,
                    validator: (value) => value == null ? 'Selecciona una materia' : null,
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Docente *',
                      border: OutlineInputBorder(),
                    ),
                    value: idDocenteSeleccionado,
                    items: docentes.map((docente) {
                      return DropdownMenuItem(
                        value: docente['id_usuario'].toString(),
                        child: Text('${docente['nombre']} ${docente['apellido']}'),
                      );
                    }).toList(),
                    onChanged: (value) => idDocenteSeleccionado = value,
                    validator: (value) => value == null ? 'Selecciona un docente' : null,
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Día *',
                      border: OutlineInputBorder(),
                    ),
                    value: diaSeleccionado,
                    items: dias.map((dia) {
                      return DropdownMenuItem(
                        value: dia,
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _getDiaColor(dia),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(dia),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) => diaSeleccionado = value,
                    validator: (value) => value == null ? 'Selecciona un día' : null,
                  ),
                  const SizedBox(height: 12),

                  InkWell(
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() => horaInicio = time);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Hora inicio *',
                        border: OutlineInputBorder(),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(horaInicio?.format(context) ?? 'Seleccionar hora'),
                          const Icon(Icons.access_time),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  InkWell(
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() => horaFin = time);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Hora fin *',
                        border: OutlineInputBorder(),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(horaFin?.format(context) ?? 'Seleccionar hora'),
                          const Icon(Icons.access_time),
                        ],
                      ),
                    ),
                  ),

                  if (verificando)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: verificando
                  ? null
                  : () async {
                      if (formKey.currentState!.validate() && horaInicio != null && horaFin != null) {
                        setState(() => verificando = true);

                        // Verificar disponibilidad primero
                        final disponibilidad = await ApiService.verificarDisponibilidadHorario(
                          idAula: int.parse(idAulaSeleccionada!),
                          diaSemana: diaSeleccionado!,
                          horaInicio: '${horaInicio!.hour.toString().padLeft(2, '0')}:${horaInicio!.minute.toString().padLeft(2, '0')}:00',
                          horaFin: '${horaFin!.hour.toString().padLeft(2, '0')}:${horaFin!.minute.toString().padLeft(2, '0')}:00',
                        );

                        setState(() => verificando = false);

                        if (!disponibilidad['disponible']) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('❌ ${disponibilidad['mensaje']}'),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                          return;
                        }

                        Navigator.pop(context);

                        final horarioData = {
                          'id_aula': int.parse(idAulaSeleccionada!),
                          'id_materia': int.parse(idMateriaSeleccionada!),
                          'id_usuario': int.parse(idDocenteSeleccionado!),
                          'dia_semana': diaSeleccionado,
                          'hora_inicio': '${horaInicio!.hour.toString().padLeft(2, '0')}:${horaInicio!.minute.toString().padLeft(2, '0')}:00',
                          'hora_fin': '${horaFin!.hour.toString().padLeft(2, '0')}:${horaFin!.minute.toString().padLeft(2, '0')}:00',
                        };

                        final result = await ApiService.createHorario(horarioData);

                        if (result['success'] == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✅ Horario creado exitosamente'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          _cargarDatos();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('❌ ${result['error'] ?? 'Error al crear'}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              child: const Text('Crear'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _eliminarHorario(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar'),
        content: const Text('¿Estás seguro de eliminar este horario?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      final success = await ApiService.deleteHorario(id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Horario eliminado'),
            backgroundColor: Colors.green,
          ),
        );
        _cargarDatos();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Error al eliminar'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Gestión de Horarios'),
        backgroundColor: const Color(0xFF1e3c72),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarDatos,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage!,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _cargarDatos,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : horarios.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.schedule, size: 80, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No hay horarios registrados',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Crea tu primer horario usando el botón +',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton.icon(
                            onPressed: _showCrearHorarioDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('Crear Horario'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1e3c72),
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: horarios.length,
                      itemBuilder: (context, index) {
                        final horario = horarios[index];
                        final colorDia = _getDiaColor(horario['dia_semana'] ?? '');
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: colorDia.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  horario['dia_semana']?[0] ?? '?',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: colorDia,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              horario['materia_nombre'] ?? 'Sin materia',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.meeting_room, size: 14, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(
                                      _getNombreAula(horario['id_aula']),
                                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.person, size: 14, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        horario['docente_nombre'] ?? 'Sin docente',
                                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${_formatHora(horario['hora_inicio'])} - ${_formatHora(horario['hora_fin'])}',
                                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            isThreeLine: true,
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _eliminarHorario(horario['id_horario']),
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCrearHorarioDialog,
        backgroundColor: const Color(0xFF1e3c72),
        child: const Icon(Icons.add),
      ),
    );
  }
}