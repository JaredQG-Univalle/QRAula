import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/horario_tabla_widget.dart';
import '../login_screen.dart';

class AulaInfoScreen extends StatefulWidget {
  final String codigoQR;

  const AulaInfoScreen({super.key, required this.codigoQR});

  @override
  State<AulaInfoScreen> createState() => _AulaInfoScreenState();
}

class _AulaInfoScreenState extends State<AulaInfoScreen> with SingleTickerProviderStateMixin {
  Map<String, dynamic> aulaInfo = {};
  List<dynamic> horarios = [];
  List<dynamic> avisos = [];
  bool isLoading = true;
  String? error;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _cargarInfo();
  }

  Future<void> _cargarInfo() async {
    try {
      // Obtener info del aula por QR
      final info = await ApiService.getAulaInfo(widget.codigoQR);
      
      if (!mounted) return;

      if (info.containsKey('error')) {
        setState(() {
          error = info['error'];
          isLoading = false;
        });
        return;
      }

      // Obtener horarios y avisos
      final horariosData = await ApiService.getHorariosAula(info['id_aula']);
      final avisosData = await ApiService.getAvisosAula(info['id_aula']);

      if (!mounted) return;

      setState(() {
        aulaInfo = info;
        horarios = horariosData;
        avisos = avisosData;
        isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() {
        error = 'Error al cargar datos: $e';
        isLoading = false;
      });
    }
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'Disponible':
        return Colors.green;
      case 'Mantenimiento':
        return Colors.orange;
      case 'Cerrada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          aulaInfo['nombre'] ?? 'Información del Aula',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1e3c72),
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4158D0), Color(0xFFC850C0)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              icon: const Icon(Icons.login, color: Colors.white, size: 16),
              label: const Text(
                'Acceso',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(error!, style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1e3c72),
                        ),
                        child: const Text('Volver'),
                      ),
                    ],
                  ),
                )
              : FadeTransition(
                  opacity: _animationController,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Header del aula
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF1e3c72), Color(0xFF2a5298)],
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _getEstadoColor(aulaInfo['estado'] ?? 'Disponible').withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  aulaInfo['estado'] ?? 'Disponible',
                                  style: TextStyle(
                                    color: _getEstadoColor(aulaInfo['estado'] ?? 'Disponible'),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                aulaInfo['nombre'] ?? 'Aula',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                aulaInfo['bloque_nombre'] ?? 'Bloque Principal',
                                style: const TextStyle(color: Colors.white70, fontSize: 16),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Información rápida
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildInfoCard(
                                  icon: Icons.people,
                                  title: 'Capacidad',
                                  value: '${aulaInfo['capacidad'] ?? 0}',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildInfoCard(
                                  icon: Icons.build,
                                  title: 'Equipamiento',
                                  value: 'Ver detalles',
                                  onTap: () => _showEquipamientoDialog(aulaInfo['equipamiento']),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // HORARIO COMPLETO
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.schedule, color: Color(0xFF1e3c72)),
                                  SizedBox(width: 8),
                                  Text(
                                    'Horario Semanal',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              HorarioTablaWidget(horarios: horarios),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Avisos
                        if (avisos.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.warning, color: Colors.orange),
                                    SizedBox(width: 8),
                                    Text(
                                      'Avisos',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                ...avisos.map((aviso) => _buildAvisoCard(aviso)).toList(),
                              ],
                            ),
                          ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF1e3c72), size: 30),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildAvisoCard(Map<String, dynamic> aviso) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  aviso['titulo'] ?? 'Aviso',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  aviso['contenido'] ?? '',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEquipamientoDialog(String? equipamiento) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Equipamiento'),
        content: Text(equipamiento ?? 'No especificado'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}