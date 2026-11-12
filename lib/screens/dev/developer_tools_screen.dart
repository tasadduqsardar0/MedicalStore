import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/role_guard.dart';
import '../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/billing_provider.dart';
import '../../providers/supplier_provider.dart';
import '../../providers/prescription_provider.dart';
import '../../providers/finance_provider.dart';
import '../../providers/settings_provider.dart';

class DeveloperToolsScreen extends StatelessWidget {
  const DeveloperToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      allowRealOwner: true,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Developer & Testing Tools'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.developer_mode, color: AppColors.primaryDark),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Testing console: Switch roles dynamically to verify UI visibility rules, and load or reset realistic pharmacy demo data.',
                      style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Role Switcher Card
            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                final currentRole = auth.effectiveRole ?? UserRole.owner;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Active User Role Switcher',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Test how the app behaves when logged in as Owner vs Staff. Staff cannot see Purchasing, Finance, Reports, Settings, profit figures or delete buttons.',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ChoiceChip(
                                label: const Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.admin_panel_settings, size: 16),
                                      SizedBox(width: 6),
                                      Text('Owner'),
                                    ],
                                  ),
                                ),
                                selected: currentRole == UserRole.owner,
                                selectedColor: AppColors.primaryLight,
                                onSelected: (selected) {
                                  if (selected) {
                                    auth.switchRole(UserRole.owner);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Switched to Owner role'),
                                        backgroundColor: AppColors.primary,
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ChoiceChip(
                                label: const Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.badge, size: 16),
                                      SizedBox(width: 6),
                                      Text('Staff'),
                                    ],
                                  ),
                                ),
                                selected: currentRole == UserRole.staff,
                                selectedColor: AppColors.primaryLight,
                                onSelected: (selected) {
                                  if (selected) {
                                    auth.switchRole(UserRole.staff);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Switched to Staff role'),
                                        backgroundColor: AppColors.warning,
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.security, size: 16),
                            label: const Text('Test Owner-Only Guard (Open Reports)'),
                            onPressed: () {
                              Navigator.pushNamed(context, '/reports');
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Demo Data Management Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pharmacy Demo Data',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Load ~17 realistic medicines (Panadol, Calpol, Augmentin, Brufen, Flagyl...), batches covering all states (in stock, low stock, out of stock, expired, near expiry, controlled), suppliers, doctors, sales, and expenses.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.cloud_download_outlined, size: 18),
                            label: const Text('Load Demo Data'),
                            onPressed: () {
                              final settings = Provider.of<SettingsProvider>(context, listen: false);
                              settings.loadAllDemoData(
                                inventory: Provider.of<InventoryProvider>(context, listen: false),
                                billing: Provider.of<BillingProvider>(context, listen: false),
                                supplier: Provider.of<SupplierProvider>(context, listen: false),
                                prescription: Provider.of<PrescriptionProvider>(context, listen: false),
                                finance: Provider.of<FinanceProvider>(context, listen: false),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Demo data loaded successfully! 17 medicines, batches, suppliers & sales populated.'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.delete_sweep_outlined, size: 18, color: AppColors.danger),
                            label: const Text('Clear Demo Data', style: TextStyle(color: AppColors.danger)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.danger),
                            ),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Clear Demo Data?'),
                                  content: const Text('This will reset the app back to empty state. Are you sure?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, false),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                                      child: const Text('Clear All'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                final settings = Provider.of<SettingsProvider>(context, listen: false);
                                settings.clearAllDemoData(
                                  inventory: Provider.of<InventoryProvider>(context, listen: false),
                                  billing: Provider.of<BillingProvider>(context, listen: false),
                                  supplier: Provider.of<SupplierProvider>(context, listen: false),
                                  prescription: Provider.of<PrescriptionProvider>(context, listen: false),
                                  finance: Provider.of<FinanceProvider>(context, listen: false),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('All demo data cleared. App is now in empty state.'),
                                    backgroundColor: AppColors.textPrimary,
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

