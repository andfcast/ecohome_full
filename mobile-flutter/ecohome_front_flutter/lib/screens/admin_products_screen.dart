import 'package:flutter/material.dart';
import '../services/product_service.dart';
import '../services/user_service.dart';
import '../models/product.dart';

class AdminProductsScreen extends StatefulWidget {
  final String token;
  final String username;
  final VoidCallback onLogout;

  const AdminProductsScreen({
    super.key,
    required this.token,
    required this.username,
    required this.onLogout,
  });

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  final ProductService _productService = ProductService();
  final UserService _userService = UserService();
  List<Product> _products = [];
  int _totalProducts = 0;
  bool _isLoading = true;
  bool _isCreating = false;

  // Controladores del formulario
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  bool _isAvailable = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  // 1. Cargar datos iniciales con validación de estado mounted
  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final productsData = await _productService.getProducts(token: widget.token);
      final statsData = await _userService.getUserStats(widget.token);

      if (!mounted) return;

      setState(() {
        _products = productsData;
        _totalProducts = statsData['totalProducts'] ?? statsData['total'] ?? productsData.length;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackBar('Error al cargar datos: ${e.toString()}', isError: true);
    }
  }

  // 2. Crear Producto y refrescar estado
  Future<void> _handleCreateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isCreating = true);

    try {
      final newProductData = {
        'name': _nameController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'is_available': _isAvailable,
      };

      await _productService.createProduct(newProductData, widget.token);

      // Limpiar campos
      _nameController.clear();
      _priceController.clear();
      
      if (!mounted) return;
      setState(() => _isAvailable = true);

      _showSnackBar('¡Producto creado exitosamente!');

      // Refrescar lista de productos y contador
      final updatedProducts = await _productService.getProducts(token: widget.token);
      
      if (!mounted) return;
      setState(() {
        _products = updatedProducts;
        _totalProducts++;
      });
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Error al crear producto: ${e.toString()}', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        backgroundColor: const Color(0xFF1E293B),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0F766E),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.person, size: 18, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  '${widget.username} ($_totalProducts)',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: widget.onLogout,
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // FORMULARIO DE CREACIÓN
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Crear Nuevo Producto',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Nombre del Producto',
                                border: OutlineInputBorder(),
                              ),
                              validator: (val) => val == null || val.trim().isEmpty
                                  ? 'Ingrese un nombre'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _priceController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'Precio (\$)',
                                border: OutlineInputBorder(),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Ingrese un precio';
                                }
                                if (double.tryParse(val.trim()) == null) {
                                  return 'Ingrese un número válido';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Checkbox(
                                  value: _isAvailable,
                                  onChanged: (val) => setState(
                                      () => _isAvailable = val ?? true),
                                ),
                                const Text('Disponible'),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                onPressed: _isCreating
                                    ? null
                                    : _handleCreateProduct,
                                child: _isCreating
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Guardar Producto',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // LISTADO GENERAL DE PRODUCTOS
                  const Text(
                    'Catálogo General de Productos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _products.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text('No hay productos registrados.'),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _products.length,
                          itemBuilder: (context, index) {
                            final prod = _products[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: prod.isAvailable
                                      ? Colors.green.shade100
                                      : Colors.red.shade100,
                                  child: Icon(
                                    prod.isAvailable
                                        ? Icons.check
                                        : Icons.close,
                                    color: prod.isAvailable
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                                title: Text(
                                  prod.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  'Precio: \$${prod.price.toStringAsFixed(2)}\nEstado: ${prod.isAvailable ? "Disponible" : "Agotado"}\nCreado por: ${prod.creator}',
                                ),
                                isThreeLine: true,
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }
}