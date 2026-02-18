import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/loan.dart';

class LoanManagementScreen extends StatefulWidget {
  const LoanManagementScreen({super.key});

  @override
  State<LoanManagementScreen> createState() => _LoanManagementScreenState();
}

class _LoanManagementScreenState extends State<LoanManagementScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Loan> _loans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLoans();
  }

  Future<void> _loadLoans() async {
    setState(() => _isLoading = true);
    final loans = await _dbHelper.getLoans();
    setState(() {
      _loans = loans;
      _isLoading = false;
    });
  }

  // ... (Dialog-Logik wie zuvor, hier abgekürzt für die Übersicht)

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat.currency(locale: 'de_DE', symbol: '€');
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: const Text('Kredite & Darlehen')),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _loans.length,
            itemBuilder: (ctx, i) {
              final loan = _loans[i];
              final remaining = loan.getRemainingAmount(now);
              final progress = 1 - (remaining / loan.totalAmount);

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(loan.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () async {
                              await _dbHelper.deleteLoan(loan.id);
                              _loadLoans();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        backgroundColor: Colors.grey[200],
                        color: Colors.orange,
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildLoanDetail('Offen', format.format(remaining)),
                          _buildLoanDetail('Rate', format.format(loan.monthlyRate)),
                          _buildLoanDetail('Gezahlt', "${(progress * 100).toStringAsFixed(1)}%"),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {}, // Hier den Add-Dialog von oben aufrufen
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildLoanDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }
}