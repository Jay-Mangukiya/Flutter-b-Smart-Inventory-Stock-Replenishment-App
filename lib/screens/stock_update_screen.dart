import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class StockUpdateScreen extends StatefulWidget {
  const StockUpdateScreen({super.key});
  @override
  State<StockUpdateScreen> createState() => _StockUpdateScreenState();
}

class _StockUpdateScreenState extends State<StockUpdateScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Product? _selectedProduct;
  final _qtyCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _qtyCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inv = context.watch<InventoryProvider>();
    final products = inv.allProducts;

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text('Stock Update'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: kPrimary,
          unselectedLabelColor: kTextSecondary,
          indicatorColor: kPrimary,
          tabs: const [
            Tab(icon: Icon(Icons.add_circle_outline), text: 'Stock In'),
            Tab(icon: Icon(Icons.remove_circle_outline), text: 'Stock Out'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildForm(context, products, isStockIn: true),
          _buildForm(context, products, isStockIn: false),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context, List<Product> products,
      {required bool isStockIn}) {
    final color = isStockIn ? kSuccess : kError;
    final icon =
        isStockIn ? Icons.add_circle_outline : Icons.remove_circle_outline;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header Banner ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.05)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(icon, color: color, size: 32),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isStockIn ? 'Add Stock' : 'Remove Stock',
                          style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w700,
                              fontSize: 16)),
                      Text(
                          isStockIn
                              ? 'Record new items added to inventory'
                              : 'Record items used or sold',
                          style: const TextStyle(
                              color: kTextSecondary, fontSize: 12)),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text('Select Product',
                style: TextStyle(
                    color: kTextPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),

            // ─── Product Dropdown ───────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: kSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kBorder),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Product>(
                  value: _selectedProduct,
                  isExpanded: true,
                  dropdownColor: kCard,
                  hint: const Text('Choose a product',
                      style: TextStyle(color: kTextSecondary)),
                  icon: const Icon(Icons.expand_more, color: kTextSecondary),
                  items: products
                      .map((p) => DropdownMenuItem(
                            value: p,
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(p.name,
                                    style: const TextStyle(
                                        color: kTextPrimary)),
                                StockStatusBadge(status: p.stockStatus),
                              ],
                            ),
                          ))
                      .toList(),
                  onChanged: (p) => setState(() => _selectedProduct = p),
                ),
              ),
            ),

            // ─── Current Stock Display ──────────────────────────────────
            if (_selectedProduct != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: kCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: kTextSecondary, size: 18),
                    const SizedBox(width: 10),
                    Text('Current stock: ',
                        style: const TextStyle(color: kTextSecondary)),
                    Text(
                        '${_selectedProduct!.quantity.toStringAsFixed(0)} units',
                        style: const TextStyle(
                            color: kTextPrimary,
                            fontWeight: FontWeight.w700)),
                    const Spacer(),
                    StockStatusBadge(status: _selectedProduct!.stockStatus),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),
            const Text('Quantity',
                style: TextStyle(
                    color: kTextPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _qtyCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: kTextPrimary, fontSize: 24),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '0',
                hintStyle:
                    const TextStyle(color: kTextSecondary, fontSize: 24),
                suffixText: 'units',
                suffixStyle: const TextStyle(color: kTextSecondary),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Quantity required';
                final n = double.tryParse(v);
                if (n == null) return 'Invalid number';
                if (n <= 0) return 'Must be greater than zero';
                return null;
              },
            ),

            const SizedBox(height: 16),
            TextFormField(
              controller: _noteCtrl,
              style: const TextStyle(color: kTextPrimary),
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                prefixIcon: Icon(Icons.notes, color: kTextSecondary),
              ),
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    padding: const EdgeInsets.symmetric(vertical: 16)),
                onPressed: _isLoading
                    ? null
                    : () => _submit(context, isStockIn: isStockIn),
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Icon(icon),
                label: Text(isStockIn ? 'Add to Stock' : 'Remove from Stock',
                    style: const TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context, {required bool isStockIn}) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please select a product'),
          backgroundColor: kWarning));
      return;
    }

    setState(() => _isLoading = true);
    final inv = context.read<InventoryProvider>();
    final qty = double.parse(_qtyCtrl.text);
    final note =
        _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim();

    String? error;
    if (isStockIn) {
      error = await inv.stockIn(
          productId: _selectedProduct!.id, quantity: qty, note: note);
    } else {
      error = await inv.stockOut(
          productId: _selectedProduct!.id, quantity: qty, note: note);
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: kError));
    } else {
      _qtyCtrl.clear();
      _noteCtrl.clear();
      setState(() => _selectedProduct = null);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isStockIn
              ? 'Stock added successfully!'
              : 'Stock removed successfully!'),
          backgroundColor: kSuccess));
    }
  }
}
