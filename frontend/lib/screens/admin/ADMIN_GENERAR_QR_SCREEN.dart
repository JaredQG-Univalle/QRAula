import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
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

  // 🔴 URL de la landing page
  static const String landingPageUrl = 'https://landing-page-qraula-oeuj.vercel.app/';

  @override
  void initState() {
    super.initState();
    _cargarAulas();
    _solicitarPermisos();
  }

  Future<void> _solicitarPermisos() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  Future<void> _cargarAulas() async {
    if (!mounted) return;
    
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final aulasData = await ApiService.getAulas();
      
      if (mounted) {
        setState(() {
          aulas = aulasData.map<Map<String, dynamic>>((aula) => {
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

  // 🔴 Generar URL para el QR con redirección
  String _generarURLQR(String codigoAula) {
    // Creamos una URL que redirige a la landing page con el código del aula
    // La landing page puede leer este parámetro y mostrar información
    return '$landingPageUrl?codigo=$codigoAula&app=aulaqr';
  }

  // 🔴 Mensaje para compartir
  String _generarMensajeCompartir(Map<String, dynamic> aula) {
    return '''
🏫 *AulaQR - ${aula['nombre']}*

📌 Bloque: ${aula['bloque']}
👥 Capacidad: ${aula['capacidad']} personas

🔍 Escanea este código QR con la app AulaQR para ver el horario completo.

📲 Descarga la app aquí:
$landingPageUrl

Código del aula: ${aula['codigo']}
    ''';
  }

  Future<void> _guardarQR() async {
    if (aulaSeleccionada == null || !mounted) return;

    setState(() => isGenerating = true);

    try {
      final boundary = _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) throw Exception('No se pudo capturar el QR');

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData?.buffer.asUint8List();

      if (pngBytes == null) throw Exception('Error al generar imagen');

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/qr_${aulaSeleccionada!['codigo']}.png');
      await file.writeAsBytes(pngBytes);

      if (!mounted) return;

      await Share.shareXFiles(
        [XFile(file.path)],
        text: _generarMensajeCompartir(aulaSeleccionada!),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ QR generado y listo para compartir'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isGenerating = false);
      }
    }
  }

  Future<void> _compartirQR() async {
    if (aulaSeleccionada == null || !mounted) return;

    setState(() => isGenerating = true);

    try {
      final boundary = _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) throw Exception('No se pudo capturar el QR');

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData?.buffer.asUint8List();

      if (pngBytes == null) throw Exception('Error al generar imagen');

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/qr_${aulaSeleccionada!['codigo']}.png');
      await file.writeAsBytes(pngBytes);

      if (!mounted) return;

      await Share.shareXFiles(
        [XFile(file.path)],
        text: _generarMensajeCompartir(aulaSeleccionada!),
      );

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al compartir: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isGenerating = false);
      }
    }
  }

  Future<void> _imprimirQR() async {
    if (!mounted) return;
    
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
                                  color: const Color(0xFF1e3c72).withValues(alpha: 0.1),
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
                                            color: Colors.grey.withValues(alpha: 0.2),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          // 🔴 AQUÍ ESTÁ EL CAMBIO IMPORTANTE
                                          // El QR ahora contiene la URL de la landing page
                                          QrImageView(
                                            data: _generarURLQR(aulaSeleccionada!['codigo']),
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
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              'Código: ${aulaSeleccionada!['codigo']}',
                                              style: TextStyle(
                                                color: Colors.blue[700],
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[100],
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.info, color: Colors.blue, size: 14),
                                                SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    'Al escanear con cámara normal, redirige a la landing page',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.grey,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ],
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
                                          label: 'Guardar',
                                          color: const Color(0xFF1e3c72),
                                          onPressed: _guardarQR,
                                        ),
                                        _buildActionButton(
                                          icon: Icons.share,
                                          label: 'Compartir',
                                          color: Colors.blue,
                                          onPressed: _compartirQR,
                                        ),
                                        _buildActionButton(
                                          icon: Icons.print,
                                          label: 'Imprimir',
                                          color: Colors.green,
                                          onPressed: _imprimirQR,
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