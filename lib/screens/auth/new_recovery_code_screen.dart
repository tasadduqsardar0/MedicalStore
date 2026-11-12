import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/app_colors.dart';

class NewRecoveryCodeScreen extends StatefulWidget {
  final String newRecoveryCode;

  const NewRecoveryCodeScreen({
    super.key,
    required this.newRecoveryCode,
  });

  @override
  State<NewRecoveryCodeScreen> createState() => _NewRecoveryCodeScreenState();
}

class _NewRecoveryCodeScreenState extends State<NewRecoveryCodeScreen> {
  bool _isCopied = false;
  bool _isAcknowledged = false;

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.newRecoveryCode));
    setState(() => _isCopied = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('New recovery code copied!'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('New Recovery Code Generated'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Success notice
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.success),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_outline, color: AppColors.success, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Password Reset Successful',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Your password has been changed. Your previous recovery code is now obsolete. Below is your NEW replacement recovery code.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textPrimary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Center(
                child: Text(
                  'YOUR NEW RECOVERY CODE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SelectableText(
                      widget.newRecoveryCode,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                        color: AppColors.primaryDark,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: Icon(
                        _isCopied ? Icons.check_circle : Icons.copy,
                        color: _isCopied ? AppColors.success : AppColors.primary,
                        size: 22,
                      ),
                      onPressed: _copyToClipboard,
                      tooltip: 'Copy Code',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: CheckboxListTile(
                  value: _isAcknowledged,
                  onChanged: (val) {
                    setState(() => _isAcknowledged = val ?? false);
                  },
                  activeColor: AppColors.primary,
                  title: const Text(
                    'I have safely recorded my new recovery code.',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),

              const Spacer(),

              ElevatedButton(
                onPressed: _isAcknowledged
                    ? () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (route) => false,
                        );
                      }
                    : null,
                child: const Text('Proceed to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

