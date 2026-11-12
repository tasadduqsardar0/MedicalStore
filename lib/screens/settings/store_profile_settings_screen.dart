import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/validators.dart';
import '../../core/role_guard.dart';
import '../../widgets/app_text_field.dart';
import '../../providers/settings_provider.dart';
import '../../providers/inventory_provider.dart';

class StoreProfileSettingsScreen extends StatefulWidget {
  const StoreProfileSettingsScreen({super.key});

  @override
  State<StoreProfileSettingsScreen> createState() => _StoreProfileSettingsScreenState();
}

class _StoreProfileSettingsScreenState extends State<StoreProfileSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _receiptFooterController = TextEditingController();
  final _nearExpiryDaysController = TextEditingController();
  final _autoLogoutMinutesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final settings = Provider.of<SettingsProvider>(context, listen: false).settings;
    _nameController.text = settings.storeName;
    _addressController.text = settings.address;
    _phoneController.text = settings.phone;
    _receiptFooterController.text = settings.receiptFooter;
    _nearExpiryDaysController.text = settings.nearExpiryDays.toString();
    _autoLogoutMinutesController.text = settings.autoLogoutMinutes.toString();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _receiptFooterController.dispose();
    _nearExpiryDaysController.dispose();
    _autoLogoutMinutesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final inventory = Provider.of<InventoryProvider>(context, listen: false);

    final nearDays = int.tryParse(_nearExpiryDaysController.text.trim()) ?? 30;
    final autoMinutes = int.tryParse(_autoLogoutMinutesController.text.trim()) ?? 10;

    settingsProvider.updateSettings(
      settingsProvider.settings.copyWith(
        storeName: _nameController.text.trim(),
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim(),
        receiptFooter: _receiptFooterController.text.trim(),
        nearExpiryDays: nearDays,
        autoLogoutMinutes: autoMinutes,
      ),
    );

    inventory.updateNearExpiryDays(nearDays);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Store settings updated successfully'), backgroundColor: AppColors.success),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Store Profile & System Settings'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Store Identification', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),

                  AppTextField(
                    controller: _nameController,
                    label: 'Store Name *',
                    hint: 'Tariq Medical Store',
                    validator: (v) => AppValidators.requiredField(v, 'Enter store name'),
                  ),
                  const SizedBox(height: 14),

                  AppTextField(
                    controller: _addressController,
                    label: 'Store Location / Address *',
                    hint: 'Main Bazaar, Hujra Shah Muqeem',
                    validator: (v) => AppValidators.requiredField(v, 'Enter address'),
                  ),
                  const SizedBox(height: 14),

                  AppTextField(
                    controller: _phoneController,
                    label: 'Store Contact Phone *',
                    hint: '0300-1234567',
                    validator: (v) => AppValidators.requiredField(v, 'Enter phone'),
                  ),
                  const SizedBox(height: 20),

                  const Text('Receipt Thermal Configuration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),

                  AppTextField(
                    controller: _receiptFooterController,
                    label: '80mm Receipt Footer Message',
                    hint: 'Get well soon! Check medicine expiry before leaving.',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 20),

                  const Text('Inventory & Security Parameters', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),

                  AppTextField(
                    controller: _nearExpiryDaysController,
                    label: 'Near-Expiry Threshold (Days) *',
                    hint: '30',
                    keyboardType: TextInputType.number,
                    helperText: 'Medicines expiring within this number of days trigger alerts',
                    validator: AppValidators.positiveInteger,
                  ),
                  const SizedBox(height: 14),

                  AppTextField(
                    controller: _autoLogoutMinutesController,
                    label: 'Auto Logout Inactivity (Minutes) *',
                    hint: '10',
                    keyboardType: TextInputType.number,
                    helperText: 'Minutes of inactivity before logging out (0 = Disabled)',
                    validator: AppValidators.nonNegativeNumber,
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Save System Settings'),
                  ),
                  const SizedBox(height: 28),
                  const Divider(),
                  const SizedBox(height: 12),
                  const Text(
                    'Administration & Data Tools',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.group_outlined, color: AppColors.primaryDark),
                      title: const Text('Staff & Users Management', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: const Text('Add, edit, or deactivate counter staff accounts'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.pushNamed(context, '/staff-list'),
                    ),
                  ),
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.backup_outlined, color: AppColors.primary),
                      title: const Text('Backup & Restore', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: const Text('Create local backups or restore store data'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.pushNamed(context, '/backup-restore'),
                    ),
                  ),
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.history, color: AppColors.textPrimary),
                      title: const Text('Activity & Security Log', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: const Text('View audit trail of logins, sales and adjustments'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.pushNamed(context, '/activity-log'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

