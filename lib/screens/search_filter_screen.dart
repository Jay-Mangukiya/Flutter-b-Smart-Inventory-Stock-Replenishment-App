import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class SearchFilterScreen extends StatefulWidget {
  const SearchFilterScreen({super.key});
  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inv = context.watch<InventoryProvider>();
    final results = inv.filteredProducts;

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(title: const Text('Search & Filter')),
      body: Column(
        children: [
          // ─── Search Bar ──────────────────────────────────────────────────
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(color: kTextPrimary),
              onChanged: (q) => inv.setSearchQuery(q),
              decoration: InputDecoration(
                hintText: 'Search products by name or category…',
                prefixIcon:
                    const Icon(Icons.search, color: kTextSecondary),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: kTextSecondary),
                        onPressed: () {
                          _searchCtrl.clear();
                          inv.setSearchQuery('');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // ─── Filter Chips ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Category',
                    style: TextStyle(
                        color: kTextSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: inv.categories.map((cat) {
                      final selected = inv.filterCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(cat),
                          selected: selected,
                          onSelected: (_) => inv.setFilterCategory(cat),
                          backgroundColor: kCard,
                          selectedColor: kPrimary.withValues(alpha: 0.25),
                          checkmarkColor: kPrimary,
                          labelStyle: TextStyle(
                              color:
                                  selected ? kPrimary : kTextSecondary,
                              fontSize: 12,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.w400),
                          side: BorderSide(
                              color: selected ? kPrimary : kBorder),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Stock Status',
                    style: TextStyle(
                        color: kTextSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children:
                        ['All', 'Normal', 'Low', 'Out of Stock'].map((s) {
                      final selected = inv.filterStatus == s;
                      final color = s == 'Normal'
                          ? kSuccess
                          : s == 'Low'
                              ? kWarning
                              : s == 'Out of Stock'
                                  ? kError
                                  : kPrimary;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(s),
                          selected: selected,
                          onSelected: (_) => inv.setFilterStatus(s),
                          backgroundColor: kCard,
                          selectedColor: color.withValues(alpha: 0.2),
                          checkmarkColor: color,
                          labelStyle: TextStyle(
                              color: selected ? color : kTextSecondary,
                              fontSize: 12,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.w400),
                          side: BorderSide(
                              color: selected ? color : kBorder),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // ─── Divider & Count ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${results.length} result${results.length != 1 ? 's' : ''}',
                    style: const TextStyle(
                        color: kTextSecondary, fontSize: 13)),
                if (inv.filterCategory != 'All' ||
                    inv.filterStatus != 'All' ||
                    inv.searchQuery.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      inv.clearFilters();
                      _searchCtrl.clear();
                    },
                    child: const Text('Clear all',
                        style: TextStyle(color: kPrimary, fontSize: 12)),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: kBorder),
          const SizedBox(height: 4),

          // ─── Results ─────────────────────────────────────────────────────
          Expanded(
            child: results.isEmpty
                ? _NoResults(
                    query: inv.searchQuery,
                    hasFilters: inv.filterCategory != 'All' ||
                        inv.filterStatus != 'All')
                : ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (ctx, i) => ProductListTile(
                      product: results[i],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  final String query;
  final bool hasFilters;
  const _NoResults({required this.query, required this.hasFilters});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: kTextSecondary),
          const SizedBox(height: 16),
          const Text('No products found',
              style: TextStyle(
                  color: kTextPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(
              query.isNotEmpty
                  ? 'No results for "$query"'
                  : hasFilters
                      ? 'No products match current filters'
                      : 'Try a different search term',
              textAlign: TextAlign.center,
              style: const TextStyle(color: kTextSecondary)),
        ],
      ),
    );
  }
}
