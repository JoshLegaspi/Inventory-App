import 'package:supabase_flutter/supabase_flutter.dart';
import 'purchaser.dart';

class PurchaserRepository {
  static final PurchaserRepository _instance = PurchaserRepository._internal();
  final _supabase = Supabase.instance.client;

  factory PurchaserRepository() {
    return _instance;
  }

  PurchaserRepository._internal();

  // Get all purchasers
  Future<List<Purchaser>> getAllPurchasers() async {
    final response = await _supabase.from('purchasers').select();
    return (response as List)
        .map((p) => Purchaser.fromJson(Map<String, dynamic>.from(p as Map)))
        .toList();
  }

  // Get purchaser by ID
  Future<Purchaser?> getPurchaserById(String id) async {
    try {
      final response = await _supabase.from('purchasers').select().eq('id', id).single();
      return Purchaser.fromJson(Map<String, dynamic>.from(response as Map));
    } catch (e) {
      return null;
    }
  }

  // Create new purchaser
  Future<Purchaser> createPurchaser({
    required String name,
    required String email,
    required String phone,
    required String company,
    required String address,
  }) async {
    try {
      final response = await _supabase.from('purchasers').insert({
        'name': name,
        'email': email,
        'phone': phone,
        'company_name': company,
        'address': address,
      }).select().single();

      return Purchaser.fromJson(Map<String, dynamic>.from(response as Map));
    } catch (e) {
      rethrow;
    }
  }

  // Update purchaser details
  Future<bool> updatePurchaser(
    String id, {
    required String name,
    required String email,
    required String phone,
    required String company,
    required String address,
  }) async {
    try {
      await _supabase.from('purchasers').update({
        'name': name,
        'email': email,
        'phone': phone,
        'company_name': company,
        'address': address,
      }).eq('id', id);
      return true;
    } catch (e) {
      rethrow;
    }
  }

  // Update purchaser stats (usually called after a sale)
  Future<void> updatePurchaserStats(
    String id, {
    required double addToTotalSpent,
    required int addToTotalOrders,
  }) async {
    // Note: In a real app, you might use a RPC function in Postgres for atomic increments
    final current = await getPurchaserById(id);
    if (current == null) return;

    await _supabase.from('purchasers').update({
      'total_spent': current.totalSpent + addToTotalSpent,
      'total_orders': current.totalOrders + addToTotalOrders,
    }).eq('id', id);
  }

  // Delete purchaser
  Future<bool> deletePurchaser(String id) async {
    try {
      await _supabase.from('purchasers').delete().eq('id', id);
      return true;
    } catch (e) {
      rethrow;
    }
  }
}
