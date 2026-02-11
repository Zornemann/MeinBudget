# MeinBudget

Behalte deine Finanzen im Griff – Einnahmen, Ausgaben &amp; Kredite einfach managen. Offline, sicher &amp; übersichtlich.

## 🎯 Features

### Kernfunktionen
- ✅ **Transaktionsverwaltung**: Einnahmen und Ausgaben erfassen und verfolgen
- ✅ **Kreditverwaltung**: Kredite mit Kreditgeber, Kreditnehmer, Laufzeit, Rate und Zinssatz verwalten
- ✅ **Kategorien**: Vordefinierte Kategorien (Gehalt, Kindergeld, Kredit, Versicherung, Tanken, Einkauf, Unterhaltung) und benutzerdefinierte Kategorien
- ✅ **Offline-Funktionalität**: Vollständige Offline-Unterstützung durch IndexedDB
- ✅ **Dark Mode**: Dunkles Design für bessere Nutzererfahrung
- ✅ **Statistiken & Grafiken**: Visualisierung der Finanzdaten mit Charts und Grafiken
- 🚧 **Zinssatz-APIs**: Integration für Zinsvergleiche (in Entwicklung)
- 🚧 **MongoDB Synchronisierung**: Cloud-Sync über MongoDB (in Entwicklung)
- 🚧 **PIN/Fingerprint-Sperre**: Sicherheit durch biometrische Authentifizierung (in Entwicklung)

### Technische Features
- Progressive Web App (PWA) für Offline-Nutzung
- Responsive Design für alle Bildschirmgrößen
- TypeScript für Typ-Sicherheit
- Moderne UI mit Tailwind CSS
- IndexedDB für lokale Datenspeicherung

## 📱 Plattformen

### Web-App
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

### Android-App
React Native basierte Android-Anwendung mit nativen Features.

**Technologie-Stack:**
- React Native
- TypeScript
- Native Android SDK

**Installation & Start:**
```bash
cd MeinBudgetAndroid
npm install
npx react-native run-android
```

## 🚀 Schnellstart

### Voraussetzungen
- Node.js 18+
- npm oder yarn
- Für Android: Android Studio und Android SDK

### Web-App starten
```bash
# Repository klonen
git clone https://github.com/Zornemann/MeinBudget.git
cd MeinBudget/webapp

# Dependencies installieren
npm install

# Entwicklungsserver starten
npm run dev
```

### Android-App starten
```bash
cd MeinBudget/MeinBudgetAndroid
npm install
npx react-native run-android
```

## 📊 Datenstruktur

### Transaktionen
- Betrag
- Typ (Einnahme/Ausgabe)
- Kategorie
- Beschreibung
- Datum

### Kredite
- Kreditgeber
- Kreditnehmer
- Gesamtsumme
- Laufzeit (Monate)
- Monatliche Rate
- Effektiver Jahreszins
- Startdatum

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
├── webapp/                    # Web-Anwendung
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
└── MeinBudgetAndroid/       # Android-Anwendung
    └── (React Native Projekt)
```

### Neue Features hinzufügen

1. **Neue Kategorie**: In den Einstellungen eine benutzerdefinierte Kategorie erstellen
2. **Datenmodell erweitern**: `webapp/types/index.ts` anpassen
3. **UI-Komponenten**: `webapp/components/` verwenden oder neue erstellen
4. **Neue Seite**: Im `webapp/app/` Verzeichnis eine neue Route hinzufügen

## 📝 Lizenz

Dieses Projekt ist für persönliche und kommerzielle Nutzung frei verfügbar.

## 🤝 Beitragen

Beiträge sind willkommen! Bitte erstellen Sie ein Issue oder Pull Request.

## 📞 Support

Bei Fragen oder Problemen erstellen Sie bitte ein Issue im GitHub-Repository.

---

Entwickelt mit ❤️ für bessere Finanzverwaltung
