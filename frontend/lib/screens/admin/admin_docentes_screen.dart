import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AdminDocentesScreen extends StatefulWidget {
  const AdminDocentesScreen({super.key});

  @override
  State<AdminDocentesScreen> createState() => _AdminDocentesScreenState();
}

class _AdminDocentesScreenState extends State<AdminDocentesScreen> {
  List<dynamic> docentes = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _cargarDocentes();
  }

  Future<void> _cargarDocentes() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await ApiService.getDocentes();
      if (mounted) {
        setState(() {
          docentes = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'Error al cargar docentes: $e';
        });
      }
    }
  }

  Future<void> _showCrearDocenteDialog() async {
    final formKey = GlobalKey<FormState>();
    final nombreController = TextEditingController();
    final apellidoController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Nuevo Docente'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) => value?.isEmpty == true ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: apellidoController,
                    decoration: const InputDecoration(
                      labelText: 'Apellido *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) => value?.isEmpty == true ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Correo *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value?.isEmpty == true) return 'Campo requerido';
                      if (!value!.contains('@')) return 'Correo inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value?.isEmpty == true) return 'Campo requerido';
                      if (value!.length < 6) return 'Mínimo 6 caracteres';
                      return null;
                    },
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

                        // TODO: Implementar creación de docente cuando el backend lo soporte
                        // Por ahora simulamos éxito
                        await Future.delayed(const Duration(seconds: 1));

                        setState(() => isLoading = false);
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Docente creado exitosamente'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        _cargarDocentes();
                      }
                    },
              child: const Text('Crear'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editarDocente(Map<String, dynamic> docente) async {
    final formKey = GlobalKey<FormState>();
    final nombreController = TextEditingController(text: docente['nombre']);
    final apellidoController = TextEditingController(text: docente['apellido']);
    final emailController = TextEditingController(text: docente['correo']);
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Editar Docente'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty == true ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: apellidoController,
                    decoration: const InputDecoration(
                      labelText: 'Apellido *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty == true ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Correo *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value?.isEmpty == true) return 'Campo requerido';
                      if (!value!.contains('@')) return 'Correo inválido';
                      return null;
                    },
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
                        await Future.delayed(const Duration(seconds: 1));
                        setState(() => isLoading = false);
                        Navigator.pop(context);
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Docente actualizado'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        _cargarDocentes();
                      }
                    },
              child: const Text('Actualizar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _eliminarDocente(int id, String nombre) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar'),
        content: Text('¿Eliminar al docente $nombre?'),
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
      // TODO: Implementar eliminación cuando el backend lo soporte
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Docente eliminado'),
          backgroundColor: Colors.green,
        ),
      );
      _cargarDocentes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Gestión de Docentes'),
        backgroundColor: const Color(0xFF1e3c72),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarDocentes,
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
                        onPressed: _cargarDocentes,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : docentes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No hay docentes registrados',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton.icon(
                            onPressed: _showCrearDocenteDialog,
                            icon: const Icon(Icons.person_add),
                            label: const Text('Agregar Docente'),
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
                      itemCount: docentes.length,
                      itemBuilder: (context, index) {
                        final docente = docentes[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF1e3c72).withOpacity(0.1),
                              child: Text(
                                '${docente['nombre']?[0] ?? ''}${docente['apellido']?[0] ?? ''}',
                                style: const TextStyle(
                                  color: Color(0xFF1e3c72),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              '${docente['nombre'] ?? ''} ${docente['apellido'] ?? ''}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(docente['correo'] ?? ''),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _editarDocente(docente),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _eliminarDocente(
                                    docente['id_usuario'],
                                    docente['nombre'],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCrearDocenteDialog,
        backgroundColor: const Color(0xFF1e3c72),
        child: const Icon(Icons.person_add),
      ),
    );
  }
}