import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../data/models/category_model.dart';
import '../../widgets/empty_state.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/auth_provider.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  void _showAddEditCategoryDialog(BuildContext context, [MedicineCategory? category]) {
    final nameController = TextEditingController(text: category?.name ?? '');
    final descController = TextEditingController(text: category?.description ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(category == null ? 'Add Category' : 'Edit Category'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Category Name *', hintText: 'e.g. Antibiotics'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Enter category name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description (optional)', hintText: 'Short description'),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              final inventory = Provider.of<InventoryProvider>(context, listen: false);

              if (category == null) {
                inventory.addCategory(nameController.text, descController.text);
              } else {
                inventory.updateCategory(category.copyWith(
                  name: nameController.text.trim(),
                  description: descController.text.trim(),
                ));
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryProvider>();
    final auth = context.watch<AuthProvider>();
    final isOwner = auth.isOwner;
    final categories = inventory.categories;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Medicine Categories'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
        onPressed: () => _showAddEditCategoryDialog(context),
      ),
      body: categories.isEmpty
          ? EmptyState(
              icon: Icons.category_outlined,
              title: 'No Categories Created',
              message: 'Organize your store inventory by creating categories like Antibiotics, Syrups, Painkillers, etc.',
              buttonText: 'Add First Category',
              onButtonPressed: () => _showAddEditCategoryDialog(context),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final count = inventory.getMedicineCountForCategory(cat.id);
                final canDelete = isOwner && count == 0;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.folder_outlined, color: AppColors.primaryDark, size: 20),
                    ),
                    title: Text(
                      cat.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    subtitle: Text(
                      cat.description.isNotEmpty ? cat.description : '$count medicines assigned',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$count medicines',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          onPressed: () => _showAddEditCategoryDialog(context, cat),
                        ),
                        if (isOwner)
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                            tooltip: canDelete ? 'Delete Category' : 'Cannot delete (has medicines)',
                            onPressed: canDelete
                                ? () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Delete Category?'),
                                        content: Text('Delete category "${cat.name}"?'),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                          ElevatedButton(
                                            onPressed: () => Navigator.pop(ctx, true),
                                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      inventory.deleteCategory(cat.id);
                                    }
                                  }
                                : () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Cannot delete a category that still contains medicines.'),
                                        backgroundColor: AppColors.warning,
                                      ),
                                    );
                                  },
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

