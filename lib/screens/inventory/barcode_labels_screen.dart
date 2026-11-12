import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../widgets/empty_state.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/settings_provider.dart';

class BarcodeLabelsScreen extends StatelessWidget {
  const BarcodeLabelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryProvider>();
    final settings = context.watch<SettingsProvider>().settings;
    final medicines = inventory.allMedicines.where((m) => m.barcode.isNotEmpty).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Barcode Shelf Labels'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined),
            tooltip: 'Print Label Sheet',
            onPressed: medicines.isEmpty
                ? null
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sent barcode labels to thermal label printer'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
          ),
        ],
      ),
      body: medicines.isEmpty
          ? const EmptyState(
              icon: Icons.qr_code_2_outlined,
              title: 'No Barcodes Found',
              message: 'Assign barcodes to medicines to generate printable shelf price tags and scanner labels.',
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.35,
              ),
              itemCount: medicines.length,
              itemBuilder: (context, index) {
                final med = medicines[index];

                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border, width: 1.2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        settings.storeName,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        med.name,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Barcode simulation lines
                      Container(
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(24, (i) {
                            return Container(
                              width: (i % 3 == 0) ? 2.5 : 1.2,
                              height: 20,
                              color: Colors.black87,
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        med.barcode,
                        style: const TextStyle(fontSize: 9, fontFamily: 'monospace', letterSpacing: 1.0),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppFormatters.currency(med.salePrice),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

