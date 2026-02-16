import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/transaction.dart';
import 'transactions_screen.dart';
import 'account_management_screen.dart';

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
    final balance = await _dbHelper.getTotalBalance();

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

  // Icon-Mapping Logik
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'gehalt': return Icons.payments;
      case 'kindergeld': return Icons.child_care;
      case 'tanken': return Icons.local_gas_station;
      case 'einkauf': return Icons.shopping_cart;
      case 'kredite': return Icons.account_balance;
      case 'versicherung': return Icons.security;
      case 'miete': return Icons.home;
      case 'freizeit': return Icons.confirmation_number;
      default: return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'de_DE', symbol: '€');

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Finanz Cockpit', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildModernBalanceCard(currencyFormat),
                    const SizedBox(height: 30),
                    _buildSectionTitle('Statistiken'),
                    const SizedBox(height: 16),
                    _buildChartCard('Einnahmen vs. Ausgaben', _buildMainPieChart()),
                    const SizedBox(height: 20),
                    _buildChartCard('Ausgaben nach Kategorien', _buildCategoryPieChart()),
                    const SizedBox(height: 30),
                    _buildSectionTitle('Schnellzugriff'),
                    const SizedBox(height: 16),
                    _buildQuickActionButton(context, 'Transaktionen', Icons.swap_horiz, Colors.indigo, const TransactionsScreen()),
                    const SizedBox(height: 12),
                    _buildQuickActionButton(context, 'Kontenverwaltung', Icons.account_balance_wallet, Colors.blueGrey, const AccountManagementScreen()),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87));
  }

  Widget _buildModernBalanceCard(NumberFormat format) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo[700]!, Colors.indigo[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.indigo.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Gesamtguthaben', style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 8),
          Text(format.format(_balance), style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSmallInfo('Einnahmen', format.format(_totalIncome), Icons.arrow_upward, Colors.greenAccent),
              _buildSmallInfo('Ausgaben', format.format(_totalExpense), Icons.arrow_downward, Colors.orangeAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallInfo(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  Widget _buildChartCard(String title, Widget chart) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54)),
          const SizedBox(height: 20),
          chart,
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(BuildContext context, String title, IconData icon, Color color, Widget screen) {
    return InkWell(
      onTap: () async {
        await Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
        _loadDashboardData();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.1))),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
            const SizedBox(width: 16),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildMainPieChart() {
    if (_totalIncome == 0 && _totalExpense == 0) return const Text('Keine Daten');
    return SizedBox(
      height: 160,
      child: PieChart(
        PieChartData(
          sectionsSpace: 4,
          centerSpaceRadius: 40,
          sections: [
            PieChartSectionData(color: Colors.greenAccent[700], value: _totalIncome, title: '', radius: 25),
            PieChartSectionData(color: Colors.redAccent[200], value: _totalExpense, title: '', radius: 25),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPieChart() {
    if (_categoryExpenses.isEmpty) return const Center(child: Text('Keine Ausgaben'));
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 30,
              sections: _categoryExpenses.entries.map((e) {
                final index = _categoryExpenses.keys.toList().indexOf(e.key);
                return PieChartSectionData(color: Colors.primaries[index % Colors.primaries.length], value: e.value, title: '', radius: 35);
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: _categoryExpenses.keys.map((cat) {
            final index = _categoryExpenses.keys.toList().indexOf(cat);
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_getCategoryIcon(cat), size: 16, color: Colors.primaries[index % Colors.primaries.length]),
                const SizedBox(width: 4),
                Text(cat, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}