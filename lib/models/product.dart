class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  int quantity;
  final String category;
  final String? supplierId;
  final String? supplierName;
  final DateTime createdAt;
  DateTime? updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.category,
    this.supplierId,
    this.supplierName,
    required this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['id'] ?? '').toString(),
      name: json['name'] as String,
      description: json['description'] ?? '',
      price: (json['unit_price'] ?? json['price'] ?? 0.0).toDouble(),
      quantity: (json['quantity'] ?? json['stock_quantity'] ?? 0).toInt(),
      category: json['category'] ?? 'General',
      supplierId: json['supplier_id'] ?? json['supplierId'],
      supplierName: json['suppliers'] != null 
          ? json['suppliers']['name'] as String? 
          : json['supplierName'] as String?,
      createdAt: DateTime.parse((json['created_at'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()).toString()),
      updatedAt: (json['updated_at'] ?? json['updatedAt']) != null 
          ? DateTime.parse((json['updated_at'] ?? json['updatedAt']).toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'unit_price': price,
      'quantity': quantity,
      'category': category,
      'supplier_id': supplierId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  double getTotalValue() => price * quantity;

  bool isLowStock(int threshold) => quantity < threshold;
}
