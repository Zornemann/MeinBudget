import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../models/transaction.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Transaction> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    
    final transactions = await _dbHelper.getTransactions();
    
    if (mounted) {
      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteTransaction(String id) async {
    await _dbHelper.deleteTransaction(id);
    if (mounted) {
      _loadTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'de_DE', symbol: '€');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaktionen'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _transactions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.receipt, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Keine Transaktionen vorhanden',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = _transactions[index];
                    return _buildTransactionCard(transaction, currencyFormat);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransactionDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTransactionCard(Transaction transaction, NumberFormat currencyFormat) {
    final isIncome = transaction.type == 'income';
    final color = isIncome ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.3),
          child: Icon(isIncome ? Icons.arrow_downward : Icons.arrow_upward, color: color),
        ),
        title: Text(transaction.category),
        subtitle: Text(
          DateFormat('dd.MM.yyyy HH:mm').format(DateTime.parse(transaction.date)),
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Text('Löschen'),
              onTap: () => _showDeleteConfirmation(transaction.id),
            ),
          ],
        ),
        onTap: () => _showTransactionDetails(transaction, currencyFormat),
      ),
    );
  }

  void _showTransactionDetails(Transaction transaction, NumberFormat currencyFormat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(transaction.category),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Betrag: ${currencyFormat.format(transaction.amount)}'),
            const SizedBox(height: 8),
            Text('Typ: ${transaction.type}'),
            const SizedBox(height: 8),
            Text('Datum: ${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.parse(transaction.date))}'),
            if (transaction.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Beschreibung: ${transaction.description}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Schließen'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation(String id) async {
    if (!mounted) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Löschen bestätigen'),
        content: const Text('Möchten Sie diese Transaktion wirklich löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Löschen', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _deleteTransaction(id);
    }
  }

  Future<void> _showAddTransactionDialog() async {
    final typeController = TextEditingController(text: 'expense');
    final categoryController = TextEditingController();
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Neue Transaktion'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: typeController.text,
                  items: const [
                    DropdownMenuItem(value: 'income', child: Text('Einnahme')),  
                    DropdownMenuItem(value: 'expense', child: Text('Ausgabe')), 
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => typeController.text = value);
                    }
                  },
                  decoration: const InputDecoration(labelText: 'Typ'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Kategorie',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Betrag',
                    border: OutlineInputBorder(),
                    prefixText: '€ ',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Datum'),
                  subtitle: Text(DateFormat('dd.MM.yyyy HH:mm').format(selectedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setDialogState(() => selectedDate = picked);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Beschreibung (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Abbrechen'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (categoryController.text.trim().isEmpty) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Bitte geben Sie eine Kategorie ein')), 
                    );
                  }
                  return;
                }

                final amount = double.tryParse(
                  amountController.text.replaceAll(',', '.'),
                );

                if (amount == null || amount <= 0) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Bitte geben Sie einen gültigen Betrag ein')), 
                    );
                  }
                  return;
                }

                final transaction = Transaction(
                  id: const Uuid().v4(),
                  type: typeController.text,
                  category: categoryController.text.trim(),
                  amount: amount,
                  description: descriptionController.text.trim(),
                  date: selectedDate.toIso8601String(),
                );

                await _dbHelper.insertTransaction(transaction);
                if (mounted) {
                  Navigator.pop(dialogContext);
                  _loadTransactions();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Transaktion hinzugefügt')), 
                  );
                }
              },
              child: const Text('Speichern'),
            ),
          ],
        ),
      );
  }
}