# Notes App - Flutter Mobile

Application mobile de gestion de notes collaboratives avec support offline-first.

## 📋 Features

✅ **Authentification**
- Login / Register avec JWT
- Tokens sécurisés (Flutter Secure Storage)
- Auto-refresh des tokens expirés

✅ **Gestion des Notes**
- CRUD complet (Create, Read, Update, Delete)
- Support Markdown avec preview
- Tags pour organisation
- Visibilité (Private, Shared, Public)
- Recherche par titre et tags
- Filtres par visibilité

✅ **Partage**
- Partage avec utilisateurs (lecture seule)
- Génération de liens publics
- Vue "Shared with Me"

✅ **Offline-First**
- Cache local SQLite
- File d'opérations en attente
- Synchronisation automatique en arrière-plan
- Indicateurs de sync (pending notes)
- Strategy: Last-Write-Wins

✅ **UX**
- Pull-to-refresh
- Empty states
- Loading indicators
- Error handling
- Material Design 3

## 🏗️ Architecture

```
lib/
├── main.dart                    # Entry point
├── app.dart                     # App widget
├── data/
│   ├── models/                  # Data models
│   │   ├── note.dart
│   │   ├── user.dart
│   │   ├── share.dart
│   │   └── api_response.dart
│   └── services/                # Business logic
│       ├── api_service.dart     # HTTP client (Dio)
│       ├── auth_service.dart    # Authentication
│       ├── note_service.dart    # Notes CRUD + offline
│       ├── sync_service.dart    # Background sync
│       └── database_helper.dart # SQLite
├── exceptions/                  # Custom exceptions
├── routes/                      # GoRouter navigation
├── screens/                     # UI screens
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   └── notes/
│       ├── notes_list_screen.dart
│       ├── shared_notes_screen.dart
│       ├── note_detail_screen.dart
│       └── note_form_screen.dart
├── state/                       # State management
│   └── providers/               # Riverpod providers
│       ├── auth_provider.dart
│       └── notes_provider.dart
├── theme/                       # App theming
│   └── app_theme.dart
├── utils/                       # Utilities
│   ├── date_formatter.dart
│   └── validators.dart
└── widgets/                     # Reusable widgets
    └── note_card.dart
```

## 🚀 Installation & Setup

### Prérequis

- Flutter SDK 3.0+
- Dart 3.0+
- Android Studio / Xcode
- Backend Spring Boot en cours d'exécution

### Installation

1. **Cloner le repository**
```bash
cd mobile-app
```

2. **Installer les dépendances**
```bash
flutter pub get
```

3. **Configurer l'API URL**

Modifier `lib/data/services/api_service.dart`:
```dart
// Pour Android Emulator
static const String baseUrl = 'http://10.0.2.2:8080/api/v1';

// Pour iOS Simulator
static const String baseUrl = 'http://localhost:8080/api/v1';

// Pour appareil physique (remplacer par votre IP)
static const String baseUrl = 'http://192.168.1.X:8080/api/v1';
```

### Lancer l'application

#### Android Emulator
```bash
# Lancer l'émulateur
flutter emulators --launch <emulator_id>

# Ou depuis Android Studio: AVD Manager > Play

# Lancer l'app
flutter run
```

#### iOS Simulator (Mac uniquement)
```bash
# Ouvrir le simulateur
open -a Simulator

# Lancer l'app
flutter run
```

#### Appareil physique

**Android:**
```bash
# Activer le mode développeur sur le téléphone
# Activer le débogage USB
# Connecter via USB

flutter devices  # Vérifier la détection
flutter run
```

**iOS:**
```bash
# Connecter l'iPhone via USB
# Faire confiance à l'ordinateur

flutter devices
flutter run
```

## 📱 Build Production

### Android APK
```bash
flutter build apk --release

# APK généré dans: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (Google Play)
```bash
flutter build appbundle --release

# AAB généré dans: build/app/outputs/bundle/release/app-release.aab
```

### iOS (Mac uniquement)
```bash
flutter build ios --release

# Ouvrir dans Xcode pour signature et upload
open ios/Runner.xcworkspace
```

## 🧪 Tests

```bash
# Tests unitaires
flutter test

# Tests avec coverage
flutter test --coverage

# Analyser le code
flutter analyze
```

## 🔧 Configuration

### Variables d'environnement

Créer `lib/core/config/env.dart` (gitignored):
```dart
class Env {
  static const String apiBaseUrl = 'YOUR_API_URL';
  static const String appName = 'Notes App';
}
```

### Permissions

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

## 📊 Fonctionnement Offline-First

### Stratégie de synchronisation

1. **Création/Modification**
    - Sauvegarde immédiate en local (SQLite)
    - Tentative de sync avec le serveur
    - Si échec → ajout à la file d'attente
    - Marquage `isSynced: false`

2. **Sync automatique**
    - Au retour de connexion (Connectivity listener)
    - Toutes les 5 minutes (Timer périodique)
    - Pull-to-refresh manuel

3. **Conflits** (Last-Write-Wins)
    - Le serveur fait autorité
    - Les modifications locales écrasent en cas de conflit
    - Pas de merge complexe

### File d'opérations en attente

```sql
CREATE TABLE pending_operations (
  id INTEGER PRIMARY KEY,
  operation_type TEXT,  -- CREATE, UPDATE, DELETE
  note_id INTEGER,
  note_data TEXT,       -- JSON de la note
  created_at TEXT,
  retries INTEGER       -- Max 5 retries
)
```

## 🎨 Personnalisation du thème

Modifier `lib/theme/app_theme.dart`:
```dart
static const Color primaryColor = Color(0xFF6366F1); // Votre couleur
```

## 📦 Dépendances principales

```yaml
dependencies:
  flutter_riverpod: ^2.4.9      # State management
  go_router: ^12.1.3            # Routing
  dio: ^5.4.0                   # HTTP client
  sqflite: ^2.3.0               # SQLite
  flutter_secure_storage: ^9.0.0 # Secure storage
  connectivity_plus: ^5.0.2     # Network status
  flutter_markdown: ^0.6.18     # Markdown rendering
  jwt_decoder: ^2.0.1           # JWT parsing
```

## 🐛 Troubleshooting

### Problème: Cannot connect to backend

**Solution:**
- Android Emulator: Utiliser `10.0.2.2` au lieu de `localhost`
- iOS Simulator: Utiliser `localhost`
- Appareil physique: Utiliser l'IP de votre machine
- Vérifier que le backend est démarré sur le port 8080

### Problème: SQLite database locked

**Solution:**
```bash
flutter clean
flutter pub get
```

### Problème: JWT token expired

**Solution:**
- L'intercepteur Dio refresh automatiquement le token
- Si le refresh échoue, l'utilisateur est déconnecté
- Vérifier que `/auth/refresh` fonctionne

### Problème: Notes not syncing

**Solution:**
- Vérifier la connexion internet
- Consulter les logs: `flutter run -v`
- Forcer un sync manuel: Pull-to-refresh

## 🔐 Sécurité

- ✅ Tokens JWT stockés dans Flutter Secure Storage (encrypted)
- ✅ Refresh automatique des tokens expirés
- ✅ HTTPS recommandé en production
- ✅ Validation des inputs côté client
- ✅ Pas de données sensibles dans les logs

## 📝 Comptes de test

Créer via l'écran Register ou utiliser:
```
Email: demo@example.com
Password: password123
```

## 🚦 Roadmap

- [ ] Dark mode
- [ ] Export notes en PDF
- [ ] Notifications push
- [ ] Édition collaborative temps réel (WebSockets)
- [ ] Recherche full-text avec SQLite FTS
- [ ] Biometric authentication
- [ ] Multi-langue (i18n)

## 📄 License

MIT

## 👥 Support

Pour toute question, consulter la documentation du backend ou créer une issue.