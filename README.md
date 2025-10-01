# Notes Suite - Application de Gestion de Notes Collaboratives

Application multi-plateforme complète pour la gestion de notes avec authentification JWT, partage collaboratif et synchronisation offline.

## 🏗️ Architecture

```
notes-suite/
├── notes-suite-module/      # API REST Spring Boot
├── notes-suite-ui/        # Frontend Angular
├── notes-suitemobile/          # Application mobile Flutter
├── docker/              # Configuration Docker
├── docker-compose.yml   # Orchestration des services
└── README.md
```

## 🚀 Démarrage Rapide

### Prérequis

- Docker & Docker Compose
- Java 17+ (pour le développement backend)
- Node.js 18+ (pour le développement frontend)
- Flutter SDK 3.0+ (pour le développement mobile)

### Commande unique pour tout démarrer

```bash
# Rendre le script exécutable
chmod +x start.sh

# Démarrer tous les services
./start.sh
```

**OU manuellement :**

```bash
docker-compose up --build -d
```

### Accès aux services

Une fois démarré, les services sont disponibles aux URLs suivantes :

- **API Backend** : http://localhost:8080
- **Documentation Swagger** : http://localhost:8080/swagger-ui.html
- **Frontend Web** : http://localhost:8081
- **Base de données PostgreSQL** : localhost:5432

### Arrêter l'application

```bash
./stop.sh
# OU
docker-compose down
```

## 📦 Composants

### Backend (Spring Boot 3)

**Technologies :**
- Spring Boot 3.5.6
- Spring Security + JWT
- Spring Data JPA
- PostgreSQL
- MapStruct
- OpenAPI/Swagger
- Testcontainers

**Fonctionnalités :**
- ✅ Authentification JWT (register, login, refresh)
- ✅ CRUD complet sur les notes
- ✅ Recherche et filtrage avancés avec pagination
- ✅ Système de tags
- ✅ Partage de notes avec d'autres utilisateurs (READ only)
- ✅ Génération de liens publics
- ✅ Gestion des visibilités (PRIVATE, SHARED, PUBLIC)
- ✅ Validation des entrées
- ✅ Gestion d'erreurs centralisée
- ✅ Logs structurés

**API Endpoints :**

**Authentification** (`/api/v1/auth`)
```
POST /register        - Inscription
POST /login          - Connexion
POST /refresh        - Rafraîchir le token
```

**Notes** (`/api/v1/notes`)
```
GET    /                     - Liste avec recherche/filtres/pagination
POST   /                     - Créer une note
GET    /{id}                 - Récupérer une note
PUT    /{id}                 - Modifier une note
DELETE /{id}                 - Supprimer une note
POST   /{id}/share/user      - Partager avec un utilisateur
POST   /{id}/share/public    - Créer un lien public
GET    /{id}/shares          - Liste des partages
```

**Partage**
```
DELETE /api/v1/shares/{id}       - Supprimer un partage
DELETE /api/v1/public-links/{id} - Supprimer un lien public
GET    /api/v1/p/{token}         - Accès public à une note
```

**Développement backend :**

```bash
cd backend-spring

# Compilation
mvn clean install

# Lancer en local (nécessite PostgreSQL)
mvn spring-boot:run

# Tests
mvn test

# Générer le JAR
mvn package
```

### Frontend (Angular)

**Technologies :**
- Angular 17+
- RxJS
- Angular Router
- HttpClient avec intercepteurs
- TailwindCSS

**Fonctionnalités :**
- ✅ Authentification (Login/Register)
- ✅ Liste des notes avec recherche et filtres
- ✅ Éditeur Markdown avec prévisualisation
- ✅ Partage de notes (utilisateur + lien public)
- ✅ Gestion de l'état global
- ✅ Notifications toast
- ✅ Skeleton loaders
- ✅ Responsive design

**Développement frontend :**

```bash
cd web-frontend

# Installation
npm install

# Serveur de développement
npm start
# ou
ng serve

# Build de production
npm run build
# ou
ng build --configuration production

# Tests
npm test
```

### Mobile (Flutter)

**Technologies :**
- Flutter 3.0+
- Dart
- SQLite (cache local)
- Dio (HTTP)

**Fonctionnalités :**
- ✅ Authentification
- ✅ Liste et détail des notes
- ✅ Création/Édition de notes
- ✅ Éditeur Markdown simple
- ✅ **Offline-first** avec cache local
- ✅ Synchronisation automatique
- ✅ Gestion des conflits (Last-Write-Wins)
- ✅ Pull-to-refresh
- ✅ Indicateurs hors-ligne

**Développement mobile :**

```bash
cd mobile-app

# Installation des dépendances
flutter pub get

# Lancer sur émulateur/device
flutter run

# Build APK (Android)
flutter build apk

# Build iOS
flutter build ios
```

## 🗄️ Modèle de Données

```sql
User (id, email, password_hash, created_at)
Note (id, owner_id, title, content_md, visibility, created_at, updated_at)
Tag (id, label)
NoteTag (id, note_id, tag_id)
Share (id, note_id, shared_with_user_id, permission)
PublicLink (id, note_id, url_token, expires_at)
```

## 🔒 Sécurité

- Authentification JWT avec access token et refresh token
- Tokens stockés de manière sécurisée
- Validation des entrées côté backend
- CORS configuré
- Ownership vérifié sur toutes les opérations sensibles
- Messages d'erreurs normalisés
- Headers de sécurité (X-Frame-Options, X-Content-Type-Options, etc.)

## 🧪 Tests

**Backend :**
```bash
cd backend-spring
mvn test
```

**Frontend :**
```bash
cd web-frontend
npm test           # Tests unitaires
npm run e2e        # Tests e2e
```

**Mobile :**
```bash
cd mobile-app
flutter test
```

## 📊 Logs

Voir les logs des services :

```bash
# Tous les services
docker-compose logs -f

# Service spécifique
docker-compose logs -f api
docker-compose logs -f db
```

## 🐛 Debugging

### Backend ne démarre pas
```bash
# Vérifier les logs
docker-compose logs api

# Vérifier la connexion DB
docker-compose exec db psql -U notesuser -d notesdb
```

### Frontend ne se charge pas
```bash
# Vérifier Nginx
docker-compose logs web

# Rebuild le frontend
cd web-frontend && npm run build
```

## 🔧 Configuration

### Variables d'environnement

Copier `.env.example` vers `.env` et modifier selon vos besoins :

```bash
cp .env.example .env
```

### Ports utilisés

- **8080** : API Backend
- **8081** : Frontend Web
- **5432** : PostgreSQL

## 📝 Comptes de démonstration

Au premier démarrage, vous pouvez créer un compte via `/api/v1/auth/register` ou l'interface web.

**Exemple de payload register :**
```json
{
  "email": "demo@example.com",
  "password": "password123"
}
```

## 🏅 Bonnes Pratiques Implémentées

- ✅ Architecture en couches (Controller → Service → Repository)
- ✅ Séparation des responsabilités (Interfaces + Implémentations)
- ✅ DTOs pour le transfert de données (Java Records)
- ✅ Mappers (MapStruct) pour Entity ↔ DTO
- ✅ Specifications pour les requêtes dynamiques
- ✅ Gestion d'erreurs centralisée
- ✅ Validation des inputs (Bean Validation)
- ✅ Logs structurés
- ✅ Documentation API (OpenAPI/Swagger)
- ✅ Tests unitaires et d'intégration
- ✅ Dockerisation complète
- ✅ Scripts de démarrage automatisés

## 📚 Documentation supplémentaire

- [Backend README](./notes-suite-module/README.md)
- [Frontend README](./notes-suite-ui/README.md)
- [Mobile README](./notes-suite-mobile/README.md)


## 🎯 Next Steps

- [ ] Édition collaborative temps réel (WebSockets)
- [ ] Export PDF des notes
- [ ] Recherche full-text avancée
- [ ] Thèmes personnalisables
- [ ] Notifications push (mobile)
- [ ] Import/Export de notes (Markdown, JSON)
- [ ] Intégration CI/CD
