import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../database/database_helper.dart';

class ExportService {
  static Future<void> exportTransactionsToCSV() async {
    final dbHelper = DatabaseHelper.instance;
    final transactions = await dbHelper.getTransactions();

    // CSV-Header und Daten zusammenstellen
    List<List<dynamic>> rows = [];
    rows.add(["Datum", "Kategorie", "Typ", "Betrag", "Beschreibung", "Konto-ID"]);

    for (var t in transactions) {
      rows.add([
        t.date.toIso8601String(),
        t.category,
        t.type,
        t.amount,
        t.description,
        t.accountId
      ]);
    }

    // In CSV-String umwandeln
    String csvData = const ListToCsvConverter(fieldDelimiter: ';').convert(rows);

    // Datei temporär speichern
    final directory = await getTemporaryDirectory();
    final path = "${directory.path}/mein_budget_export.csv";
    final file = File(path);
    await file.writeAsString(csvData);

    // Datei zum Teilen anbieten
    await Share.shareXFiles([XFile(path)], text: 'Mein Budget Export');
  }
}