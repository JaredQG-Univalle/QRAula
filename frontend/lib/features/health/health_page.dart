import 'package:flutter/material.dart';
import '../../core/config/env.dart';
import '../../core/network/api_client.dart';
import '../../core/network/endpoints.dart';

class HealthPage extends StatefulWidget {
  const HealthPage({super.key});

  @override
  State<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage> {
  late final ApiClient api;

  @override
  void initState() {
    super.initState();
    api = ApiClient(baseUrl: Env.apiBaseUrl);
  }

  Future<String> _test() async {
    final rootText = await api.getText(Endpoints.root);
    final health = await api.getJson(Endpoints.health);
    return 'Root: $rootText\nHealth: ${health['message'] ?? health}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conexión Backend')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FutureBuilder<String>(
            future: _test(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return Text('❌ Error:\n${snapshot.error}');
              }
              return Text('✅ Conectado:\n\n${snapshot.data}');
            },
          ),
        ),
      ),
    );
  }
}
