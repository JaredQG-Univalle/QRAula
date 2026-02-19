import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../services/api_service.dart';

class AdminGenerarQRScreen extends StatefulWidget {
  const AdminGenerarQRScreen({super.key});

  @override
  State<AdminGenerarQRScreen> createState() => _AdminGenerarQRScreenState();
}

class _AdminGenerarQRScreenState extends State<AdminGenerarQRScreen> {
  List<Map<String, dynamic>> aulas = [];
  Map<String, dynamic>? aulaSeleccionada;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _cargarAulas();
  }

  Future<void> _cargarAulas() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final aulasData = await ApiService.getAulas();
      
      if (mounted) {
        setState(() {
          aulas = aulasData.map((aula) => {
            'id': aula['id_aula'],
            'nombre': aula['nombre'],
            'codigo': aula['codigo_qr'],
          }).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'Error al cargar aulas: $e';
        });
      }
    }
  }

  Future<void> _downloadQR() async {
    // TODO: Implementar descarga real
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ QR de ${aulaSeleccionada!['nombre']} guardado'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _printQR() async {
    // TODO: Implementar impresión real
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🖨️ Enviando QR a impresión...'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Generar Códigos QR'),
        backgroundColor: const Color(0xFF1e3c72),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarAulas,
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
                        onPressed: _cargarAulas,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : aulas.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.qr_code, size: 80, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No hay aulas disponibles',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Primero crea algunas aulas',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Selecciona un aula',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...aulas.map((aula) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: aulaSeleccionada?['id'] == aula['id']
                                  ? const BorderSide(color: Color(0xFF1e3c72), width: 2)
                                  : BorderSide.none,
                            ),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1e3c72).withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.meeting_room, color: Color(0xFF1e3c72)),
                              ),
                              title: Text(
                                aula['nombre'],
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text('Código: ${aula['codigo']}'),
                              trailing: aulaSeleccionada?['id'] == aula['id']
                                  ? const Icon(Icons.check_circle, color: Colors.green)
                                  : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
                              onTap: () {
                                setState(() {
                                  aulaSeleccionada = aula;
                                });
                              },
                            ),
                          )),
                          
                          if (aulaSeleccionada != null) ...[
                            const SizedBox(height: 24),
                            const Divider(),
                            const SizedBox(height: 16),
                            
                            Center(
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withValues(alpha: 0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: QrImageView(
                                      data: aulaSeleccionada!['codigo'],
                                      version: QrVersions.auto,
                                      size: 250,
                                      backgroundColor: Colors.white,
                                      foregroundColor: const Color(0xFF1e3c72),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    aulaSeleccionada!['nombre'],
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2C3E50),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1e3c72).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'Código: ${aulaSeleccionada!['codigo']}',
                                      style: const TextStyle(
                                        color: Color(0xFF1e3c72),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildActionButton(
                                        icon: Icons.download,
                                        label: 'Descargar',
                                        color: const Color(0xFF1e3c72),
                                        onPressed: _downloadQR,
                                      ),
                                      _buildActionButton(
                                        icon: Icons.print,
                                        label: 'Imprimir',
                                        color: Colors.green,
                                        onPressed: _printQR,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}