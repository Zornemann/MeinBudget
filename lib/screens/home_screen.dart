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
  List<Transaction> _recentTransactions = [];
  List<Loan> _activeLoans = [];
  double _totalIncome = 0;
  double _totalExpenses = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final transactions = await _dbHelper.getTransactions();
    final loans = await _dbHelper.getLoans();

    // Berechne Summen für aktuellen Monat
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    double income = 0;
    double expenses = 0;

    for (var transaction in transactions) {
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
      _recentTransactions = transactions.take(5).toList();
      _activeLoans = loans;
      _totalIncome = income;
      _totalExpenses = expenses;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'de_DE', symbol: '€');
    final balance = _totalIncome - _totalExpenses;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MeinBudget'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Übersichtskarte
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              'Aktueller Monat',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildSummaryItem(
                                  context,
                                  'Einnahmen',
                                  currencyFormat.format(_totalIncome),
                                  Colors.green,
                                  Icons.arrow_downward,
                                ),
                                _buildSummaryItem(
                                  context,
                                  'Ausgaben',
                                  currencyFormat.format(_totalExpenses),
                                  Colors.red,
                                  Icons.arrow_upward,
                                ),
                              ],
                            ),
                            const Divider(height: 32),
                            Text(
                              'Saldo',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currencyFormat.format(balance),
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: balance >= 0 ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Aktionen
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const TransactionsScreen(),
                                ),
                              );
                              _loadData();
                            },
                            icon: const Icon(Icons.account_balance_wallet),
                            label: const Text('Transaktionen'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoansScreen(),
                                ),
                              );
                              _loadData();
                            },
                            icon: const Icon(Icons.credit_card),
                            label: const Text('Kredite'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Letzte Transaktionen
                    Text(
                      'Letzte Transaktionen',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    if (_recentTransactions.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: Text('Keine Transaktionen vorhanden'),
                          ),
                        ),
                      )
                    else
                      ...(_recentTransactions.map((transaction) => Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: transaction.type == 'income'
                                    ? Colors.green
                                    : Colors.red,
                                child: Icon(
                                  transaction.type == 'income'
                                      ? Icons.arrow_downward
                                      : Icons.arrow_upward,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(transaction.category),
                              subtitle: Text(transaction.description),
                              trailing: Text(
                                currencyFormat.format(transaction.amount),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: transaction.type == 'income'
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ),
                          ))),
                    const SizedBox(height: 24),

                    // Aktive Kredite
                    if (_activeLoans.isNotEmpty) ...[
                      Text(
                        'Aktive Kredite',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      ...(_activeLoans.map((loan) {
                        final remaining = loan.getRemainingAmount(DateTime.now());
                        return Card(
                          child: ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.credit_card),
                            ),
                            title: Text(loan.name),
                            subtitle: Text(
                              '${loan.durationMonths} Monate • ${loan.interestRate.toStringAsFixed(2)}% Zinsen',
                            ),
                            trailing: Text(
                              currencyFormat.format(remaining),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      })),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
