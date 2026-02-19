import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AdminAulasScreen extends StatefulWidget {
  const AdminAulasScreen({super.key});

  @override
  State<AdminAulasScreen> createState() => _AdminAulasScreenState();
}

class _AdminAulasScreenState extends State<AdminAulasScreen> {
  List<dynamic> aulas = [];
  List<dynamic> bloques = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => isLoading = true);
    
    final aulasData = await ApiService.getAulas();
    final bloquesData = await ApiService.getBloques();
    
    if (mounted) {
      setState(() {
        aulas = aulasData;
        bloques = bloquesData;
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

  void _showDialog({Map<String, dynamic>? aula}) {
    final isEdit = aula != null;
    final formKey = GlobalKey<FormState>();
    
    final nombreController = TextEditingController(text: aula?['nombre'] ?? '');
    final capacidadController = TextEditingController(text: aula?['capacidad']?.toString() ?? '');
    final equipamientoController = TextEditingController(text: aula?['equipamiento'] ?? '');
    final codigoQRController = TextEditingController(text: aula?['codigo_qr'] ?? '');
    String? idBloqueSeleccionado = aula?['id_bloque']?.toString();
    String estadoSeleccionado = aula?['estado'] ?? 'Disponible';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Editar Aula' : 'Nueva Aula'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: idBloqueSeleccionado,
                  decoration: const InputDecoration(labelText: 'Bloque *'),
                  items: bloques.map((bloque) {
                    return DropdownMenuItem(
                      value: bloque['id_bloque'].toString(),
                      child: Text(bloque['nombre']),
                    );
                  }).toList(),
                  onChanged: (value) => idBloqueSeleccionado = value,
                  validator: (value) => value == null ? 'Selecciona un bloque' : null,
                ),
                TextFormField(
                  controller: nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre *'),
                  validator: (value) => value?.isEmpty == true ? 'Campo requerido' : null,
                ),
                TextFormField(
                  controller: capacidadController,
                  decoration: const InputDecoration(labelText: 'Capacidad *'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value?.isEmpty == true ? 'Campo requerido' : null,
                ),
                TextFormField(
                  controller: codigoQRController,
                  decoration: const InputDecoration(labelText: 'Código QR *'),
                  validator: (value) => value?.isEmpty == true ? 'Campo requerido' : null,
                ),
                TextFormField(
                  controller: equipamientoController,
                  decoration: const InputDecoration(labelText: 'Equipamiento'),
                  maxLines: 3,
                ),
                DropdownButtonFormField<String>(
                  value: estadoSeleccionado,
                  decoration: const InputDecoration(labelText: 'Estado'),
                  items: const [
                    DropdownMenuItem(value: 'Disponible', child: Text('Disponible')),
                    DropdownMenuItem(value: 'Mantenimiento', child: Text('Mantenimiento')),
                    DropdownMenuItem(value: 'Cerrada', child: Text('Cerrada')),
                  ],
                  onChanged: (value) => estadoSeleccionado = value!,
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
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                
                final aulaData = {
                  'id_bloque': int.parse(idBloqueSeleccionado!),
                  'nombre': nombreController.text,
                  'capacidad': int.parse(capacidadController.text),
                  'codigo_qr': codigoQRController.text,
                  'equipamiento': equipamientoController.text,
                  'estado': estadoSeleccionado,
                };

                if (isEdit) {
                  await ApiService.updateAula(aula!['id_aula'], aulaData);
                } else {
                  await ApiService.createAula(aulaData);
                }
                
                _cargarDatos();
              }
            },
            child: Text(isEdit ? 'Actualizar' : 'Crear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Gestión de Aulas'),
        backgroundColor: const Color(0xFF1e3c72),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : aulas.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.meeting_room, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No hay aulas registradas',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => _showDialog(),
                        icon: const Icon(Icons.add),
                        label: const Text('Crear Primera Aula'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: aulas.length,
                  itemBuilder: (context, index) {
                    final aula = aulas[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: _getEstadoColor(aula['estado']).withOpacity(0.2),
                          child: Icon(
                            Icons.meeting_room,
                            color: _getEstadoColor(aula['estado']),
                            size: 20,
                          ),
                        ),
                        title: Text(
                          aula['nombre'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${aula['bloque_nombre']} • Cap. ${aula['capacidad']}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showDialog(aula: aula),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Confirmar'),
                                    content: Text('¿Eliminar ${aula['nombre']}?'),
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
                                  await ApiService.deleteAula(aula['id_aula']);
                                  _cargarDatos();
                                }
                              },
                            ),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow('Código QR', aula['codigo_qr']),
                                _buildInfoRow('Equipamiento', aula['equipamiento'] ?? 'No especificado'),
                                _buildInfoRow('Estado', aula['estado'], 
                                  color: _getEstadoColor(aula['estado'])),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDialog(),
        backgroundColor: const Color(0xFF1e3c72),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: color),
            ),
          ),
        ],
      ),
    );
  }
}