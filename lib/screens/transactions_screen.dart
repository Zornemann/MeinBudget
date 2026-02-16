import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../models/transaction.dart';
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
  List<Transaction> _incomeTransactions = [];
  List<Transaction> _expenseTransactions = [];
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
      _incomeTransactions = transactions.where((t) => t.type == 'income').toList();
      _expenseTransactions = transactions.where((t) => t.type == 'expense').toList();
      _isLoading = false;
    });
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
        onPressed: () => _showTransactionDialog(_tabController.index == 0 ? 'income' : 'expense'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTransactionList(List<Transaction> transactions, String type) {
    final currencyFormat = NumberFormat.currency(locale: 'de_DE', symbol: '€');
    final dateFormat = DateFormat('dd.MM.yyyy');

    if (transactions.isEmpty) {
      return const Center(child: Text('Keine Einträge vorhanden'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: type == 'income' ? Colors.green : Colors.red,
              child: Icon(type == 'income' ? Icons.add : Icons.remove, color: Colors.white),
            ),
            title: Text(transaction.category),
            subtitle: Text("${transaction.description}\n${dateFormat.format(transaction.date)}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(currencyFormat.format(transaction.amount), 
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showTransactionDialog(type, existing: transaction),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDelete(transaction.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(String id) async {
    final bool? confirmed = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Löschen?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Nein')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Ja')),
        ],
      ),
    );
    if (confirmed == true) {
      await _dbHelper.deleteTransaction(id);
      _loadTransactions();
    }
  }

  Future<void> _showTransactionDialog(String type, {Transaction? existing}) async {
    List<Category> categories = await _dbHelper.getCategories(type);
    final accounts = await _dbHelper.getAccounts();

    String selectedAccountId = existing?.accountId ?? (accounts.isNotEmpty ? accounts[0]['id'] : 'default_main');
    String? selectedCategory = existing?.category ?? (categories.isNotEmpty ? categories[0].name : null);
    
    final amountController = TextEditingController(text: existing?.amount.toString().replaceAll('.', ',') ?? '');
    final descController = TextEditingController(text: existing?.description ?? '');
    bool showNewCat = false;
    final newCatController = TextEditingController();

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(existing == null ? 'Neu' : 'Editieren'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedAccountId,
                  items: accounts.map<DropdownMenuItem<String>>((a) => 
                    DropdownMenuItem(value: a['id'].toString(), child: Text(a['name'].toString()))).toList(),
                  onChanged: (v) => setDialogState(() => selectedAccountId = v!),
                  decoration: const InputDecoration(labelText: 'Konto'),
                ),
                if (!showNewCat)
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    items: [
                      ...categories.map((c) => DropdownMenuItem(value: c.name, child: Text(c.name))),
                      const DropdownMenuItem(value: 'new', child: Text('+ Neue Kategorie')),
                    ],
                    onChanged: (v) {
                      if (v == 'new') setDialogState(() => showNewCat = true);
                      else setDialogState(() => selectedCategory = v);
                    },
                    decoration: const InputDecoration(labelText: 'Kategorie'),
                  )
                else
                  TextField(controller: newCatController, decoration: const InputDecoration(labelText: 'Kategorie Name')),
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Betrag (€)'),
                ),
                TextField(controller: descController, decoration: const InputDecoration(labelText: 'Beschreibung')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Abbrechen')),
            ElevatedButton(
              onPressed: () async {
                final amountText = amountController.text.replaceAll(',', '.');
                final amount = double.tryParse(amountText) ?? 0.0;

                if (amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ungültiger Betrag!')));
                  return;
                }

                String finalCategory;
                if (showNewCat && newCatController.text.isNotEmpty) {
                  finalCategory = newCatController.text;
                  final nCat = Category(id: const Uuid().v4(), name: finalCategory, type: type, isCustom: true);
                  await _dbHelper.insertCategory(nCat);
                } else {
                  finalCategory = selectedCategory ?? '';
                }

                if (finalCategory.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kategorie fehlt!')));
                  return;
                }

                try {
                  final t = Transaction(
                    id: existing?.id ?? const Uuid().v4(),
                    accountId: selectedAccountId,
                    type: type,
                    category: finalCategory,
                    amount: amount,
                    description: descController.text,
                    date: existing?.date ?? DateTime.now(),
                  );
                  await _dbHelper.insertTransaction(t);
                  Navigator.pop(ctx);
                  _loadTransactions();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fehler: $e')));
                }
              },
              child: const Text('Speichern'),
            )
          ],
        ),
      ),
    );
  }
}