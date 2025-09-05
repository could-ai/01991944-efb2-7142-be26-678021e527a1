import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:couldai_user_app/models/income.dart';
import 'package:couldai_user_app/models/expense.dart';
import 'package:intl/intl.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  late Box<Income> incomeBox;
  late Box<Expense> expenseBox;
  
  @override
  void initState() {
    super.initState();
    incomeBox = Hive.box<Income>('income');
    expenseBox = Hive.box<Expense>('expense');
  }
  
  List<dynamic> get allTransactions {
    final incomes = incomeBox.values.map((income) => {'type': 'income', 'data': income}).toList();
    final expenses = expenseBox.values.map((expense) => {'type': 'expense', 'data': expense}).toList();
    final all = [...incomes, ...expenses];
    all.sort((a, b) => (b['data'] as dynamic).date.compareTo((a['data'] as dynamic).date));
    return all;
  }
  
  void _deleteTransaction(dynamic transaction, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (transaction['type'] == 'income') {
                incomeBox.deleteAt(index);
              } else {
                expenseBox.deleteAt(index);
              }
              Navigator.of(context).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Transactions'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ValueListenableBuilder(
        valueListenable: incomeBox.listenable(),
        builder: (context, Box<Income> incomeBox, _) {
          return ValueListenableBuilder(
            valueListenable: expenseBox.listenable(),
            builder: (context, Box<Expense> expenseBox, _) {
              final transactions = allTransactions;
              
              if (transactions.isEmpty) {
                return const Center(
                  child: Text('No transactions yet. Add some income or expenses!'),
                );
              }
              
              return ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  final data = transaction['data'];
                  final isIncome = transaction['type'] == 'income';
                  
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isIncome ? Colors.green.shade100 : Colors.red.shade100,
                        child: Icon(
                          isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                          color: isIncome ? Colors.green : Colors.red,
                        ),
                      ),
                      title: Text(data.description),
                      subtitle: Text(
                        '${DateFormat('MMM dd, yyyy').format(data.date)} • ${data.category}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '₹${data.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: isIncome ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.grey),
                            onPressed: () => _deleteTransaction(transaction, index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}