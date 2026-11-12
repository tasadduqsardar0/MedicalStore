import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:tariq_medical_store/core/formatters.dart';
import 'package:tariq_medical_store/core/stock_rules.dart';
import 'package:tariq_medical_store/data/models/batch_model.dart';
import 'package:tariq_medical_store/data/repositories/billing_repository.dart';
import 'package:tariq_medical_store/data/repositories/finance_repository.dart';
import 'package:tariq_medical_store/data/repositories/inventory_repository.dart';
import 'package:tariq_medical_store/data/repositories/prescription_repository.dart';
import 'package:tariq_medical_store/data/repositories/settings_repository.dart';
import 'package:tariq_medical_store/data/repositories/staff_repository.dart';
import 'package:tariq_medical_store/data/repositories/supplier_repository.dart';
import 'package:tariq_medical_store/main.dart';
import 'package:tariq_medical_store/providers/auth_provider.dart';
import 'package:tariq_medical_store/providers/billing_provider.dart';
import 'package:tariq_medical_store/providers/finance_provider.dart';
import 'package:tariq_medical_store/providers/inventory_provider.dart';
import 'package:tariq_medical_store/providers/prescription_provider.dart';
import 'package:tariq_medical_store/providers/reports_provider.dart';
import 'package:tariq_medical_store/providers/settings_provider.dart';
import 'package:tariq_medical_store/providers/supplier_provider.dart';

void main() {
  test('Currency formatter formats Pakistani Rupee cleanly', () {
    expect(AppFormatters.currency(1250), 'Rs 1,250');
    expect(AppFormatters.currency(0), 'Rs 0');
  });

  test('StockRules formats packs + loose and enforces FEFO & expiry', () {
    expect(
      StockRules.formatStockDisplay(
        totalUnits: 34,
        unitsPerPack: 10,
        packTypeName: 'Strip',
        unitName: 'Tablet',
      ),
      '3 Strips + 4 Tablets',
    );

    final now = DateTime.now();
    final expiredBatch = Batch(
      id: 'b1',
      medicineId: 'm1',
      batchNumber: 'EXP1',
      expiryDate: now.subtract(const Duration(days: 5)),
      quantityUnits: 50,
      purchasePrice: 30,
    );
    final earlierBatch = Batch(
      id: 'b2',
      medicineId: 'm1',
      batchNumber: 'EARLY',
      expiryDate: now.add(const Duration(days: 20)),
      quantityUnits: 15,
      purchasePrice: 30,
    );
    final laterBatch = Batch(
      id: 'b3',
      medicineId: 'm1',
      batchNumber: 'LATE',
      expiryDate: now.add(const Duration(days: 200)),
      quantityUnits: 40,
      purchasePrice: 30,
    );

    final batches = [expiredBatch, laterBatch, earlierBatch];

    // Expired stock is never counted as sellable
    expect(StockRules.sellableStockUnits(batches, now), 55);
    expect(StockRules.totalStockUnits(batches), 105);

    // FEFO allocates from earlierBatch first, skipping expiredBatch
    final allocation = StockRules.allocateFEFO(
      batches: batches,
      requestedUnits: 20,
      now: now,
    );
    expect(allocation[earlierBatch], 15);
    expect(allocation[laterBatch], 5);
    expect(allocation.containsKey(expiredBatch), isFalse);

    // Past expiry date rejected for new batch
    expect(StockRules.isValidBatchExpiry(now.subtract(const Duration(days: 1)), now), isFalse);
    expect(StockRules.isValidBatchExpiry(now.add(const Duration(days: 10)), now), isTrue);

    // Cannot edit units or delete medicine while stock > 0
    expect(StockRules.canEditUnitsPerPack(batches), isFalse);
    expect(StockRules.canDeleteMedicine(batches), isFalse);
    expect(StockRules.canDeleteMedicine([]), isTrue);
  });

  test('BillingProvider accepts optional customer name and defaults to Walk-in Customer', () {
    final billing = BillingProvider(billingRepository: MockBillingRepository());
    expect(billing.displayCustomerName, 'Walk-in Customer');

    billing.setCustomerName('  Tariq Ali  ');
    expect(billing.displayCustomerName, 'Tariq Ali');

    billing.clearCart();
    expect(billing.displayCustomerName, 'Walk-in Customer');
  });

  testWidgets('First-run setup screen displays store header and owner form', (WidgetTester tester) async {
    final inventoryRepo = MockInventoryRepository();
    final billingRepo = MockBillingRepository();
    final supplierRepo = MockSupplierRepository();
    final prescriptionRepo = MockPrescriptionRepository();
    final financeRepo = MockFinanceRepository();
    final staffRepo = MockStaffRepository();
    final settingsRepo = MockSettingsRepository();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => AuthProvider(
              staffRepository: staffRepo,
              settingsRepository: settingsRepo,
            ),
          ),
          ChangeNotifierProvider(create: (_) => InventoryProvider(inventoryRepository: inventoryRepo)),
          ChangeNotifierProvider(create: (_) => BillingProvider(billingRepository: billingRepo)),
          ChangeNotifierProvider(create: (_) => SupplierProvider(supplierRepository: supplierRepo)),
          ChangeNotifierProvider(create: (_) => PrescriptionProvider(prescriptionRepository: prescriptionRepo)),
          ChangeNotifierProvider(create: (_) => FinanceProvider(financeRepository: financeRepo)),
          ChangeNotifierProvider(create: (_) => ReportsProvider()),
          ChangeNotifierProvider(
            create: (_) => SettingsProvider(
              settingsRepository: settingsRepo,
              staffRepository: staffRepo,
            ),
          ),
        ],
        child: const TariqMedicalStoreApp(),
      ),
    );

    expect(find.text('Tariq Medical Store'), findsOneWidget);
    expect(find.text('Main Bazaar, Hujra Shah Muqeem'), findsOneWidget);
    expect(find.text('First-Time Setup: Owner Account'), findsOneWidget);
  });
}
