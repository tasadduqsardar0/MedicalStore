import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/validators.dart';
import '../../core/role_guard.dart';
import '../../data/models/user_model.dart';
import '../../widgets/app_text_field.dart';
import '../../providers/settings_provider.dart';

class AddEditStaffScreen extends StatefulWidget {
  final String? staffId;

  const AddEditStaffScreen({super.key, this.staffId});

  @override
  State<AddEditStaffScreen> createState() => _AddEditStaffScreenState();
}

class _AddEditStaffScreenState extends State<AddEditStaffScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  UserRole _role = UserRole.staff;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.staffId != null) {
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      final staff = settings.staffList.firstWhere((u) => u.id == widget.staffId);
      _nameController.text = staff.name;
      _usernameController.text = staff.username;
      _passwordController.text = staff.password;
      _phoneController.text = staff.phone;
      _role = staff.role;
      _isActive = staff.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final isEditing = widget.staffId != null;

    final user = User(
      id: isEditing ? widget.staffId! : 'staff-${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      username: _usernameController.text.trim().toLowerCase(),
      password: _passwordController.text.trim(),
      role: _role,
      phone: _phoneController.text.trim(),
      isActive: _isActive,
    );

    if (isEditing) {
      settings.updateStaff(user);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Staff member updated'), backgroundColor: AppColors.success),
      );
    } else {
      settings.addStaff(user);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Staff account created'), backgroundColor: AppColors.success),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.staffId != null;

    return RoleGuard(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(isEditing ? 'Edit Staff Member' : 'Register New Staff'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(
                    controller: _nameController,
                    label: 'Staff Full Name *',
                    hint: 'e.g. Ali Raza',
                    validator: (v) => AppValidators.requiredField(v, 'Enter staff name'),
                  ),
                  const SizedBox(height: 14),

                  AppTextField(
                    controller: _usernameController,
                    label: 'Login Username *',
                    hint: 'e.g. ali',
                    readOnly: isEditing,
                    validator: (v) => AppValidators.requiredField(v, 'Enter login username'),
                  ),
                  const SizedBox(height: 14),

                  AppPasswordField(
                    controller: _passwordController,
                    label: 'Login Password *',
                    hint: 'Set staff password',
                    validator: AppValidators.password,
                  ),
                  const SizedBox(height: 14),

                  AppTextField(
                    controller: _phoneController,
                    label: 'Contact Phone Number (optional)',
                    hint: 'e.g. 0304-9876543',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 14),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Role Permissions *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<UserRole>(
                        key: ValueKey(_role),
                        initialValue: _role,
                        items: const [
                          DropdownMenuItem(value: UserRole.staff, child: Text('Staff (Billing & Stock Counter)')),
                          DropdownMenuItem(value: UserRole.owner, child: Text('Owner (Full Administrator)')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _role = val);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: SwitchListTile(
                      title: const Text('Account Enabled / Active', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      value: _isActive,
                      activeThumbColor: AppColors.primary,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) => setState(() => _isActive = val),
                    ),
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: _submit,
                    child: Text(isEditing ? 'Save Staff Changes' : 'Create Staff Member'),
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

