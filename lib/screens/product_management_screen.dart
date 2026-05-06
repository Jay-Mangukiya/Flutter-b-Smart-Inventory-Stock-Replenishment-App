import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/inventory_provider.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class ProductManagementScreen extends StatelessWidget {
  const ProductManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final inv = context.watch<InventoryProvider>();
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: () => _showProductForm(context, null),
              icon: const Icon(Icons.add, color: kPrimary),
              label: const Text('Add', style: TextStyle(color: kPrimary)),
            ),
          ),
        ],
      ),
      body: inv.allProducts.isEmpty
          ? _Empty()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: inv.allProducts.length,
              itemBuilder: (context, i) {
                final product = inv.allProducts[i];
                return ProductListTile(
                  product: product,
                  onEdit: () => _showProductForm(context, product),
                  onDelete: () => _confirmDelete(context, inv, product),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProductForm(context, null),
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
    );
  }

  Future<void> _showProductForm(
      BuildContext context, Product? product) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kSurface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _ProductFormSheet(product: product),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, InventoryProvider inv, Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Product?',
            style: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to delete "${product.name}"?',
            style: const TextStyle(color: kTextSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kError),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<InventoryProvider>().deleteProduct(product.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('"${product.name}" deleted'),
            backgroundColor: kError));
      }
    }
  }
}

class _Empty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 72, color: kTextSecondary),
          const SizedBox(height: 16),
          const Text('No products yet',
              style: TextStyle(
                  color: kTextPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('Tap the + button to add your first product',
              style: TextStyle(color: kTextSecondary)),
        ],
      ),
    );
  }
}

// ─── Product Form Bottom Sheet ─────────────────────────────────────────────
class _ProductFormSheet extends StatefulWidget {
  final Product? product;
  const _ProductFormSheet({this.product});

  @override
  State<_ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends State<_ProductFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _categoryCtrl;
  late final TextEditingController _quantityCtrl;
  late final TextEditingController _minThresholdCtrl;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.product != null;
    _nameCtrl = TextEditingController(text: widget.product?.name ?? '');
    _categoryCtrl =
        TextEditingController(text: widget.product?.category ?? '');
    _quantityCtrl = TextEditingController(
        text: widget.product?.quantity.toString() ?? '');
    _minThresholdCtrl = TextEditingController(
        text: widget.product?.minThreshold.toString() ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _categoryCtrl.dispose();
    _quantityCtrl.dispose();
    _minThresholdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 32),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Handle ─────────────────────────────────────────────────
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: kBorder, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text(_isEditing ? 'Edit Product' : 'Add New Product',
                style: const TextStyle(
                    color: kTextPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 24),

            // ─── Fields ──────────────────────────────────────────────────
            _Field(
              controller: _nameCtrl,
              label: 'Product Name',
              icon: Icons.label_outline,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Product name is required'
                  : null,
            ),
            const SizedBox(height: 14),
            _Field(
              controller: _categoryCtrl,
              label: 'Category',
              icon: Icons.category_outlined,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Category is required' : null,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _Field(
                    controller: _quantityCtrl,
                    label: 'Quantity',
                    icon: Icons.numbers,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Required';
                      }
                      final n = double.tryParse(v);
                      if (n == null || n < 0) {
                        return 'Must be ≥ 0';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _Field(
                    controller: _minThresholdCtrl,
                    label: 'Min Threshold',
                    icon: Icons.warning_amber_outlined,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Required';
                      }
                      final n = double.tryParse(v);
                      if (n == null || n < 0) {
                        return 'Must be ≥ 0';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                child: Text(_isEditing ? 'Save Changes' : 'Add Product'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final inv = context.read<InventoryProvider>();
    final now = DateTime.now();

    if (_isEditing) {
      widget.product!
        ..name = _nameCtrl.text.trim()
        ..category = _categoryCtrl.text.trim()
        ..quantity = double.parse(_quantityCtrl.text)
        ..minThreshold = double.parse(_minThresholdCtrl.text)
        ..updatedAt = now;
      await inv.updateProduct(widget.product!);
    } else {
      final p = Product(
        id: const Uuid().v4(),
        name: _nameCtrl.text.trim(),
        category: _categoryCtrl.text.trim(),
        quantity: double.parse(_quantityCtrl.text),
        minThreshold: double.parse(_minThresholdCtrl.text),
        createdAt: now,
        updatedAt: now,
      );
      await inv.addProduct(p);
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_isEditing ? 'Product updated!' : 'Product added!'),
          backgroundColor: kSuccess));
    }
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: kTextPrimary),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: kTextSecondary, size: 20),
      ),
      validator: validator,
    );
  }
}
