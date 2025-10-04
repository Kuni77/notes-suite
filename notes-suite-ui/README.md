# Notes App - Frontend Angular

Application web de gestion de notes collaboratives avec support Markdown.

## 📋 Features

✅ **Authentification**
- Login / Register avec JWT
- Auto-refresh des tokens expirés
- Stockage sécurisé des tokens (localStorage)

✅ **Gestion des Notes**
- CRUD complet (Create, Read, Update, Delete)
- Support Markdown avec preview
- Tags pour organisation
- Visibilité (Private, Shared, Public)
- 2 onglets : "My Notes" / "Shared with Me"

✅ **Recherche & Filtres**
- Recherche par titre
- Filtre par visibilité (Private/Shared/Public)
- Filtre par tags
- Pagination

✅ **Partage**
- Partage avec utilisateurs (lecture seule)
- Génération de liens publics
- Gestion des accès

✅ **UX/UI**
- Design moderne avec TailwindCSS
- Responsive (mobile, tablet, desktop)
- Toast notifications
- Loading states
- Error handling

## 🏗️ Architecture

```
src/
├── app/
│   ├── core/                          # Singleton services, guards, interceptors
│   │   ├── guards/
│   │   │   ├── auth.guard.ts
│   │   │   └── no-auth.guard.ts
│   │   ├── interceptors/
│   │   │   ├── jwt.interceptor.ts
│   │   │   └── error.interceptor.ts
│   │   ├── services/
│   │   │   ├── auth.service.ts
│   │   │   ├── note.service.ts
│   │   │   ├── share.service.ts
│   │   │   └── token.service.ts
│   │   ├── models/                    # Interfaces/Models de base
│   │   │   ├── auth.model.ts
│   │   │   ├── note.model.ts
│   │   │   ├── share.model.ts
│   │   │   └── api-response.model.ts
│   │   └── 
│   │
│   ├── shared/                        # Composants, directives, pipes réutilisables
│   │   ├── components/                # Dumb components
│   │   │   ├── button/
│   │   │   ├── input/
│   │   │   ├── card/
│   │   │   ├── loader/
│   │   │   ├── toast/
│   │   │   └── modal/
│   │   ├── directives/
│   │   ├── pipes/
│   │   │   └── markdown.pipe.ts
│   │   └── 
│   │
│   ├── features/                      # Modules fonctionnels
│   │   ├── auth/
│   │   │   ├── pages/                 # Smart components (containers)
│   │   │   │   ├── login/
│   │   │   │   │   └── login.component.ts
│   │   │   │   └── register/
│   │   │   │       └── register.component.ts
│   │   │   ├── components/            # Dumb components
│   │   │   │   ├── auth-form/
│   │   │   │   └── auth-layout/
│   │   │   ├── auth-routes.ts
│   │   │   └── 
│   │   │
│   │   ├── notes/
│   │   │   ├── pages/                 # Smart components
│   │   │   │   ├── note-list/
│   │   │   │   │   └── note-list.component.ts
│   │   │   │   ├── note-detail/
│   │   │   │   │   └── note-detail.component.ts
│   │   │   │   └── note-editor/
│   │   │   │       └── note-editor.component.ts
│   │   │   ├── components/            # Dumb components
│   │   │   │   ├── note-card/
│   │   │   │   ├── note-form/
│   │   │   │   ├── note-filters/
│   │   │   │   ├── tag-input/
│   │   │   │   ├── markdown-editor/
│   │   │   │   └── markdown-preview/
│   │   │   ├── notes-routes.ts
│   │   │   └── 
│   │   │
│   │   ├── share/
│   │   │   ├── pages/
│   │   │   │   └── share-management/
│   │   │   ├── components/
│   │   │   │   ├── share-dialog/
│   │   │   │   └── public-link-dialog/
│   │   │   └── 
│   │   │
│   │   └── public/
│   │       ├── pages/
│   │       │   └── public-note-view/
│   │       └── 
│   │
│   ├── layout/                        # Layouts de l'app
│   │   ├── main-layout/
│   │   ├── auth-layout/
│   │   └── 
│   │
│   ├── app-routes.ts
│   ├── app.component.ts
│   └── 
│
├── assets/
├── environments/
├── styles.scss
└── index.html
```

## 🚀 Installation & Setup

### Prérequis

- Node.js 18+ et npm
- Angular CLI 17+
- Backend Spring Boot en cours d'exécution

### Installation

1. **Installer les dépendances**
```bash
cd web-frontend
npm install
```

2. **Configurer l'API URL**

Modifier `src/environments/environment.ts`:
```typescript
export const environment = {
  production: false,
  apiUrl: 'http://localhost:8080/api/v1'
};
```

### Lancer l'application

#### Mode développement
```bash
npm start
# ou
ng serve

# Application disponible sur: http://localhost:4200
```

#### Mode production
```bash
npm run build
# ou
ng build --configuration production

# Build généré dans: dist/web-frontend
```

## 🧪 Tests

```bash
# Tests unitaires
npm test
# ou
ng test

# Tests e2e
npm run e2e
# ou
ng e2e

# Tests avec coverage
ng test --code-coverage
```

## 📦 Build & Déploiement

### Build de production
```bash
npm run build
```

### Servir le build localement
```bash
npm install -g http-server
cd dist/web-frontend
http-server -p 4200
```

### Docker (optionnel)

**Dockerfile:**
```dockerfile
FROM node:18-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=build /app/dist/web-frontend /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

**nginx.conf:**
```nginx
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /api {
        proxy_pass http://backend:8080;
    }
}
```

**Build & Run:**
```bash
docker build -t notes-frontend .
docker run -p 4200:80 notes-frontend
```

## 🛠️ Technologies

- **Angular** 17+ (Standalone Components)
- **TypeScript** 5+
- **RxJS** 7+ (Reactive programming)
- **TailwindCSS** 3+ (Styling)
- **Marked** (Markdown rendering)
- **ngx-toastr** (Toast notifications)
- **Angular Router** (Navigation & Guards)

## 📚 Structure des Composants

### Auth Module
- **LoginComponent** - Écran de connexion
- **RegisterComponent** - Écran d'inscription

### Notes Module
- **NoteListComponent** - Liste des notes avec filtres
- **NoteDetailComponent** - Affichage d'une note
- **NoteFormComponent** - Création/Édition de note
- **SharedNotesComponent** - Notes partagées avec moi

### Services
- **AuthService** - Authentification JWT
- **NoteService** - CRUD notes
- **ShareService** - Partage de notes

### Guards & Interceptors
- **AuthGuard** - Protection des routes authentifiées
- **AuthInterceptor** - Injection automatique du token JWT

## 🔐 Authentification

### Flow JWT
1. Login → Backend retourne `{accessToken, refreshToken}`
2. Tokens stockés dans `localStorage`
3. `AuthInterceptor` ajoute le token à chaque requête
4. Si 401 → Refresh automatique du token
5. Si refresh échoue → Redirection vers login

### Sécurité
- ✅ Tokens JWT stockés en localStorage (HTTPS recommandé en prod)
- ✅ Refresh token automatique
- ✅ Guards sur routes protégées
- ✅ Intercepteur pour injection du token
- ✅ Logout nettoie le localStorage

## 🎨 Styling avec TailwindCSS

### Couleurs principales
```css
--primary: #6366F1 (Indigo)
--secondary: #8B5CF6 (Purple)
--success: #10B981 (Green)
--error: #EF4444 (Red)
--warning: #F59E0B (Amber)
```

### Classes utilitaires
- `btn-primary` - Bouton principal
- `card` - Carte avec ombre
- `input-field` - Champ de formulaire
- `badge-private/shared/public` - Badges de visibilité

## 📝 Modèles de Données

### Note
```typescript
interface Note {
  id: number;
  title: string;
  contentMd: string;
  visibility: 'PRIVATE' | 'SHARED' | 'PUBLIC';
  ownerEmail: string;
  tags: string[];
  createdAt: string;
  updatedAt: string;
}
```

### User
```typescript
interface User {
  email: string;
  accessToken: string;
  refreshToken: string;
}
```

### ApiResponse
```typescript
interface ApiResponse<T> {
  success: boolean;
  message?: string;
  data?: T;
  metadata?: PageMetadata;
}
```

## 🔌 API Endpoints Utilisés

```typescript
// Auth
POST   /api/v1/auth/register
POST   /api/v1/auth/login
POST   /api/v1/auth/refresh

// Notes
GET    /api/v1/notes
GET    /api/v1/notes/shared
GET    /api/v1/notes/{id}
POST   /api/v1/notes
PUT    /api/v1/notes/{id}
DELETE /api/v1/notes/{id}

// Share
POST   /api/v1/notes/{id}/share/user
POST   /api/v1/notes/{id}/share/public

// Public
GET    /api/v1/public/p/{token}
```

## 🐛 Troubleshooting

### Problème: CORS errors

**Solution:**
Vérifier que le backend a configuré CORS correctement:
```java
@CrossOrigin(origins = "http://localhost:4200")
```

### Problème: 401 Unauthorized

**Solution:**
- Vérifier que le backend est démarré
- Vérifier le token dans localStorage
- Tester le refresh token
- Re-login si nécessaire

### Problème: Build errors

**Solution:**
```bash
# Nettoyer et réinstaller
rm -rf node_modules package-lock.json
npm install

# Nettoyer le cache Angular
ng cache clean
```

### Problème: Markdown ne s'affiche pas

**Solution:**
Vérifier l'import de `marked` dans le composant:
```typescript
import { marked } from 'marked';
```

## 📊 Performance

### Optimisations appliquées
- ✅ Lazy loading des modules
- ✅ OnPush change detection strategy
- ✅ Standalone components (moins de bundle size)
- ✅ Tree-shaking avec production build
- ✅ Compression gzip (si serveur configuré)

### Build size (approximatif)
- **Development**: ~5MB
- **Production**: ~500KB (minifié + gzip)

## 🚦 Environnements

### Development (`environment.ts`)
```typescript
export const environment = {
  production: false,
  apiUrl: 'http://localhost:8080/api/v1',
  enableDebug: true
};
```

### Production (`environment.prod.ts`)
```typescript
export const environment = {
  production: true,
  apiUrl: 'https://api.yourapp.com/api/v1',
  enableDebug: false
};
```

## 📝 Comptes de Test

Créer via l'écran Register ou utiliser:
```
Email: demo@example.com
Password: password123
```

## 📄 License

MIT
