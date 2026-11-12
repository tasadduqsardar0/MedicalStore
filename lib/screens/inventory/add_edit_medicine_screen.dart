import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/validators.dart';
import '../../core/stock_rules.dart';
import '../../widgets/app_text_field.dart';
import '../../data/models/medicine_model.dart';
import '../../providers/inventory_provider.dart';

class AddEditMedicineScreen extends StatefulWidget {
  final String? medicineId; // null = Add, non-null = Edit

  const AddEditMedicineScreen({super.key, this.medicineId});

  @override
  State<AddEditMedicineScreen> createState() => _AddEditMedicineScreenState();
}

class _AddEditMedicineScreenState extends State<AddEditMedicineScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _genericController = TextEditingController();
  final _companyController = TextEditingController();
  final _unitsPerPackController = TextEditingController(text: '10');
  final _salePriceController = TextEditingController();
  final _loosePriceController = TextEditingController();
  final _minStockController = TextEditingController(text: '10');
  final _barcodeController = TextEditingController();

  String? _selectedCategoryId;
  DosageForm _selectedForm = DosageForm.tablet;
  PackType _selectedPackType = PackType.strip;
  bool _isControlled = false;
  bool _isLooseEnabled = true;
  bool _canEditUnits = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMedicineData();
    });
  }

  void _loadMedicineData() {
    final inventory = Provider.of<InventoryProvider>(context, listen: false);

    if (widget.medicineId != null) {
      final med = inventory.getMedicineById(widget.medicineId!);
      if (med != null) {
        _nameController.text = med.name;
        _genericController.text = med.genericName;
        _companyController.text = med.company;
        _unitsPerPackController.text = med.unitsPerPack.toString();
        _salePriceController.text = med.salePrice.toStringAsFixed(0);
        _loosePriceController.text = med.loosePrice.toStringAsFixed(0);
        _minStockController.text = med.minimumStockPacks.toString();
        _barcodeController.text = med.barcode;
        _selectedCategoryId = med.categoryId;
        _selectedForm = med.form;
        _selectedPackType = med.packType;
        _isControlled = med.isControlled;
        _isLooseEnabled = med.isLooseEnabled;

        // Rule: Units per pack cannot be changed while the medicine has stock!
        final batches = inventory.getBatchesForMedicine(med.id);
        _canEditUnits = StockRules.canEditUnitsPerPack(batches);
        setState(() {});
      }
    } else {
      // Default category if available
      if (inventory.categories.isNotEmpty) {
        setState(() {
          _selectedCategoryId = inventory.categories.first.id;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _genericController.dispose();
    _companyController.dispose();
    _unitsPerPackController.dispose();
    _salePriceController.dispose();
    _loosePriceController.dispose();
    _minStockController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  void _onPackTypeChanged(PackType type) {
    setState(() {
      _selectedPackType = type;
      // Loose switch is ON by default for Strip, OFF for Bottle!
      _isLooseEnabled = type.defaultLooseEnabled;
      if (type == PackType.bottle || type == PackType.tube || type == PackType.vial) {
        if (_unitsPerPackController.text == '10') {
          _unitsPerPackController.text = '1';
        }
      }
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a medicine category'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final inventory = Provider.of<InventoryProvider>(context, listen: false);
    final isEditing = widget.medicineId != null;

    final salePrice = double.tryParse(_salePriceController.text.trim()) ?? 0.0;
    final loosePrice = double.tryParse(_loosePriceController.text.trim()) ?? (salePrice / (int.tryParse(_unitsPerPackController.text) ?? 1));

    final medicine = Medicine(
      id: isEditing ? widget.medicineId! : 'med-${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      genericName: _genericController.text.trim(),
      categoryId: _selectedCategoryId!,
      company: _companyController.text.trim(),
      form: _selectedForm,
      packType: _selectedPackType,
      unitsPerPack: int.tryParse(_unitsPerPackController.text.trim()) ?? 1,
      salePrice: salePrice,
      loosePrice: loosePrice,
      minimumStockPacks: int.tryParse(_minStockController.text.trim()) ?? 10,
      barcode: _barcodeController.text.trim(),
      isControlled: _isControlled,
      isLooseEnabled: _isLooseEnabled,
    );

    if (isEditing) {
      inventory.updateMedicine(medicine);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medicine updated successfully'), backgroundColor: AppColors.success),
      );
    } else {
      inventory.addMedicine(medicine);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medicine added successfully'), backgroundColor: AppColors.success),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryProvider>();
    final categories = inventory.categories;
    final isEditing = widget.medicineId != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Medicine' : 'Add New Medicine'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Controlled Drug Toggle
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _isControlled ? AppColors.controlledLight : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isControlled ? AppColors.controlled : AppColors.border,
                    ),
                  ),
                  child: SwitchListTile(
                    title: const Text(
                      'Controlled Drug (Schedule / Narcotic)',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(
                      'Requires prescription and auto-logs into Controlled Drug Register upon sale.',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: _isControlled,
                    activeThumbColor: AppColors.controlled,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) => setState(() => _isControlled = val),
                  ),
                ),
                const SizedBox(height: 16),

                // Name & Generic
                AppTextField(
                  controller: _nameController,
                  label: 'Medicine Brand Name *',
                  hint: 'e.g. Panadol 500mg',
                  validator: (v) => AppValidators.requiredField(v, 'Enter brand name'),
                ),
                const SizedBox(height: 14),

                AppTextField(
                  controller: _genericController,
                  label: 'Generic / Formula Name *',
                  hint: 'e.g. Paracetamol',
                  validator: (v) => AppValidators.requiredField(v, 'Enter generic formula name'),
                ),
                const SizedBox(height: 14),

                // Category Dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Category *',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      key: ValueKey('cat_$_selectedCategoryId'),
                      initialValue: _selectedCategoryId,
                      hint: const Text('Select Category'),
                      items: categories.map((cat) {
                        return DropdownMenuItem(value: cat.id, child: Text(cat.name));
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedCategoryId = val),
                      validator: (v) => v == null ? 'Select category' : null,
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                AppTextField(
                  controller: _companyController,
                  label: 'Manufacturer / Pharmaceutical Company *',
                  hint: 'e.g. GSK Pakistan, Abbott',
                  validator: (v) => AppValidators.requiredField(v, 'Enter company name'),
                ),
                const SizedBox(height: 14),

                // Dosage Form & Pack Type Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Dosage Form *',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<DosageForm>(
                            key: ValueKey('form_$_selectedForm'),
                            initialValue: _selectedForm,
                            items: DosageForm.values.map((f) {
                              return DropdownMenuItem(value: f, child: Text(f.label));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedForm = val);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pack Type *',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<PackType>(
                            key: ValueKey('pack_$_selectedPackType'),
                            initialValue: _selectedPackType,
                            items: PackType.values.map((p) {
                              return DropdownMenuItem(value: p, child: Text(p.label));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) _onPackTypeChanged(val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Units Per Pack
                AppTextField(
                  controller: _unitsPerPackController,
                  label: 'Units Per Pack (e.g. 10 tablets/strip) *',
                  hint: '10',
                  keyboardType: TextInputType.number,
                  readOnly: !_canEditUnits,
                  helperText: !_canEditUnits
                      ? 'Cannot change units per pack while medicine has stock.'
                      : 'Smallest units contained in one pack.',
                  validator: AppValidators.positiveInteger,
                ),
                const SizedBox(height: 14),

                // Loose switch
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: SwitchListTile(
                    title: const Text('Allow Selling Loose Units', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: Text('Customer can buy individual ${_selectedForm.defaultUnitName.toLowerCase()}s'),
                    value: _isLooseEnabled,
                    activeThumbColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) => setState(() => _isLooseEnabled = val),
                  ),
                ),
                const SizedBox(height: 14),

                // Pricing Row
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _salePriceController,
                        label: 'Pack Sale Price (Rs) *',
                        hint: '40',
                        keyboardType: TextInputType.number,
                        validator: AppValidators.positiveNumber,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        controller: _loosePriceController,
                        label: 'Loose Price (Rs)',
                        hint: '4',
                        keyboardType: TextInputType.number,
                        validator: _isLooseEnabled ? AppValidators.positiveNumber : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Minimum Stock (packs) & Barcode
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _minStockController,
                        label: 'Min Stock (Packs) *',
                        hint: '10',
                        keyboardType: TextInputType.number,
                        validator: AppValidators.positiveInteger,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        controller: _barcodeController,
                        label: 'Barcode',
                        hint: '8964...',
                        keyboardType: TextInputType.text,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: _submit,
                  child: Text(isEditing ? 'Save Medicine Changes' : 'Create Medicine'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

