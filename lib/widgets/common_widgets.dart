import 'package:flutter/material.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';

// ─── Stock Status Badge ────────────────────────────────────────────────────
class StockStatusBadge extends StatelessWidget {
  final StockStatus status;
  const StockStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      StockStatus.normal => ('Normal', kSuccess),
      StockStatus.low => ('Low', kWarning),
      StockStatus.critical => ('Critical', kCritical),
      StockStatus.outOfStock => ('Out of Stock', kError),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

// ─── Gradient Card ────────────────────────────────────────────────────────
class GradientCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final IconData icon;

  const GradientCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1)),
          const SizedBox(height: 4),
          Text(title,
              style: const TextStyle(
                  color: kTextPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          Text(subtitle,
              style:
                  const TextStyle(color: kTextSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}

// ─── Section Header ────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const SectionHeader({super.key, required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                color: kTextPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700)),
        if (action != null)
          TextButton(
              onPressed: onAction,
              child: Text(action!, style: const TextStyle(color: kPrimary))),
      ],
    );
  }
}

// ─── Product Tile ─────────────────────────────────────────────────────────
class ProductListTile extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProductListTile({
    super.key,
    required this.product,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (product.stockStatus) {
      StockStatus.normal => kSuccess,
      StockStatus.low => kWarning,
      StockStatus.critical => kCritical,
      StockStatus.outOfStock => kError,
    };

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 48,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name,
                        style: const TextStyle(
                            color: kTextPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 15)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: kPrimary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(product.category,
                              style: const TextStyle(
                                  color: kPrimary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500)),
                        ),
                        const SizedBox(width: 8),
                        Text('Min: ${product.minThreshold}',
                            style: const TextStyle(
                                color: kTextSecondary, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(product.quantity.toStringAsFixed(0),
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 22,
                          fontWeight: FontWeight.w800)),
                  Text('units',
                      style:
                          const TextStyle(color: kTextSecondary, fontSize: 11)),
                ],
              ),
              if (onEdit != null || onDelete != null)
                PopupMenuButton<String>(
                  color: kCard,
                  icon: const Icon(Icons.more_vert, color: kTextSecondary),
                  itemBuilder: (context) => [
                    if (onEdit != null)
                      const PopupMenuItem(
                          value: 'edit',
                          child:
                              Row(children: [Icon(Icons.edit, color: kPrimary, size: 18), SizedBox(width: 8), Text('Edit', style: TextStyle(color: kTextPrimary))])),
                    if (onDelete != null)
                      const PopupMenuItem(
                          value: 'delete',
                          child:
                              Row(children: [Icon(Icons.delete, color: kError, size: 18), SizedBox(width: 8), Text('Delete', style: TextStyle(color: kError))])),
                  ],
                  onSelected: (val) {
                    if (val == 'edit') onEdit?.call();
                    if (val == 'delete') onDelete?.call();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
