import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../core/role_guard.dart';
import '../../data/models/finance_model.dart';
import '../../widgets/empty_state.dart';
import '../../providers/finance_provider.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  ExpenseCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Store Expenses'),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('Add Expense'),
          onPressed: () => Navigator.pushNamed(context, '/add-expense'),
        ),
        body: Consumer<FinanceProvider>(
          builder: (context, financeProvider, _) {
            final allExpenses = financeProvider.expenses;
            final expenses = _selectedCategory == null
                ? allExpenses
                : allExpenses.where((e) => e.category == _selectedCategory).toList();

            final totalSpent = expenses.fold(0.0, (sum, e) => sum + e.amount);

            return Column(
              children: [
                // Top Total Spent Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  color: AppColors.surface,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Expenses:',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                      ),
                      Text(
                        AppFormatters.currency(totalSpent),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.danger),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Category Filter Chips
                SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: const Text('All Categories'),
                          selected: _selectedCategory == null,
                          onSelected: (_) => setState(() => _selectedCategory = null),
                        ),
                      ),
                      ...ExpenseCategory.values.map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            label: Text(cat.label),
                            selected: isSelected,
                            onSelected: (_) => setState(() => _selectedCategory = isSelected ? null : cat),
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                Expanded(
                  child: expenses.isEmpty
                      ? EmptyState(
                          icon: Icons.money_off_outlined,
                          title: 'No Expenses Recorded',
                          message: 'Log store expenses such as rent, electricity, tea, supplies and salaries.',
                          buttonText: 'Add First Expense',
                          onButtonPressed: () => Navigator.pushNamed(context, '/add-expense'),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                          itemCount: expenses.length,
                          itemBuilder: (context, index) {
                            final exp = expenses[index];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.dangerLight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.arrow_outward, color: AppColors.danger, size: 20),
                                ),
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(exp.category.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    Text(
                                      '- ${AppFormatters.currency(exp.amount)}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.danger),
                                    ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (exp.description.isNotEmpty)
                                      Text(exp.description, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary)),
                                    Text(
                                      '${AppFormatters.date(exp.date)} • ${exp.paymentMethod} • Recorded by ${exp.recordedBy}',
                                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

