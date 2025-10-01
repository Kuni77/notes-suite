# Backend Spring Boot - Notes API

API REST complète pour la gestion de notes collaboratives avec authentification JWT.

## 🛠️ Technologies

- **Spring Boot 3.5.6**
- **Spring Security** (JWT)
- **Spring Data JPA**
- **PostgreSQL 15**
- **MapStruct** (Mapping Entity ↔ DTO)
- **Lombok** (Réduction boilerplate)
- **OpenAPI/Swagger** (Documentation)
- **Testcontainers** (Tests d'intégration)
- **Java 17**
- **Maven**

## 📁 Structure du projet

```
backend-spring/
├── src/
│   ├── main/
│   │   ├── java/com/notesapp/backend/
│   │   │   ├── config/              # Configurations (Security, JWT, OpenAPI, ApiVersionning)
│   │   │   ├── controller/          # Controllers REST
│   │   │   ├── entity/              # Entités JPA
│   │   │   │   └── enums/           # Enums (Visibility, Permission)
│   │   │   │   └── audit/           # Enums (Visibility, Permission)
│   │   │   ├── exception/           # Exceptions personnalisées
│   │   │   ├── mapper/              # MapStruct mappers
│   │   │   ├── repository/          # Repositories JPA
│   │   │   ├── security/            # JWT Provider, Filter, UserDetailsService
│   │   │   ├── service/             # Interfaces de services
│   │   │   │   └── specification/   # Specifications pour requêtes dynamiques
│   │   │       ├── dto/                 # Data Transfer Objects (Records)
│   │   │   │     └── response/           # Enums (Visibility, Permission)
│   │   │   │   └── criteria/        # Critères de recherche
│   │   │   │   └── impl/            # Implémentations des services
│   │   │   └── BackendApplication.java
│   │   └── resources/
│   │       ├── application.properties
│   │       └── application-prod.properties
│   └── test/                        # Tests unitaires et d'intégration
├── Dockerfile
├── pom.xml
└── README.md
```

## ⚙️ Configuration

### Prérequis

- Java 17+
- Maven 3.8+
- PostgreSQL 15+ (ou Docker)

### Configuration locale

1. **Créer la base de données**

```sql
CREATE DATABASE notesdb;
CREATE USER notesuser WITH PASSWORD 'notespass';
GRANT ALL PRIVILEGES ON DATABASE notesdb TO notesuser;
```

2. **Configurer application.properties**

```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/notesdb
spring.datasource.username=notesuser
spring.datasource.password=notespass
```

3. **Variables d'environnement (optionnel)**

```bash
export DB_USERNAME=notesuser
export DB_PASSWORD=notespass
export JWT_SECRET=your-secret-key-here
```

## 🚀 Lancement

### Avec Maven

```bash
# Compilation
mvn clean install

# Lancer l'application
mvn spring-boot:run

# Avec profil prod
mvn spring-boot:run -Dspring-boot.run.profiles=prod
```

### Avec Docker

```bash
# Build l'image
docker build -t notes-api .

# Lancer le conteneur
docker run -p 8080:8080 \
  -e SPRING_PROFILES_ACTIVE=prod \
  -e DB_USERNAME=notesuser \
  -e DB_PASSWORD=notespass \
  notes-api
```

### Avec Docker Compose (recommandé)

```bash
# Depuis la racine du projet
docker-compose up -d
```

## 📡 API Endpoints

**Base URL** : `http://localhost:8080/api/v1`

### Authentification

| Méthode | Endpoint | Description | Auth |
|---------|----------|-------------|------|
| POST | `/auth/register` | Inscription | ❌ |
| POST | `/auth/login` | Connexion | ❌ |
| POST | `/auth/refresh` | Rafraîchir token | ❌ |

**Exemple Register/Login :**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Réponse :**
```json
{
  "status": 201,
  "data": {
    "accessToken": "eyJhbGc...",
    "refreshToken": "eyJhbGc...",
    "tokenType": "Bearer",
    "email": "user@example.com"
  },
  "message": "User registered successfully"
}
```

### Notes

| Méthode | Endpoint | Description | Auth |
|---------|----------|-------------|------|
| GET | `/notes` | Liste avec filtres | ✅ |
| POST | `/notes` | Créer une note | ✅ |
| GET | `/notes/{id}` | Récupérer une note | ✅ |
| PUT | `/notes/{id}` | Modifier une note | ✅ |
| DELETE | `/notes/{id}` | Supprimer une note | ✅ |

**Paramètres de recherche (GET /notes) :**
- `query` : Recherche dans le titre
- `visibility` : PRIVATE, SHARED, PUBLIC
- `tag` : Filtrer par tag
- `page` : Numéro de page (défaut: 0)
- `size` : Taille de page (défaut: 10)
- `sortBy` : Champ de tri (défaut: updatedAt)
- `sortDirection` : asc ou desc (défaut: desc)

**Exemple création de note :**
```json
{
  "title": "Ma première note",
  "contentMd": "# Contenu en Markdown\n\nCeci est ma note.",
  "tags": ["important", "travail"]
}
```

### Partage

| Méthode | Endpoint | Description | Auth |
|---------|----------|-------------|------|
| POST | `/notes/{id}/share/user` | Partager avec utilisateur | ✅ |
| POST | `/notes/{id}/share/public` | Créer lien public | ✅ |
| GET | `/notes/{id}/shares` | Liste des partages | ✅ |
| DELETE | `/shares/{id}` | Supprimer un partage | ✅ |
| DELETE | `/public-links/{id}` | Supprimer lien public | ✅ |
| GET | `/p/{token}` | Accès public | ❌ |

**Exemple partage avec utilisateur :**
```json
{
  "email": "colleague@example.com"
}
```

## 🔐 Authentification

L'API utilise JWT (JSON Web Tokens) pour l'authentification.

**Header requis pour les endpoints protégés :**
```
Authorization: Bearer <access_token>
```

**Durée de validité :**
- Access Token : 24h
- Refresh Token : 7 jours

## 📊 Format de réponse standard

Toutes les réponses API suivent ce format :

```json
{
  "status": 200,
  "data": { ... },
  "message": "Success",
  "metadata": {
    "size": 10,
    "totalElements": 50,
    "totalPages": 5,
    "number": 0
  }
}
```

**En cas d'erreur :**
```json
{
  "status": 400,
  "message": "Validation failed",
  "errors": {
    "title": "Title must be between 3 and 255 characters",
    "email": "Email should be valid"
  },
  "timestamp": "2025-01-15T10:30:00"
}
```

## 🧪 Tests

### Lancer tous les tests

```bash
mvn test
```

### Tests unitaires uniquement

```bash
mvn test -Dtest=*Test
```

### Tests d'intégration

```bash
mvn test -Dtest=*IT
```

### Coverage

```bash
mvn clean test jacoco:report
# Rapport dans target/site/jacoco/index.html
```

## 📖 Documentation API (Swagger)

Une fois l'application lancée, accédez à la documentation interactive :

**Swagger UI** : http://localhost:8080/swagger-ui.html

**OpenAPI JSON** : http://localhost:8080/api-docs

Vous pouvez tester tous les endpoints directement depuis l'interface Swagger.

## 🗄️ Base de données

### Schéma

```sql
-- Users
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL
);

-- Notes
CREATE TABLE notes (
    id BIGSERIAL PRIMARY KEY,
    owner_id BIGINT NOT NULL REFERENCES users(id),
    title VARCHAR(255) NOT NULL,
    content_md TEXT,
    visibility VARCHAR(50) NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

-- Tags
CREATE TABLE tags (
    id BIGSERIAL PRIMARY KEY,
    label VARCHAR(255) UNIQUE NOT NULL
);

-- Note_Tags (liaison)
CREATE TABLE note_tags (
    id BIGSERIAL PRIMARY KEY,
    note_id BIGINT NOT NULL REFERENCES notes(id),
    tag_id BIGINT NOT NULL REFERENCES tags(id)
);

-- Shares
CREATE TABLE shares (
    id BIGSERIAL PRIMARY KEY,
    note_id BIGINT NOT NULL REFERENCES notes(id),
    shared_with_user_id BIGINT NOT NULL REFERENCES users(id),
    permission VARCHAR(50) NOT NULL
);

-- Public Links
CREATE TABLE public_links (
    id BIGSERIAL PRIMARY KEY,
    note_id BIGINT NOT NULL REFERENCES notes(id),
    url_token VARCHAR(255) UNIQUE NOT NULL,
    expires_at TIMESTAMP
);
```

### Migrations

Le projet utilise Hibernate DDL auto-update. Pour la production, il est recommandé d'utiliser Flyway ou Liquibase.

**Pour ajouter Flyway :**

```xml
<dependency>
    <groupId>org.flywaydb</groupId>
    <artifactId>flyway-core</artifactId>
</dependency>
```

Puis créer des migrations dans `src/main/resources/db/migration/`

## 🔧 Configuration avancée

### Profils Spring

- **default** : Développement local
- **prod** : Production avec Docker

### Activer un profil

```bash
# Via commande
mvn spring-boot:run -Dspring-boot.run.profiles=prod

# Via variable d'environnement
export SPRING_PROFILES_ACTIVE=prod
```

### Variables d'environnement

| Variable | Description | Défaut |
|----------|-------------|--------|
| `DB_USERNAME` | Utilisateur PostgreSQL | notesuser |
| `DB_PASSWORD` | Mot de passe PostgreSQL | notespass |
| `JWT_SECRET` | Secret pour signer les JWT | (valeur par défaut) |
| `SPRING_PROFILES_ACTIVE` | Profil Spring actif | default |

## 🏗️ Architecture

### Couches de l'application

```
Controller (REST API)
    ↓
Service (Logique métier)
    ↓
Repository (Accès données)
    ↓
Database (PostgreSQL)
```

### Flux d'authentification

```
1. Client → POST /auth/register → AuthController
2. AuthController → AuthService.register()
3. AuthService → UserService.createUser()
4. UserService → UserRepository.save()
5. AuthService → JwtTokenProvider.generateToken()
6. AuthController → Retourne tokens au client
```

### Flux de requête protégée

```
1. Client → GET /notes (avec JWT) → JwtAuthenticationFilter
2. JwtAuthenticationFilter → Valide JWT
3. JwtAuthenticationFilter → Charge UserDetails
4. JwtAuthenticationFilter → Set SecurityContext
5. NoteController → Récupère user depuis Authentication
6. NoteController → NoteService.searchNotes()
7. NoteService → NoteRepository.findAll(spec, pageable)
8. NoteMapper → Entity → DTO
9. Controller → Retourne ApiResponse<List<NoteResponse>>
```

## 🐛 Debugging

### Activer les logs SQL

Dans `application.properties` :
```properties
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.format_sql=true
logging.level.org.hibernate.SQL=DEBUG
logging.level.org.hibernate.type.descriptor.sql.BasicBinder=TRACE
```

### Logs détaillés Spring Security

```properties
logging.level.org.springframework.security=TRACE
```

### Accéder à la console H2 (dev uniquement)

Pour tester rapidement sans PostgreSQL :

```xml
<dependency>
    <groupId>com.h2database</groupId>
    <artifactId>h2</artifactId>
    <scope>runtime</scope>
</dependency>
```

```properties
spring.datasource.url=jdbc:h2:mem:testdb
spring.h2.console.enabled=true
```

Console : http://localhost:8080/h2-console

## 🚨 Gestion des erreurs

Toutes les exceptions sont capturées par `GlobalExceptionHandler` :

- **ResourceNotFoundException** → 404
- **UnauthorizedException** → 403
- **BadRequestException** → 400
- **BadCredentialsException** → 401
- **MethodArgumentNotValidException** → 400 (avec détails validation)
- **Exception** → 500

## ⚡ Performance

### Optimisations implémentées

- ✅ Lazy loading des relations
- ✅ Pagination des résultats
- ✅ Index sur colonnes fréquemment requêtées
- ✅ Specifications pour requêtes optimisées
- ✅ Connection pooling (HikariCP)
- ✅ Cache de second niveau Hibernate (optionnel)

### Ajouter le cache

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-cache</artifactId>
</dependency>
<dependency>
    <groupId>org.ehcache</groupId>
    <artifactId>ehcache</artifactId>
</dependency>
```

```properties
spring.cache.type=ehcache
spring.jpa.properties.hibernate.cache.use_second_level_cache=true
```

## 📦 Build & Déploiement

### Build JAR

```bash
mvn clean package -DskipTests
# JAR généré dans target/backend-1.0.0.jar
```

### Lancer le JAR

```bash
java -jar target/backend-1.0.0.jar
```

### Build Docker Image

```bash
docker build -t notes-api:1.0.0 .
```

### Push vers Docker Hub

```bash
docker tag notes-api:1.0.0 username/notes-api:1.0.0
docker push username/notes-api:1.0.0
```

## 🔒 Sécurité - Checklist

- ✅ Passwords hashés avec BCrypt
- ✅ JWT avec signature HMAC-SHA256
- ✅ Validation des inputs (Bean Validation)
- ✅ Protection CSRF désactivée (API stateless)
- ✅ CORS configuré
- ✅ Ownership vérifié sur toutes les opérations
- ✅ SQL Injection protection (JPA/Hibernate)
- ✅ Headers de sécurité HTTP
- ⚠️ TODO: Rate limiting
- ⚠️ TODO: HTTPS en production

## 🧩 Extensions possibles

### Ajout de fonctionnalités

1. **Audit Trail**
```java
@EntityListeners(AuditingEntityListener.class)
public class Note {
    @CreatedBy
    private String createdBy;
    
    @LastModifiedBy
    private String lastModifiedBy;
}
```

2. **Soft Delete**
```java
@SQLDelete(sql = "UPDATE notes SET deleted = true WHERE id = ?")
@Where(clause = "deleted = false")
private boolean deleted = false;
```

3. **Versioning**
```java
@Version
private Long version;
```

4. **Full-text Search**
```xml
<dependency>
    <groupId>org.hibernate.search</groupId>
    <artifactId>hibernate-search-mapper-orm</artifactId>
</dependency>
```

## 📚 Ressources

- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [Spring Security](https://spring.io/projects/spring-security)
- [Spring Data JPA](https://spring.io/projects/spring-data-jpa)
- [MapStruct](https://mapstruct.org/)
- [JWT.io](https://jwt.io/)


## ❓ FAQ

**Q: Comment changer le port de l'API ?**
```properties
server.port=8090
```

**Q: Comment désactiver Swagger en production ?**
```properties
springdoc.swagger-ui.enabled=false
```

**Q: Comment augmenter la taille max d'upload ?**
```properties
spring.servlet.multipart.max-file-size=10MB
spring.servlet.multipart.max-request-size=10MB
```

**Q: Erreur "table already exists" au démarrage ?**
```properties
spring.jpa.hibernate.ddl-auto=validate
# ou
spring.jpa.hibernate.ddl-auto=none
```
