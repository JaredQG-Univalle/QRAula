import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AdminReportesScreen extends StatefulWidget {
  const AdminReportesScreen({super.key});

  @override
  State<AdminReportesScreen> createState() => _AdminReportesScreenState();
}

class _AdminReportesScreenState extends State<AdminReportesScreen> {
  List<dynamic> reportes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarReportes();
  }

  Future<void> _cargarReportes() async {
    setState(() => isLoading = true);
    
    final data = await ApiService.getReportes();
    
    if (mounted) {
      setState(() {
        reportes = data;
        isLoading = false;
      });
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
        return Icons.pending;
      case 'En Proceso':
        return Icons.autorenew;
      case 'Resuelto':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  Future<void> _cambiarEstado(int id, String nuevoEstado) async {
    final success = await ApiService.updateEstadoReporte(id, nuevoEstado);
    if (success) {
      _cargarReportes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Reportes Técnicos'),
        backgroundColor: const Color(0xFF1e3c72),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : reportes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, size: 80, color: Colors.green[300]),
                      const SizedBox(height: 16),
                      Text(
                        'No hay reportes pendientes',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: reportes.length,
                  itemBuilder: (context, index) {
                    final reporte = reportes[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: _getEstadoColor(reporte['estado']).withOpacity(0.2),
                          child: Icon(
                            _getEstadoIcon(reporte['estado']),
                            color: _getEstadoColor(reporte['estado']),
                            size: 20,
                          ),
                        ),
                        title: Text(
                          reporte['aula_nombre'] ?? 'Aula',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Reportado por: ${reporte['usuario_nombre'] ?? ''}'),
                            Text('Fecha: ${_formatFecha(reporte['fecha_reporte'])}'),
                          ],
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
                                  child: Text(reporte['descripcion'] ?? ''),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Cambiar estado:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildEstadoButton(
                                      'Pendiente',
                                      reporte['estado'] == 'Pendiente',
                                      Colors.red,
                                      () => _cambiarEstado(reporte['id_reporte'], 'Pendiente'),
                                    ),
                                    _buildEstadoButton(
                                      'En Proceso',
                                      reporte['estado'] == 'En Proceso',
                                      Colors.orange,
                                      () => _cambiarEstado(reporte['id_reporte'], 'En Proceso'),
                                    ),
                                    _buildEstadoButton(
                                      'Resuelto',
                                      reporte['estado'] == 'Resuelto',
                                      Colors.green,
                                      () => _cambiarEstado(reporte['id_reporte'], 'Resuelto'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildEstadoButton(String texto, bool isActive, Color color, VoidCallback onTap) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: isActive ? color : color.withOpacity(0.2),
            foregroundColor: isActive ? Colors.white : color,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
          child: Text(
            texto,
            style: const TextStyle(fontSize: 11),
          ),
        ),
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