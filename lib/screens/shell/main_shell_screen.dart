import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../widgets/app_drawer.dart';
import '../../providers/inventory_provider.dart';
import '../dashboard/dashboard_screen.dart';
import '../billing/new_sale_screen.dart';
import '../inventory/stock_home_screen.dart';
import '../dashboard/notifications_screen.dart';

class MainShellScreen extends StatefulWidget {
  final int initialTab;
  const MainShellScreen({super.key, this.initialTab = 0});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  void switchTab(int index) {
    setState(() => _currentIndex = index);
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryProvider>();
    final alertCount = inventory.lowStockMedicines.length +
        inventory.nearExpiryBatches.length +
        inventory.expiredBatches.length;

    final screens = [
      DashboardScreen(onNavigateTab: switchTab, onOpenDrawer: _openDrawer),
      NewSaleScreen(isEmbedded: true, onOpenDrawer: _openDrawer),
      StockHomeScreen(onOpenDrawer: _openDrawer),
      NotificationsScreen(onOpenDrawer: _openDrawer),
    ];

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentIndex != 0) {
          setState(() => _currentIndex = 0);
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        drawer: AppDrawer(onSelectDashboard: () => switchTab(0)),
        body: IndexedStack(
          index: _currentIndex,
          children: screens,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (idx) {
            setState(() => _currentIndex = idx);
          },
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            const NavigationDestination(
              icon: Icon(Icons.point_of_sale_outlined),
              selectedIcon: Icon(Icons.point_of_sale),
              label: 'Sale',
            ),
            const NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined),
              selectedIcon: Icon(Icons.inventory_2),
              label: 'Stock',
            ),
            NavigationDestination(
              icon: alertCount > 0
                  ? Badge(
                      label: Text('$alertCount'),
                      backgroundColor: AppColors.danger,
                      child: const Icon(Icons.notifications_outlined),
                    )
                  : const Icon(Icons.notifications_outlined),
              selectedIcon: alertCount > 0
                  ? Badge(
                      label: Text('$alertCount'),
                      backgroundColor: AppColors.danger,
                      child: const Icon(Icons.notifications),
                    )
                  : const Icon(Icons.notifications),
              label: 'Alerts',
            ),
          ],
        ),
      ),
    );
  }
}

