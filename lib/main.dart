import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'models/product.dart';
import 'models/stock_log.dart';
import 'providers/inventory_provider.dart';
import 'screens/dashboard_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ─── Initialize Hive ──────────────────────────────────────────────────────
  await Hive.initFlutter();
  Hive.registerAdapter(ProductAdapter());
  Hive.registerAdapter(StockLogAdapter());

  await Hive.openBox<Product>('products');
  await Hive.openBox<StockLog>('stock_logs');

  runApp(const InventoryApp());
}

class InventoryApp extends StatelessWidget {
  const InventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => InventoryProvider()..init(),
      child: MaterialApp(
        title: 'Inventory Manager',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const _AppRoot(),
      ),
    );
  }
}

class _AppRoot extends StatelessWidget {
  const _AppRoot();

  @override
  Widget build(BuildContext context) {
    final inv = context.watch<InventoryProvider>();
    if (!inv.initialized) {
      return const Scaffold(
        backgroundColor: kBackground,
        body: Center(
          child: CircularProgressIndicator(color: kPrimary),
        ),
      );
    }
    return const DashboardScreen();
  }
}
