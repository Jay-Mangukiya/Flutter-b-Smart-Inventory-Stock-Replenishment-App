import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/product.dart';
import '../models/stock_log.dart';

class InventoryProvider extends ChangeNotifier {
  final _uuid = const Uuid();

  bool _initialized = false;
  bool get initialized => _initialized;

  // Hive boxes — accessed lazily after init()
  Box<Product> get _products => Hive.box<Product>('products');
  Box<StockLog> get _logs => Hive.box<StockLog>('stock_logs');

  // ─── Search & Filter State ────────────────────────────────────────────────
  String _searchQuery = '';
  String _filterCategory = 'All';
  String _filterStatus = 'All';

  String get searchQuery => _searchQuery;
  String get filterCategory => _filterCategory;
  String get filterStatus => _filterStatus;

  // ─── Init ─────────────────────────────────────────────────────────────────
  Future<void> init() async {
    _initialized = true;
    notifyListeners();
  }

  // ─── Products ──────────────────────────────────────────────────────────────
  List<Product> get allProducts => _products.values.toList();

  List<Product> get filteredProducts {
    return allProducts.where((p) {
      final matchesSearch = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.category.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory =
          _filterCategory == 'All' || p.category == _filterCategory;

      final matchesStatus = _filterStatus == 'All' ||
          (_filterStatus == 'Normal' && p.stockStatus == StockStatus.normal) ||
          (_filterStatus == 'Low' &&
              (p.stockStatus == StockStatus.low ||
                  p.stockStatus == StockStatus.critical)) ||
          (_filterStatus == 'Out of Stock' &&
              p.stockStatus == StockStatus.outOfStock);

      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();
  }

  List<Product> get lowStockProducts =>
      allProducts.where((p) => p.isLowStock).toList();

  List<Product> get recentlyUpdated {
    final list = allProducts.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list.take(5).toList();
  }

  List<String> get categories {
    final cats = allProducts.map((p) => p.category).toSet().toList()..sort();
    return ['All', ...cats];
  }

  int get totalProducts => allProducts.length;
  int get lowStockCount => lowStockProducts.length;
  int get outOfStockCount => allProducts.where((p) => p.isOutOfStock).length;

  Future<void> addProduct(Product product) async {
    await _products.put(product.id, product);
    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    product.updatedAt = DateTime.now();
    await product.save();
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    await _products.delete(id);
    final logsToDelete = _logs.values
        .where((l) => l.productId == id)
        .map((l) => l.id)
        .toList();
    for (final logId in logsToDelete) {
      await _logs.delete(logId);
    }
    notifyListeners();
  }

  Product? getProductById(String id) => _products.get(id);

  // ─── Stock Updates ─────────────────────────────────────────────────────────
  Future<String?> stockIn({
    required String productId,
    required double quantity,
    String? note,
  }) async {
    final product = _products.get(productId);
    if (product == null) return 'Product not found.';
    if (quantity <= 0) return 'Quantity must be greater than zero.';

    final before = product.quantity;
    product.quantity += quantity;
    product.updatedAt = DateTime.now();
    await product.save();

    final log = StockLog(
      id: _uuid.v4(),
      productId: productId,
      productName: product.name,
      type: StockLogType.stockIn,
      quantityChanged: quantity,
      quantityBefore: before,
      quantityAfter: product.quantity,
      note: note,
      timestamp: DateTime.now(),
    );
    await _logs.put(log.id, log);
    notifyListeners();
    return null;
  }

  Future<String?> stockOut({
    required String productId,
    required double quantity,
    String? note,
  }) async {
    final product = _products.get(productId);
    if (product == null) return 'Product not found.';
    if (quantity <= 0) return 'Quantity must be greater than zero.';
    if (product.quantity - quantity < 0) {
      return 'Insufficient stock. Available: ${product.quantity}';
    }

    final before = product.quantity;
    product.quantity -= quantity;
    product.updatedAt = DateTime.now();
    await product.save();

    final log = StockLog(
      id: _uuid.v4(),
      productId: productId,
      productName: product.name,
      type: StockLogType.stockOut,
      quantityChanged: quantity,
      quantityBefore: before,
      quantityAfter: product.quantity,
      note: note,
      timestamp: DateTime.now(),
    );
    await _logs.put(log.id, log);
    notifyListeners();
    return null;
  }

  // ─── Stock Logs ────────────────────────────────────────────────────────────
  List<StockLog> get allLogs {
    final logs = _logs.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return logs;
  }

  List<StockLog> logsForProduct(String productId) =>
      allLogs.where((l) => l.productId == productId).toList();

  // ─── Search & Filter ───────────────────────────────────────────────────────
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterCategory(String category) {
    _filterCategory = category;
    notifyListeners();
  }

  void setFilterStatus(String status) {
    _filterStatus = status;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _filterCategory = 'All';
    _filterStatus = 'All';
    notifyListeners();
  }
}
