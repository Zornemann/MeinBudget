import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MeinBudgetApp());
}

class MeinBudgetApp extends StatelessWidget {
  const MeinBudgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MeinBudget',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // Helles Thema: Sauber und professionell
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B5E20), // Ein sattes "Geld-Grün"
          primary: const Color(0xFF1B5E20),
          surface: const Color(0xFFF8F9FA), // Ganz leichtes Grau/Weiß für den Hintergrund
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF8F9FA),
          foregroundColor: Color(0xFF1B5E20),
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        // Dunkles Thema: Modernes Anthrazit/Dunkelblau
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color(0xFF81C784),
          surface: const Color(0xFF121212), // Tiefes Schwarz/Grau
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          elevation: 0,
        ),
      ),
      themeMode: ThemeMode.system, 
      home: const HomeScreen(),
    );
  }
}