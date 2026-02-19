import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
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
  bool isGenerating = false;
  String? errorMessage;
  final GlobalKey _qrKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _cargarAulas();
    _solicitarPermisos();
  }

  Future<void> _solicitarPermisos() async {
    if (await Permission.storage.request().isGranted) {
      print('✅ Permiso de almacenamiento concedido');
    }
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
            'bloque': aula['bloque_nombre'] ?? 'Sin bloque',
            'capacidad': aula['capacidad'] ?? 0,
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
    if (aulaSeleccionada == null) return;

    setState(() => isGenerating = true);

    try {
      // Capturar el widget del QR como imagen
      final boundary = _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) throw Exception('No se pudo capturar el QR');

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData?.buffer.asUint8List();

      if (pngBytes == null) throw Exception('Error al generar imagen');

      // Guardar en la galería
      final result = await ImageGallerySaver.saveImage(
        pngBytes,
        quality: 100,
        name: 'aula_qr_${aulaSeleccionada!['codigo']}_${DateTime.now().millisecondsSinceEpoch}.png',
      );

      if (result['isSuccess']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ QR guardado en la galería'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        throw Exception('Error al guardar');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error al guardar: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() => isGenerating = false);
    }
  }

  Future<void> _shareQR() async {
    if (aulaSeleccionada == null) return;

    setState(() => isGenerating = true);

    try {
      // Capturar el widget del QR como imagen
      final boundary = _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) throw Exception('No se pudo capturar el QR');

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData?.buffer.asUint8List();

      if (pngBytes == null) throw Exception('Error al generar imagen');

      // Guardar temporalmente
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/qr_${aulaSeleccionada!['codigo']}.png').create();
      await file.writeAsBytes(pngBytes);

      // Compartir
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Código QR del aula: ${aulaSeleccionada!['nombre']}\nCódigo: ${aulaSeleccionada!['codigo']}',
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error al compartir: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() => isGenerating = false);
    }
  }

  Future<void> _printQR() async {
    if (aulaSeleccionada == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🖨️ Función de impresión en desarrollo'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
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
                      Text(
                        errorMessage!,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _cargarAulas,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1e3c72),
                        ),
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
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.qr_code,
                              size: 60,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'No hay aulas disponibles',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Primero crea algunas aulas',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
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
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...aulas.map((aula) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            elevation: 2,
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
                                  color: const Color(0xFF1e3c72).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.meeting_room, color: Color(0xFF1e3c72), size: 20),
                              ),
                              title: Text(
                                aula['nombre'],
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Bloque: ${aula['bloque']}'),
                                  Text('Código: ${aula['codigo']}'),
                                ],
                              ),
                              trailing: aulaSeleccionada?['id'] == aula['id']
                                  ? Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.check, color: Colors.white, size: 16),
                                    )
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
                                  RepaintBoundary(
                                    key: _qrKey,
                                    child: Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.2),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          QrImageView(
                                            data: aulaSeleccionada!['codigo'],
                                            version: QrVersions.auto,
                                            size: 200,
                                            backgroundColor: Colors.white,
                                            foregroundColor: const Color(0xFF1e3c72),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            aulaSeleccionada!['nombre'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            'Código: ${aulaSeleccionada!['codigo']}',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  if (isGenerating)
                                    const CircularProgressIndicator()
                                  else
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
                                          icon: Icons.share,
                                          label: 'Compartir',
                                          color: Colors.blue,
                                          onPressed: _shareQR,
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
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        minimumSize: const Size(100, 40),
      ),
    );
  }
}