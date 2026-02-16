import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';

class AccountManagementScreen extends StatefulWidget {
  const AccountManagementScreen({super.key});

  @override
  State<AccountManagementScreen> createState() => _AccountManagementScreenState();
}

class _AccountManagementScreenState extends State<AccountManagementScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> _accounts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    setState(() => _isLoading = true);
    final accounts = await _dbHelper.getAccounts();
    setState(() {
      _accounts = accounts;
      _isLoading = false;
    });
  }

  void _showAccountDialog({Map<String, dynamic>? existingAccount}) {
    final nameController = TextEditingController(text: existingAccount?['name'] ?? '');
    final balanceController = TextEditingController(
      text: existingAccount?['initialBalance']?.toString().replaceAll('.', ',') ?? '0,00'
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existingAccount == null ? 'Neues Konto' : 'Konto bearbeiten'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Kontoname (z.B. Sparkasse)'),
            ),
            TextField(
              controller: balanceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Startguthaben (€)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Abbrechen')),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text;
              final balance = double.tryParse(balanceController.text.replaceAll(',', '.')) ?? 0.0;

              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name fehlt!')));
                return;
              }

              final account = {
                'id': existingAccount?['id'] ?? const Uuid().v4(),
                'name': name,
                'icon': 'account_balance',
                'initialBalance': balance,
              };

              await _dbHelper.insertAccount(account);
              Navigator.pop(ctx);
              _loadAccounts();
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Konten verwalten')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _accounts.length,
              itemBuilder: (context, index) {
                final acc = _accounts[index];
                return ListTile(
                  leading: const Icon(Icons.account_balance, color: Colors.blue),
                  title: Text(acc['name']),
                  subtitle: Text('Startguthaben: ${acc['initialBalance']} €'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit), onPressed: () => _showAccountDialog(existingAccount: acc)),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          // Hinweis: Du müsstest im DatabaseHelper noch deleteAccount implementieren!
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Löschen-Funktion folgt')));
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAccountDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}