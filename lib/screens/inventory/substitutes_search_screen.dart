import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../widgets/alert_chip.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/app_search_bar.dart';
import '../../providers/inventory_provider.dart';

class SubstitutesSearchScreen extends StatefulWidget {
  final String? initialGenericName;

  const SubstitutesSearchScreen({super.key, this.initialGenericName});

  @override
  State<SubstitutesSearchScreen> createState() => _SubstitutesSearchScreenState();
}

class _SubstitutesSearchScreenState extends State<SubstitutesSearchScreen> {
  final _searchController = TextEditingController();
  String _genericQuery = '';

  @override
  void initState() {
    super.initState();
    if (widget.initialGenericName != null) {
      _searchController.text = widget.initialGenericName!;
      _genericQuery = widget.initialGenericName!.trim().toLowerCase();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryProvider>();
    final matches = _genericQuery.isNotEmpty ? inventory.searchSubstitutes(_genericQuery) : [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Medicine Substitutes Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSearchBar(
                  controller: _searchController,
                  hintText: 'Search by generic formula (e.g. Paracetamol, Ibuprofen)...',
                  onChanged: (val) {
                    setState(() => _genericQuery = val.trim().toLowerCase());
                  },
                  onClear: () {
                    setState(() => _genericQuery = '');
                  },
                ),
                const SizedBox(height: 8),
                const Text(
                  'Quick suggestions:',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children: [
                    'Paracetamol',
                    'Ibuprofen',
                    'Amoxicillin',
                    'Omeprazole',
                    'Metronidazole',
                  ].map((formula) {
                    return ActionChip(
                      label: Text(formula),
                      labelStyle: const TextStyle(fontSize: 11),
                      backgroundColor: AppColors.surface,
                      onPressed: () {
                        _searchController.text = formula;
                        setState(() => _genericQuery = formula.toLowerCase());
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Matches
          Expanded(
            child: _genericQuery.isEmpty
                ? const EmptyState(
                    icon: Icons.find_replace_outlined,
                    title: 'Search Generic Formula',
                    message: 'Enter any chemical formula or generic name above to see all matching brand substitutes currently in store stock.',
                  )
                : matches.isEmpty
                    ? EmptyState(
                        icon: Icons.search_off,
                        title: 'No Substitutes Found',
                        message: 'No medicines in stock match the generic formula "$_genericQuery".',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: matches.length,
                        itemBuilder: (context, index) {
                          final med = matches[index];
                          final status = inventory.getStockStatus(med);
                          final stockText = inventory.getStockDisplayText(med);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              med.name,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                            ),
                                            Text(
                                              med.genericName,
                                              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                                            ),
                                            Text(
                                              '${med.company} • ${med.form.label}',
                                              style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                                            ),
                                          ],
                                        ),
                                      ),
                                      AlertChip.fromStatus(status),
                                    ],
                                  ),
                                  const Divider(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Stock: $stockText',
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                                      ),
                                      Text(
                                        'Price: ${AppFormatters.currency(med.salePrice)} / pack',
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                      ),
                                    ],
                                  ),
                                ],
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

