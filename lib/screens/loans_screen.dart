import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../models/loan.dart';

class LoansScreen extends StatefulWidget {
  const LoansScreen({super.key});

  @override
  State<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends State<LoansScreen> {
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

  Future<void> _deleteLoan(String id) async {
    await _dbHelper.deleteLoan(id);
    _loadLoans();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'de_DE', symbol: '€');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kredite'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _loans.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.credit_card, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Keine Kredite vorhanden',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _loans.length,
                  itemBuilder: (context, index) {
                    final loan = _loans[index];
                    return _buildLoanCard(loan, currencyFormat);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddLoanDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildLoanCard(Loan loan, NumberFormat currencyFormat) {
    final now = DateTime.now();
    final remainingAmount = loan.getRemainingAmount(now);
    final paidAmount = loan.getPaidAmount(now);
    final progress = loan.totalAmount > 0 ? paidAmount / loan.totalAmount : 0.0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        leading: const CircleAvatar(
          child: Icon(Icons.credit_card),
        ),
        title: Text(
          loan.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Verbleibend: ${currencyFormat.format(remainingAmount)}',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Gesamtsumme:', currencyFormat.format(loan.totalAmount)),
                _buildInfoRow('Laufzeit:', '${loan.durationMonths} Monate'),
                _buildInfoRow('Monatliche Rate:', currencyFormat.format(loan.monthlyRate)),
                _buildInfoRow('Effektiver Zinsatz:', '${loan.interestRate.toStringAsFixed(2)} %'),
                _buildInfoRow(
                  'Startdatum:',
                  DateFormat('dd.MM.yyyy').format(loan.startDate),
                ),
                if (loan.description != null && loan.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Beschreibung:',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(loan.description!),
                ],
                const SizedBox(height: 16),
                const Text(
                  'Fortschritt:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                  minHeight: 10,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Gezahlt: ${currencyFormat.format(paidAmount)}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      '${(progress * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => _showDeleteConfirmation(loan.id),
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text(
                      'Löschen',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Löschen bestätigen'),
        content: const Text('Möchten Sie diesen Kredit wirklich löschen?'),
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
      await _deleteLoan(id);
    }
  }

  Future<void> _showAddLoanDialog() async {
    final nameController = TextEditingController();
    final totalAmountController = TextEditingController();
    final interestRateController = TextEditingController();
    final durationController = TextEditingController();
    final monthlyRateController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    // Capture the context before the async operation
    final scaffoldMessengerContext = context;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Neuer Kredit'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name des Kredits',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: totalAmountController,
                  decoration: const InputDecoration(
                    labelText: 'Gesamtsumme',
                    border: OutlineInputBorder(),
                    prefixText: '€ ',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: durationController,
                  decoration: const InputDecoration(
                    labelText: 'Laufzeit (Monate)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: monthlyRateController,
                  decoration: const InputDecoration(
                    labelText: 'Monatliche Rate',
                    border: OutlineInputBorder(),
                    prefixText: '€ ',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: interestRateController,
                  decoration: const InputDecoration(
                    labelText: 'Effektiver Zinsatz',
                    border: OutlineInputBorder(),
                    suffixText: '%',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Startdatum'),
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
                // Validierung
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bitte geben Sie einen Namen ein'),
                    ),
                  );
                  return;
                }

                final totalAmount = double.tryParse(
                  totalAmountController.text.replaceAll(',', '.'),
                );
                final interestRate = double.tryParse(
                  interestRateController.text.replaceAll(',', '.'),
                );
                final duration = int.tryParse(durationController.text);
                final monthlyRate = double.tryParse(
                  monthlyRateController.text.replaceAll(',', '.'),
                );

                if (totalAmount == null || totalAmount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bitte geben Sie eine gültige Gesamtsumme ein'),
                    ),
                  );
                  return;
                }

                if (interestRate == null || interestRate < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bitte geben Sie einen gültigen Zinsatz ein'),
                    ),
                  );
                  return;
                }

                if (duration == null || duration <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bitte geben Sie eine gültige Laufzeit ein'),
                    ),
                  );
                  return;
                }

                if (monthlyRate == null || monthlyRate <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bitte geben Sie eine gültige monatliche Rate ein'),
                    ),
                  );
                  return;
                }

                final loan = Loan(
                  id: const Uuid().v4(),
                  name: nameController.text.trim(),
                  totalAmount: totalAmount,
                  interestRate: interestRate,
                  durationMonths: duration,
                  monthlyRate: monthlyRate,
                  startDate: selectedDate,
                  description: descriptionController.text.trim(),
                );

                await _dbHelper.insertLoan(loan);
                Navigator.pop(dialogContext);
                _loadLoans();
                
                if (mounted) {
                  ScaffoldMessenger.of(scaffoldMessengerContext).showSnackBar(
                    const SnackBar(content: Text('Kredit hinzugefügt')),
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
