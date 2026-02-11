# MeinBudget

Behalte deine Finanzen im Griff – Einnahmen, Ausgaben & Kredite einfach managen. Offline, sicher & übersichtlich.

## 🎯 Features

### Kernfunktionen
- ✅ **Transaktionsverwaltung**: Einnahmen und Ausgaben erfassen und verfolgen
- ✅ **Kreditverwaltung**: Kredite mit Kreditgeber, Kreditnehmer, Laufzeit, Rate und Zinssatz verwalten
- ✅ **Kategorien**: Vordefinierte Kategorien (Gehalt, Kindergeld, Kredit, Versicherung, Tanken, Einkauf, Unterhaltung) und benutzerdefinierte Kategorien
- ✅ **Offline-Funktionalität**: Vollständige Offline-Unterstützung durch IndexedDB (Web) und SQLite (Flutter)
- ✅ **Dark Mode**: Dunkles Design für bessere Nutzererfahrung
- ✅ **Statistiken & Grafiken**: Visualisierung der Finanzdaten mit Charts und Grafiken
- 🚧 **Zinssatz-APIs**: Integration für Zinsvergleiche (in Entwicklung)
- 🚧 **MongoDB Synchronisierung**: Cloud-Sync über MongoDB (in Entwicklung)
- 🚧 **PIN/Fingerprint-Sperre**: Sicherheit durch biometrische Authentifizierung (in Entwicklung)

### Technische Features
- Multi-Plattform: Web-App (Next.js) und Mobile App (Flutter)
- Progressive Web App (PWA) für Offline-Nutzung
- Responsive Design für alle Bildschirmgrößen
- TypeScript für Typ-Sicherheit
- Moderne UI mit Tailwind CSS und Material Design 3

## 📱 Plattformen

### Web-App (Next.js)
Die Web-Anwendung ist eine moderne Progressive Web App (PWA) basierend auf Next.js.

**Technologie-Stack:**
- Next.js 16 mit App Router
- TypeScript
- Tailwind CSS
- Zustand (State Management)
- IndexedDB (Offline-Speicherung)
- Recharts (Diagramme)

**Installation & Start:**
```bash
cd webapp
npm install
npm run dev    # Entwicklungsserver
npm run build  # Produktions-Build
npm run start  # Produktionsserver
```

Die App läuft dann unter `http://localhost:3000`

### Flutter App (Android & Web)
Cross-Platform App mit Flutter für Android und Web.

**Technologie-Stack:**
- Flutter SDK
- SQLite (sqflite) für mobile, IndexedDB für Web
- Material Design 3
- Dart

**Voraussetzungen:**
- Flutter SDK (Version 3.0.0 oder höher)
- Für Android: Android Studio mit Android SDK
- Für Web: Chrome Browser

**Installation & Start:**
```bash
# Abhängigkeiten installieren
flutter pub get

# Als Web-App starten
flutter run -d chrome

# Auf Android starten
flutter run -d android
```

**Build erstellen:**
```bash
# Android APK
flutter build apk

# Web Build
flutter build web
```

## 🚀 Schnellstart

### Voraussetzungen
- Node.js 18+ (für Web-App)
- Flutter SDK 3.0.0+ (für Flutter App)
- npm oder yarn
- Für Android: Android Studio und Android SDK

### Web-App starten (Next.js)
```bash
# Repository klonen
git clone https://github.com/Zornemann/MeinBudget.git
cd MeinBudget/webapp

# Dependencies installieren
npm install

# Entwicklungsserver starten
npm run dev
```

### Flutter App starten
```bash
cd MeinBudget
flutter pub get
flutter run -d chrome  # oder -d android
```

## 📊 Datenstruktur

### Transaktionen
- Betrag
- Typ (Einnahme/Ausgabe)
- Kategorie
- Beschreibung
- Datum

### Kredite
- Kreditgeber/Kreditnehmer (Web) oder Name (Flutter)
- Gesamtsumme
- Laufzeit (Monate)
- Monatliche Rate
- Effektiver Jahreszins
- Startdatum
- Fortschrittsanzeige

### Kategorien
- Vordefinierte Kategorien mit Icons und Farben
- Benutzerdefinierte Kategorien erstellen
- Zuordnung zu Einnahmen oder Ausgaben

## 🔒 Sicherheit

- Lokale Datenspeicherung (keine Daten verlassen das Gerät ohne Sync)
- Optional: PIN-Schutz
- Optional: Biometrische Authentifizierung
- Optional: Verschlüsselte Cloud-Synchronisierung

## 🎨 Screenshots

### Dashboard
Übersicht über Einnahmen, Ausgaben und aktuelle Bilanz

### Transaktionen
Einfaches Hinzufügen und Verwalten von Transaktionen

### Kredite
Detaillierte Kreditverwaltung mit Zinsberechnung

### Statistiken
Visualisierung der Finanzdaten mit Charts

### Einstellungen
Anpassung von Design, Kategorien und Sicherheitseinstellungen

## 🛠️ Entwicklung

### Projektstruktur
```
MeinBudget/
├── webapp/                    # Next.js Web-Anwendung
│   ├── app/                   # Next.js App Router
│   │   ├── page.tsx          # Dashboard
│   │   ├── transactions/     # Transaktionsverwaltung
│   │   ├── credits/          # Kreditverwaltung
│   │   ├── statistics/       # Statistiken
│   │   └── settings/         # Einstellungen
│   ├── components/           # React-Komponenten
│   │   ├── ui/              # UI-Basiskomponenten
│   │   └── features/        # Feature-spezifische Komponenten
│   ├── lib/                 # Utilities und Logik
│   │   ├── db/             # IndexedDB-Layer
│   │   ├── stores/         # Zustand-Stores
│   │   └── utils.ts        # Hilfsfunktionen
│   └── types/              # TypeScript-Typen
├── lib/                      # Flutter App
│   ├── database/
│   │   └── database_helper.dart    # SQLite Datenbank-Helper
│   ├── models/
│   │   ├── transaction.dart        # Transaktionsmodell
│   │   ├── loan.dart               # Kreditmodell
│   │   └── category.dart           # Kategoriemodell
│   ├── screens/
│   │   ├── home_screen.dart        # Dashboard
│   │   ├── transactions_screen.dart # Transaktionsverwaltung
│   │   └── loans_screen.dart       # Kreditverwaltung
│   └── main.dart                   # App-Einstiegspunkt
└── .github/
    └── workflows/            # CI/CD Workflows
```

### Neue Features hinzufügen

**Für Web-App (Next.js):**
1. **Neue Kategorie**: In den Einstellungen eine benutzerdefinierte Kategorie erstellen
2. **Datenmodell erweitern**: `webapp/types/index.ts` anpassen
3. **UI-Komponenten**: `webapp/components/` verwenden oder neue erstellen
4. **Neue Seite**: Im `webapp/app/` Verzeichnis eine neue Route hinzufügen

**Für Flutter App:**
1. **Neue Screen**: In `lib/screens/` neue Dart-Datei erstellen
2. **Datenmodell**: In `lib/models/` neues Modell definieren
3. **Datenbank**: `database_helper.dart` um neue Tabellen erweitern

## 📝 Lizenz

Dieses Projekt ist für persönliche und kommerzielle Nutzung frei verfügbar. (MIT License)

## 🤝 Beitragen

Beiträge sind willkommen! Bitte erstellen Sie ein Issue oder Pull Request.

## 📞 Support

Bei Fragen oder Problemen erstellen Sie bitte ein Issue im GitHub-Repository.

---

Entwickelt mit ❤️ für bessere Finanzverwaltung
