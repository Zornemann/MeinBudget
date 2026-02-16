import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/transaction.dart';
import '../models/loan.dart';
import 'transactions_screen.dart';
import 'loans_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  
  // Multi-Account Variablen
  String _selectedAccountId = 'default_main'; 
  List<Map<String, dynamic>> _accounts = [];
  
  List<Transaction> _recentTransactions = [];
  List<Loan> _activeLoans = [];
  double _totalIncome = 0;
  double _totalExpenses = 0;
  double _grandTotal = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

   // --- HIER DIE VERVOLLSTÄNDIGTE LOAD-DATA METHODE ---
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final accounts = await _dbHelper.getAccounts();
    final allTransactions = await _dbHelper.getTransactions();
    
    // 1. Berechnung des Gesamtvermögens über ALLE Konten
    double totalAll = 0;
    for (var t in allTransactions) {
      totalAll += (t.type == 'income' ? t.amount : -t.amount);
    }

    // 2. Filter für das aktuell ausgewählte Konto
    final filteredTransactions = allTransactions
        .where((t) => t.accountId == _selectedAccountId)
        .toList();

    final loans = await _dbHelper.getLoans();
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    double income = 0;
    double expenses = 0;

    for (var transaction in filteredTransactions) {
      if ((transaction.date.isAfter(startOfMonth) || 
           transaction.date.isAtSameMomentAs(startOfMonth)) &&
          (transaction.date.isBefore(endOfMonth) || 
           transaction.date.isAtSameMomentAs(endOfMonth))) {
        if (transaction.type == 'income') {
          income += transaction.amount;
        } else {
          expenses += transaction.amount;
        }
      }
    }

    setState(() {
      _accounts = accounts;
      _grandTotal = totalAll; // Neuer Wert für alle Konten
      _recentTransactions = filteredTransactions.take(5).toList();
      _activeLoans = loans;
      _totalIncome = income;
      _totalExpenses = expenses;
      _isLoading = false;
    });
  }

  // --- HIER DAS OPTIMIERTE BUILD FÜR DEN HEADER ---
  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'de_DE', symbol: '€');
    final balance = _totalIncome - _totalExpenses;
    
    // Name des aktuellen Kontos finden
    final currentAccountName = _accounts.isEmpty 
        ? 'Lädt...' 
        : _accounts.firstWhere((a) => a['id'] == _selectedAccountId, orElse: () => _accounts.first)['name'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('MeinBudget'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Gesamtvermögen (alle Konten)',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            currencyFormat.format(_grandTotal),
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                          ),
                          const Divider(height: 32, indent: 60, endIndent: 60),
                          Text(
                            'Saldo: $currentAccountName',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            currencyFormat.format(balance),
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: balance >= 0 ? Colors.green : Colors.red,
                                ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    _buildAccountSwitcher(),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(context, 'Einnahmen', _totalIncome, Colors.green, Icons.add_circle_outline),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(context, 'Ausgaben', _totalExpenses, Colors.red, Icons.remove_circle_outline),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text('Verwaltung', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildActionButton(context, 'Transaktionen', Icons.account_balance_wallet, const TransactionsScreen()),
                              const SizedBox(width: 12),
                              _buildActionButton(context, 'Kredite', Icons.credit_card, const LoansScreen()),
                            ],
                          ),
                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Letzte Transaktionen', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                              TextButton(
                                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TransactionsScreen())),
                                child: const Text('Alle zeigen'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (_recentTransactions.isEmpty)
                            _buildEmptyState()
                          else
                            ..._recentTransactions.map((t) => _buildTransactionTile(t, currencyFormat)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // --- HILFS-WIDGETS ---

Widget _buildAccountSwitcher() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text('Meine Konten', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 70,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _accounts.length + 1, // +1 für den Hinzufügen-Button
            itemBuilder: (context, index) {
              if (index == _accounts.length) {
                return _buildAddAccountCard();
              }

              final acc = _accounts[index];
              final isSelected = acc['id'] == _selectedAccountId;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedAccountId = acc['id']);
                  _loadData();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 140,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? Theme.of(context).colorScheme.primary 
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      acc['name'],
                      style: TextStyle(
                        color: isSelected ? Colors.white : null,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddAccountCard() {
    return GestureDetector(
      onTap: _showAddAccountDialog,
      child: Container(
        width: 60,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
            style: BorderStyle.dashed,
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddAccountDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Neues Konto'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'z.B. Bargeld, Tagesgeld...',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                final newAccount = {
                  'id': DateTime.now().millisecondsSinceEpoch.toString(),
                  'name': controller.text,
                  'icon': 'account_balance',
                  'initialBalance': 0.0,
                };
                await _dbHelper.insertAccount(newAccount);
                Navigator.pop(context);
                _loadData();
              }
            },
            child: const Text('Erstellen'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, double amount, Color color, IconData icon) {
    final currencyFormat = NumberFormat.currency(locale: 'de_DE', symbol: '€');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          FittedBox(
            child: Text(
              currencyFormat.format(amount),
              style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, Widget screen) {
    return Expanded(
      child: InkWell(
        onTap: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
          _loadData();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionTile(Transaction t, NumberFormat format) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (t.type == 'income' ? Colors.green : Colors.red).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            t.type == 'income' ? Icons.arrow_downward : Icons.arrow_upward,
            color: t.type == 'income' ? Colors.green : Colors.red,
            size: 20,
          ),
        ),
        title: Text(t.category, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(t.description),
        trailing: Text(
          format.format(t.amount),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: t.type == 'income' ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Text('Keine Buchungen auf diesem Konto.'),
      ),
    );
  }
}