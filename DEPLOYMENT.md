# Deployment Guide for MeinBudget

## Android Deployment

### Debug APK (für Testing)
```bash
flutter build apk --debug
```

### Release APK
```bash
flutter build apk --release
```

Die APK befindet sich dann in: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (für Play Store)
```bash
flutter build appbundle --release
```

## Web Deployment

### Build für Web
```bash
flutter build web --release
```

Die Build-Dateien befinden sich dann in: `build/web/`

### Web Hosting

Die Dateien aus `build/web/` können auf jedem Webserver gehostet werden:

1. **GitHub Pages**: Kopiere die Dateien nach `docs/` und aktiviere GitHub Pages
2. **Firebase Hosting**: 
   ```bash
   firebase init hosting
   firebase deploy
   ```
3. **Netlify**: Drag & Drop der `build/web/` Ordner auf netlify.com
4. **Vercel**: Deploy via Vercel CLI oder GitHub Integration

### Offline-Funktionalität

Die App funktioniert offline durch:
- SQLite lokale Datenbank (auf Android)
- IndexedDB über sqflite_common_ffi_web (im Browser)
- Service Worker für Web-App (automatisch generiert)

## Plattformspezifische Hinweise

### Android
- Minimum SDK: 21 (Android 5.0 Lollipop)
- Target SDK: Latest (siehe pubspec.yaml)
- Benötigte Berechtigungen: Internet (für initiale Installation)

### Web
- Unterstützte Browser: Chrome, Firefox, Safari, Edge (moderne Versionen)
- Progressive Web App (PWA) fähig
- Offline-Speicher via IndexedDB
- Kann als App auf dem Homescreen installiert werden

## Testing

### Android Emulator
```bash
flutter emulators --launch <emulator_id>
flutter run
```

### Chrome Web
```bash
flutter run -d chrome
```

### Alle verbundenen Geräte
```bash
flutter devices
flutter run -d <device_id>
```
