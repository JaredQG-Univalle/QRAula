import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qraulaprueba/main.dart';

void main() {
  testWidgets('AulaQR app test', (WidgetTester tester) async {
    // CORREGIDO: Cambiar MyApp por AulaQRApp
    await tester.pumpWidget(const AulaQRApp());

    // Verificar que el texto "AulaQR" aparece en la pantalla de splash
    expect(find.text('AulaQR'), findsOneWidget);
    
    // Esperar 2 segundos para que pase el splash screen
    await tester.pump(const Duration(seconds: 2));
    
    // Verificar que aparece la pantalla de login
    expect(find.text('INGRESAR'), findsOneWidget);
  });
}