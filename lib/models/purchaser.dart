class Purchaser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String company;
  final String address;
  final DateTime createdAt;
  double totalSpent;
  int totalOrders;

  Purchaser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.company,
    required this.address,
    required this.createdAt,
    this.totalSpent = 0.0,
    this.totalOrders = 0,
  });

  factory Purchaser.fromJson(Map<String, dynamic> json) {
    return Purchaser(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      company: (json['company_name'] ?? json['company'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      createdAt: DateTime.parse(json['created_at'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()),
      totalSpent: (json['total_spent'] ?? json['totalSpent'] as num?)?.toDouble() ?? 0.0,
      totalOrders: (json['total_orders'] ?? json['totalOrders'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'company_name': company,
      'address': address,
      'created_at': createdAt.toIso8601String(),
      'total_spent': totalSpent,
      'total_orders': totalOrders,
    };
  }

  double getAverageOrderValue() {
    if (totalOrders == 0) return 0.0;
    return totalSpent / totalOrders;
  }
}
