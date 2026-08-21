import 'dart:convert';
import 'package:http/http.dart' as http;


class AuthService{
  final String baseUrl = 'http://localhost:3000';

  /// Realiza la petición de inicio de sesión y retorna la respuesta en un Map
    Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    } else {
      // Lanzar excepción con el mensaje que retorne el backend o uno por defecto
      throw Exception(data['message'] ?? 'Error al iniciar sesión (${response.statusCode})');
    }
  }
}