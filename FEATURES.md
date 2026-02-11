# MeinBudget - Features & Technical Details

## 🎯 Hauptfunktionen

### 1. Dashboard (Startseite)
- **Monatsübersicht**: Zeigt Einnahmen, Ausgaben und Saldo des aktuellen Monats
- **Letzte Transaktionen**: Die 5 neuesten Transaktionen werden angezeigt
- **Aktive Kredite**: Übersicht aller laufenden Kredite
- **Pull-to-Refresh**: Daten aktualisieren durch Herunterziehen

### 2. Transaktionsverwaltung

#### Einnahmen
**Vordefinierte Kategorien:**
- Gehalt
- Kindergeld

**Funktionen:**
- Betrag eingeben (€)
- Beschreibung hinzufügen
- Datum wählen
- Eigene Kategorien erstellen
- Transaktionen löschen

#### Ausgaben
**Vordefinierte Kategorien:**
- Kredite
- Einkauf
- Tanken
- Versicherung
- Unterhaltung
- Spareinlagen

**Funktionen:**
- Betrag eingeben (€)
- Beschreibung hinzufügen
- Datum wählen
- Eigene Kategorien erstellen
- Transaktionen löschen

### 3. Kreditverwaltung

**Kreditinformationen:**
- Name des Kredits
- Gesamtsumme (€)
- Laufzeit (Monate)
- Monatliche Rate (€)
- Effektiver Zinsatz (%)
- Startdatum
- Optionale Beschreibung

**Berechnungen:**
- Automatische Berechnung der verbleibenden Summe
- Automatische Berechnung der bereits gezahlten Summe
- Fortschrittsbalken (visuell)
- Prozentuale Anzeige des Fortschritts

**Anzeige:**
- Übersichtskarte mit allen Details
- Expandierbare Listenansicht
- Farbcodierte Fortschrittsanzeige

### 4. Kategorieverwaltung

**Vordefinierte Kategorien:**
- Automatisch bei erster Nutzung eingefügt
- Können nicht gelöscht werden (nur benutzerdefinierte)

**Benutzerdefinierte Kategorien:**
- Während der Transaktionseingabe erstellbar
- Für Einnahmen und Ausgaben getrennt
- Werden in der Datenbank gespeichert
- Für zukünftige Transaktionen verfügbar

## 🔧 Technische Details

### Architektur

```
MeinBudget App
├── Presentation Layer (UI)
│   ├── Screens (Hauptseiten)
│   │   ├── HomeScreen (Dashboard)
│   │   ├── TransactionsScreen (Einnahmen/Ausgaben)
│   │   └── LoansScreen (Kredite)
│   └── Widgets (Wiederverwendbare Komponenten)
│
├── Domain Layer (Geschäftslogik)
│   └── Models
│       ├── Transaction (Einnahmen/Ausgaben)
│       ├── Loan (Kredite)
│       └── Category (Kategorien)
│
└── Data Layer (Datenpersistenz)
    └── DatabaseHelper (SQLite)
```

### Datenmodelle

#### Transaction Model
```dart
- id: String (UUID)
- type: String ('income' | 'expense')
- category: String
- amount: double
- description: String
- date: DateTime
```

#### Loan Model
```dart
- id: String (UUID)
- name: String
- totalAmount: double
- interestRate: double
- durationMonths: int
- monthlyRate: double
- startDate: DateTime
- description: String (optional)

Methods:
- getRemainingAmount(DateTime): double
- getPaidAmount(DateTime): double
```

#### Category Model
```dart
- id: String (UUID)
- name: String
- type: String ('income' | 'expense')
- isCustom: bool
```

### Datenbank Schema

#### Tabelle: transactions
```sql
CREATE TABLE transactions (
  id TEXT PRIMARY KEY,
  type TEXT NOT NULL,
  category TEXT NOT NULL,
  amount REAL NOT NULL,
  description TEXT NOT NULL,
  date TEXT
)
```

#### Tabelle: loans
```sql
CREATE TABLE loans (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  totalAmount REAL NOT NULL,
  interestRate REAL NOT NULL,
  durationMonths INTEGER NOT NULL,
  monthlyRate REAL NOT NULL,
  startDate TEXT,
  description TEXT
)
```

#### Tabelle: categories
```sql
CREATE TABLE categories (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  type TEXT NOT NULL,
  isCustom INTEGER NOT NULL
)
```

### Offline-Speicherung

**Android:**
- SQLite Datenbank via `sqflite` Package
- Speicherort: App-spezifischer Datenordner
- Persistenz: Daten bleiben nach App-Neustart erhalten

**Web:**
- IndexedDB via `sqflite_common_ffi_web` Package
- Browser-lokaler Speicher
- Persistenz: Daten bleiben im Browser erhalten
- Funktioniert auch offline (Progressive Web App)

### UI/UX Design

**Material Design 3:**
- Moderne, klare Benutzeroberfläche
- Konsistente Farbpalette (Grün als Hauptfarbe)
- Dark Mode Support
- Responsive Layout

**Interaktionen:**
- Pull-to-Refresh auf dem Dashboard
- Swipe/Tap Interaktionen
- Bestätigungsdialoge für Löschvorgänge
- Expandierbare Listen für Kreditdetails

**Icons & Visualisierung:**
- Material Icons für alle Aktionen
- Farbcodierung (Grün = Einnahmen, Rot = Ausgaben)
- Fortschrittsbalken für Kredite
- Runde Avatare für Kategorien

### Performance

**Optimierungen:**
- Lazy Loading von Listen
- Effiziente Datenbankabfragen
- Minimale Dependencies
- Schnelle Startzeit

**Skalierbarkeit:**
- Paginierung für große Datenmengen vorbereitet
- Effiziente Indexierung in der Datenbank
- Asynchrone Datenbankoperationen

## 🌐 Plattform-Kompatibilität

### Android
- **Minimum SDK**: 21 (Android 5.0 Lollipop)
- **Target SDK**: Latest
- **APK Größe**: ~20-30 MB (komprimiert)
- **Berechtigungen**: Internet (nur für Installation)

### Web
- **Browser**: Chrome, Firefox, Safari, Edge
- **PWA**: Progressive Web App fähig
- **Offline**: Funktioniert vollständig offline
- **Installation**: Als App auf Homescreen installierbar

## 🔒 Sicherheit & Datenschutz

**Datenschutz:**
- ✅ Keine Cloud-Speicherung
- ✅ Keine Datenübertragung an Server
- ✅ Keine Analytics oder Tracking
- ✅ Keine Werbung
- ✅ Vollständig Open Source

**Sicherheit:**
- Lokale Datenspeicherung
- Betriebssystem-Level Verschlüsselung (Android)
- Keine sensiblen Daten im Klartext
- Keine externen Abhängigkeiten für Kern-Funktionalität

## 🎨 UI Screens

### 1. Dashboard
- Header: "MeinBudget"
- Karte: Monatsübersicht (Einnahmen, Ausgaben, Saldo)
- Buttons: Transaktionen, Kredite
- Liste: Letzte Transaktionen
- Liste: Aktive Kredite

### 2. Transaktionen Screen
- Tabs: Einnahmen / Ausgaben
- Listen: Alle Transaktionen sortiert nach Datum
- FAB: Neue Transaktion hinzufügen
- Actions: Löschen

### 3. Kredite Screen
- Liste: Alle Kredite
- Expandierbare Karten mit Details
- Fortschrittsbalken
- FAB: Neuen Kredit hinzufügen
- Actions: Löschen

### 4. Dialoge
- Neue Transaktion Dialog
- Neuer Kredit Dialog
- Neue Kategorie Input
- Lösch-Bestätigung
- Datumswähler

## 📊 Zukünftige Erweiterungen (Optional)

Mögliche Features für zukünftige Versionen:
- 📈 Diagramme und Statistiken
- 📅 Monatliche/Jährliche Übersichten
- 💾 Backup & Export (CSV, PDF)
- 🔔 Erinnerungen für Zahlungen
- 🎯 Budget-Planung
- 📱 iOS Support
- 🌍 Mehrsprachigkeit
- 💱 Mehrere Währungen
- 🔄 Wiederkehrende Transaktionen
- 🏷️ Tags für Transaktionen

## 📝 Entwicklung

**Code-Qualität:**
- Dart Linting aktiviert
- Type-safe Code
- Null-safety
- Clean Architecture Pattern
- Dokumentierte Funktionen

**Testing:**
- Unit Tests für Models
- Widget Tests für UI
- Integration Tests für Flows
- GitHub Actions CI/CD

**Maintenance:**
- Regelmäßige Updates
- Bug Fixes
- Community-Feedback
- Open Source Contributions
