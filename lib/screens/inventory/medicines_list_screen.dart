import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../widgets/alert_chip.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/app_search_bar.dart';
import '../../providers/inventory_provider.dart';

class MedicinesListScreen extends StatefulWidget {
  const MedicinesListScreen({super.key});

  @override
  State<MedicinesListScreen> createState() => _MedicinesListScreenState();
}

class _MedicinesListScreenState extends State<MedicinesListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryProvider>();
    final categories = inventory.categories;
    final medicines = inventory.filteredMedicines;
    final selectedCatId = inventory.selectedCategoryId;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Medicines List'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Medicine'),
        onPressed: () => Navigator.pushNamed(context, '/add-medicine'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: AppSearchBar(
              controller: _searchController,
              hintText: 'Search medicine name, generic, company...',
              onChanged: (val) => inventory.setSearchQuery(val),
              onClear: () => inventory.setSearchQuery(''),
            ),
          ),

          // Categories Horizontal Filter Chips
          if (categories.isNotEmpty)
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: const Text('All Categories'),
                      selected: selectedCatId == null,
                      selectedColor: AppColors.primaryLight,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: selectedCatId == null ? FontWeight.bold : FontWeight.normal,
                        color: selectedCatId == null ? AppColors.primaryDark : AppColors.textPrimary,
                      ),
                      onSelected: (_) => inventory.setSelectedCategory(null),
                    ),
                  ),
                  ...categories.map((cat) {
                    final isSelected = selectedCatId == cat.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(cat.name),
                        selected: isSelected,
                        selectedColor: AppColors.primaryLight,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                        ),
                        onSelected: (_) {
                          inventory.setSelectedCategory(isSelected ? null : cat.id);
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          const SizedBox(height: 8),

          // Medicines List or Empty State
          Expanded(
            child: medicines.isEmpty
                ? EmptyState(
                    icon: Icons.medication_outlined,
                    title: 'No Medicines Found',
                    message: inventory.searchQuery.isNotEmpty || selectedCatId != null
                        ? 'No medicines match your search criteria. Try a different term or clear filters.'
                        : 'No medicines have been added yet. Tap below or load demo data in Developer Tools.',
                    buttonText: 'Add New Medicine',
                    onButtonPressed: () => Navigator.pushNamed(context, '/add-medicine'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                    itemCount: medicines.length,
                    itemBuilder: (context, index) {
                      final med = medicines[index];
                      final status = inventory.getStockStatus(med);
                      final stockText = inventory.getStockDisplayText(med);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/medicine-detail',
                              arguments: med.id,
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  med.name,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.textPrimary,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (med.isControlled) ...[
                                                const SizedBox(width: 6),
                                                AlertChip.controlled(),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            med.genericName,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textSecondary,
                                              fontStyle: FontStyle.italic,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${med.company} • ${med.form.label}',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textTertiary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    AlertChip.fromStatus(status),
                                  ],
                                ),
                                const Divider(height: 18),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Stock Available',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          stockText,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        const Text(
                                          'Retail Price',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          AppFormatters.currency(med.salePrice),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

