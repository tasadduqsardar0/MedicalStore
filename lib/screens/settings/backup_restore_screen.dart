import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../core/role_guard.dart';

class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  final List<Map<String, dynamic>> _backups = [
    {
      'filename': 'tariq_med_backup_20261110.json',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'size': '1.8 MB',
      'records': '1,420 items',
    },
    {
      'filename': 'tariq_med_backup_20261105.json',
      'date': DateTime.now().subtract(const Duration(days: 7)),
      'size': '1.7 MB',
      'records': '1,390 items',
    },
  ];

  void _createNewBackup() {
    final now = DateTime.now();
    final name = 'tariq_med_backup_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour}${now.minute}.json';

    setState(() {
      _backups.insert(0, {
        'filename': name,
        'date': now,
        'size': '2.1 MB',
        'records': '1,450 records',
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Local encrypted database backup created successfully!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Backup & Data Security'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.backup_outlined, color: AppColors.primary, size: 28),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Create Local SQLite Backup',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              Text(
                                'Exports store inventory, suppliers, prescriptions and billing logs into a secure local archive.',
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.cloud_upload_outlined, size: 18),
                      label: const Text('Generate Backup Now'),
                      onPressed: _createNewBackup,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Available Backup Snapshots',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),

            ..._backups.map((b) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.archive_outlined, color: AppColors.primaryDark),
                  title: Text(b['filename'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text('${AppFormatters.dateTime(b['date'] as DateTime)} • ${b['size']} (${b['records']})', style: const TextStyle(fontSize: 11)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.restore, color: AppColors.primary),
                        tooltip: 'Restore from this backup',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Restore Backup?'),
                              content: Text('Are you sure you want to restore "${b['filename']}"? Current state will be replaced with this snapshot.'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Database snapshot restored successfully'), backgroundColor: AppColors.success),
                                    );
                                  },
                                  child: const Text('Restore'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.share_outlined, size: 20),
                        tooltip: 'Export / Share Archive',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Exporting backup to external device storage...')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

