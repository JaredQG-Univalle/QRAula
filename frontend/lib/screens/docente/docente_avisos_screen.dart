import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class DocenteAvisosScreen extends StatefulWidget {
  const DocenteAvisosScreen({super.key});

  @override
  State<DocenteAvisosScreen> createState() => _DocenteAvisosScreenState();
}

class _DocenteAvisosScreenState extends State<DocenteAvisosScreen> {
  List<dynamic> avisos = [];
  List<dynamic> aulas = [];
  bool isLoading = true;
  String? errorMessage;
  int? idDocente;

  @override
  void initState() {
    super.initState();
    _cargarDatosIniciales();
  }

  Future<void> _cargarDatosIniciales() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Cargar aulas y avisos en paralelo
      final results = await Future.wait([
        ApiService.getAulas(),
        ApiService.getAvisos(), // ⚠️ NECESITAMOS CREAR ESTE MÉTODO
      ]);

      if (mounted) {
        setState(() {
          aulas = results[0];
          avisos = results[1];
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'Error al cargar datos: $e';
        });
      }
    }
  }

  String _getNombreAula(int? idAula) {
    try {
      final aula = aulas.firstWhere((a) => a['id_aula'] == idAula, orElse: () => null);
      return aula?['nombre'] ?? 'Aula desconocida';
    } catch (e) {
      return 'Aula desconocida';
    }
  }

  Future<void> _showCrearAvisoDialog() async {
    final formKey = GlobalKey<FormState>();
    final tituloController = TextEditingController();
    final contenidoController = TextEditingController();
    String? idAulaSeleccionada;
    DateTime? fechaExpiracion;
    bool isLoading = false;

    // Recargar aulas si es necesario
    if (aulas.isEmpty) {
      final aulasData = await ApiService.getAulas();
      if (mounted) {
        setState(() {
          aulas = aulasData;
        });
      }
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Nuevo Aviso'),
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
                        child: Text(aula['nombre']),
                      );
                    }).toList(),
                    onChanged: (value) => idAulaSeleccionada = value,
                    validator: (value) => value == null ? 'Selecciona un aula' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: tituloController,
                    decoration: const InputDecoration(
                      labelText: 'Título *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (value) => value?.isEmpty == true ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: contenidoController,
                    decoration: const InputDecoration(
                      labelText: 'Contenido *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 4,
                    validator: (value) => value?.isEmpty == true ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    title: Text(
                      fechaExpiracion == null 
                          ? 'Fecha de expiración (opcional)' 
                          : 'Expira: ${_formatFecha(fechaExpiracion.toString())}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 7)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() => fechaExpiracion = date);
                      }
                    },
                  ),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.all(16),
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
              onPressed: isLoading
                  ? null
                  : () async {
                      if (formKey.currentState!.validate()) {
                        setState(() => isLoading = true);

                        final avisoData = {
                          'id_aula': int.parse(idAulaSeleccionada!),
                          'titulo': tituloController.text,
                          'contenido': contenidoController.text,
                          if (fechaExpiracion != null)
                            'fecha_expiracion': fechaExpiracion!.toIso8601String(),
                        };

                        final result = await ApiService.createAviso(avisoData);

                        setState(() => isLoading = false);

                        if (result['success'] == true) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✅ Aviso creado exitosamente'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          _cargarDatosIniciales(); // Recargar lista
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
              child: const Text('Publicar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _eliminarAviso(int id, String titulo) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar'),
        content: Text('¿Eliminar el aviso "$titulo"?'),
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
      final success = await ApiService.deleteAviso(id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Aviso eliminado'),
            backgroundColor: Colors.green,
          ),
        );
        _cargarDatosIniciales(); // Recargar lista
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
        title: const Text('Mis Avisos'),
        backgroundColor: const Color(0xFF1e3c72),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarDatosIniciales,
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
                      Text(errorMessage!),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _cargarDatosIniciales,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : avisos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.warning, size: 80, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No hay avisos',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Crea tu primer aviso usando el botón +',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton.icon(
                            onPressed: _showCrearAvisoDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('Crear Aviso'),
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
                      itemCount: avisos.length,
                      itemBuilder: (context, index) {
                        final aviso = avisos[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ExpansionTile(
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.warning,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            title: Text(
                              aviso['titulo'] ?? 'Sin título',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Aula: ${_getNombreAula(aviso['id_aula'])}',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                ),
                                Text(
                                  'Publicado: ${_formatFecha(aviso['fecha_publicacion'])}',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton(
                              icon: const Icon(Icons.more_vert),
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Eliminar'),
                                    ],
                                  ),
                                ),
                              ],
                              onSelected: (value) {
                                if (value == 'delete') {
                                  _eliminarAviso(aviso['id_aviso'], aviso['titulo']);
                                }
                              },
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        aviso['contenido'] ?? '',
                                        style: const TextStyle(height: 1.5),
                                      ),
                                    ),
                                    if (aviso['fecha_expiracion'] != null) ...[
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          const Icon(Icons.access_time, size: 16, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Expira: ${_formatFecha(aviso['fecha_expiracion'])}',
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCrearAvisoDialog,
        backgroundColor: const Color(0xFF1e3c72),
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatFecha(String? fecha) {
    if (fecha == null) return '';
    try {
      final datetime = DateTime.parse(fecha);
      return '${datetime.day}/${datetime.month}/${datetime.year}';
    } catch (e) {
      return fecha;
    }
  }
}