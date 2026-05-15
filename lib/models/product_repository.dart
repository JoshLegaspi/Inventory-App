import 'package:supabase_flutter/supabase_flutter.dart';
import 'product.dart';

class ProductRepository {
  static final ProductRepository _instance = ProductRepository._internal();
  final _supabase = Supabase.instance.client;

  factory ProductRepository() => _instance;
  ProductRepository._internal();

  // Get products with supplier details using a join
  Future<List<Product>> getAllProducts() async {
    final response = await _supabase
        .from('products')
        .select('*, suppliers(*)');
    
    return (response as List).map((data) => Product.fromJson(data)).toList();
  }

  Future<Product> addProduct({
    required String name,
    String? description, // Add this line
    required String sku,
    required double unitPrice,
    required int quantity,
    required String category,
    String? supplierId,
  }) async {
    try {
      final response = await _supabase.from('products').insert({
        'name': name,
        'description': description,
        'sku': sku,
        'unit_price': unitPrice,
        'quantity': quantity,
        'category': category,
        'supplier_id': supplierId,
      }).select().single();

      return Product.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateStock(String productId, int newQuantity) async {
    await _supabase
        .from('products')
        .update({'quantity': newQuantity})
        .eq('id', productId);
  }

  Future<void> updateProduct(String id, Map<String, dynamic> updates) async {
    await _supabase
        .from('products')
        .update(updates)
        .eq('id', id);
  }

  Future<void> deleteProduct(String id) async {
    await _supabase
        .from('products')
        .delete()
        .eq('id', id);
  }
}