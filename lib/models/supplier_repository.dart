import 'package:supabase_flutter/supabase_flutter.dart';
import 'supplier.dart';

class SupplierRepository {
  static final SupplierRepository _instance = SupplierRepository._internal();
  final _supabase = Supabase.instance.client;

  factory SupplierRepository() {
    return _instance;
  }

  SupplierRepository._internal();

  // Get all suppliers
  Future<List<Supplier>> getAllSuppliers() async {
    try {
      final response = await _supabase
          .from('suppliers')
          .select()
          .order('name', ascending: true);
      
      final List<dynamic> data = response as List<dynamic>;
      return data
          .map((json) => Supplier.fromJson(Map<String, dynamic>.from(json as Map)))
          .toList();
    } catch (e) {
      print('Error in getAllSuppliers: $e');
      rethrow;
    }
  }

  // Add new supplier
  Future<Supplier> addSupplier({
    required String name,
    required String contactPerson,
    required String email,
    required String phone,
    required String address,
  }) async {
    try {
      final response = await _supabase.from('suppliers').insert({
        'name': name,
        'contact_person': contactPerson,
        'email': email,
        'phone': phone,
        'address': address,
      }).select().single();

      return Supplier.fromJson(Map<String, dynamic>.from(response as Map));
    } catch (e) {
      print('Error in addSupplier: $e');
      rethrow; // Rethrow to let the UI handle the error message
    }
  }

  // Edit supplier
  Future<bool> editSupplier(
    String id, {
    required String name,
    required String contactPerson,
    required String email,
    required String phone,
    required String address,
  }) async {
    try {
      await _supabase.from('suppliers').update({
        'name': name,
        'contact_person': contactPerson,
        'email': email,
        'phone': phone,
        'address': address,
      }).eq('id', id);
      return true;
    } catch (e) {
      rethrow;
    }
  }

  // Delete supplier
  Future<bool> deleteSupplier(String id) async {
    try {
      await _supabase.from('suppliers').delete().eq('id', id);
      return true;
    } catch (e) {
      rethrow;
    }
  }
}