import 'package:supabase_flutter/supabase_flutter.dart';
import 'purchase.dart';

class PurchaseRepository {
  static final PurchaseRepository _instance = PurchaseRepository._internal();
  final _supabase = Supabase.instance.client;

  factory PurchaseRepository() => _instance;
  PurchaseRepository._internal();

  Future<List<Purchase>> getAllPurchases() async {
    final response = await _supabase
        .from('purchases')
        .select('*, products(name), purchasers(name)');
        
    return (response as List)
        .map((p) => Purchase.fromJson(Map<String, dynamic>.from(p as Map)))
        .toList();
  }

  Future<Purchase> recordSale({
    required String productId,
    required String purchaserId,
    required int quantity,
    required double unitPrice,
    required double totalPrice,
    required String paymentStatus,
    int? installmentCount,
    double? installmentAmount,
    String? notes,
  }) async {
    final response = await _supabase.from('purchases').insert({
      'product_id': productId,
      'purchaser_id': purchaserId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_amount': totalPrice,
      'payment_status': paymentStatus,
      'installment_count': installmentCount,
      'installment_amount': installmentAmount,
      'notes': notes,
    }).select().single();

    return Purchase.fromJson(Map<String, dynamic>.from(response as Map));
  }

  Future<void> clearAllPurchases() async {
    await _supabase.from('purchases').delete().neq('id', '00000000-0000-0000-0000-000000000000');
  }
}