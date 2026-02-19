import 'package:flutter/material.dart';

class HorarioTablaWidget extends StatelessWidget {
  final List<dynamic> horarios;

  const HorarioTablaWidget({super.key, required this.horarios});

  // 🎨 Paleta
  static const Color primaryColor = Color(0xFF1E3A8A);
  static const Color secondaryColor = Color(0xFF3B82F6);
  static const Color accentColor = Color(0xFF6366F1);
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF1F2937);

  // Organizar horarios por día y hora
  Map<String, Map<String, Map<String, dynamic>?>> _organizarHorarios() {
    final Map<String, Map<String, Map<String, dynamic>?>> resultado = {};

    final List<String> bloquesHorarios = [
      '08:35 - 09:25',
      '09:25 - 10:15',
      '10:25 - 11:15',
      '11:15 - 12:05',
      '12:15 - 13:05',
      '13:05 - 13:55',
      '14:05 - 14:55',
    ];

    final List<String> dias = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado'
    ];

    // Inicializar estructura
    for (var bloque in bloquesHorarios) {
      resultado[bloque] = {};
      for (var dia in dias) {
        resultado[bloque]![dia] = null;
      }
    }

    // Llenar con datos reales
    for (var horario in horarios) {
      final dia = horario['dia_semana'] ?? '';
      final horaInicio = (horario['hora_inicio'] ?? '').toString().substring(0, 5);
      final horaFin = (horario['hora_fin'] ?? '').toString().substring(0, 5);
      final bloque = '$horaInicio - $horaFin';

      if (resultado.containsKey(bloque) &&
          resultado[bloque]!.containsKey(dia)) {
        resultado[bloque]![dia] = horario as Map<String, dynamic>;
      }
    }

    return resultado;
  }

  @override
  Widget build(BuildContext context) {
    final horariosOrganizados = _organizarHorarios();

    final List<String> dias = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado'
    ];

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Table(
            border: TableBorder(
              horizontalInside: BorderSide(color: Colors.grey.shade200),
              verticalInside: BorderSide(color: Colors.grey.shade100),
            ),
            columnWidths: const {
              0: FixedColumnWidth(110),
              1: FixedColumnWidth(130),
              2: FixedColumnWidth(130),
              3: FixedColumnWidth(130),
              4: FixedColumnWidth(130),
              5: FixedColumnWidth(130),
              6: FixedColumnWidth(130),
            },
            children: [
              // 🔵 Encabezado moderno
              TableRow(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, secondaryColor],
                  ),
                ),
                children: [
                  _buildHeaderCell('Hora'),
                  for (var dia in dias) _buildHeaderCell(dia),
                ],
              ),

              // 🔽 Filas
              for (var bloque in horariosOrganizados.keys)
                _buildRow(bloque, horariosOrganizados[bloque]!, dias),
            ],
          ),
        ),
      ),
    );
  }

  TableRow _buildRow(
      String bloque,
      Map<String, Map<String, dynamic>?> horariosBloque,
      List<String> dias) {
    final bool esReceso = bloque == '12:15 - 13:05';

    return TableRow(
      decoration: BoxDecoration(
        color: esReceso ? lightBackground : Colors.white,
      ),
      children: [
        // Hora
        Container(
          padding: const EdgeInsets.all(10),
          color: lightBackground,
          child: Text(
            bloque,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: primaryColor,
            ),
          ),
        ),

        // Días
        for (var dia in dias)
          _buildCell(horariosBloque[dia], esReceso),
      ],
    );
  }

  Widget _buildCell(Map<String, dynamic>? horario, bool esReceso) {
    if (esReceso) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Center(
          child: Icon(Icons.free_breakfast_rounded,
              color: Colors.grey, size: 20),
        ),
      );
    }

    if (horario == null) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Center(child: Text("—")),
      );
    }

    final materia = horario['materia_nombre'] ?? '';
    final docente =
        (horario['docente_nombre'] ?? '').toString().split(' ').first;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: accentColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          // ignore: deprecated_member_use
          border: Border.all(color: accentColor.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              materia,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: textDark,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                docente,
                style: const TextStyle(
                  fontSize: 9,
                  color: primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String texto) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        texto,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}
