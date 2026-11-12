import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/validators.dart';
import '../../widgets/app_text_field.dart';
import '../../providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _recoveryCodeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _recoveryCodeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final newCode = auth.resetPasswordWithRecoveryCode(
      username: _usernameController.text,
      recoveryCode: _recoveryCodeController.text,
      newPassword: _newPasswordController.text,
    );

    if (newCode != null) {
      Navigator.pushReplacementNamed(
        context,
        '/new-recovery-code',
        arguments: newCode,
      );
    } else {
      setState(() {
        _errorMessage = 'Invalid username or recovery code. Please check and try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Reset Owner Password'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info Box
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.shield_outlined, color: AppColors.primaryDark, size: 24),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Enter the username and your one-time recovery code to set a new password. A brand new recovery code will be generated upon reset.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.dangerLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.danger),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(fontSize: 13, color: AppColors.danger),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                AppTextField(
                  controller: _usernameController,
                  label: 'Owner Username',
                  hint: 'Enter your owner username',
                  prefixIcon: const Icon(Icons.person_outline, size: 20),
                  validator: (v) => AppValidators.requiredField(v, 'Enter username'),
                ),
                const SizedBox(height: 14),

                AppTextField(
                  controller: _recoveryCodeController,
                  label: 'Recovery Code',
                  hint: 'e.g. ABCD-EFGH-JKLM',
                  prefixIcon: const Icon(Icons.vpn_key_outlined, size: 20),
                  validator: (v) => AppValidators.requiredField(v, 'Enter your recovery code'),
                ),
                const SizedBox(height: 14),

                AppPasswordField(
                  controller: _newPasswordController,
                  label: 'New Password',
                  hint: 'Enter new password',
                  validator: AppValidators.password,
                ),
                const SizedBox(height: 14),

                AppPasswordField(
                  controller: _confirmPasswordController,
                  label: 'Confirm New Password',
                  hint: 'Re-enter new password',
                  validator: (v) => AppValidators.confirmPassword(v, _newPasswordController.text),
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Reset Password & Get New Code'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

