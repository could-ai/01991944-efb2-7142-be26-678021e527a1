import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:couldai_user_app/models/income.dart';
import 'package:couldai_user_app/models/expense.dart';
import 'package:couldai_user_app/screens/add_transaction_screen.dart';
import 'package:couldai_user_app/screens/transaction_list_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Box<Income> incomeBox;
  late Box<Expense> expenseBox;
  
  @override
  void initState() {
    super.initState();
    incomeBox = Hive.box<Income>('income');
    expenseBox = Hive.box<Expense>('expense');
  }
  
  double get totalIncome {
    return incomeBox.values.fold(0, (sum, income) => sum + income.amount);
  }
  
  double get totalExpense {
    return expenseBox.values.fold(0, (sum, expense) => sum + expense.amount);
  }
  
  double get balance => totalIncome - totalExpense;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Income & Expense Tracker'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ValueListenableBuilder(
        valueListenable: incomeBox.listenable(),
        builder: (context, Box<Income> incomeBox, _) {
          return ValueListenableBuilder(
            valueListenable: expenseBox.listenable(),
            builder: (context, Box<Expense> expenseBox, _) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Balance Summary
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              'Current Balance',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '₹${balance.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: balance >= 0 ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      'Income',
                                      style: Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    Text(
                                      '₹${totalIncome.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      'Expense',
                                      style: Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    Text(
                                      '₹${totalExpense.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Quick Actions
                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _navigateToAddTransaction(context, true),
                            icon: const Icon(Icons.add, color: Colors.green),
                            label: const Text('Add Income'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade50,
                              foregroundColor: Colors.green.shade800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _navigateToAddTransaction(context, false),
                            icon: const Icon(Icons.remove, color: Colors.red),
                            label: const Text('Add Expense'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade50,
                              foregroundColor: Colors.red.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _navigateToTransactionList(context),
                      icon: const Icon(Icons.list),
                      label: const Text('View All Transactions'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
  
  void _navigateToAddTransaction(BuildContext context, bool isIncome) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(isIncome: isIncome),
      ),
    );
  }
  
  void _navigateToTransactionList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TransactionListScreen(),
      ),
    );
  }
}