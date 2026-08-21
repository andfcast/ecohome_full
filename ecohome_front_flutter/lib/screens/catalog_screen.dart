import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class CatalogScreen extends StatefulWidget {
  final String? token;
  final String currentUserEmail;
  final VoidCallback onLogout;

  const CatalogScreen({
    super.key,
    this.token,
    required this.currentUserEmail,
    required this.onLogout,
  });

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final ProductService _productService = ProductService();
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _fetchCatalog();
  }

  void _fetchCatalog() {
    setState(() {
      _productsFuture = _productService.getProducts(token: widget.token);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        title: const Text('Catálogo de Productos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchCatalog,
          ),          
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: widget.onLogout,
          ),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text('Error al cargar catálogo: ${snapshot.error}'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _fetchCatalog,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final products = snapshot.data ?? [];

          if (products.isEmpty) {
            return const Center(
              child: Text('No hay productos disponibles en el catálogo.'),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              // Calculamos el número de columnas según el ancho disponible en la pantalla
              final screenWidth = constraints.maxWidth;
              int crossAxisCount = 2; // Por defecto para móviles

              if (screenWidth > 1200) {
                crossAxisCount = 5; // Pantallas muy anchas / monitores grandes
              } else if (screenWidth > 800) {
                crossAxisCount = 4; // Laptops y escritorio
              } else if (screenWidth > 600) {
                crossAxisCount = 3; // Tablets
              }

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200), // Ancho máximo del contenedor
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 0.8, // Relación de aspecto para controlar la altura
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];

                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Área del ícono (altura ajustada)
                              Expanded(
                                child: Center(
                                  child: Icon(
                                    Icons.inventory_2_outlined,
                                    size: 40,
                                    color: product.isAvailable ? Colors.teal : Colors.grey,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Nombre del producto
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              // Precio
                              Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.teal,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Badge Disponibilidad
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: product.isAvailable
                                      ? Colors.green.shade50
                                      : Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: product.isAvailable
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                                child: Text(
                                  product.isAvailable ? 'Disponible' : 'Agotado',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: product.isAvailable
                                        ? Colors.green.shade700
                                        : Colors.red.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}