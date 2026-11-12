import '../models/medicine_model.dart';
import '../models/batch_model.dart';
import '../models/category_model.dart';
import '../models/supplier_model.dart';
import '../models/purchase_order_model.dart';
import '../models/sale_model.dart';
import '../models/prescription_model.dart';
import '../models/finance_model.dart';
import '../models/audit_model.dart';

class DemoData {
  static List<MedicineCategory> get categories => [
    const MedicineCategory(id: 'cat-1', name: 'Analgesics & Pain Relief', description: 'Pain and fever management medicines'),
    const MedicineCategory(id: 'cat-2', name: 'Antibiotics', description: 'Broad and narrow spectrum antibacterial medicines'),
    const MedicineCategory(id: 'cat-3', name: 'Gastrointestinal', description: 'Stomach, antacid and digestive treatments'),
    const MedicineCategory(id: 'cat-4', name: 'Cardiovascular', description: 'Blood pressure and heart medications'),
    const MedicineCategory(id: 'cat-5', name: 'Respiratory & Cough', description: 'Syrups, inhalers, and cold medications'),
    const MedicineCategory(id: 'cat-6', name: 'Sedatives & Controlled', description: 'Schedule / Controlled drugs requiring Rx'),
    const MedicineCategory(id: 'cat-7', name: 'Vitamins & Minerals', description: 'Supplements and multivitamins'),
    const MedicineCategory(id: 'cat-8', name: 'Topical & Creams', description: 'Skin ointments and external care'),
  ];

  static List<Medicine> get medicines => [
    // 1. Panadol 500mg
    const Medicine(
      id: 'med-1',
      name: 'Panadol 500mg',
      genericName: 'Paracetamol',
      categoryId: 'cat-1',
      company: 'GSK Pakistan',
      form: DosageForm.tablet,
      packType: PackType.strip,
      unitsPerPack: 10,
      salePrice: 40.0,
      loosePrice: 4.0,
      minimumStockPacks: 20,
      barcode: '896400010011',
      isControlled: false,
      isLooseEnabled: true,
    ),
    // 2. Panadol Extra
    const Medicine(
      id: 'med-2',
      name: 'Panadol Extra',
      genericName: 'Paracetamol + Caffeine',
      categoryId: 'cat-1',
      company: 'GSK Pakistan',
      form: DosageForm.tablet,
      packType: PackType.strip,
      unitsPerPack: 10,
      salePrice: 60.0,
      loosePrice: 6.0,
      minimumStockPacks: 15,
      barcode: '896400010028',
      isControlled: false,
      isLooseEnabled: true,
    ),
    // 3. Calpol 120mg Syrup
    const Medicine(
      id: 'med-3',
      name: 'Calpol 120mg Syrup',
      genericName: 'Paracetamol',
      categoryId: 'cat-1',
      company: 'GSK Pakistan',
      form: DosageForm.syrup,
      packType: PackType.bottle,
      unitsPerPack: 1,
      salePrice: 110.0,
      loosePrice: 110.0,
      minimumStockPacks: 10,
      barcode: '896400010035',
      isControlled: false,
      isLooseEnabled: false,
    ),
    // 4. Augmentin 625mg
    const Medicine(
      id: 'med-4',
      name: 'Augmentin 625mg',
      genericName: 'Amoxicillin + Clavulanic Acid',
      categoryId: 'cat-2',
      company: 'GSK Pakistan',
      form: DosageForm.tablet,
      packType: PackType.strip,
      unitsPerPack: 6,
      salePrice: 280.0,
      loosePrice: 50.0,
      minimumStockPacks: 10,
      barcode: '896400020010',
      isControlled: false,
      isLooseEnabled: true,
    ),
    // 5. Augmentin DS 156mg Susp
    const Medicine(
      id: 'med-5',
      name: 'Augmentin DS 156mg Susp',
      genericName: 'Amoxicillin + Clavulanic Acid',
      categoryId: 'cat-2',
      company: 'GSK Pakistan',
      form: DosageForm.syrup,
      packType: PackType.bottle,
      unitsPerPack: 1,
      salePrice: 220.0,
      loosePrice: 220.0,
      minimumStockPacks: 8,
      barcode: '896400020027',
      isControlled: false,
      isLooseEnabled: false,
    ),
    // 6. Brufen 400mg
    const Medicine(
      id: 'med-6',
      name: 'Brufen 400mg',
      genericName: 'Ibuprofen',
      categoryId: 'cat-1',
      company: 'Abbott Laboratories',
      form: DosageForm.tablet,
      packType: PackType.strip,
      unitsPerPack: 10,
      salePrice: 55.0,
      loosePrice: 6.0,
      minimumStockPacks: 25,
      barcode: '896400030019',
      isControlled: false,
      isLooseEnabled: true,
    ),
    // 7. Flagyl 400mg
    const Medicine(
      id: 'med-7',
      name: 'Flagyl 400mg',
      genericName: 'Metronidazole',
      categoryId: 'cat-3',
      company: 'Sanofi-Aventis',
      form: DosageForm.tablet,
      packType: PackType.strip,
      unitsPerPack: 10,
      salePrice: 45.0,
      loosePrice: 5.0,
      minimumStockPacks: 20,
      barcode: '896400040018',
      isControlled: false,
      isLooseEnabled: true,
    ),
    // 8. Disprin 300mg (Low Stock)
    const Medicine(
      id: 'med-8',
      name: 'Disprin 300mg',
      genericName: 'Aspirin',
      categoryId: 'cat-1',
      company: 'Reckitt Benckiser',
      form: DosageForm.tablet,
      packType: PackType.strip,
      unitsPerPack: 10,
      salePrice: 35.0,
      loosePrice: 4.0,
      minimumStockPacks: 20,
      barcode: '896400050017',
      isControlled: false,
      isLooseEnabled: true,
    ),
    // 9. Rizek 20mg (Low Stock)
    const Medicine(
      id: 'med-9',
      name: 'Rizek 20mg',
      genericName: 'Omeprazole',
      categoryId: 'cat-3',
      company: 'Getz Pharma',
      form: DosageForm.capsule,
      packType: PackType.strip,
      unitsPerPack: 14,
      salePrice: 320.0,
      loosePrice: 24.0,
      minimumStockPacks: 15,
      barcode: '896400060016',
      isControlled: false,
      isLooseEnabled: true,
    ),
    // 10. Lexotanil 3mg (CONTROLLED)
    const Medicine(
      id: 'med-10',
      name: 'Lexotanil 3mg',
      genericName: 'Bromazepam',
      categoryId: 'cat-6',
      company: 'Martin Dow',
      form: DosageForm.tablet,
      packType: PackType.strip,
      unitsPerPack: 10,
      salePrice: 195.0,
      loosePrice: 20.0,
      minimumStockPacks: 10,
      barcode: '896400070015',
      isControlled: true,
      isLooseEnabled: true,
    ),
    // 11. Rivotril 2mg (CONTROLLED)
    const Medicine(
      id: 'med-11',
      name: 'Rivotril 2mg',
      genericName: 'Clonazepam',
      categoryId: 'cat-6',
      company: 'Martin Dow',
      form: DosageForm.tablet,
      packType: PackType.strip,
      unitsPerPack: 10,
      salePrice: 240.0,
      loosePrice: 25.0,
      minimumStockPacks: 8,
      barcode: '896400080014',
      isControlled: true,
      isLooseEnabled: true,
    ),
    // 12. Surbex Z
    const Medicine(
      id: 'med-12',
      name: 'Surbex Z',
      genericName: 'Multivitamins + Zinc',
      categoryId: 'cat-7',
      company: 'Abbott Laboratories',
      form: DosageForm.tablet,
      packType: PackType.bottle,
      unitsPerPack: 30,
      salePrice: 380.0,
      loosePrice: 15.0,
      minimumStockPacks: 12,
      barcode: '896400090013',
      isControlled: false,
      isLooseEnabled: false,
    ),
    // 13. Arinac Forte (Near Expiry)
    const Medicine(
      id: 'med-13',
      name: 'Arinac Forte',
      genericName: 'Ibuprofen + Pseudoephedrine',
      categoryId: 'cat-5',
      company: 'Abbott Laboratories',
      form: DosageForm.tablet,
      packType: PackType.strip,
      unitsPerPack: 10,
      salePrice: 120.0,
      loosePrice: 13.0,
      minimumStockPacks: 10,
      barcode: '896400100019',
      isControlled: false,
      isLooseEnabled: true,
    ),
    // 14. Polyfax Skin Ointment
    const Medicine(
      id: 'med-14',
      name: 'Polyfax Skin Ointment',
      genericName: 'Polymyxin B + Bacitracin',
      categoryId: 'cat-8',
      company: 'GSK Pakistan',
      form: DosageForm.cream,
      packType: PackType.tube,
      unitsPerPack: 1,
      salePrice: 95.0,
      loosePrice: 95.0,
      minimumStockPacks: 10,
      barcode: '896400110018',
      isControlled: false,
      isLooseEnabled: false,
    ),
    // 15. Loprin 75mg (OUT OF STOCK)
    const Medicine(
      id: 'med-15',
      name: 'Loprin 75mg',
      genericName: 'Aspirin',
      categoryId: 'cat-4',
      company: 'Highnoon Laboratories',
      form: DosageForm.tablet,
      packType: PackType.strip,
      unitsPerPack: 10,
      salePrice: 42.0,
      loosePrice: 5.0,
      minimumStockPacks: 15,
      barcode: '896400120017',
      isControlled: false,
      isLooseEnabled: true,
    ),
    // 16. Amoxil 500mg (EXPIRED BATCH ONLY)
    const Medicine(
      id: 'med-16',
      name: 'Amoxil 500mg',
      genericName: 'Amoxicillin',
      categoryId: 'cat-2',
      company: 'GSK Pakistan',
      form: DosageForm.capsule,
      packType: PackType.strip,
      unitsPerPack: 10,
      salePrice: 160.0,
      loosePrice: 18.0,
      minimumStockPacks: 10,
      barcode: '896400130016',
      isControlled: false,
      isLooseEnabled: true,
    ),
    // 17. Gravinate 50mg
    const Medicine(
      id: 'med-17',
      name: 'Gravinate 50mg',
      genericName: 'Dimenhydrinate',
      categoryId: 'cat-3',
      company: 'Searle Pakistan',
      form: DosageForm.tablet,
      packType: PackType.strip,
      unitsPerPack: 10,
      salePrice: 50.0,
      loosePrice: 5.0,
      minimumStockPacks: 15,
      barcode: '896400140015',
      isControlled: false,
      isLooseEnabled: true,
    ),
  ];

  static List<Batch> get batches {
    final now = DateTime.now();
    return [
      // Panadol 500mg: 2 batches to test FEFO!
      Batch(id: 'bat-1', medicineId: 'med-1', batchNumber: 'B-2401', expiryDate: now.add(const Duration(days: 90)), quantityUnits: 250, purchasePrice: 32.0),
      Batch(id: 'bat-2', medicineId: 'med-1', batchNumber: 'B-2402', expiryDate: now.add(const Duration(days: 360)), quantityUnits: 400, purchasePrice: 32.0),

      // Panadol Extra
      Batch(id: 'bat-3', medicineId: 'med-2', batchNumber: 'PE-981', expiryDate: now.add(const Duration(days: 300)), quantityUnits: 300, purchasePrice: 48.0),

      // Calpol Syrup
      Batch(id: 'bat-4', medicineId: 'med-3', batchNumber: 'CAL-11', expiryDate: now.add(const Duration(days: 240)), quantityUnits: 35, purchasePrice: 88.0),

      // Augmentin 625mg
      Batch(id: 'bat-5', medicineId: 'med-4', batchNumber: 'AUG-625', expiryDate: now.add(const Duration(days: 420)), quantityUnits: 120, purchasePrice: 230.0),

      // Augmentin DS Susp
      Batch(id: 'bat-6', medicineId: 'med-5', batchNumber: 'AUG-DS', expiryDate: now.add(const Duration(days: 180)), quantityUnits: 25, purchasePrice: 175.0),

      // Brufen 400mg
      Batch(id: 'bat-7', medicineId: 'med-6', batchNumber: 'BR-400', expiryDate: now.add(const Duration(days: 400)), quantityUnits: 500, purchasePrice: 42.0),

      // Flagyl 400mg
      Batch(id: 'bat-8', medicineId: 'med-7', batchNumber: 'FL-400', expiryDate: now.add(const Duration(days: 310)), quantityUnits: 350, purchasePrice: 34.0),

      // Disprin 300mg (LOW STOCK: min is 20 packs = 200 units, current has 60 units = 6 packs)
      Batch(id: 'bat-9', medicineId: 'med-8', batchNumber: 'DSP-09', expiryDate: now.add(const Duration(days: 200)), quantityUnits: 60, purchasePrice: 26.0),

      // Rizek 20mg (LOW STOCK: min is 15 packs = 210 caps, current has 42 caps = 3 packs)
      Batch(id: 'bat-10', medicineId: 'med-9', batchNumber: 'RZ-20', expiryDate: now.add(const Duration(days: 250)), quantityUnits: 42, purchasePrice: 260.0),

      // Lexotanil 3mg (CONTROLLED DRUG)
      Batch(id: 'bat-11', medicineId: 'med-10', batchNumber: 'LEX-301', expiryDate: now.add(const Duration(days: 290)), quantityUnits: 150, purchasePrice: 155.0),

      // Rivotril 2mg (CONTROLLED DRUG)
      Batch(id: 'bat-12', medicineId: 'med-11', batchNumber: 'RIV-202', expiryDate: now.add(const Duration(days: 340)), quantityUnits: 120, purchasePrice: 190.0),

      // Surbex Z
      Batch(id: 'bat-13', medicineId: 'med-12', batchNumber: 'SBX-77', expiryDate: now.add(const Duration(days: 500)), quantityUnits: 40, purchasePrice: 300.0),

      // Arinac Forte (NEAR EXPIRY: expires in 12 days!)
      Batch(id: 'bat-14', medicineId: 'med-13', batchNumber: 'ARN-12', expiryDate: now.add(const Duration(days: 12)), quantityUnits: 90, purchasePrice: 92.0),

      // Polyfax Ointment
      Batch(id: 'bat-15', medicineId: 'med-14', batchNumber: 'PFX-5', expiryDate: now.add(const Duration(days: 280)), quantityUnits: 25, purchasePrice: 72.0),

      // Loprin 75mg: OUT OF STOCK (0 units)
      Batch(id: 'bat-16', medicineId: 'med-15', batchNumber: 'LOP-01', expiryDate: now.add(const Duration(days: 150)), quantityUnits: 0, purchasePrice: 30.0),

      // Amoxil 500mg: EXPIRED STOCK (expired 15 days ago)
      Batch(id: 'bat-17', medicineId: 'med-16', batchNumber: 'AMX-99', expiryDate: now.subtract(const Duration(days: 15)), quantityUnits: 100, purchasePrice: 125.0),

      // Gravinate 50mg
      Batch(id: 'bat-18', medicineId: 'med-17', batchNumber: 'GRV-44', expiryDate: now.add(const Duration(days: 320)), quantityUnits: 220, purchasePrice: 38.0),
    ];
  }

  static List<Supplier> get suppliers => [
    const Supplier(
      id: 'sup-1',
      companyName: 'GSK Pakistan Distribution',
      contactPerson: 'Khurram Shehzad',
      phone: '0300-8451234',
      email: 'orders.lahore@gsk.com',
      address: 'Circular Road, Lahore / Depalpur Depot',
      balancePayable: 45000.0,
    ),
    const Supplier(
      id: 'sup-2',
      companyName: 'Abbott Laboratories Pak Ltd',
      contactPerson: 'Zahid Mehmood',
      phone: '0321-9988776',
      email: 'zahid@abbottdist.com',
      address: 'G.T. Road, Okara Region',
      balancePayable: 28500.0,
    ),
    const Supplier(
      id: 'sup-3',
      companyName: 'Getz Pharma Distribution Hub',
      contactPerson: 'Nasir Abbas',
      phone: '0333-6543210',
      email: 'nasir@getzpharma.pk',
      address: 'Kachehri Bazar, Okara',
      balancePayable: 16200.0,
    ),
    const Supplier(
      id: 'sup-4',
      companyName: 'Martin Dow Healthcare',
      contactPerson: 'Bilal Farooq',
      phone: '0301-4455667',
      email: 'bilal.f@martindow.com',
      address: 'Multan Road Agency, Sahiwal',
      balancePayable: 12000.0,
    ),
  ];

  static List<Doctor> get doctors => [
    const Doctor(
      id: 'doc-1',
      name: 'Dr. Muhammad Irfan',
      clinicHospital: 'THQ Hospital / Private Clinic Hujra',
      phone: '0300-9876543',
      licenseNumber: 'PMDC-44211-P',
    ),
    const Doctor(
      id: 'doc-2',
      name: 'Dr. Naveed Akhtar',
      clinicHospital: 'Al-Shifa Family Clinic, Main Bazaar',
      phone: '0321-1234567',
      licenseNumber: 'PMDC-38910-P',
    ),
    const Doctor(
      id: 'doc-3',
      name: 'Dr. Saima Kausar',
      clinicHospital: 'Fatima Maternity Hospital, Depalpur Road',
      phone: '0333-8765432',
      licenseNumber: 'PMDC-55102-P',
    ),
  ];

  static List<Prescription> get prescriptions {
    final now = DateTime.now();
    return [
      Prescription(
        id: 'rx-1',
        rxNumber: 'RX-5001',
        patientName: 'Muhammad Aslam',
        patientAge: 52,
        patientGender: 'Male',
        doctorId: 'doc-1',
        doctorName: 'Dr. Muhammad Irfan',
        date: now.subtract(const Duration(hours: 4)),
        instructions: 'Take medicines after meal with water. Avoid oily food.',
        medicines: const [
          PrescriptionMedicineItem(medicineId: 'med-4', medicineName: 'Augmentin 625mg', dosage: '1 tablet twice daily', durationDays: 5, quantity: 10),
          PrescriptionMedicineItem(medicineId: 'med-1', medicineName: 'Panadol 500mg', dosage: '1 tablet thrice daily', durationDays: 3, quantity: 9),
        ],
        isDispensed: true,
      ),
      Prescription(
        id: 'rx-2',
        rxNumber: 'RX-5002',
        patientName: 'Haji Bashir Ahmed',
        patientAge: 68,
        patientGender: 'Male',
        doctorId: 'doc-2',
        doctorName: 'Dr. Naveed Akhtar',
        date: now.subtract(const Duration(hours: 1)),
        instructions: 'Take 1 tablet at night for anxiety/sleep disturbance.',
        medicines: const [
          PrescriptionMedicineItem(medicineId: 'med-10', medicineName: 'Lexotanil 3mg', dosage: '1 tablet at bedtime', durationDays: 10, quantity: 10),
        ],
        isDispensed: false,
      ),
    ];
  }

  static List<ControlledDrugEntry> get controlledEntries {
    final now = DateTime.now();
    return [
      ControlledDrugEntry(
        id: 'ctrl-1',
        date: now.subtract(const Duration(days: 2)),
        medicineId: 'med-10',
        medicineName: 'Lexotanil 3mg',
        patientName: 'Haji Bashir Ahmed',
        doctorName: 'Dr. Naveed Akhtar',
        prescriptionNumber: 'RX-4998',
        quantityDispensed: 10,
        remainingStockUnits: 150,
        pharmacistName: 'Tariq Mahmood (Owner)',
      ),
      ControlledDrugEntry(
        id: 'ctrl-2',
        date: now.subtract(const Duration(days: 5)),
        medicineId: 'med-11',
        medicineName: 'Rivotril 2mg',
        patientName: 'Akram Ali',
        doctorName: 'Dr. Muhammad Irfan',
        prescriptionNumber: 'RX-4985',
        quantityDispensed: 10,
        remainingStockUnits: 120,
        pharmacistName: 'Tariq Mahmood (Owner)',
      ),
    ];
  }

  static List<Sale> get sales {
    final now = DateTime.now();
    return [
      Sale(
        id: 'sale-1',
        invoiceNumber: 'INV-1001',
        date: now.subtract(const Duration(hours: 3)),
        customerName: 'Muhammad Aslam',
        items: const [
          SaleItem(
            medicineId: 'med-1',
            medicineName: 'Panadol 500mg',
            genericName: 'Paracetamol',
            isLoose: false,
            quantity: 2,
            unitsPerPack: 10,
            unitPrice: 40.0,
            lineTotal: 80.0,
          ),
          SaleItem(
            medicineId: 'med-4',
            medicineName: 'Augmentin 625mg',
            genericName: 'Amoxicillin + Clavulanic Acid',
            isLoose: false,
            quantity: 1,
            unitsPerPack: 6,
            unitPrice: 280.0,
            lineTotal: 280.0,
          ),
        ],
        subtotal: 360.0,
        discount: 20.0,
        netTotal: 340.0,
        paymentMethod: PaymentMethod.cash,
        cashTendered: 500.0,
        changeAmount: 160.0,
        staffId: 'staff-1',
        staffName: 'Tariq Mahmood',
        estimatedCost: 260.0,
      ),
      Sale(
        id: 'sale-2',
        invoiceNumber: 'INV-1002',
        date: now.subtract(const Duration(hours: 2)),
        customerName: 'Haji Bashir Ahmed',
        items: const [
          SaleItem(
            medicineId: 'med-12',
            medicineName: 'Surbex Z',
            genericName: 'Multivitamins + Zinc',
            isLoose: false,
            quantity: 1,
            unitsPerPack: 30,
            unitPrice: 380.0,
            lineTotal: 380.0,
          ),
          SaleItem(
            medicineId: 'med-6',
            medicineName: 'Brufen 400mg',
            genericName: 'Ibuprofen',
            isLoose: false,
            quantity: 2,
            unitsPerPack: 10,
            unitPrice: 55.0,
            lineTotal: 110.0,
          ),
        ],
        subtotal: 490.0,
        discount: 10.0,
        netTotal: 480.0,
        paymentMethod: PaymentMethod.card,
        staffId: 'staff-1',
        staffName: 'Tariq Mahmood',
        estimatedCost: 350.0,
      ),
      Sale(
        id: 'sale-3',
        invoiceNumber: 'INV-1003',
        date: now.subtract(const Duration(minutes: 45)),
        customerName: 'Walk-in Customer',
        items: const [
          SaleItem(
            medicineId: 'med-3',
            medicineName: 'Calpol 120mg Syrup',
            genericName: 'Paracetamol',
            isLoose: false,
            quantity: 1,
            unitsPerPack: 1,
            unitPrice: 110.0,
            lineTotal: 110.0,
          ),
          SaleItem(
            medicineId: 'med-1',
            medicineName: 'Panadol 500mg',
            genericName: 'Paracetamol',
            isLoose: true, // Loose unit test!
            quantity: 5,
            unitsPerPack: 10,
            unitPrice: 4.0,
            lineTotal: 20.0,
          ),
        ],
        subtotal: 130.0,
        discount: 0.0,
        netTotal: 130.0,
        paymentMethod: PaymentMethod.cash,
        cashTendered: 200.0,
        changeAmount: 70.0,
        staffId: 'staff-2',
        staffName: 'Ali Raza',
        estimatedCost: 95.0,
      ),
    ];
  }

  static List<Expense> get expenses {
    final now = DateTime.now();
    return [
      Expense(
        id: 'exp-1',
        category: ExpenseCategory.teaSnacks,
        amount: 350.0,
        description: 'Morning tea and biscuits for shop staff',
        paymentMethod: 'Cash',
        date: now.subtract(const Duration(hours: 4)),
        recordedBy: 'Tariq Mahmood',
      ),
      Expense(
        id: 'exp-2',
        category: ExpenseCategory.supplies,
        amount: 800.0,
        description: 'Plastic packaging bags and thermal receipt paper roll',
        paymentMethod: 'Cash',
        date: now.subtract(const Duration(hours: 2)),
        recordedBy: 'Tariq Mahmood',
      ),
    ];
  }

  static List<PurchaseOrder> get purchaseOrders {
    final now = DateTime.now();
    return [
      PurchaseOrder(
        id: 'po-1',
        poNumber: 'PO-2001',
        supplierId: 'sup-1',
        supplierName: 'GSK Pakistan Distribution',
        orderDate: now.subtract(const Duration(days: 2)),
        expectedDeliveryDate: now.add(const Duration(days: 2)),
        status: POStatus.sent,
        items: const [
          POLineItem(medicineId: 'med-1', medicineName: 'Panadol 500mg', packQuantity: 50, purchasePricePerPack: 32.0),
          POLineItem(medicineId: 'med-4', medicineName: 'Augmentin 625mg', packQuantity: 20, purchasePricePerPack: 230.0),
        ],
        totalAmount: 6200.0,
        notes: 'Urgent delivery needed by Saturday.',
      ),
      PurchaseOrder(
        id: 'po-2',
        poNumber: 'PO-2002',
        supplierId: 'sup-2',
        supplierName: 'Abbott Laboratories Pak Ltd',
        orderDate: now.subtract(const Duration(days: 5)),
        status: POStatus.received,
        items: const [
          POLineItem(medicineId: 'med-6', medicineName: 'Brufen 400mg', packQuantity: 40, purchasePricePerPack: 42.0),
          POLineItem(medicineId: 'med-12', medicineName: 'Surbex Z', packQuantity: 15, purchasePricePerPack: 300.0),
        ],
        totalAmount: 6180.0,
        notes: 'Standard monthly refill',
      ),
    ];
  }

  static List<ActivityLog> get activityLogs {
    final now = DateTime.now();
    return [
      ActivityLog(id: 'act-1', timestamp: now.subtract(const Duration(hours: 5)), userName: 'Tariq Mahmood', role: 'Owner', action: 'Login', details: 'User logged in successfully'),
      ActivityLog(id: 'act-2', timestamp: now.subtract(const Duration(hours: 3)), userName: 'Tariq Mahmood', role: 'Owner', action: 'New Sale', details: 'Created invoice INV-1001 (Rs 340)'),
      ActivityLog(id: 'act-3', timestamp: now.subtract(const Duration(hours: 2)), userName: 'Tariq Mahmood', role: 'Owner', action: 'New Sale', details: 'Created card invoice INV-1002 (Rs 480)'),
      ActivityLog(id: 'act-4', timestamp: now.subtract(const Duration(minutes: 45)), userName: 'Ali Raza', role: 'Staff', action: 'New Sale', details: 'Created cash invoice INV-1003 (Rs 130)'),
    ];
  }
}
