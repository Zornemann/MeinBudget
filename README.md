# MeinBudget

Behalte deine Finanzen im Griff – Einnahmen, Ausgaben & Kredite einfach managen. Offline, sicher & übersichtlich.

## Funktionen

- ✅ **Einnahmen verwalten** - Erfasse deine Einnahmen mit vordefinierten Kategorien (Gehalt, Kindergeld) oder eigenen Kategorien
- ✅ **Ausgaben verwalten** - Verwalte deine Ausgaben in verschiedenen Kategorien (Kredite, Einkauf, Tanken, Versicherung, Unterhaltung, Spareinlagen)
- ✅ **Kredite verwalten** - Vollständige Kreditübersicht mit:
  - Gesamtsumme
  - Laufzeit in Monaten
  - Monatliche Rate
  - Effektiver Zinsatz
  - Fortschrittsanzeige mit bezahltem und verbleibendem Betrag
- ✅ **Eigene Kategorien** - Erstelle eigene Kategorien für Einnahmen und Ausgaben
- ✅ **Offline-Funktionalität** - Alle Daten werden lokal gespeichert mit SQLite
- ✅ **Dashboard** - Übersichtliche Darstellung des aktuellen Monats mit Einnahmen, Ausgaben und Saldo
- ✅ **Multi-Plattform** - Läuft auf Android und als Web-App

## Technologie

Diese App wurde mit Flutter entwickelt und verwendet:

- **Flutter** - Cross-Platform UI Framework
- **SQLite** (sqflite) - Lokale Datenbank für Offline-Speicherung
- **Material Design 3** - Modernes UI-Design

## Installation und Ausführung

### Voraussetzungen

- Flutter SDK (Version 3.0.0 oder höher)
- Für Android: Android Studio mit Android SDK
- Für Web: Chrome Browser

### Abhängigkeiten installieren

```bash
flutter pub get
```

### App starten

**Als Web-App:**
```bash
flutter run -d chrome
```

**Auf Android:**
```bash
flutter run -d android
```

### Build erstellen

**Android APK:**
```bash
flutter build apk
```

**Web Build:**
```bash
flutter build web
```

Die Web-Build-Dateien befinden sich dann im Ordner `build/web/`.

## Nutzung

### Transaktionen verwalten

1. Tippe auf "Transaktionen" im Dashboard
2. Wähle zwischen "Einnahmen" und "Ausgaben" mit den Tabs
3. Tippe auf das ➕ Symbol, um eine neue Transaktion hinzuzufügen
4. Wähle eine Kategorie (oder erstelle eine neue)
5. Gib Betrag, Beschreibung und Datum ein
6. Speichern

### Kredite verwalten

1. Tippe auf "Kredite" im Dashboard
2. Tippe auf das ➕ Symbol, um einen neuen Kredit hinzuzufügen
3. Gib alle Details ein:
   - Name des Kredits
   - Gesamtsumme
   - Laufzeit in Monaten
   - Monatliche Rate
   - Effektiver Zinsatz
   - Startdatum
4. Speichern
5. Erweitere einen Kredit in der Liste, um alle Details und den Fortschritt zu sehen

## Struktur

```
lib/
├── database/
│   └── database_helper.dart    # SQLite Datenbank-Helper
├── models/
│   ├── transaction.dart        # Transaktionsmodell (Einnahmen/Ausgaben)
│   ├── loan.dart               # Kreditmodell
│   └── category.dart           # Kategoriemodell
├── screens/
│   ├── home_screen.dart        # Dashboard
│   ├── transactions_screen.dart # Transaktionsverwaltung
│   └── loans_screen.dart       # Kreditverwaltung
└── main.dart                   # App-Einstiegspunkt
```

## Lizenz

MIT License
