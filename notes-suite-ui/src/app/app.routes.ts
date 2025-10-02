import { Routes } from '@angular/router';
import { noAuthGuard } from './core/guards/no-auth.guard';
import { authGuard } from './core/guards/auth.guard';

export const routes: Routes = [
    {
    path: '',
    redirectTo: '/notes',
    pathMatch: 'full'
  },
  {
    path: 'auth',
    canActivate: [noAuthGuard],
    loadChildren: () => import('./features/auth/auth.routes').then(m => m.AUTH_ROUTES)
  },
  {
    path: 'notes',
    canActivate: [authGuard],
    loadChildren: () => import('./features/notes/notes.routes').then(m => m.NOTES_ROUTES)
  },
  {
    path: 'p/:token',
    loadComponent: () => import('./features/public/pages/public-note-view/public-note-view.component')
      .then(m => m.PublicNoteViewComponent)
  },
  {
    path: '**',
    redirectTo: '/notes'
  }
];
