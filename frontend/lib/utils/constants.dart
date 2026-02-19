import 'package:flutter/material.dart';

class AppConstants {
  static const String baseUrl = 'http://192.168.1.X:3000/api'; // CAMBIA por tu IP
  
  // QUITAMOS const y Colors porque no son constantes en tiempo de compilación
  static Map<String, Color> get estadoColors => {
    'Disponible': Colors.green,
    'Mantenimiento': Colors.orange,
    'Cerrada': Colors.red,
  };
  
  static const List<String> diasSemana = [
    'Lunes',
    'Martes',
    'Miercoles',
    'Jueves',
    'Viernes',
    'Sabado'
  ];
}