import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  static const String baseUrl = 'http://localhost:3000';

  /// Obtiene las métricas y estadísticas del usuario autenticado Nombre (N)
  Future<Map<String, dynamic>> getUserStats(String token) async {
    final url = Uri.parse('$baseUrl/users/me/stats');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(
        errorData['message'] ?? 'Error al obtener las estadísticas del usuario',
      );
    }
  }
}