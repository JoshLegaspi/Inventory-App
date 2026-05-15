class Supplier {
  final String id;
  final String name; // Company Name
  final String contactPerson;
  final String email;
  final String phone;
  final String address;
  final DateTime createdAt;
  double totalPurchased; // Total amount purchased from this supplier
  int totalOrders;

  Supplier({
    required this.id,
    required this.name,
    required this.contactPerson,
    required this.email,
    required this.phone,
    required this.address,
    required this.createdAt,
    this.totalPurchased = 0.0,
    this.totalOrders = 0,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      contactPerson: (json['contact_person'] ?? json['contactPerson'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      createdAt: DateTime.parse(json['created_at'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()),
      totalPurchased: (json['total_purchased'] ?? json['totalPurchased'] as num?)?.toDouble() ?? 0.0,
      totalOrders: (json['total_orders'] ?? json['totalOrders'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contactPerson': contactPerson,
      'email': email,
      'phone': phone,
      'address': address,
      'createdAt': createdAt.toIso8601String(),
      'totalPurchased': totalPurchased,
      'totalOrders': totalOrders,
    };
  }
}