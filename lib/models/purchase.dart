class Purchase {
  final String id;
  final String purchaserId;
  final String purchaserName;
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalAmount;
  final String paymentStatus; // 'fully_paid' or 'installments'
  final double? installmentAmount;
  final int? installmentCount;
  final double? remainingBalance;
  final DateTime createdAt;
  final String? notes;

  Purchase({
    required this.id,
    required this.purchaserId,
    required this.purchaserName,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
    required this.paymentStatus,
    this.installmentAmount,
    this.installmentCount,
    this.remainingBalance,
    required this.createdAt,
    this.notes,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: (json['id'] ?? '').toString(),
      purchaserId: (json['purchaser_id'] ?? json['purchaserId'] ?? '').toString(),
      purchaserName: (json['purchasers']?['name'] ?? json['purchaserName'] ?? 'Unknown').toString(),
      productId: (json['product_id'] ?? json['productId'] ?? '').toString(),
      productName: (json['products']?['name'] ?? json['productName'] ?? 'Unknown Product').toString(),
      quantity: (json['quantity'] ?? 0) as int,
      unitPrice: (json['unit_price'] ?? json['unitPrice'] ?? 0.0).toDouble(),
      totalAmount: (json['total_amount'] ?? json['totalAmount'] ?? 0.0).toDouble(),
      paymentStatus: (json['payment_status'] ?? json['paymentStatus'] ?? 'fully_paid').toString(),
      installmentAmount: (json['installment_amount'] ?? json['installmentAmount'] as num?)?.toDouble(),
      installmentCount: json['installment_count'] ?? json['installmentCount'] as int?,
      remainingBalance: (json['remaining_balance'] ?? json['remainingBalance'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['created_at'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()),
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'purchaser_id': purchaserId,
      'purchaser_name': purchaserName,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_amount': totalAmount,
      'payment_status': paymentStatus,
      'installment_amount': installmentAmount,
      'installment_count': installmentCount,
      'remaining_balance': remainingBalance,
      'created_at': createdAt.toIso8601String(),
      'notes': notes,
    };
  }
}
