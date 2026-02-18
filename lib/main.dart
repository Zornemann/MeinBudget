import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'screens/home_screen.dart';

void main() async {
  // Wichtig: Initialisierung der Flutter-Bindings
  WidgetsFlutterBinding.ensureInitialized();

  // Biometrische Abfrage beim Start
  final bool authenticated = await _authenticateAtStart();

  if (authenticated) {
    runApp(const MeinBudgetApp());
  } else {
    // Falls die Authentifizierung abgebrochen wurde, wird die App nicht gestartet
    // oder zeigt einen Error-Screen.
    runApp(const MaterialApp(
      home: Scaffold(
        body: Center(child: Text('Zugriff verweigert. Bitte starte die App neu.')),
      ),
    ));
  }
}

Future<bool> _authenticateAtStart() async {
  final LocalAuthentication auth = LocalAuthentication();
  
  // Prüfen, ob das Gerät Biometrie unterstützt
  final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
  final bool canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();

  if (!canAuthenticate) return true; // Falls das Gerät kein FaceID/Fingerabdruck hat

  try {
    return await auth.authenticate(
      localizedReason: 'Bitte authentifiziere dich, um deine Finanzen zu sehen',
      options: const AuthenticationOptions(
        stickyAuth: true, // Verhindert Umgehen durch Task-Wechsel
        biometricOnly: false, // Erlaubt PIN/Muster als Fallback
      ),
    );
  } catch (e) {
    return false;
  }
}

class MeinBudgetApp extends StatelessWidget {
  const MeinBudgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MeinBudget',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}