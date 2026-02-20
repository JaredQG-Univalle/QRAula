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
      print('🔍 Escaneando QR: ${widget.codigoQR}');
      
      final info = await ApiService.getAulaInfo(widget.codigoQR);
      
      if (!mounted) return;

      if (info.containsKey('error')) {
        setState(() {
          error = info['error'];
          isLoading = false;
        });
        return;
      }

      print('✅ Aula encontrada: ${info['nombre']} (ID: ${info['id_aula']})');

      final resultados = await Future.wait([
        ApiService.getHorariosAula(info['id_aula']),
        ApiService.getAvisosAula(info['id_aula']),
      ]);

      if (!mounted) return;

      setState(() {
        aulaInfo = info;
        horarios = resultados[0];
        avisos = resultados[1];
        isLoading = false;
      });
      
      _animationController.forward();
    } catch (e) {
      print('❌ Error: $e');
      if (mounted) {
        setState(() {
          error = 'Error al cargar datos: ${e.toString()}';
          isLoading = false;
        });
      }
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

  IconData _getEstadoIcon(String estado) {
    switch (estado) {
      case 'Disponible':
        return Icons.check_circle;
      case 'Mantenimiento':
        return Icons.build;
      case 'Cerrada':
        return Icons.cancel;
      default:
        return Icons.help;
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
              ? _buildErrorWidget()
              : FadeTransition(
                  opacity: _animationController,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 16),
                        _buildQuickInfo(),
                        const SizedBox(height: 24),
                        _buildHorarioSection(),
                        const SizedBox(height: 24),
                        if (avisos.isNotEmpty) _buildAvisosSection(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1e3c72), Color(0xFF2a5298)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _getEstadoColor(aulaInfo['estado'] ?? 'Disponible').withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: _getEstadoColor(aulaInfo['estado'] ?? 'Disponible'),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getEstadoIcon(aulaInfo['estado'] ?? 'Disponible'),
                  color: _getEstadoColor(aulaInfo['estado'] ?? 'Disponible'),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  aulaInfo['estado'] ?? 'Disponible',
                  style: TextStyle(
                    color: _getEstadoColor(aulaInfo['estado'] ?? 'Disponible'),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            aulaInfo['nombre'] ?? 'Aula',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.apartment, color: Colors.white70, size: 16),
              const SizedBox(width: 4),
              Text(
                aulaInfo['bloque_nombre'] ?? 'Bloque Principal',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildInfoCard(
              icon: Icons.people,
              title: 'Capacidad',
              value: '${aulaInfo['capacidad'] ?? 0}',
              subtitle: 'personas',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildInfoCard(
              icon: Icons.build,
              title: 'Equipamiento',
              value: 'Ver detalles',
              subtitle: 'tocar para ver',
              onTap: () => _showEquipamientoDialog(aulaInfo['equipamiento']),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1e3c72).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF1e3c72), size: 24),
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF2C3E50),
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorarioSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1e3c72).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.schedule, color: Color(0xFF1e3c72), size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Horario Semanal',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          HorarioTablaWidget(horarios: horarios),
        ],
      ),
    );
  }

  Widget _buildAvisosSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.warning, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Avisos',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...avisos.map((aviso) => _buildAvisoCard(aviso)),
        ],
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B6B).withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning, color: Colors.white, size: 24),
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
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  aviso['contenido'] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              '¡Ups! Algo salió mal',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _cargarInfo(),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
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
      ),
    );
  }

  void _showEquipamientoDialog(String? equipamiento) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Equipamiento'),
        content: SingleChildScrollView(
          child: Text(equipamiento ?? 'No especificado'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}