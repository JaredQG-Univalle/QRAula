import 'package:flutter/material.dart';
import 'admin_aulas_screen.dart';
import 'admin_horarios_screen.dart';
import 'admin_reportes_screen.dart';
import 'admin_docentes_screen.dart';
import 'admin_materias_screen.dart';
import 'admin_bloques_screen.dart';
import 'admin_estadisticas_screen.dart';
import 'admin_generar_qr_screen.dart';
import '../../services/auth_service.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  String? nombreAdmin;

  @override
  void initState() {
    super.initState();
    _cargarNombre();
  }

  Future<void> _cargarNombre() async {
    final nombre = await AuthService.getNombre();
    if (mounted) {
      setState(() {
        nombreAdmin = nombre;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text(
          'Panel de Administración',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF1e3c72),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.logout();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/');
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1e3c72), Color(0xFF2a5298)],
          ),
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: const BoxDecoration(
                  color: Color(0xFFF4F6FA),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35),
                  ),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),
                      _buildSectionTitle("Gestión Principal"),
                      const SizedBox(height: 15),
                      _buildGridPrincipal(),
                      const SizedBox(height: 30),
                      _buildSectionTitle("Configuración"),
                      const SizedBox(height: 15),
                      _buildGridConfiguracion(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                nombreAdmin?.isNotEmpty == true
                    ? nombreAdmin!
                        .split(' ')
                        .map((e) => e[0])
                        .take(2)
                        .join()
                    : 'AD',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1e3c72),
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Bienvenido",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                nombreAdmin ?? "Administrador",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  "Administrador",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return const Padding(
      padding: EdgeInsets.only(left: 4),
      child: Text(
        "",
      ),
    );
  }

  Widget _buildGridPrincipal() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 18,
      crossAxisSpacing: 18,
      childAspectRatio: 1.05,
      children: [
        _modernCard(Icons.meeting_room, "Aulas", const Color(0xFF4158D0), () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AdminAulasScreen()));
        }),
        _modernCard(Icons.schedule, "Horarios", const Color(0xFF4CAF50), () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AdminHorariosScreen()));
        }),
        _modernCard(Icons.warning, "Reportes", const Color(0xFFFF9800), () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AdminReportesScreen()));
        }),
        _modernCard(Icons.qr_code, "Generar QR", const Color(0xFF9C27B0), () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AdminGenerarQRScreen()));
        }),
      ],
    );
  }

  Widget _buildGridConfiguracion() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 18,
      crossAxisSpacing: 18,
      childAspectRatio: 1.05,
      children: [
        _modernCard(Icons.people, "Docentes", const Color(0xFF00BCD4), () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AdminDocentesScreen()));
        }),
        _modernCard(Icons.menu_book, "Materias", const Color(0xFFFF5722), () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AdminMateriasScreen()));
        }),
        _modernCard(Icons.apartment, "Bloques", const Color(0xFF607D8B), () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AdminBloquesScreen()));
        }),
        _modernCard(Icons.bar_chart, "Estadísticas",
            const Color(0xFF795548), () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AdminEstadisticasScreen()));
        }),
      ],
    );
  }

  Widget _modernCard(
      IconData icon, String title, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      elevation: 6,
      shadowColor: color.withOpacity(0.2),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
