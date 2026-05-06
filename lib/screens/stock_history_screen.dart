import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/inventory_provider.dart';
import '../models/stock_log.dart';
import '../theme/app_theme.dart';

class StockHistoryScreen extends StatelessWidget {
  const StockHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final inv = context.watch<InventoryProvider>();
    final logs = inv.allLogs;

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text('Stock History'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Chip(
              label: Text('${logs.length} logs',
                  style: const TextStyle(color: kTextSecondary, fontSize: 12)),
              backgroundColor: kCard,
              side: const BorderSide(color: kBorder),
            ),
          ),
        ],
      ),
      body: logs.isEmpty
          ? _Empty()
          : ListView.builder(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: logs.length,
              itemBuilder: (ctx, i) {
                // Group by date
                final log = logs[i];
                final showDate = i == 0 ||
                    !_sameDay(log.timestamp, logs[i - 1].timestamp);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showDate) _DateHeader(date: log.timestamp),
                    _LogTile(log: log),
                  ],
                );
              },
            ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _DateHeader extends StatelessWidget {
  final DateTime date;
  const _DateHeader({required this.date});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;
    final isYesterday = date
        .difference(DateTime(now.year, now.month, now.day - 1))
        .inDays ==
        0;

    final label = isToday
        ? 'Today'
        : isYesterday
            ? 'Yesterday'
            : DateFormat('MMMM d, yyyy').format(date);

    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Row(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: kPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kPrimary.withValues(alpha: 0.3)),
            ),
            child: Text(label,
                style: const TextStyle(
                    color: kPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 12),
          const Expanded(child: Divider(color: kBorder)),
        ],
      ),
    );
  }
}

class _LogTile extends StatelessWidget {
  final StockLog log;
  const _LogTile({required this.log});

  @override
  Widget build(BuildContext context) {
    final isStockIn = log.type == StockLogType.stockIn;
    final color = isStockIn ? kSuccess : kError;
    final icon = isStockIn ? Icons.add_circle : Icons.remove_circle;
    final sign = isStockIn ? '+' : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // ─── Icon ─────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),

            // ─── Details ──────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(log.productName,
                      style: const TextStyle(
                          color: kTextPrimary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                          '${log.quantityBefore.toStringAsFixed(0)} → ${log.quantityAfter.toStringAsFixed(0)} units',
                          style: const TextStyle(
                              color: kTextSecondary, fontSize: 12)),
                    ],
                  ),
                  if (log.note != null && log.note!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text('📝 ${log.note}',
                        style: const TextStyle(
                            color: kTextSecondary, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ],
              ),
            ),

            // ─── Quantity Change ──────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('$sign${log.quantityChanged.toStringAsFixed(0)}',
                    style: TextStyle(
                        color: color,
                        fontSize: 20,
                        fontWeight: FontWeight.w800)),
                Text(DateFormat('h:mm a').format(log.timestamp),
                    style: const TextStyle(
                        color: kTextSecondary, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 72, color: kTextSecondary),
          const SizedBox(height: 16),
          const Text('No stock history yet',
              style: TextStyle(
                  color: kTextPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('Stock updates will appear here',
              style: TextStyle(color: kTextSecondary)),
        ],
      ),
    );
  }
}
