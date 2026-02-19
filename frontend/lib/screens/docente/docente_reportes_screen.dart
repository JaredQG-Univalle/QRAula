import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class DocenteReportesScreen extends StatefulWidget {
  const DocenteReportesScreen({super.key});

  @override
  State<DocenteReportesScreen> createState() => _DocenteReportesScreenState();
}

class _DocenteReportesScreenState extends State<DocenteReportesScreen> {
  List<dynamic> reportes = [];
  List<dynamic> aulas = [];
  bool isLoading = true;
  String? errorMessage;
  int? idDocente;

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
      // 🔴 CORREGIDO: Usar getMisReportes() en lugar de getReportes()
      final results = await Future.wait([
        ApiService.getAulas(),
        ApiService.getMisReportes(), // ← ESTE ES EL CAMBIO IMPORTANTE
      ]);

      if (mounted) {
        setState(() {
          aulas = results[0];
          reportes = results[1];
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

  String _getNombreAula(int? idAula) {
    try {
      final aula = aulas.firstWhere((a) => a['id_aula'] == idAula, orElse: () => null);
      return aula?['nombre'] ?? 'Aula desconocida';
    } catch (e) {
      return 'Aula desconocida';
    }
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'Pendiente':
        return Colors.red;
      case 'En Proceso':
        return Colors.orange;
      case 'Resuelto':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getEstadoIcon(String estado) {
    switch (estado) {
      case 'Pendiente':
        return Icons.pending_actions;
      case 'En Proceso':
        return Icons.autorenew;
      case 'Resuelto':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  String _getEstadoText(String estado) {
    switch (estado) {
      case 'Pendiente':
        return 'Pendiente';
      case 'En Proceso':
        return 'En Proceso';
      case 'Resuelto':
        return 'Resuelto';
      default:
        return 'Desconocido';
    }
  }

  Future<void> _showCrearReporteDialog() async {
    final formKey = GlobalKey<FormState>();
    final descripcionController = TextEditingController();
    String? idAulaSeleccionada;
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
          title: const Text('Nuevo Reporte Técnico'),
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
                      prefixIcon: Icon(Icons.meeting_room),
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
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descripcionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción del problema *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                      hintText: 'Ej: Proyector no enciende, Silla rota, Aire acondicionado no funciona...',
                      alignLabelWithHint: true,
                    ),
                    maxLines: 5,
                    validator: (value) {
                      if (value?.isEmpty == true) return 'Campo requerido';
                      if (value!.length < 10) return 'Describe el problema con más detalle (mínimo 10 caracteres)';
                      return null;
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

                        final reporteData = {
                          'id_aula': int.parse(idAulaSeleccionada!),
                          'descripcion': descripcionController.text,
                        };

                        final result = await ApiService.createReporte(reporteData);

                        setState(() => isLoading = false);

                        if (result['success'] == true) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✅ Reporte enviado exitosamente'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 3),
                            ),
                          );
                          _cargarDatos(); // Recargar lista
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('❌ ${result['error'] ?? 'Error al enviar'}'),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      }
                    },
              child: const Text('Enviar Reporte'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Mis Reportes Técnicos'),
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1e3c72),
                        ),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : reportes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.report_problem,
                              size: 60,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'No hay reportes',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Reporta problemas técnicos usando el botón +',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton.icon(
                            onPressed: _showCrearReporteDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('Nuevo Reporte'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1e3c72),
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: reportes.length,
                      itemBuilder: (context, index) {
                        final reporte = reportes[index];
                        final colorEstado = _getEstadoColor(reporte['estado'] ?? 'Pendiente');
                        
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
                                color: colorEstado.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _getEstadoIcon(reporte['estado'] ?? 'Pendiente'),
                                color: colorEstado,
                                size: 24,
                              ),
                            ),
                            title: Text(
                              'Aula: ${_getNombreAula(reporte['id_aula'])}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorEstado.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _getEstadoText(reporte['estado'] ?? 'Pendiente'),
                                    style: TextStyle(
                                      color: colorEstado,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Fecha: ${_formatFecha(reporte['fecha_reporte'])}',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                ),
                              ],
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '📝 Descripción del problema:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1e3c72),
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.grey[300]!),
                                      ),
                                      child: Text(
                                        reporte['descripcion'] ?? '',
                                        style: const TextStyle(
                                          height: 1.5,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCrearReporteDialog,
        backgroundColor: const Color(0xFF1e3c72),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Reporte'),
      ),
    );
  }

  String _formatFecha(String? fecha) {
    if (fecha == null) return '';
    try {
      final datetime = DateTime.parse(fecha);
      return '${datetime.day}/${datetime.month}/${datetime.year} ${datetime.hour}:${datetime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return fecha;
    }
  }
}