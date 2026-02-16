import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/transaction.dart';
import 'transactions_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  double _balance = 0.0;
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;
  Map<String, double> _categoryExpenses = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    final transactions = await _dbHelper.getTransactions();
    final balance = await _dbHelper.getAccountBalance('default_main');

    double income = 0;
    double expense = 0;
    Map<String, double> catExp = {};

    for (var t in transactions) {
      if (t.type == 'income') {
        income += t.amount;
      } else {
        expense += t.amount;
        catExp[t.category] = (catExp[t.category] ?? 0) + t.amount;
      }
    }

    setState(() {
      _balance = balance;
      _totalIncome = income;
      _totalExpense = expense;
      _categoryExpenses = catExp;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'de_DE', symbol: '€');

    return Scaffold(
      appBar: AppBar(title: const Text('Mein Budget Dashboard'), centerTitle: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildBalanceCard(currencyFormat),
                    const SizedBox(height: 24),
                    const Text('Einnahmen vs. Ausgaben', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildMainPieChart(),
                    const SizedBox(height: 40),
                    const Text('Ausgaben nach Kategorien', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildCategoryPieChart(),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.list),
                      label: const Text('Transaktionen verwalten'),
                      onPressed: () async {
                        await Navigator.push(context, MaterialPageRoute(builder: (context) => const TransactionsScreen()));
                        _loadDashboardData();
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBalanceCard(NumberFormat format) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('Aktueller Kontostand', style: TextStyle(fontSize: 16)),
            Text(format.format(_balance),
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: _balance >= 0 ? Colors.green : Colors.red)),
          ],
        ),
      ),
    );
  }

  Widget _buildMainPieChart() {
    if (_totalIncome == 0 && _totalExpense == 0) return const Text('Keine Daten');
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(color: Colors.green, value: _totalIncome, title: 'In', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            PieChartSectionData(color: Colors.red, value: _totalExpense, title: 'Out', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPieChart() {
    if (_categoryExpenses.isEmpty) return const Text('Keine Ausgaben');
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: _categoryExpenses.entries.map((e) {
            return PieChartSectionData(
              color: Colors.primaries[_categoryExpenses.keys.toList().indexOf(e.key) % Colors.primaries.length],
              value: e.value,
              title: e.key,
              radius: 60,
              titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
            );
          }).toList(),
        ),
      ),
    );
  }
}