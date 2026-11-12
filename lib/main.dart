import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Core
import 'core/app_theme.dart';

// Models
import 'data/models/sale_model.dart';

// Repositories
import 'data/repositories/inventory_repository.dart';
import 'data/repositories/billing_repository.dart';
import 'data/repositories/supplier_repository.dart';
import 'data/repositories/prescription_repository.dart';
import 'data/repositories/finance_repository.dart';
import 'data/repositories/staff_repository.dart';
import 'data/repositories/settings_repository.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/inventory_provider.dart';
import 'providers/billing_provider.dart';
import 'providers/supplier_provider.dart';
import 'providers/prescription_provider.dart';
import 'providers/finance_provider.dart';
import 'providers/reports_provider.dart';
import 'providers/settings_provider.dart';

// Screens
import 'screens/auth/first_run_owner_setup_screen.dart';
import 'screens/auth/recovery_code_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/new_recovery_code_screen.dart';
import 'screens/shell/main_shell_screen.dart';
import 'screens/dashboard/notifications_screen.dart';
import 'screens/dashboard/profile_screen.dart';
import 'screens/inventory/medicines_list_screen.dart';
import 'screens/inventory/add_edit_medicine_screen.dart';
import 'screens/inventory/medicine_detail_screen.dart';
import 'screens/inventory/categories_screen.dart';
import 'screens/inventory/batches_list_screen.dart';
import 'screens/inventory/add_batch_screen.dart';
import 'screens/inventory/stock_adjustment_screen.dart';
import 'screens/inventory/low_stock_screen.dart';
import 'screens/inventory/expiry_screen.dart';
import 'screens/inventory/disposal_screen.dart';
import 'screens/inventory/substitutes_search_screen.dart';
import 'screens/inventory/stock_audit_screen.dart';
import 'screens/inventory/barcode_labels_screen.dart';
import 'screens/billing/payment_screen.dart';
import 'screens/billing/receipt_preview_screen.dart';
import 'screens/billing/held_bills_screen.dart';
import 'screens/billing/sales_history_screen.dart';
import 'screens/billing/invoice_detail_screen.dart';
import 'screens/billing/sales_return_screen.dart';
import 'screens/billing/return_confirmation_refund_screen.dart';
import 'screens/billing/barcode_scanner_screen.dart';
import 'screens/purchasing/suppliers_list_screen.dart';
import 'screens/purchasing/add_edit_supplier_screen.dart';
import 'screens/purchasing/supplier_profile_ledger_screen.dart';
import 'screens/purchasing/purchase_orders_screen.dart';
import 'screens/purchasing/new_purchase_order_screen.dart';
import 'screens/purchasing/goods_received_screen.dart';
import 'screens/purchasing/purchase_return_screen.dart';
import 'screens/purchasing/supplier_payment_screen.dart';
import 'screens/prescriptions/prescriptions_screen.dart';
import 'screens/prescriptions/doctors_screen.dart';
import 'screens/prescriptions/controlled_drug_register_screen.dart';
import 'screens/finance/cash_register_screen.dart';
import 'screens/finance/daily_closing_summary_screen.dart';
import 'screens/finance/expenses_screen.dart';
import 'screens/finance/add_expense_screen.dart';
import 'screens/finance/profit_and_loss_screen.dart';
import 'screens/reports/reports_home_screen.dart';
import 'screens/reports/sales_report_screen.dart';
import 'screens/reports/purchase_report_screen.dart';
import 'screens/reports/stock_report_screen.dart';
import 'screens/reports/expiry_report_screen.dart';
import 'screens/reports/profit_report_screen.dart';
import 'screens/reports/staff_performance_report_screen.dart';
import 'screens/settings/staff_list_screen.dart';
import 'screens/settings/add_edit_staff_screen.dart';
import 'screens/settings/store_profile_settings_screen.dart';
import 'screens/settings/backup_restore_screen.dart';
import 'screens/settings/activity_log_screen.dart';
import 'screens/dev/developer_tools_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize In-Memory Repositories
  final inventoryRepo = MockInventoryRepository();
  final billingRepo = MockBillingRepository();
  final supplierRepo = MockSupplierRepository();
  final prescriptionRepo = MockPrescriptionRepository();
  final financeRepo = MockFinanceRepository();
  final staffRepo = MockStaffRepository();
  final settingsRepo = MockSettingsRepository();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            staffRepository: staffRepo,
            settingsRepository: settingsRepo,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => InventoryProvider(inventoryRepository: inventoryRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => BillingProvider(billingRepository: billingRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => SupplierProvider(supplierRepository: supplierRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => PrescriptionProvider(prescriptionRepository: prescriptionRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => FinanceProvider(financeRepository: financeRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => ReportsProvider(),
        ),
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
}

class TariqMedicalStoreApp extends StatelessWidget {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  const TariqMedicalStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    auth.onAutoLogout = () {
      navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
    };

    return Listener(
      onPointerDown: (_) => auth.userActivityDetected(),
      behavior: HitTestBehavior.translucent,
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Tariq Medical Store',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: auth.isFirstRunCompleted ? '/login' : '/first-run',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            // Module 1: Auth
            case '/first-run':
              return MaterialPageRoute(builder: (_) => const FirstRunOwnerSetupScreen());
            case '/recovery-code':
              final args = settings.arguments as Map<String, dynamic>?;
              return MaterialPageRoute(
                builder: (_) => RecoveryCodeScreen(
                  recoveryCode: args?['code'] ?? 'RECOVERY-CODE',
                  isFirstRun: args?['isFirstRun'] ?? false,
                ),
              );
            case '/login':
              return MaterialPageRoute(builder: (_) => const LoginScreen());
            case '/forgot-password':
              return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
            case '/new-recovery-code':
              final code = settings.arguments as String? ?? 'NEW-CODE';
              return MaterialPageRoute(builder: (_) => NewRecoveryCodeScreen(newRecoveryCode: code));

            // Shell & Navigation
            case '/main':
              return MaterialPageRoute(builder: (_) => const MainShellScreen());

            // Module 2: Dashboard & Profile
            case '/dashboard':
              return MaterialPageRoute(builder: (_) => const MainShellScreen(initialTab: 0));
            case '/notifications':
              return MaterialPageRoute(builder: (_) => const NotificationsScreen());
            case '/profile':
              return MaterialPageRoute(builder: (_) => const ProfileScreen());

            // Module 3: Inventory (14 screens)
            case '/inventory':
              return MaterialPageRoute(builder: (_) => const MainShellScreen(initialTab: 2));
            case '/medicines':
              return MaterialPageRoute(builder: (_) => const MedicinesListScreen());
            case '/add-medicine':
              return MaterialPageRoute(builder: (_) => const AddEditMedicineScreen());
            case '/edit-medicine':
              final medId = settings.arguments as String?;
              return MaterialPageRoute(builder: (_) => AddEditMedicineScreen(medicineId: medId));
            case '/medicine-detail':
              final medId = settings.arguments as String;
              return MaterialPageRoute(builder: (_) => MedicineDetailScreen(medicineId: medId));
            case '/categories':
              return MaterialPageRoute(builder: (_) => const CategoriesScreen());
            case '/batches':
              return MaterialPageRoute(builder: (_) => const BatchesListScreen());
            case '/add-batch':
              final medId = settings.arguments as String?;
              return MaterialPageRoute(builder: (_) => AddBatchScreen(preselectedMedicineId: medId));
            case '/stock-adjustment':
              return MaterialPageRoute(builder: (_) => const StockAdjustmentScreen());
            case '/low-stock':
              return MaterialPageRoute(builder: (_) => const LowStockScreen());
            case '/expiry':
              final tabIdx = settings.arguments as int? ?? 0;
              return MaterialPageRoute(builder: (_) => ExpiryScreen(initialTabIndex: tabIdx));
            case '/disposal':
              return MaterialPageRoute(builder: (_) => const DisposalScreen());
            case '/substitutes':
              final generic = settings.arguments as String?;
              return MaterialPageRoute(builder: (_) => SubstitutesSearchScreen(initialGenericName: generic));
            case '/stock-audit':
              return MaterialPageRoute(builder: (_) => const StockAuditScreen());
            case '/barcode-labels':
              return MaterialPageRoute(builder: (_) => const BarcodeLabelsScreen());

            // Module 4: Billing and Sales (9 screens)
            case '/new-sale':
              return MaterialPageRoute(builder: (_) => const MainShellScreen(initialTab: 1));
            case '/payment':
              return MaterialPageRoute(builder: (_) => const PaymentScreen());
            case '/receipt-preview':
              final sale = settings.arguments as Sale;
              return MaterialPageRoute(builder: (_) => ReceiptPreviewScreen(sale: sale));
            case '/held-bills':
              return MaterialPageRoute(builder: (_) => const HeldBillsScreen());
            case '/sales-history':
              return MaterialPageRoute(builder: (_) => const SalesHistoryScreen());
            case '/invoice-detail':
              final saleId = settings.arguments as String;
              return MaterialPageRoute(builder: (_) => InvoiceDetailScreen(saleId: saleId));
            case '/sales-return':
              final sale = settings.arguments as Sale?;
              return MaterialPageRoute(builder: (_) => SalesReturnScreen(preloadedSale: sale));
            case '/return-refund-confirmation':
              final data = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(builder: (_) => ReturnConfirmationRefundScreen(returnData: data));
            case '/barcode-scanner':
              return MaterialPageRoute(builder: (_) => const BarcodeScannerScreen());

            // Module 5: Purchasing and Suppliers (8 screens)
            case '/purchasing':
            case '/suppliers':
              return MaterialPageRoute(builder: (_) => const SuppliersListScreen());
            case '/add-supplier':
              return MaterialPageRoute(builder: (_) => const AddEditSupplierScreen());
            case '/edit-supplier':
              final supId = settings.arguments as String;
              return MaterialPageRoute(builder: (_) => AddEditSupplierScreen(supplierId: supId));
            case '/supplier-profile':
              final supId = settings.arguments as String;
              return MaterialPageRoute(builder: (_) => SupplierProfileLedgerScreen(supplierId: supId));
            case '/purchase-orders':
              return MaterialPageRoute(builder: (_) => const PurchaseOrdersScreen());
            case '/new-po':
              final supId = settings.arguments as String?;
              return MaterialPageRoute(builder: (_) => NewPurchaseOrderScreen(preselectedSupplierId: supId));
            case '/goods-received':
              final poId = settings.arguments as String?;
              return MaterialPageRoute(builder: (_) => GoodsReceivedScreen(purchaseOrderId: poId));
            case '/purchase-return':
              return MaterialPageRoute(builder: (_) => const PurchaseReturnScreen());
            case '/supplier-payment':
              final supId = settings.arguments as String?;
              return MaterialPageRoute(builder: (_) => SupplierPaymentScreen(preselectedSupplierId: supId));

            // Prescriptions and Controlled Drugs (3 screens)
            case '/prescriptions':
              return MaterialPageRoute(builder: (_) => const PrescriptionsScreen());
            case '/doctors':
              return MaterialPageRoute(builder: (_) => const DoctorsScreen());
            case '/controlled-drugs':
              return MaterialPageRoute(builder: (_) => const ControlledDrugRegisterScreen());

            // Module 8: Finance (5 screens)
            case '/finance':
            case '/cash-register':
              return MaterialPageRoute(builder: (_) => const CashRegisterScreen());
            case '/daily-closing':
              return MaterialPageRoute(builder: (_) => const DailyClosingSummaryScreen());
            case '/expenses':
              return MaterialPageRoute(builder: (_) => const ExpensesScreen());
            case '/add-expense':
              return MaterialPageRoute(builder: (_) => const AddExpenseScreen());
            case '/profit-and-loss':
              return MaterialPageRoute(builder: (_) => const ProfitAndLossScreen());

            // Module 9: Reports (8 screens)
            case '/reports':
              return MaterialPageRoute(builder: (_) => const ReportsHomeScreen());
            case '/sales-report':
              return MaterialPageRoute(builder: (_) => const SalesReportScreen());
            case '/purchase-report':
              return MaterialPageRoute(builder: (_) => const PurchaseReportScreen());
            case '/stock-report':
              return MaterialPageRoute(builder: (_) => const StockReportScreen());
            case '/expiry-report':
              return MaterialPageRoute(builder: (_) => const ExpiryReportScreen());
            case '/profit-report':
              return MaterialPageRoute(builder: (_) => const ProfitReportScreen());
            case '/staff-performance-report':
              return MaterialPageRoute(builder: (_) => const StaffPerformanceReportScreen());

            // Module 10: Staff and Settings (5 screens)
            case '/settings':
            case '/store-settings':
              return MaterialPageRoute(builder: (_) => const StoreProfileSettingsScreen());
            case '/staff-list':
              return MaterialPageRoute(builder: (_) => const StaffListScreen());
            case '/add-staff':
              return MaterialPageRoute(builder: (_) => const AddEditStaffScreen());
            case '/edit-staff':
              final sId = settings.arguments as String;
              return MaterialPageRoute(builder: (_) => AddEditStaffScreen(staffId: sId));
            case '/backup-restore':
              return MaterialPageRoute(builder: (_) => const BackupRestoreScreen());
            case '/activity-log':
              return MaterialPageRoute(builder: (_) => const ActivityLogScreen());

            // Developer Tools
            case '/dev-tools':
              return MaterialPageRoute(builder: (_) => const DeveloperToolsScreen());

            default:
              return MaterialPageRoute(builder: (_) => const MainShellScreen());
          }
        },
      ),
    );
  }
}
