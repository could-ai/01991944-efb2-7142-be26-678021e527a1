import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:couldai_user_app/models/income.dart';
import 'package:couldai_user_app/models/expense.dart';
import 'package:uuid/uuid.dart';

class AddTransactionScreen extends StatefulWidget {
  final bool isIncome;
  
  const AddTransactionScreen({super.key, required this.isIncome});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  
  late Box<Income> incomeBox;
  late Box<Expense> expenseBox;
  
  @override
  void initState() {
    super.initState();
    incomeBox = Hive.box<Income>('income');
    expenseBox = Hive.box<Expense>('expense');
  }
  
  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _categoryController.dispose();
    super.dispose();
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  
  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      final uuid = const Uuid();
      final description = _descriptionController.text.trim();
      final amount = double.parse(_amountController.text.trim());
      final category = _categoryController.text.trim().isEmpty ? 'General' : _categoryController.text.trim();
      
      if (widget.isIncome) {
        final income = Income(
          id: uuid.v4(),
          description: description,
          amount: amount,
          date: _selectedDate,
          category: category,
        );
        incomeBox.add(income);
      } else {
        final expense = Expense(
          id: uuid.v4(),
          description: description,
          amount: amount,
          date: _selectedDate,
          category: category,
        );
        expenseBox.add(expense);
      }
      
      Navigator.of(context).pop();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add ${widget.isIncome ? 'Income' : 'Expense'}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixText: '₹',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amount = double.tryParse(value.trim());
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category (optional)',
                  hintText: 'e.g., Food, Transport, Salary',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: const Text('Select Date'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveTransaction,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: widget.isIncome ? Colors.green : Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text('Save ${widget.isIncome ? 'Income' : 'Expense'}'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}