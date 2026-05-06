import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'stock_update_screen.dart';
import 'product_management_screen.dart';
import 'stock_history_screen.dart';
import 'search_filter_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final _screens = const [
    _DashboardBody(),
    ProductManagementScreen(),
    StockUpdateScreen(),
    StockHistoryScreen(),
    SearchFilterScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: kSurface,
          border: Border(top: BorderSide(color: kBorder)),
        ),
        child: NavigationBar(
          backgroundColor: kSurface,
          selectedIndex: _selectedIndex,
          onDestinationSelected: (i) => setState(() => _selectedIndex = i),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard, color: kPrimary),
                label: 'Dashboard'),
            NavigationDestination(
                icon: Icon(Icons.inventory_2_outlined),
                selectedIcon: Icon(Icons.inventory_2, color: kPrimary),
                label: 'Products'),
            NavigationDestination(
                icon: Icon(Icons.swap_horiz_outlined),
                selectedIcon: Icon(Icons.swap_horiz, color: kPrimary),
                label: 'Stock'),
            NavigationDestination(
                icon: Icon(Icons.history_outlined),
                selectedIcon: Icon(Icons.history, color: kPrimary),
                label: 'History'),
            NavigationDestination(
                icon: Icon(Icons.search_outlined),
                selectedIcon: Icon(Icons.search, color: kPrimary),
                label: 'Search'),
          ],
        ),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody();

  @override
  Widget build(BuildContext context) {
    final inv = context.watch<InventoryProvider>();

    return Scaffold(
      backgroundColor: kBackground,
      body: CustomScrollView(
        slivers: [
          // ─── App Bar ──────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            snap: true,
            backgroundColor: kSurface,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Inventory',
                      style: TextStyle(
                          color: kPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                  const Text('Dashboard',
                      style: TextStyle(
                          color: kTextPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Alert Banner ──────────────────────────────────────
                  if (inv.lowStockCount > 0) ...[
                    _AlertBanner(count: inv.lowStockCount),
                    const SizedBox(height: 20),
                  ],

                  // ─── Summary Cards ─────────────────────────────────────
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.9,
                    children: [
                      GradientCard(
                        title: 'Total Products',
                        value: inv.totalProducts.toString(),
                        subtitle: 'In inventory',
                        color: kPrimary,
                        icon: Icons.inventory_2,
                      ),
                      GradientCard(
                        title: 'Low Stock',
                        value: inv.lowStockCount.toString(),
                        subtitle: 'Need attention',
                        color: kWarning,
                        icon: Icons.warning_amber_rounded,
                      ),
                      GradientCard(
                        title: 'Out of Stock',
                        value: inv.outOfStockCount.toString(),
                        subtitle: 'Fully depleted',
                        color: kError,
                        icon: Icons.remove_shopping_cart,
                      ),
                      GradientCard(
                        title: 'Categories',
                        value: (inv.categories.length - 1).toString(),
                        subtitle: 'Distinct groups',
                        color: kInfo,
                        icon: Icons.category,
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ─── Low Stock Items ───────────────────────────────────
                  if (inv.lowStockProducts.isNotEmpty) ...[
                    const SectionHeader(title: '⚠️  Low Stock Alerts'),
                    const SizedBox(height: 12),
                    ...inv.lowStockProducts
                        .map((p) => _LowStockCard(product: p)),
                    const SizedBox(height: 28),
                  ],

                  // ─── Recently Updated ──────────────────────────────────
                  const SectionHeader(title: '🕐  Recently Updated'),
                  const SizedBox(height: 12),
                  if (inv.recentlyUpdated.isEmpty)
                    _EmptyState(
                        message: 'No products yet. Add some to get started!'),
                  ...inv.recentlyUpdated.map((p) => _RecentTile(product: p)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertBanner extends StatelessWidget {
  final int count;
  const _AlertBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kWarning.withValues(alpha: 0.2), kError.withValues(alpha: 0.1)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kWarning.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: kWarning, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$count item${count > 1 ? 's' : ''} running low!',
                    style: const TextStyle(
                        color: kTextPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
                const Text('Stock below minimum threshold',
                    style: TextStyle(color: kTextSecondary, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LowStockCard extends StatelessWidget {
  final Product product;
  const _LowStockCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final color = product.stockStatus == StockStatus.critical
        ? kCritical
        : product.stockStatus == StockStatus.outOfStock
            ? kError
            : kWarning;
    final pct = product.minThreshold > 0
        ? (product.quantity / product.minThreshold).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(product.name,
                    style: const TextStyle(
                        color: kTextPrimary, fontWeight: FontWeight.w600)),
              ),
              StockStatusBadge(status: product.stockStatus),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: kBorder,
                    color: color,
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text('${product.quantity.toStringAsFixed(0)} / ${product.minThreshold.toStringAsFixed(0)}',
                  style: TextStyle(
                      color: color, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecentTile extends StatelessWidget {
  final Product product;
  const _RecentTile({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kBorder)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.inventory_2, color: kPrimary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(product.name,
                  style: const TextStyle(
                      color: kTextPrimary, fontWeight: FontWeight.w600)),
              Text(product.category,
                  style:
                      const TextStyle(color: kTextSecondary, fontSize: 12)),
            ]),
          ),
          StockStatusBadge(status: product.stockStatus),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, color: kTextSecondary, size: 48),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: kTextSecondary, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
