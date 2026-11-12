import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/validators.dart';
import '../../widgets/app_text_field.dart';
import '../../providers/auth_provider.dart';

class FirstRunOwnerSetupScreen extends StatefulWidget {
  const FirstRunOwnerSetupScreen({super.key});

  @override
  State<FirstRunOwnerSetupScreen> createState() => _FirstRunOwnerSetupScreenState();
}

class _FirstRunOwnerSetupScreenState extends State<FirstRunOwnerSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Tariq Mahmood');
  final _usernameController = TextEditingController(text: 'owner');
  final _phoneController = TextEditingController(text: '0300-1234567');
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final recoveryCode = await auth.setupOwner(
      name: _nameController.text,
      username: _usernameController.text,
      password: _passwordController.text,
      phone: _phoneController.text,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.pushReplacementNamed(
        context,
        '/recovery-code',
        arguments: {'code': recoveryCode, 'isFirstRun': true},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo / Header
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.local_pharmacy_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tariq Medical Store',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Main Bazaar, Hujra Shah Muqeem',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Welcome Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.admin_panel_settings, color: AppColors.primaryDark, size: 24),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'First-Time Setup: Owner Account',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Please create the pharmacy owner credentials. You will receive a one-time recovery code next.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textPrimary,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Fields
                  AppTextField(
                    controller: _nameController,
                    label: 'Owner Full Name',
                    hint: 'e.g. Tariq Mahmood',
                    prefixIcon: const Icon(Icons.person_outline, size: 20),
                    validator: (v) => AppValidators.requiredField(v, 'Enter owner full name'),
                  ),
                  const SizedBox(height: 14),

                  AppTextField(
                    controller: _usernameController,
                    label: 'Owner Username (for login)',
                    hint: 'e.g. owner',
                    prefixIcon: const Icon(Icons.account_circle_outlined, size: 20),
                    validator: (v) => AppValidators.requiredField(v, 'Enter login username'),
                  ),
                  const SizedBox(height: 14),

                  AppTextField(
                    controller: _phoneController,
                    label: 'Contact Phone Number',
                    hint: 'e.g. 0300-1234567',
                    keyboardType: TextInputType.phone,
                    prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                    validator: AppValidators.phone,
                  ),
                  const SizedBox(height: 14),

                  AppPasswordField(
                    controller: _passwordController,
                    label: 'Password',
                    hint: 'Create owner password',
                    validator: AppValidators.password,
                  ),
                  const SizedBox(height: 14),

                  AppPasswordField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password',
                    hint: 'Re-enter owner password',
                    validator: (v) => AppValidators.confirmPassword(v, _passwordController.text),
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Create Account & Generate Recovery Code'),
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

