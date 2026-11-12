import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../widgets/alert_chip.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showChangePasswordDialog(BuildContext context) {
    final currentPw = TextEditingController();
    final newPw = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Password'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentPw,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Current Password'),
                validator: (v) => v == null || v.isEmpty ? 'Enter current password' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: newPw,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New Password'),
                validator: (v) => v == null || v.length < 4 ? 'Min 4 characters required' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              final auth = Provider.of<AuthProvider>(context, listen: false);
              final ok = auth.changePassword(currentPw.text, newPw.text);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(ok ? 'Password updated successfully' : 'Incorrect current password'),
                  backgroundColor: ok ? AppColors.success : AppColors.danger,
                ),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final settings = context.watch<SettingsProvider>().settings;
    final user = auth.currentUser;
    final isOwner = auth.isOwner;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('User & Store Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // User Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      user?.name.isNotEmpty == true ? user!.name[0] : 'U',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.name ?? 'Unknown User',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${user?.username ?? "user"}',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  AlertChip.role(isOwner ? 'Owner (Full Admin Access)' : 'Staff Member', isOwner: isOwner),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Store Details
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pharmacy Store Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 12),
                  _ProfileRow(label: 'Store Name', value: settings.storeName),
                  _ProfileRow(label: 'Location', value: settings.address),
                  _ProfileRow(label: 'Phone Contact', value: settings.phone),
                  _ProfileRow(label: 'Currency', value: 'Pakistani Rupee (Rs)'),
                  _ProfileRow(label: 'Language', value: 'English'),
                  _ProfileRow(
                    label: 'Auto Logout Inactivity',
                    value: settings.autoLogoutMinutes > 0 ? '${settings.autoLogoutMinutes} minutes' : 'Disabled (0)',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Security Settings Card
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.lock_reset, color: AppColors.primary),
                  title: const Text('Change Password'),
                  subtitle: const Text('Update your personal login password'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showChangePasswordDialog(context),
                ),
                if (isOwner)
                  ListTile(
                    leading: const Icon(Icons.vpn_key_outlined, color: AppColors.primaryDark),
                    title: const Text('One-Time Recovery Code Policy'),
                    subtitle: const Text('Shown once on setup & after each password reset'),
                    trailing: const Icon(Icons.info_outline, size: 18),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Recovery Code Security'),
                          content: const Text(
                            'For your security, the owner recovery code is displayed ONLY ONCE during initial setup and after each password reset.\n\nIf you lose access, use "Forgot Password?" on the Login screen with your saved recovery code to reset your password and receive a brand new code.',
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Logout Button
          ElevatedButton.icon(
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('Logout Session'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              minimumSize: const Size.fromHeight(48),
            ),
            onPressed: () {
              auth.logout();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
          ),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

