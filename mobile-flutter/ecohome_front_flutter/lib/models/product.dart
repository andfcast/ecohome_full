class Product {
  final int id;
  final String name;
  final double price;
  final bool isAvailable;
  final String? creator;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.isAvailable,
    this.creator
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    double parsedPrice = 0.0;
    final rawPrice = json['price'];
    if (rawPrice is num) {
      parsedPrice = rawPrice.toDouble();
    } else if (rawPrice is String) {
      parsedPrice = double.tryParse(rawPrice) ?? 0.0;
    }

    bool parsedAvailability = false;
    final rawAvailability = json['isavailable'] ?? json['is_available'];
    if (rawAvailability is bool) {
      parsedAvailability = rawAvailability;
    } else if (rawAvailability is int) {
      parsedAvailability = rawAvailability == 1;
    } else if (rawAvailability is String) {
      parsedAvailability = rawAvailability.toLowerCase() == 'true' || rawAvailability == '1';
    } 

    return Product(
      id: json['id'],
      name: json['name'] ?? '',
      price: parsedPrice,
      isAvailable: parsedAvailability,
      creator: json['creator'] ?? ''
    );
  }
}