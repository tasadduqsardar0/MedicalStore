import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/billing_provider.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final _barcodeInputController = TextEditingController();

  @override
  void dispose() {
    _barcodeInputController.dispose();
    super.dispose();
  }

  void _onBarcodeDetected(String barcode) {
    if (barcode.trim().isEmpty) return;

    final inventory = Provider.of<InventoryProvider>(context, listen: false);
    final billing = Provider.of<BillingProvider>(context, listen: false);

    final med = inventory.getMedicineByBarcode(barcode.trim());

    if (med != null) {
      final error = billing.addItem(
        medicine: med,
        isLoose: false,
        quantity: 1,
        inventoryProvider: inventory,
      );

      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppColors.danger),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added 1 pack of ${med.name} (${AppFormatters.currency(med.salePrice)}) to bill'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No medicine found with barcode "$barcode"'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryProvider>();
    final barcodedMedicines = inventory.allMedicines.where((m) => m.barcode.isNotEmpty).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Barcode Scanner (Camera)'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Viewfinder Simulation
            Expanded(
              flex: 5,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    color: Colors.grey.shade900,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt_outlined, size: 64, color: Colors.white.withValues(alpha: 0.3)),
                          const SizedBox(height: 12),
                          Text(
                            'Align barcode inside the green viewfinder box',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Reticle
                  Container(
                    width: 260,
                    height: 160,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.success, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Divider(color: AppColors.danger, thickness: 1.5),
                    ),
                  ),
                ],
              ),
            ),

            // Manual & Test Triggers Area
            Expanded(
              flex: 4,
              child: Container(
                color: AppColors.surface,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Manual Entry or Quick Scan Test:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _barcodeInputController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'Type or paste barcode digits...',
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            onSubmitted: _onBarcodeDetected,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _onBarcodeDetected(_barcodeInputController.text),
                          child: const Text('Scan'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Quick test tap chips
                    const Text('Tap a medicine barcode to simulate instant scan:', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    const SizedBox(height: 6),
                    Expanded(
                      child: barcodedMedicines.isEmpty
                          ? const Center(child: Text('No barcoded medicines found. Load demo data to test!'))
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: barcodedMedicines.length,
                              itemBuilder: (context, idx) {
                                final med = barcodedMedicines[idx];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: ActionChip(
                                    avatar: const Icon(Icons.qr_code, size: 16),
                                    label: Text('${med.name} (${med.barcode.substring(med.barcode.length - 4)})'),
                                    backgroundColor: AppColors.surfaceVariant,
                                    onPressed: () => _onBarcodeDetected(med.barcode),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

