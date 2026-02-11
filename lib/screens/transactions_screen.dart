import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../models/transaction.dart' as models;
import '../models/category.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen>
    with SingleTickerProviderStateMixin {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  late TabController _tabController;
  List<models.Transaction> _incomeTransactions = [];
  List<models.Transaction> _expenseTransactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTransactions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    
    final transactions = await _dbHelper.getTransactions();
    
    setState(() {
      _incomeTransactions = transactions
          .where((t) => t.type == 'income')
          .toList();
      _expenseTransactions = transactions
          .where((t) => t.type == 'expense')
          .toList();
      _isLoading = false;
    });
  }

  Future<void> _deleteTransaction(String id) async {
    await _dbHelper.deleteTransaction(id);
    _loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaktionen'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Einnahmen', icon: Icon(Icons.arrow_downward)),
            Tab(text: 'Ausgaben', icon: Icon(Icons.arrow_upward)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTransactionList(_incomeTransactions, 'income'),
                _buildTransactionList(_expenseTransactions, 'expense'),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionDialog(
          _tabController.index == 0 ? 'income' : 'expense',
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTransactionList(List<models.Transaction> transactions, String type) {
    final currencyFormat = NumberFormat.currency(locale: 'de_DE', symbol: '€');

    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == 'income' ? Icons.account_balance_wallet : Icons.shopping_cart,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Keine ${type == 'income' ? 'Einnahmen' : 'Ausgaben'} vorhanden',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final dateFormat = DateFormat('dd.MM.yyyy');
        
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: type == 'income' ? Colors.green : Colors.red,
              child: Icon(
                type == 'income' ? Icons.arrow_downward : Icons.arrow_upward,
                color: Colors.white,
              ),
            ),
            title: Text(transaction.category),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.description),
                Text(
                  dateFormat.format(transaction.date),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currencyFormat.format(transaction.amount),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: type == 'income' ? Colors.green : Colors.red,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteConfirmation(transaction.id),
                ),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Future<void> _showDeleteConfirmation(String id) async {
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

    if (confirmed == true) {
      await _deleteTransaction(id);
    }
  }

  Future<void> _showAddTransactionDialog(String type) async {
    final categories = await _dbHelper.getCategories(type);
    
    String? selectedCategory = categories.isNotEmpty ? categories[0].name : null;
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    bool showNewCategoryField = false;
    final newCategoryController = TextEditingController();

    // Capture the context before the async operation
    final widgetContext = context;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            type == 'income' ? 'Neue Einnahme' : 'Neue Ausgabe',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!showNewCategoryField) ...[
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Kategorie',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      ...categories.map((cat) => DropdownMenuItem(
                            value: cat.name,
                            child: Text(cat.name),
                          )),
                      const DropdownMenuItem(
                        value: '__new__',
                        child: Text('+ Neue Kategorie'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == '__new__') {
                        setDialogState(() => showNewCategoryField = true);
                      } else {
                        setDialogState(() => selectedCategory = value);
                      }
                    },
                  ),
                ] else ...[
                  TextField(
                    controller: newCategoryController,
                    decoration: InputDecoration(
                      labelText: 'Neue Kategorie',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setDialogState(() {
                            showNewCategoryField = false;
                            newCategoryController.clear();
                          });
                        },
                      ),
                    ),
                  ),
                ],
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
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Beschreibung',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Datum'),
                  subtitle: Text(DateFormat('dd.MM.yyyy').format(selectedDate)),
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
                final amount = double.tryParse(
                  amountController.text.replaceAll(',', '.'),
                );
                
                if (amount == null || amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bitte geben Sie einen gültigen Betrag ein'),
                    ),
                  );
                  return;
                }

                String categoryName;
                if (showNewCategoryField) {
                  categoryName = newCategoryController.text.trim();
                  if (categoryName.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Bitte geben Sie einen Kategorienamen ein'),
                      ),
                    );
                    return;
                  }
                  // Neue Kategorie speichern
                  final newCategory = Category(
                    id: const Uuid().v4(),
                    name: categoryName,
                    type: type,
                    isCustom: true,
                  );
                  await _dbHelper.insertCategory(newCategory);
                } else {
                  categoryName = selectedCategory ?? '';
                }

                final transaction = models.Transaction(
                  id: const Uuid().v4(),
                  type: type,
                  category: categoryName,
                  amount: amount,
                  description: descriptionController.text,
                  date: selectedDate,
                );

                await _dbHelper.insertTransaction(transaction);
                Navigator.pop(dialogContext);
                _loadTransactions();
                
                if (mounted) {
                  ScaffoldMessenger.of(widgetContext).showSnackBar(
                    SnackBar(
                      content: Text(
                        type == 'income'
                            ? 'Einnahme hinzugefügt'
                            : 'Ausgabe hinzugefügt',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Speichern'),
            ),
          ],
        ),
      ),
    );
  }
}
