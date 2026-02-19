import 'package:flutter/material.dart';

class AdminEstadisticasScreen extends StatefulWidget {
  const AdminEstadisticasScreen({super.key});

  @override
  State<AdminEstadisticasScreen> createState() => _AdminEstadisticasScreenState();
}

class _AdminEstadisticasScreenState extends State<AdminEstadisticasScreen> {
  String periodoSeleccionado = 'Semanal';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Estadísticas de Uso'),
        backgroundColor: const Color(0xFF1e3c72),
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                periodoSeleccionado = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'Diario',
                child: Text('Diario'),
              ),
              const PopupMenuItem(
                value: 'Semanal',
                child: Text('Semanal'),
              ),
              const PopupMenuItem(
                value: 'Mensual',
                child: Text('Mensual'),
              ),
              const PopupMenuItem(
                value: 'Anual',
                child: Text('Anual'),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjetas de resumen
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(
                  'Total Aulas',
                  '8',
                  Icons.meeting_room,
                  const Color(0xFF4158D0),
                ),
                _buildStatCard(
                  'Horarios',
                  '45',
                  Icons.schedule,
                  const Color(0xFF4CAF50),
                ),
                _buildStatCard(
                  'Docentes',
                  '12',
                  Icons.people,
                  const Color(0xFFFF9800),
                ),
                _buildStatCard(
                  'Consultas QR',
                  '1,234',
                  Icons.qr_code,
                  const Color(0xFF9C27B0),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Gráfico de uso (placeholder)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Uso de Aulas - $periodoSeleccionado',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.insert_chart,
                              size: 60,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Gráfico de uso',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Aulas más usadas
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Aulas más utilizadas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildRankingItem(1, 'Aula 101', '45 reservas', Colors.amber),
                    _buildRankingItem(2, 'Laboratorio 201', '38 reservas', Colors.grey),
                    _buildRankingItem(3, 'Aula Magna', '32 reservas', Colors.brown),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Reportes recientes
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reportes Técnicos Pendientes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.warning, color: Colors.red),
                      ),
                      title: const Text('Aula 101 - Proyector dañado'),
                      subtitle: const Text('Hace 2 días'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Pendiente',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingItem(int posicion, String nombre, String detalle, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$posicion',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  detalle,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}