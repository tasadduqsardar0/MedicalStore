import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/validators.dart';
import '../../core/role_guard.dart';
import '../../data/models/supplier_model.dart';
import '../../widgets/app_text_field.dart';
import '../../providers/supplier_provider.dart';

class AddEditSupplierScreen extends StatefulWidget {
  final String? supplierId;

  const AddEditSupplierScreen({super.key, this.supplierId});

  @override
  State<AddEditSupplierScreen> createState() => _AddEditSupplierScreenState();
}

class _AddEditSupplierScreenState extends State<AddEditSupplierScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.supplierId != null) {
      final supplierProvider = Provider.of<SupplierProvider>(context, listen: false);
      final sup = supplierProvider.getSupplierById(widget.supplierId!);
      if (sup != null) {
        _companyController.text = sup.companyName;
        _contactPersonController.text = sup.contactPerson;
        _phoneController.text = sup.phone;
        _emailController.text = sup.email;
        _addressController.text = sup.address;
      }
    }
  }

  @override
  void dispose() {
    _companyController.dispose();
    _contactPersonController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final supplierProvider = Provider.of<SupplierProvider>(context, listen: false);
    final isEditing = widget.supplierId != null;

    final sup = Supplier(
      id: isEditing ? widget.supplierId! : 'sup-${DateTime.now().millisecondsSinceEpoch}',
      companyName: _companyController.text.trim(),
      contactPerson: _contactPersonController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      address: _addressController.text.trim(),
    );

    if (isEditing) {
      supplierProvider.updateSupplier(sup);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Supplier updated'), backgroundColor: AppColors.success),
      );
    } else {
      supplierProvider.addSupplier(sup);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Supplier added'), backgroundColor: AppColors.success),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.supplierId != null;

    return RoleGuard(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(isEditing ? 'Edit Supplier' : 'Add New Supplier'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(
                    controller: _companyController,
                    label: 'Company / Agency Name *',
                    hint: 'e.g. GSK Distribution Lahore',
                    validator: (v) => AppValidators.requiredField(v, 'Enter company name'),
                  ),
                  const SizedBox(height: 14),

                  AppTextField(
                    controller: _contactPersonController,
                    label: 'Contact Person / Agent *',
                    hint: 'e.g. Khurram Shehzad',
                    validator: (v) => AppValidators.requiredField(v, 'Enter contact person name'),
                  ),
                  const SizedBox(height: 14),

                  AppTextField(
                    controller: _phoneController,
                    label: 'Contact Phone Number *',
                    hint: 'e.g. 0300-1234567',
                    keyboardType: TextInputType.phone,
                    validator: (v) => AppValidators.requiredField(v, 'Enter phone number'),
                  ),
                  const SizedBox(height: 14),

                  AppTextField(
                    controller: _emailController,
                    label: 'Email Address (optional)',
                    hint: 'orders@distributor.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 14),

                  AppTextField(
                    controller: _addressController,
                    label: 'Depot / Office Address',
                    hint: 'e.g. Depalpur Road, Okara / Lahore',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: _submit,
                    child: Text(isEditing ? 'Save Supplier' : 'Register Supplier'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

