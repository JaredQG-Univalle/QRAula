import 'package:flutter/material.dart';
import 'screens/inicio_screen.dart';

void main() {
  runApp(const AulaQRApp());
}

class AulaQRApp extends StatelessWidget {
  const AulaQRApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AulaQR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1e3c72)),
        useMaterial3: true,
      ),
      home: const InicioScreen(),
    );
  }
}