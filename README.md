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