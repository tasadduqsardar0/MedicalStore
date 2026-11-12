import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../core/role_guard.dart';
import '../../widgets/empty_state.dart';
import '../../providers/settings_provider.dart';

class ActivityLogScreen extends StatelessWidget {
  const ActivityLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Store Audit & Activity Log'),
        ),
        body: Consumer<SettingsProvider>(
          builder: (context, settings, _) {
            final logs = settings.activityLogs;

            if (logs.isEmpty) {
              return const EmptyState(
                icon: Icons.history,
                title: 'No Activity Logged',
                message: 'All system transactions, security logins, and inventory changes will be audited here.',
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.security, color: AppColors.primaryDark, size: 20),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(log.action, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(
                          AppFormatters.dateTime(log.timestamp),
                          style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 2),
                        Text(log.details, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary)),
                        Text(
                          'User: ${log.userName} (${log.role})',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

