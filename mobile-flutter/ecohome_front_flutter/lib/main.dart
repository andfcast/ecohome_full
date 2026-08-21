import 'dart:convert';
import 'screens/main_screen.dart';
import 'screens/admin_products_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoHome Store',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controladores para capturar lo que el usuario escribe
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  // Método de logout extraído para evitar la advertencia de BuildContext
  Future<void> _logoutUser(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('user_role');
    await prefs.remove('user_email');
    await prefs.remove('user_name');

    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false, // Elimina todo el historial de rutas
      );
    }
  }

  // Función para consumir el backend de Express.js
  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Por favor llena todos los campos');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // URL de tu backend en Express.js
      final url = Uri.parse('http://localhost:3000/auth/login');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final token = data['token'] ?? data['jwt'];
        
        // Extracción de datos de perfil
        final user = data['user'] ?? data;
        final role = user['role'] ?? 'client';
        final username = user['name'];
        if (token != null) {
          // 2. Guardar el token en SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt_token', token.toString());
          await prefs.setString('user_role', role.toString());
          await prefs.setString('user_email', email);
          await prefs.setString('user_name', username.toString());

          final userEmail = _emailController.text.trim();

          if (mounted) {
            // REDIRECCIÓN CONDICIONAL SEGÚN ROL
            if (role == 'admin') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => AdminProductsScreen(
                    token: token.toString(),
                    username: username.toString(),
                    onLogout: () => _logoutUser(context),
                  ),
                ),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MainScreen(
                    currentUserEmail: userEmail,
                    onLogout: () => _logoutUser(context),
                  ),
                ),
              );
            }
          }
        } else {
          _showMessage('Login exitoso pero no se recibió el token');
        }
      } else {
        final errorData = jsonDecode(response.body);
        _showMessage(errorData['message'] ?? 'Error de autenticación');
      }
    } catch (e) {
      _showMessage('No se pudo conectar con el servidor ($e)');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.eco,
                  size: 64,
                  color: Colors.teal,
                ),
                const SizedBox(height: 16),
                const Text(
                  'EcoHome Store',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Campo Email
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 16),

                // Campo Contraseña
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 24),

                // Botón Ingresar
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Iniciar Sesión',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}