import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../data/models/medicine_model.dart';
import '../../widgets/empty_state.dart';
import '../../providers/billing_provider.dart';
import '../../providers/inventory_provider.dart';

class NewSaleScreen extends StatefulWidget {
  final bool isEmbedded; // true when loaded as bottom navigation tab
  final VoidCallback? onOpenDrawer;

  const NewSaleScreen({super.key, this.isEmbedded = false, this.onOpenDrawer});

  @override
  State<NewSaleScreen> createState() => _NewSaleScreenState();
}

class _NewSaleScreenState extends State<NewSaleScreen> {
  final _searchController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _discountController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _customerNameController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  void _showAddMedicineDialog(BuildContext context, Medicine med) {
    final inventory = Provider.of<InventoryProvider>(context, listen: false);
    final billing = Provider.of<BillingProvider>(context, listen: false);

    bool isLoose = med.isLooseEnabled ? med.packType.defaultLooseEnabled : false;
    int quantity = 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final availableUnits = inventory.getSellableUnits(med.id);
            final unitPrice = isLoose ? med.loosePrice : med.salePrice;
            final lineTotal = unitPrice * quantity;

            return Container(
              padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          med.name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  Text(
                    '${med.genericName} • Available: $availableUnits ${med.unitName}s',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),

                  // Pack vs Loose Selector
                  if (med.isLooseEnabled) ...[
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: Center(child: Text('Full ${med.packType.label} (${AppFormatters.currency(med.salePrice)})')),
                            selected: !isLoose,
                            selectedColor: AppColors.primaryLight,
                            onSelected: (selected) {
                              if (selected) setModalState(() => isLoose = false);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: Center(child: Text('Loose ${med.unitName} (${AppFormatters.currency(med.loosePrice)})')),
                            selected: isLoose,
                            selectedColor: AppColors.primaryLight,
                            onSelected: (selected) {
                              if (selected) setModalState(() => isLoose = true);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Quantity Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Quantity:',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          IconButton.outlined(
                            icon: const Icon(Icons.remove),
                            onPressed: quantity > 1 ? () => setModalState(() => quantity--) : null,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text(
                              '$quantity',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton.outlined(
                            icon: const Icon(Icons.add),
                            onPressed: () => setModalState(() => quantity++),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Amount:', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                      Text(
                        AppFormatters.currency(lineTotal),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: () {
                      final error = billing.addItem(
                        medicine: med,
                        isLoose: isLoose,
                        quantity: quantity,
                        inventoryProvider: inventory,
                      );
                      Navigator.pop(ctx);
                      if (error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error), backgroundColor: AppColors.danger),
                        );
                      }
                    },
                    child: const Text('Add to Bill'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final billing = context.watch<BillingProvider>();
    final inventory = context.watch<InventoryProvider>();
    final cartItems = billing.cartItems;
    if (_customerNameController.text != billing.customerName) {
      _customerNameController.text = billing.customerName;
      _customerNameController.selection = TextSelection.fromPosition(
        TextPosition(offset: _customerNameController.text.length),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('New Sale (Billing)'),
        leading: widget.isEmbedded
            ? (widget.onOpenDrawer != null
                ? IconButton(
                    icon: const Icon(Icons.menu),
                    tooltip: 'Open Menu',
                    onPressed: widget.onOpenDrawer,
                  )
                : null)
            : const BackButton(),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Barcode Scanner',
            onPressed: () {
              Navigator.pushNamed(context, '/barcode-scanner');
            },
          ),
          IconButton(
            icon: const Icon(Icons.pause_circle_outline),
            tooltip: 'Park / Hold Bill',
            onPressed: cartItems.isEmpty
                ? null
                : () {
                    billing.holdCurrentBill();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Bill parked in Held Bills'), backgroundColor: AppColors.primary),
                    );
                  },
          ),
          PopupMenuButton<String>(
            tooltip: 'Billing Options',
            onSelected: (val) {
              if (val == 'held') Navigator.pushNamed(context, '/held-bills');
              if (val == 'history') Navigator.pushNamed(context, '/sales-history');
              if (val == 'return') Navigator.pushNamed(context, '/sales-return');
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'held',
                child: Row(
                  children: [
                    const Icon(Icons.pause_presentation_outlined, size: 18),
                    const SizedBox(width: 8),
                    Text('Held Bills (${billing.heldBills.length})'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'history',
                child: Row(
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Sales History'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'return',
                child: Row(
                  children: [
                    Icon(Icons.assignment_return_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Sales Return'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Customer Name Input Banner
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: TextField(
              controller: _customerNameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Customer Name (Optional)',
                hintText: 'Walk-in Customer',
                prefixIcon: const Icon(Icons.person_outline, size: 20, color: AppColors.primary),
                suffixIcon: _customerNameController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _customerNameController.clear();
                          billing.setCustomerName('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
              onChanged: (val) => billing.setCustomerName(val),
            ),
          ),

          // Search to Add Medicine
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Autocomplete<Medicine>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<Medicine>.empty();
                }
                final query = textEditingValue.text.toLowerCase();
                return inventory.allMedicines.where((med) {
                  return med.name.toLowerCase().contains(query) ||
                      med.genericName.toLowerCase().contains(query) ||
                      med.barcode.contains(query);
                });
              },
              displayStringForOption: (med) => '${med.name} (${AppFormatters.currency(med.salePrice)})',
              onSelected: (med) {
                _showAddMedicineDialog(context, med);
              },
              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    hintText: 'Search medicine name, barcode or formula...',
                    prefixIcon: Icon(Icons.search, size: 20, color: AppColors.textSecondary),
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                );
              },
            ),
          ),

          // Cart Items List
          Expanded(
            child: cartItems.isEmpty
                ? const EmptyState(
                    icon: Icons.add_shopping_cart,
                    title: 'Current Bill is Empty',
                    message: 'Search for a medicine or scan a barcode above to add items to this sale invoice.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.medicineName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${item.isLoose ? "Loose Unit" : "Full Pack"} • ${AppFormatters.currency(item.unitPrice)} each',
                                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, size: 20),
                                    onPressed: () {
                                      billing.updateItemQuantity(index, item.quantity - 1, inventory);
                                    },
                                  ),
                                  Text(
                                    '${item.quantity}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline, size: 20),
                                    onPressed: () {
                                      billing.updateItemQuantity(index, item.quantity + 1, inventory);
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    AppFormatters.currency(item.lineTotal),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryDark),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                                    onPressed: () => billing.removeItem(index),
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

          // Total & Checkout Summary Card
          if (cartItems.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal:', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        Text(AppFormatters.currency(billing.subtotal), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text('Discount:', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Flat Discount (Rs)'),
                                    content: TextField(
                                      controller: _discountController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(labelText: 'Discount Amount (Rs)', hintText: '0'),
                                    ),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                                      ElevatedButton(
                                        onPressed: () {
                                          final val = double.tryParse(_discountController.text) ?? 0.0;
                                          billing.setDiscount(val);
                                          Navigator.pop(ctx);
                                        },
                                        child: const Text('Apply'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: const Text('(Change)', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        Text('- ${AppFormatters.currency(billing.discount)}', style: const TextStyle(fontSize: 13, color: AppColors.danger, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Net Total:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(
                          AppFormatters.currency(billing.netTotal),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                      onPressed: () {
                        Navigator.pushNamed(context, '/payment');
                      },
                      child: const Text('Proceed to Payment'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

