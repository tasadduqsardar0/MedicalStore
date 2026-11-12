import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/app_colors.dart';

class RecoveryCodeScreen extends StatefulWidget {
  final String recoveryCode;
  final bool isFirstRun;

  const RecoveryCodeScreen({
    super.key,
    required this.recoveryCode,
    this.isFirstRun = false,
  });

  @override
  State<RecoveryCodeScreen> createState() => _RecoveryCodeScreenState();
}

class _RecoveryCodeScreenState extends State<RecoveryCodeScreen> {
  bool _isAcknowledged = false;
  bool _isCopied = false;

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.recoveryCode));
    setState(() => _isCopied = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Recovery code copied to clipboard!'),
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
        title: const Text('One-Time Recovery Code'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Warning Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warningLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.warning),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Save This Code In A Safe Place',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'This code is shown ONLY ONCE. If you ever forget the owner password, this recovery code is the only way to reset it without losing store records.',
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

              // Code Display Card
              Center(
                child: Text(
                  'YOUR OWNER RECOVERY CODE',
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
                      widget.recoveryCode,
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

              // Acknowledge Checkbox
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
                    'I have written down and securely stored this recovery code.',
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

              // Proceed Button
              ElevatedButton(
                onPressed: _isAcknowledged
                    ? () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/main',
                          (route) => false,
                        );
                      }
                    : null,
                child: Text(widget.isFirstRun ? 'Enter Tariq Medical Store' : 'Return to App'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

