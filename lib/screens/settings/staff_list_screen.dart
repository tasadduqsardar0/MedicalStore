import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/role_guard.dart';
import '../../data/models/user_model.dart';
import '../../widgets/alert_chip.dart';
import '../../widgets/empty_state.dart';
import '../../providers/settings_provider.dart';

class StaffListScreen extends StatelessWidget {
  const StaffListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Staff & User Management'),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.person_add),
          label: const Text('Add Staff'),
          onPressed: () => Navigator.pushNamed(context, '/add-staff'),
        ),
        body: Consumer<SettingsProvider>(
          builder: (context, settings, _) {
            final staff = settings.staffList;

            if (staff.isEmpty) {
              return EmptyState(
                icon: Icons.people_outline,
                title: 'No Staff Accounts',
                message: 'Register counter staff members with restricted billing and inventory permissions.',
                buttonText: 'Add First Staff Member',
                onButtonPressed: () => Navigator.pushNamed(context, '/add-staff'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
              itemCount: staff.length,
              itemBuilder: (context, index) {
                final user = staff[index];
                final isOwner = user.role == UserRole.owner;

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      backgroundColor: isOwner ? AppColors.primaryLight : AppColors.surfaceVariant,
                      child: Text(
                        user.name[0],
                        style: TextStyle(
                          color: isOwner ? AppColors.primaryDark : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(width: 8),
                        AlertChip.role(isOwner ? 'Owner' : 'Staff', isOwner: isOwner),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('@${user.username} • Phone: ${user.phone.isNotEmpty ? user.phone : "None"}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        Text(
                          user.isActive ? 'Status: Active Account' : 'Status: Deactivated',
                          style: TextStyle(
                            fontSize: 11,
                            color: user.isActive ? AppColors.success : AppColors.danger,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    trailing: !isOwner
                        ? IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => Navigator.pushNamed(context, '/edit-staff', arguments: user.id),
                          )
                        : null,
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

