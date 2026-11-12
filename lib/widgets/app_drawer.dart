import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import 'alert_chip.dart';

class AppDrawer extends StatelessWidget {
  final VoidCallback? onSelectDashboard;

  const AppDrawer({super.key, this.onSelectDashboard});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final settings = context.watch<SettingsProvider>().settings;
    final user = auth.currentUser;
    final isOwner = auth.isOwner;
    final isRealOwner = auth.isRealOwner;

    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.local_pharmacy_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          settings.storeName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          settings.address,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              user?.name ?? 'User',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            AlertChip.role(
                              isOwner ? 'Owner' : 'Staff',
                              isOwner: isOwner,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Navigation Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  // EVERYONE SECTION
                  _DrawerItem(
                    icon: Icons.dashboard_outlined,
                    title: 'Dashboard',
                    onTap: () {
                      Navigator.pop(context);
                      if (onSelectDashboard != null) {
                        onSelectDashboard!();
                      }
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.medical_services_outlined,
                    title: 'Prescriptions',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/prescriptions');
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.lock_clock_outlined,
                    title: 'Controlled Drugs',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/controlled-drugs');
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.person_outline,
                    title: 'Profile',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/profile');
                    },
                  ),

                  // OWNER ONLY SECTION
                  if (isOwner) ...[
                    const Divider(height: 24),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Text(
                        'OWNER ONLY',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                    _DrawerItem(
                      icon: Icons.local_shipping_outlined,
                      title: 'Purchasing & Suppliers',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/purchasing');
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'Finance & Cash Register',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/finance');
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.bar_chart_outlined,
                      title: 'Reports & Analytics',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/reports');
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.settings_outlined,
                      title: 'Staff & Settings',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/settings');
                      },
                    ),
                  ],

                  if (isRealOwner) ...[
                    const Divider(height: 16),
                    _DrawerItem(
                      icon: Icons.developer_mode_outlined,
                      title: 'Developer Tools',
                      textColor: AppColors.primaryDark,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/dev-tools');
                      },
                    ),
                  ],
                ],
              ),
            ),

            // Logout Footer
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.danger, size: 22),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Confirm Logout'),
                    content: const Text('Are you sure you want to log out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  Navigator.pop(context); // Close drawer
                  auth.logout();
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? textColor;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? AppColors.textPrimary, size: 22),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      dense: true,
      visualDensity: const VisualDensity(vertical: -1),
      onTap: onTap,
    );
  }
}

