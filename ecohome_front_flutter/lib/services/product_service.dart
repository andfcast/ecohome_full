import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductService {
  final String baseUrl = 'http://localhost:3000/products';

  Future<List<Product>> getProducts({String? token}) async {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data is List ? data : (data['data'] ?? []);
      return list.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Error al obtener el catálogo (${response.statusCode})');
    }
  }

  Future<Product> createProduct(Map<String, dynamic> productData, String token) async {
    final url = Uri.parse(baseUrl);

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(productData),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      // Extraemos la propiedad "product" del JSON
      final Map<String, dynamic> productJson = body['product'] ?? body;
      return Product.fromJson(productJson);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Error al crear el producto');
    }
  }
}