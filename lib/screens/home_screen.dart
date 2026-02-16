import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import 'transactions_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  double _balance = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    // Standardkonto (aus deiner DB): 'default_main'
    final balance = await _dbHelper.getAccountBalance('default_main');
    setState(() {
      _balance = balance;
      _isLoading = false;
    });
  }

  /// Wird nach jeder Transaktion aufgerufen, um neue Summen zu laden
  void _refreshAfterTransaction() {
    _loadBalance();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'de_DE', symbol: '€');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mein Budget'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadBalance,
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 40),
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.account_balance_wallet,
                        size: 80,
                        color: Colors.blueAccent,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Aktueller Kontostand',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currencyFormat.format(_balance),
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: _balance >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.list),
                        label: const Text('Transaktionen anzeigen'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        onPressed: () async {
                          // Navigiere zum Transaktionsscreen
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TransactionsScreen(),
                            ),
                          );
                          // Nach Rückkehr: neu berechnen
                          _refreshAfterTransaction();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
//bild fix