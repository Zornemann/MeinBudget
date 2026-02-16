import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';
import '../models/transaction.dart';
import 'transactions_screen.dart';
import 'account_management_screen.dart';
import 'loan_management_screen.dart'; // Wichtig: Import für Kredite

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
  List<Map<String, dynamic>> _accountBalances = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    // Startet das Tutorial nach dem ersten Frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _showOnboardingIfNeeded());
  }

  Future<void> _showOnboardingIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final bool showIntro = prefs.getBool('show_onboarding') ?? true;

    if (showIntro) {
      _showOnboardingDialog(prefs);
    }
  }

  void _showOnboardingDialog(SharedPreferences prefs) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Willkommen! 🚀', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              const Text('So startest du richtig:'),
              const SizedBox(height: 15),
              _buildTutorialItem(Icons.account_balance_wallet, Colors.blueGrey, 'Konten', 'Lege zuerst deine Konten an.'),
              _buildTutorialItem(Icons.swap_horiz, Colors.indigo, 'Transaktionen', 'Trage hier Einnahmen & Ausgaben ein.'),
              _buildTutorialItem(Icons.account_balance, Colors.orange, 'Kredite', 'Verwalte hier deine Darlehen.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              prefs.setBool('show_onboarding', false);
              Navigator.pop(ctx);
            },
            child: const Text('Alles klar!'),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorialItem(IconData icon, Color color, String title, String desc) {
    return ListTile(
      leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(desc),
      contentPadding: EdgeInsets.zero,
    );
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    final transactions = await _dbHelper.getTransactions();
    final balance = await _dbHelper.getTotalBalance();
    final accounts = await _dbHelper.getAccounts();

    double income = 0;
    double expense = 0;
    Map<String, double> catExp = {};

    for (var t in transactions) {
      if (t.type == 'income') income += t.amount;
      else {
        expense += t.amount;
        catExp[t.category] = (catExp[t.category] ?? 0) + t.amount;
      }
    }

    List<Map<String, dynamic>> accStats = [];
    for (var acc in accounts) {
      final transBal = await _dbHelper.getAccountBalance(acc['id']);
      final total = (acc['initialBalance'] as num).toDouble() + transBal;
      accStats.add({'name': acc['name'], 'balance': total});
    }

    setState(() {
      _balance = balance;
      _totalIncome = income;
      _totalExpense = expense;
      _categoryExpenses = catExp;
      _accountBalances = accStats;
      _isLoading = false;
    });
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'gehalt': return Icons.payments;
      case 'tanken': return Icons.local_gas_station;
      case 'einkauf': return Icons.shopping_cart;
      case 'miete': return Icons.home;
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
        centerTitle: true, elevation: 0, backgroundColor: Colors.transparent, foregroundColor: Colors.black,
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildModernBalanceCard(currencyFormat),
              const SizedBox(height: 30),
              _buildChartCard('Einnahmen vs. Ausgaben', _buildMainPieChart()),
              const SizedBox(height: 20),
              _buildChartCard('Ausgaben / Kategorien', _buildCategoryPieChart()),
              const SizedBox(height: 20),
              _buildChartCard('Konten-Verteilung', _buildAccountPieChart()),
              const SizedBox(height: 30),
              _buildQuickActionButton(context, 'Transaktionen', Icons.swap_horiz, Colors.indigo, const TransactionsScreen()),
              const SizedBox(height: 12),
              _buildQuickActionButton(context, 'Kontenverwaltung', Icons.account_balance_wallet, Colors.blueGrey, const AccountManagementScreen()),
              const SizedBox(height: 12),
              _buildQuickActionButton(context, 'Kredite & Darlehen', Icons.account_balance, Colors.orange, const LoanManagementScreen()),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernBalanceCard(NumberFormat format) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.indigo[700]!, Colors.indigo[400]!]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Text('Gesamtguthaben', style: TextStyle(color: Colors.white70)),
          Text(format.format(_balance), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfo('In', format.format(_totalIncome), Colors.greenAccent),
              _buildInfo('Out', format.format(_totalExpense), Colors.orangeAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfo(String l, String v, Color c) => Column(children: [Text(l, style: TextStyle(color: c)), Text(v, style: const TextStyle(color: Colors.white))]);

  Widget _buildChartCard(String t, Widget c) => Container(
    width: double.infinity, padding: const EdgeInsets.all(20), margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
    child: Column(children: [Text(t, style: const TextStyle(color: Colors.grey)), const SizedBox(height: 15), c]),
  );

  Widget _buildQuickActionButton(BuildContext context, String t, IconData i, Color c, Widget s) => InkWell(
    onTap: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => s)); _loadDashboardData(); },
    child: Container(
      padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(children: [Icon(i, color: c), const SizedBox(width: 15), Text(t, style: const TextStyle(fontWeight: FontWeight.bold)), const Spacer(), const Icon(Icons.chevron_right)]),
    ),
  );

  Widget _buildMainPieChart() => SizedBox(height: 140, child: PieChart(PieChartData(sections: [
    PieChartSectionData(color: Colors.greenAccent, value: _totalIncome, radius: 30, title: ''),
    PieChartSectionData(color: Colors.redAccent, value: _totalExpense, radius: 30, title: ''),
  ])));

  Widget _buildCategoryPieChart() => Column(children: [
    SizedBox(height: 140, child: PieChart(PieChartData(sections: _categoryExpenses.entries.map((e) => PieChartSectionData(color: Colors.primaries[_categoryExpenses.keys.toList().indexOf(e.key) % 15], value: e.value, radius: 30, title: '')).toList()))),
    const SizedBox(height: 10),
    Wrap(spacing: 10, children: _categoryExpenses.keys.map((cat) => Row(mainAxisSize: MainAxisSize.min, children: [Icon(_getCategoryIcon(cat), size: 12), Text(' $cat', style: const TextStyle(fontSize: 10))])).toList())
  ]);

  Widget _buildAccountPieChart() => SizedBox(height: 140, child: PieChart(PieChartData(sections: _accountBalances.map((a) => PieChartSectionData(color: Colors.accents[_accountBalances.indexOf(a) % 15], value: a['balance'] < 0 ? 0 : a['balance'], title: a['name'], radius: 30, titleStyle: const TextStyle(fontSize: 10))).toList())));
}