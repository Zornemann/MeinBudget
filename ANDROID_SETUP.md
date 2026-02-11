# Android App Setup Guide

## Einleitung
Diese Anleitung beschreibt, wie die Android-Version von MeinBudget mit React Native erstellt werden kann.

## Voraussetzungen
- Node.js 18+
- Android Studio
- Android SDK
- Java Development Kit (JDK) 17+

## Android App mit React Native erstellen

### 1. React Native Projekt initialisieren
```bash
# Im MeinBudget-Hauptverzeichnis
npx @react-native-community/cli@latest init MeinBudgetAndroid --skip-install
cd MeinBudgetAndroid
npm install
```

### 2. Benötigte Dependencies installieren
```bash
# Navigation
npm install @react-navigation/native @react-navigation/bottom-tabs @react-navigation/stack
npm install react-native-screens react-native-safe-area-context

# State Management
npm install zustand

# Storage
npm install @react-native-async-storage/async-storage

# Charts
npm install react-native-chart-kit react-native-svg

# Biometric Authentication
npm install react-native-biometrics

# Secure Storage
npm install react-native-keychain
```

### 3. Projektstruktur
```
MeinBudgetAndroid/
├── android/               # Native Android-Code
├── ios/                   # Native iOS-Code (optional)
├── src/
│   ├── components/       # React-Komponenten
│   ├── screens/          # App-Bildschirme
│   ├── navigation/       # Navigation-Setup
│   ├── store/           # Zustand State Management
│   ├── services/        # API und Storage Services
│   ├── types/           # TypeScript-Typen
│   └── utils/           # Hilfsfunktionen
├── App.tsx              # Hauptkomponente
└── package.json
```

### 4. Wichtige Features implementieren

#### Storage Layer (AsyncStorage)
```typescript
// src/services/storage.ts
import AsyncStorage from '@react-native-async-storage/async-storage';

export const StorageService = {
  async saveTransactions(transactions: Transaction[]) {
    await AsyncStorage.setItem('transactions', JSON.stringify(transactions));
  },
  
  async getTransactions(): Promise<Transaction[]> {
    const data = await AsyncStorage.getItem('transactions');
    return data ? JSON.parse(data) : [];
  },
  
  // Weitere Methoden...
};
```

#### Biometric Authentication
```typescript
// src/services/biometric.ts
import ReactNativeBiometrics from 'react-native-biometrics';

export const BiometricService = {
  async checkAvailability() {
    const rnBiometrics = new ReactNativeBiometrics();
    const { available, biometryType } = await rnBiometrics.isSensorAvailable();
    return { available, biometryType };
  },
  
  async authenticate() {
    const rnBiometrics = new ReactNativeBiometrics();
    const { success } = await rnBiometrics.simplePrompt({
      promptMessage: 'Authentifizierung erforderlich'
    });
    return success;
  }
};
```

### 5. App starten
```bash
# Android
npx react-native run-android

# iOS (optional)
npx react-native run-ios
```

## Deployment

### Android APK erstellen
```bash
cd android
./gradlew assembleRelease
# APK befindet sich in: android/app/build/outputs/apk/release/
```

### Android App Bundle für Google Play
```bash
cd android
./gradlew bundleRelease
# AAB befindet sich in: android/app/build/outputs/bundle/release/
```

## Wichtige Anmerkungen

### Permissions (android/app/src/main/AndroidManifest.xml)
```xml
<manifest>
  <!-- Internet für Sync -->
  <uses-permission android:name="android.permission.INTERNET" />
  
  <!-- Biometric -->
  <uses-permission android:name="android.permission.USE_BIOMETRIC" />
  <uses-permission android:name="android.permission.USE_FINGERPRINT" />
</manifest>
```

### Offline First Strategie
Die App sollte primär offline funktionieren:
1. Alle Daten lokal in AsyncStorage speichern
2. Bei Internetverbindung: Sync mit Backend (MongoDB)
3. Konflikterkennung und -lösung implementieren

### Code Sharing mit Web-App
Um Code zwischen Web und Android zu teilen:
1. Gemeinsame TypeScript-Typen verwenden (aus webapp/types/)
2. Business-Logik in separate Module auslagern
3. Plattformspezifische Implementierungen für Storage/UI

## Testing

### Unit Tests
```bash
npm test
```

### E2E Tests mit Detox
```bash
npm install -D detox
npx detox test
```

## Weitere Ressourcen
- [React Native Dokumentation](https://reactnative.dev/)
- [React Navigation](https://reactnavigation.org/)
- [Zustand Docs](https://docs.pmnd.rs/zustand/)
- [AsyncStorage](https://react-native-async-storage.github.io/async-storage/)

---

Für Fragen zur Android-Implementierung öffnen Sie bitte ein Issue im Repository.
