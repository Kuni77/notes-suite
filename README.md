# 📝 Notes Suite - Application de Gestion de Notes Collaboratives

Application complète de gestion de notes avec:
- **Backend** Spring Boot (JWT, PostgreSQL)
- **Frontend Web** Angular
- **Mobile** Flutter (offline-first)

## 🏗️ Architecture Globale

```
notes-suite/
├── notes-suite-module/          # API REST Spring Boot
├── notes-suite-ui/            # Application web Angular
├── notes-suite-mobile/              # Application mobile Flutter
├── docker/                  # Configuration Docker
│   └── docker-compose.yml
└── README.md
```

## ✨ Fonctionnalités

### 🔐 Authentification
- Register / Login avec JWT
- Refresh token automatique
- Stockage sécurisé des tokens

### 📝 Gestion des Notes
- CRUD complet
- Support Markdown
- Tags pour organisation
- Visibilité (Private, Shared, Public)
- Recherche et filtres avancés
- Pagination

### 🤝 Partage & Collaboration
- Partage avec utilisateurs (lecture seule)
- Liens publics avec token
- Vue "Shared with Me"

### 📱 Mobile Offline-First (Flutter)
- Cache local SQLite
- File d'opérations en attente
- Synchronisation automatique
- Stratégie Last-Write-Wins
- Indicateurs de sync

## 🚀 Démarrage Rapide

### Prérequis

- Docker & Docker Compose
- Node.js 18+ (pour Angular)
- Flutter SDK 3.0+ (pour mobile)
- Java 17+ (si run sans Docker)

### Option 1: Docker Compose (Recommandé)

```bash
# 1. Démarrer backend + base de données
cd docker
docker-compose up -d

# Backend disponible sur: http://localhost:8080
# PostgreSQL sur: localhost:5432

# 2. Démarrer le frontend web
cd ../web-frontend
npm install
npm start
# Web app sur: http://localhost:4200

# 3. Démarrer l'app mobile
cd ../mobile-app
flutter pub get
flutter run
```

### Option 2: Commande Unique

```bash
# Script de démarrage complet (à créer)
./start.sh
```

## 📦 Composants

### 🔧 Backend Spring Boot

**Stack:** Spring Boot 3, Spring Security (JWT), Spring Data JPA, PostgreSQL, OpenAPI

**Endpoints:**
- `POST /api/v1/auth/register` - Inscription
- `POST /api/v1/auth/login` - Connexion
- `POST /api/v1/auth/refresh` - Refresh token
- `GET /api/v1/notes` - Liste des notes (avec filtres)
- `GET /api/v1/notes/shared` - Notes partagées avec moi
- `POST /api/v1/notes` - Créer une note
- `PUT /api/v1/notes/{id}` - Modifier une note
- `DELETE /api/v1/notes/{id}` - Supprimer une note
- `POST /api/v1/notes/{id}/share/user` - Partager avec utilisateur
- `POST /api/v1/notes/{id}/share/public` - Créer un lien public
- `GET /api/v1/public/p/{token}` - Note publique

📄 [Documentation complète](./backend-spring/README.md)

### 🌐 Frontend Angular

**Stack:** Angular 17+, Standalone Components, TailwindCSS, Markdown Editor

**Features:**
- Authentification (Login/Register)
- 2 onglets: "My Notes" / "Shared with Me"
- Filtres (recherche, tags, visibilité)
- Édition Markdown avec preview
- Partage (utilisateurs + liens publics)
- Design moderne et responsive

📄 [Documentation complète](./web-frontend/README.md)

### 📱 Mobile Flutter

**Stack:** Flutter 3+, Riverpod, Dio, SQLite, GoRouter

**Features:**
- Authentification JWT
- CRUD notes avec Markdown
- Offline-first (cache SQLite)
- Sync automatique en arrière-plan
- Pull-to-refresh
- Material Design 3

📄 [Documentation complète](./mobile-app/README.md)

## 🐳 Docker

### Services

```yaml
services:
  db:
    image: postgres:15
    ports: 5432:5432
    
  api:
    build: ./backend-spring
    ports: 8080:8080
    depends_on: db
    
  # web: (optionnel, build du frontend)
  #   build: ./web-frontend
  #   ports: 80:80
```

### Commandes Docker

```bash
# Démarrer tous les services
docker-compose up -d

# Voir les logs
docker-compose logs -f

# Arrêter
docker-compose down

# Rebuild
docker-compose up --build
```

## 🗄️ Base de Données

### PostgreSQL

**Connection:**
- Host: `localhost`
- Port: `5432`
- Database: `notesdb`
- User: `notesuser`
- Password: `notespass`

### Schéma

```sql
users (id, email, password_hash, created_at)
notes (id, owner_id, title, content_md, visibility, created_at, updated_at)
tags (id, label)
note_tags (note_id, tag_id)
shares (id, note_id, shared_with_user_id, permission)
public_links (id, note_id, url_token, expires_at)
```

## 🧪 Tests

### Backend
```bash
cd backend-spring
./mvnw test
```

### Frontend
```bash
cd web-frontend
npm test
```

### Mobile
```bash
cd mobile-app
flutter test
```

## 📊 Modèle de Données Commun

### Note
```json
{
  "id": 1,
  "title": "My Note",
  "contentMd": "# Hello\n\nMarkdown content",
  "tags": ["work", "important"],
  "visibility": "PRIVATE|SHARED|PUBLIC",
  "ownerEmail": "user@example.com",
  "createdAt": "2025-01-15T10:30:00Z",
  "updatedAt": "2025-01-15T10:30:00Z"
}
```

### User
```json
{
  "email": "user@example.com",
  "accessToken": "eyJ...",
  "refreshToken": "eyJ..."
}
```

## 🔐 Sécurité

- ✅ JWT avec refresh token
- ✅ BCrypt pour les mots de passe (force 10)
- ✅ Tokens stockés de façon sécurisée
- ✅ Validation inputs côté serveur et client
- ✅ Protection ownership sur les notes
- ✅ CORS configuré

## 📝 Comptes de Test

```
Email: demo@example.com
Password: password123
```

Ou créer via l'écran Register

## 🛠️ Technologies

### Backend
- Spring Boot 3.2
- Spring Security 6
- Spring Data JPA
- PostgreSQL 15
- JWT (jjwt 0.12)
- MapStruct
- OpenAPI/Swagger

### Frontend Web
- Angular 17+
- Standalone Components
- TailwindCSS
- RxJS
- Marked (Markdown)

### Mobile
- Flutter 3+
- Riverpod (State Management)
- Dio (HTTP Client)
- SQLite (Offline Storage)
- GoRouter (Navigation)
- Flutter Markdown

## 📚 Documentation API

Une fois le backend démarré, la documentation Swagger est disponible sur:
```
http://localhost:8080/swagger-ui.html
```

## 🚦 Roadmap

### MVP ✅
- [x] Auth JWT
- [x] CRUD Notes
- [x] Partage utilisateurs
- [x] Liens publics
- [x] Filtres & recherche
- [x] Mobile offline-first
- [x] Sync automatique

### V2 (Bonus)
- [ ] Édition collaborative temps réel (WebSockets)
- [ ] Export PDF
- [ ] Notifications push (mobile)
- [ ] Dark mode
- [ ] Multi-langue (i18n)
- [ ] Recherche full-text avancée
- [ ] BFF NestJS (optionnel)

## 🐛 Troubleshooting

### Backend ne démarre pas
```bash
# Vérifier PostgreSQL
docker-compose ps

# Vérifier les logs
docker-compose logs api

# Rebuild
docker-compose up --build
```

### Frontend: Cannot connect to API
```bash
# Vérifier que le backend est démarré
curl http://localhost:8080/api/v1/notes

# Vérifier la config dans environment.ts
```

### Mobile: Cannot connect to backend
- Android Emulator: Utiliser `10.0.2.2` au lieu de `localhost`
- iOS Simulator: Utiliser `localhost`
- Appareil physique: Utiliser l'IP de votre machine

## 📄 License

MIT

## 👥 Auteurs

Développé dans le cadre d'un exercice technique.

## 📞 Support

Pour toute question:
- Backend: Voir [backend-spring/README.md](./notes-suite-module/README.md)
- Frontend: Voir [web-frontend/README.md](./notes-suite_ui/README.md)
- Mobile: Voir [mobile-app/README.md](./notes-suite-mobile/README.md)