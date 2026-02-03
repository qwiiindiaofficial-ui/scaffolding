import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase_service.dart';

class StockService {
  final SupabaseClient _client = SupabaseService.client;

  Future<List<Map<String, dynamic>>> getCategories(String companyId) async {
    final response = await _client
        .from('stock_categories')
        .select()
        .eq('company_id', companyId)
        .order('name');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> createCategory({
    required String companyId,
    required String name,
    String? hsnCode,
    String? imageUrl,
    String? description,
  }) async {
    final data = {
      'company_id': companyId,
      'name': name,
      'hsn_code': hsnCode,
      'image_url': imageUrl,
      'description': description,
    };

    final response = await _client
        .from('stock_categories')
        .insert(data)
        .select()
        .single();

    return response;
  }

  Future<List<Map<String, dynamic>>> getStockItems({
    required String companyId,
    String? categoryId,
    bool? isActive,
  }) async {
    var query = _client
        .from('stock_items')
        .select('*, stock_categories(name)')
        .eq('company_id', companyId);

    if (categoryId != null) {
      query = query.eq('category_id', categoryId);
    }

    if (isActive != null) {
      query = query.eq('is_active', isActive);
    }

    final response = await query.order('name');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> getStockItem(String itemId) async {
    final response = await _client
        .from('stock_items')
        .select('*, stock_categories(name)')
        .eq('id', itemId)
        .maybeSingle();
    return response;
  }

  Future<Map<String, dynamic>> createStockItem({
    required String companyId,
    String? categoryId,
    required String name,
    String? size,
    String? hsnCode,
    int quantity = 0,
    String unit = 'pcs',
    double weightPerUnit = 0,
    double rentRate = 0,
    double saleRate = 0,
    String? imageUrl,
  }) async {
    final data = {
      'company_id': companyId,
      'category_id': categoryId,
      'name': name,
      'size': size,
      'hsn_code': hsnCode,
      'quantity': quantity,
      'available_quantity': quantity,
      'dispatched_quantity': 0,
      'unit': unit,
      'weight_per_unit': weightPerUnit,
      'rent_rate': rentRate,
      'sale_rate': saleRate,
      'image_url': imageUrl,
      'is_active': true,
    };

    final response = await _client
        .from('stock_items')
        .insert(data)
        .select()
        .single();

    return response;
  }

  Future<Map<String, dynamic>> updateStockItem({
    required String itemId,
    String? categoryId,
    String? name,
    String? size,
    String? hsnCode,
    int? quantity,
    int? availableQuantity,
    int? dispatchedQuantity,
    String? unit,
    double? weightPerUnit,
    double? rentRate,
    double? saleRate,
    String? imageUrl,
    bool? isActive,
  }) async {
    final data = <String, dynamic>{'updated_at': DateTime.now().toIso8601String()};

    if (categoryId != null) data['category_id'] = categoryId;
    if (name != null) data['name'] = name;
    if (size != null) data['size'] = size;
    if (hsnCode != null) data['hsn_code'] = hsnCode;
    if (quantity != null) data['quantity'] = quantity;
    if (availableQuantity != null) data['available_quantity'] = availableQuantity;
    if (dispatchedQuantity != null) data['dispatched_quantity'] = dispatchedQuantity;
    if (unit != null) data['unit'] = unit;
    if (weightPerUnit != null) data['weight_per_unit'] = weightPerUnit;
    if (rentRate != null) data['rent_rate'] = rentRate;
    if (saleRate != null) data['sale_rate'] = saleRate;
    if (imageUrl != null) data['image_url'] = imageUrl;
    if (isActive != null) data['is_active'] = isActive;

    final response = await _client
        .from('stock_items')
        .update(data)
        .eq('id', itemId)
        .select()
        .single();

    return response;
  }

  Future<void> deleteStockItem(String itemId) async {
    await _client.from('stock_items').delete().eq('id', itemId);
  }

  Future<Map<String, dynamic>> createStockTransaction({
    required String companyId,
    required String stockItemId,
    required String transactionType,
    required int quantity,
    String? referenceType,
    String? referenceId,
    String? notes,
  }) async {
    final data = {
      'company_id': companyId,
      'stock_item_id': stockItemId,
      'transaction_type': transactionType,
      'quantity': quantity,
      'reference_type': referenceType,
      'reference_id': referenceId,
      'notes': notes,
      'created_by': SupabaseService.currentUserId,
    };

    final response = await _client
        .from('stock_transactions')
        .insert(data)
        .select()
        .single();

    return response;
  }

  Future<List<Map<String, dynamic>>> getStockTransactions({
    required String stockItemId,
    int limit = 50,
  }) async {
    final response = await _client
        .from('stock_transactions')
        .select()
        .eq('stock_item_id', stockItemId)
        .order('transaction_date', ascending: false)
        .limit(limit);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> searchStockItems({
    required String companyId,
    required String searchTerm,
  }) async {
    final response = await _client
        .from('stock_items')
        .select('*, stock_categories(name)')
        .eq('company_id', companyId)
        .or('name.ilike.%$searchTerm%,size.ilike.%$searchTerm%')
        .limit(20);

    return List<Map<String, dynamic>>.from(response);
  }
}
