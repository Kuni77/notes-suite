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