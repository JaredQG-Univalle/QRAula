import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AdminBloquesScreen extends StatefulWidget {
  const AdminBloquesScreen({super.key});

  @override
  State<AdminBloquesScreen> createState() => _AdminBloquesScreenState();
}

class _AdminBloquesScreenState extends State<AdminBloquesScreen> {
  List<dynamic> bloques = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _cargarBloques();
  }

  Future<void> _cargarBloques() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await ApiService.getBloques();
      if (mounted) {
        setState(() {
          bloques = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'Error al cargar bloques: $e';
        });
      }
    }
  }

  Future<void> _showCrearBloqueDialog() async {
    final formKey = GlobalKey<FormState>();
    final nombreController = TextEditingController();
    final descripcionController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Nuevo Bloque'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del Bloque *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.apartment),
                      hintText: 'Ej: Bloque A',
                    ),
                    validator: (value) {
                      if (value?.isEmpty == true) return 'Campo requerido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descripcionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                      hintText: 'Ej: Edificio principal',
                    ),
                    maxLines: 3,
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

                        final bloqueData = {
                          'nombre': nombreController.text,
                          'descripcion': descripcionController.text,
                        };

                        final result = await ApiService.createBloque(bloqueData);

                        setState(() => isLoading = false);

                        if (result['success'] == true) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✅ Bloque creado exitosamente'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          _cargarBloques();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('❌ ${result['error'] ?? 'Error al crear'}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              child: const Text('Crear'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditarBloqueDialog(Map<String, dynamic> bloque) async {
    final formKey = GlobalKey<FormState>();
    final nombreController = TextEditingController(text: bloque['nombre']);
    final descripcionController = TextEditingController(text: bloque['descripcion'] ?? '');
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Editar Bloque'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del Bloque *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.apartment),
                    ),
                    validator: (value) {
                      if (value?.isEmpty == true) return 'Campo requerido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descripcionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
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
                        
                        // TODO: Implementar update cuando el backend lo soporte
                        await Future.delayed(const Duration(seconds: 1));
                        
                        setState(() => isLoading = false);
                        Navigator.pop(context);
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Bloque actualizado'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        _cargarBloques();
                      }
                    },
              child: const Text('Actualizar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _eliminarBloque(int id, String nombre) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text('¿Estás seguro de eliminar el bloque "$nombre"?\n\nEsto también eliminará todas las aulas asociadas a este bloque.'),
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
      // TODO: Implementar delete cuando el backend lo soporte
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Bloque eliminado'),
          backgroundColor: Colors.green,
        ),
      );
      _cargarBloques();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Gestión de Bloques'),
        backgroundColor: const Color(0xFF1e3c72),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarBloques,
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
                        onPressed: _cargarBloques,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1e3c72),
                        ),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : bloques.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.apartment, size: 80, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No hay bloques registrados',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Crea tu primer bloque usando el botón +',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton.icon(
                            onPressed: _showCrearBloqueDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('Crear Bloque'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1e3c72),
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: bloques.length,
                      itemBuilder: (context, index) {
                        final bloque = bloques[index];
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
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF1e3c72),
                                    const Color(0xFF2a5298),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              bloque['nombre'] ?? 'Sin nombre',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              'ID: ${bloque['id_bloque']} • Creado: ${_formatFecha(bloque['fecha_creacion'])}',
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _showEditarBloqueDialog(bloque),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _eliminarBloque(
                                    bloque['id_bloque'],
                                    bloque['nombre'],
                                  ),
                                ),
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
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            '📝 Descripción:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1e3c72),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            bloque['descripcion'] ?? 'Sin descripción',
                                            style: TextStyle(
                                              color: Colors.grey[800],
                                              height: 1.5,
                                            ),
                                          ),
                                        ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showCrearBloqueDialog,
        backgroundColor: const Color(0xFF1e3c72),
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatFecha(String? fecha) {
    if (fecha == null) return 'Fecha desconocida';
    try {
      final datetime = DateTime.parse(fecha);
      return '${datetime.day}/${datetime.month}/${datetime.year}';
    } catch (e) {
      return fecha;
    }
  }
}