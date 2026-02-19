import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.100.6:3000/api';

  // ============= MÉTODOS PRIVADOS =============
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static void _printLog(String type, String message, [dynamic data]) {
    print('📌 $type: $message');
    if (data != null) print('   Data: $data');
  }

  // ============= AUTH =============
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      _printLog('AUTH', 'Login intent for: $email');
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'correo': email, 'password': password}),
      ).timeout(const Duration(seconds: 10));

      _printLog('AUTH', 'Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        return {'error': 'Credenciales incorrectas'};
      } else {
        return {'error': 'Error ${response.statusCode}: ${response.body}'};
      }
    } catch (e) {
      _printLog('AUTH ERROR', e.toString());
      return {'error': 'Error de conexión: $e'};
    }
  }

  // ============= AULAS =============
  static Future<Map<String, dynamic>> getAulaInfo(String codigoQR) async {
    try {
      _printLog('AULAS', 'Buscando aula con QR: $codigoQR');
      
      final response = await http.get(
        Uri.parse('$baseUrl/aulas/qr/$codigoQR'),
      ).timeout(const Duration(seconds: 10));

      _printLog('AULAS', 'Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        return {'error': 'Aula no encontrada'};
      } else {
        return {'error': 'Error ${response.statusCode}'};
      }
    } catch (e) {
      _printLog('AULAS ERROR', e.toString());
      return {'error': 'Error al obtener información: $e'};
    }
  }

  static Future<List<dynamic>> getAulas() async {
    try {
      final headers = await _getHeaders();
      _printLog('AULAS', 'Obteniendo todas las aulas');
      
      final response = await http.get(
        Uri.parse('$baseUrl/aulas'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _printLog('AULAS', 'Encontradas: ${data.length} aulas');
        return data;
      }
      return [];
    } catch (e) {
      _printLog('AULAS ERROR', e.toString());
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getAulaById(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/aulas/$id'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      _printLog('AULAS ERROR', e.toString());
      return null;
    }
  }

  static Future<Map<String, dynamic>> createAula(Map<String, dynamic> aula) async {
    try {
      final headers = await _getHeaders();
      _printLog('AULAS', 'Creando aula: ${aula['nombre']}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/aulas'),
        headers: headers,
        body: json.encode(aula),
      ).timeout(const Duration(seconds: 10));

      _printLog('AULAS', 'Create response: ${response.statusCode}');
      
      if (response.statusCode == 201) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {
          'success': false, 
          'error': 'Error ${response.statusCode}: ${response.body}'
        };
      }
    } catch (e) {
      _printLog('AULAS ERROR', e.toString());
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updateAula(int id, Map<String, dynamic> aula) async {
    try {
      final headers = await _getHeaders();
      _printLog('AULAS', 'Actualizando aula ID: $id');
      
      final response = await http.put(
        Uri.parse('$baseUrl/aulas/$id'),
        headers: headers,
        body: json.encode(aula),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        return {
          'success': false, 
          'error': 'Error ${response.statusCode}: ${response.body}'
        };
      }
    } catch (e) {
      _printLog('AULAS ERROR', e.toString());
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<bool> deleteAula(int id) async {
    try {
      final headers = await _getHeaders();
      _printLog('AULAS', 'Eliminando aula ID: $id');
      
      final response = await http.delete(
        Uri.parse('$baseUrl/aulas/$id'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      _printLog('AULAS ERROR', e.toString());
      return false;
    }
  }

  static Future<bool> updateEstadoAula(int id, String estado) async {
    try {
      final headers = await _getHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/aulas/$id/estado'),
        headers: headers,
        body: json.encode({'estado': estado}),
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      _printLog('AULAS ERROR', e.toString());
      return false;
    }
  }

  // ============= HORARIOS =============
  static Future<List<dynamic>> getHorariosAula(int idAula) async {
    try {
      _printLog('HORARIOS', 'Obteniendo horarios para aula ID: $idAula');
      
      final response = await http.get(
        Uri.parse('$baseUrl/horarios/aula/$idAula'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _printLog('HORARIOS', 'Encontrados: ${data.length} horarios');
        return data;
      }
      return [];
    } catch (e) {
      _printLog('HORARIOS ERROR', e.toString());
      return [];
    }
  }

  static Future<List<dynamic>> getHorarios() async {
    try {
      final headers = await _getHeaders();
      _printLog('HORARIOS', 'Obteniendo todos los horarios');
      
      final response = await http.get(
        Uri.parse('$baseUrl/horarios'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _printLog('HORARIOS', 'Encontrados: ${data.length} horarios');
        return data;
      }
      return [];
    } catch (e) {
      _printLog('HORARIOS ERROR', e.toString());
      return [];
    }
  }

  static Future<Map<String, dynamic>> verificarDisponibilidadHorario({
    required int idAula,
    required String diaSemana,
    required String horaInicio,
    required String horaFin,
    int? idHorarioExcluir,
  }) async {
    try {
      final headers = await _getHeaders();
      _printLog('HORARIOS', 'Verificando disponibilidad');
      
      final body = {
        'id_aula': idAula,
        'dia_semana': diaSemana,
        'hora_inicio': horaInicio,
        'hora_fin': horaFin,
        if (idHorarioExcluir != null) 'id_horario_excluir': idHorarioExcluir,
      };
      
      final response = await http.post(
        Uri.parse('$baseUrl/horarios/verificar-disponibilidad'),
        headers: headers,
        body: json.encode(body),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'disponible': false, 'mensaje': 'Error al verificar'};
    } catch (e) {
      _printLog('HORARIOS ERROR', e.toString());
      return {'disponible': false, 'mensaje': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> createHorario(Map<String, dynamic> horario) async {
    try {
      final headers = await _getHeaders();
      _printLog('HORARIOS', 'Creando horario');
      
      final response = await http.post(
        Uri.parse('$baseUrl/horarios'),
        headers: headers,
        body: json.encode(horario),
      ).timeout(const Duration(seconds: 10));

      _printLog('HORARIOS', 'Create response: ${response.statusCode}');
      
      if (response.statusCode == 201) {
        return {'success': true, 'data': json.decode(response.body)};
      } else if (response.statusCode == 409) {
        final error = json.decode(response.body);
        return {
          'success': false, 
          'error': error['message'] ?? 'Conflicto de horarios',
          'conflicto': error['conflicto']
        };
      } else {
        return {
          'success': false, 
          'error': 'Error ${response.statusCode}: ${response.body}'
        };
      }
    } catch (e) {
      _printLog('HORARIOS ERROR', e.toString());
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<bool> deleteHorario(int id) async {
    try {
      final headers = await _getHeaders();
      _printLog('HORARIOS', 'Eliminando horario ID: $id');
      
      final response = await http.delete(
        Uri.parse('$baseUrl/horarios/$id'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      _printLog('HORARIOS ERROR', e.toString());
      return false;
    }
  }

  // ============= AVISOS =============
  static Future<List<dynamic>> getAvisos() async {
    try {
      final headers = await _getHeaders();
      _printLog('AVISOS', 'Obteniendo todos los avisos');
      
      final response = await http.get(
        Uri.parse('$baseUrl/avisos'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      _printLog('AVISOS', 'Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _printLog('AVISOS', 'Encontrados: ${data.length} avisos');
        return data;
      }
      return [];
    } catch (e) {
      _printLog('AVISOS ERROR', e.toString());
      return [];
    }
  }

  static Future<List<dynamic>> getAvisosAula(int idAula) async {
    try {
      _printLog('AVISOS', 'Obteniendo avisos para aula ID: $idAula');
      
      final response = await http.get(
        Uri.parse('$baseUrl/avisos/aula/$idAula'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      }
      return [];
    } catch (e) {
      _printLog('AVISOS ERROR', e.toString());
      return [];
    }
  }

  static Future<Map<String, dynamic>> createAviso(Map<String, dynamic> aviso) async {
    try {
      final headers = await _getHeaders();
      _printLog('AVISOS', 'Creando aviso: ${aviso['titulo']}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/avisos'),
        headers: headers,
        body: json.encode(aviso),
      ).timeout(const Duration(seconds: 10));

      _printLog('AVISOS', 'Create response: ${response.statusCode}');
      
      if (response.statusCode == 201) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {
          'success': false, 
          'error': 'Error ${response.statusCode}: ${response.body}'
        };
      }
    } catch (e) {
      _printLog('AVISOS ERROR', e.toString());
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<bool> deleteAviso(int id) async {
    try {
      final headers = await _getHeaders();
      _printLog('AVISOS', 'Eliminando aviso ID: $id');
      
      final response = await http.delete(
        Uri.parse('$baseUrl/avisos/$id'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      _printLog('AVISOS ERROR', e.toString());
      return false;
    }
  }

  // ============= BLOQUES =============
  static Future<List<dynamic>> getBloques() async {
    try {
      final headers = await _getHeaders();
      _printLog('BLOQUES', 'Obteniendo todos los bloques');
      
      final response = await http.get(
        Uri.parse('$baseUrl/bloques'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _printLog('BLOQUES', 'Encontrados: ${data.length} bloques');
        return data;
      }
      return [];
    } catch (e) {
      _printLog('BLOQUES ERROR', e.toString());
      return [];
    }
  }

  static Future<Map<String, dynamic>> getBloqueById(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/bloques/$id'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      }
      return {'success': false};
    } catch (e) {
      return {'success': false};
    }
  }

  static Future<Map<String, dynamic>> createBloque(Map<String, dynamic> bloque) async {
    try {
      final headers = await _getHeaders();
      _printLog('BLOQUES', 'Creando bloque: ${bloque['nombre']}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/bloques'),
        headers: headers,
        body: json.encode(bloque),
      ).timeout(const Duration(seconds: 10));

      _printLog('BLOQUES', 'Create response: ${response.statusCode}');
      
      if (response.statusCode == 201) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {
          'success': false, 
          'error': 'Error ${response.statusCode}: ${response.body}'
        };
      }
    } catch (e) {
      _printLog('BLOQUES ERROR', e.toString());
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updateBloque(int id, Map<String, dynamic> bloque) async {
    try {
      final headers = await _getHeaders();
      _printLog('BLOQUES', 'Actualizando bloque ID: $id');
      
      final response = await http.put(
        Uri.parse('$baseUrl/bloques/$id'),
        headers: headers,
        body: json.encode(bloque),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        return {
          'success': false, 
          'error': 'Error ${response.statusCode}: ${response.body}'
        };
      }
    } catch (e) {
      _printLog('BLOQUES ERROR', e.toString());
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<bool> deleteBloque(int id) async {
    try {
      final headers = await _getHeaders();
      _printLog('BLOQUES', 'Eliminando bloque ID: $id');
      
      final response = await http.delete(
        Uri.parse('$baseUrl/bloques/$id'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      _printLog('BLOQUES ERROR', e.toString());
      return false;
    }
  }

  // ============= REPORTES =============
  static Future<List<dynamic>> getReportes() async {
    try {
      final headers = await _getHeaders();
      _printLog('REPORTES', 'Obteniendo todos los reportes');
      
      final response = await http.get(
        Uri.parse('$baseUrl/reportes'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _printLog('REPORTES', 'Encontrados: ${data.length} reportes');
        return data;
      }
      return [];
    } catch (e) {
      _printLog('REPORTES ERROR', e.toString());
      return [];
    }
  }

  static Future<List<dynamic>> getMisReportes() async {
    try {
      final headers = await _getHeaders();
      _printLog('REPORTES', 'Obteniendo mis reportes');
      
      final response = await http.get(
        Uri.parse('$baseUrl/reportes/mis-reportes'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _printLog('REPORTES', 'Encontrados: ${data.length} reportes');
        return data;
      }
      return [];
    } catch (e) {
      _printLog('REPORTES ERROR', e.toString());
      return [];
    }
  }

  static Future<Map<String, dynamic>> createReporte(Map<String, dynamic> reporte) async {
    try {
      final headers = await _getHeaders();
      _printLog('REPORTES', 'Creando reporte');
      
      final response = await http.post(
        Uri.parse('$baseUrl/reportes'),
        headers: headers,
        body: json.encode(reporte),
      ).timeout(const Duration(seconds: 10));

      _printLog('REPORTES', 'Create response: ${response.statusCode}');
      
      if (response.statusCode == 201) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {
          'success': false, 
          'error': 'Error ${response.statusCode}: ${response.body}'
        };
      }
    } catch (e) {
      _printLog('REPORTES ERROR', e.toString());
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<bool> updateEstadoReporte(int id, String estado) async {
    try {
      final headers = await _getHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/reportes/$id/estado'),
        headers: headers,
        body: json.encode({'estado': estado}),
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      _printLog('REPORTES ERROR', e.toString());
      return false;
    }
  }

  static Future<bool> deleteReporte(int id) async {
    try {
      final headers = await _getHeaders();
      _printLog('REPORTES', 'Eliminando reporte ID: $id');
      
      final response = await http.delete(
        Uri.parse('$baseUrl/reportes/$id'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      _printLog('REPORTES ERROR', e.toString());
      return false;
    }
  }

  // ============= DOCENTES =============
  static Future<List<dynamic>> getDocentes() async {
    try {
      final headers = await _getHeaders();
      _printLog('DOCENTES', 'Obteniendo docentes');
      
      final response = await http.get(
        Uri.parse('$baseUrl/usuarios/docentes'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _printLog('DOCENTES', 'Encontrados: ${data.length} docentes');
        return data;
      }
      return [];
    } catch (e) {
      _printLog('DOCENTES ERROR', e.toString());
      return [];
    }
  }

  static Future<List<dynamic>> getAllUsuarios() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/usuarios'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> createDocente(Map<String, dynamic> docente) async {
    try {
      final headers = await _getHeaders();
      _printLog('DOCENTES', 'Creando docente: ${docente['nombre']}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/usuarios'),
        headers: headers,
        body: json.encode({
          ...docente,
          'rol': 'DOCENTE'
        }),
      ).timeout(const Duration(seconds: 10));

      _printLog('DOCENTES', 'Create response: ${response.statusCode}');
      
      if (response.statusCode == 201) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {
          'success': false, 
          'error': 'Error ${response.statusCode}: ${response.body}'
        };
      }
    } catch (e) {
      _printLog('DOCENTES ERROR', e.toString());
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updateDocente(int id, Map<String, dynamic> docente) async {
    try {
      final headers = await _getHeaders();
      _printLog('DOCENTES', 'Actualizando docente ID: $id');
      
      final response = await http.put(
        Uri.parse('$baseUrl/usuarios/$id'),
        headers: headers,
        body: json.encode(docente),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        return {
          'success': false, 
          'error': 'Error ${response.statusCode}: ${response.body}'
        };
      }
    } catch (e) {
      _printLog('DOCENTES ERROR', e.toString());
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<bool> deleteDocente(int id) async {
    try {
      final headers = await _getHeaders();
      _printLog('DOCENTES', 'Eliminando docente ID: $id');
      
      final response = await http.delete(
        Uri.parse('$baseUrl/usuarios/$id'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      _printLog('DOCENTES ERROR', e.toString());
      return false;
    }
  }

  // ============= MATERIAS =============
  static Future<List<dynamic>> getMaterias() async {
    try {
      final headers = await _getHeaders();
      _printLog('MATERIAS', 'Obteniendo materias');
      
      final response = await http.get(
        Uri.parse('$baseUrl/materias'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _printLog('MATERIAS', 'Encontradas: ${data.length} materias');
        return data;
      }
      return [];
    } catch (e) {
      _printLog('MATERIAS ERROR', e.toString());
      return [];
    }
  }

  static Future<Map<String, dynamic>> getMateriaById(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/materias/$id'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      }
      return {'success': false};
    } catch (e) {
      return {'success': false};
    }
  }

  static Future<Map<String, dynamic>> createMateria(Map<String, dynamic> materia) async {
    try {
      final headers = await _getHeaders();
      _printLog('MATERIAS', 'Creando materia: ${materia['nombre']}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/materias'),
        headers: headers,
        body: json.encode(materia),
      ).timeout(const Duration(seconds: 10));

      _printLog('MATERIAS', 'Create response: ${response.statusCode}');
      
      if (response.statusCode == 201) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {
          'success': false, 
          'error': 'Error ${response.statusCode}: ${response.body}'
        };
      }
    } catch (e) {
      _printLog('MATERIAS ERROR', e.toString());
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updateMateria(int id, Map<String, dynamic> materia) async {
    try {
      final headers = await _getHeaders();
      _printLog('MATERIAS', 'Actualizando materia ID: $id');
      
      final response = await http.put(
        Uri.parse('$baseUrl/materias/$id'),
        headers: headers,
        body: json.encode(materia),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        return {
          'success': false, 
          'error': 'Error ${response.statusCode}: ${response.body}'
        };
      }
    } catch (e) {
      _printLog('MATERIAS ERROR', e.toString());
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<bool> deleteMateria(int id) async {
    try {
      final headers = await _getHeaders();
      _printLog('MATERIAS', 'Eliminando materia ID: $id');
      
      final response = await http.delete(
        Uri.parse('$baseUrl/materias/$id'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      _printLog('MATERIAS ERROR', e.toString());
      return false;
    }
  }

  // ============= LOGOUT =============
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _printLog('AUTH', 'Sesión cerrada');
  }
}