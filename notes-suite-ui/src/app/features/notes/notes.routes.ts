import { Routes } from '@angular/router';
import { MainLayoutComponent } from '../../layouts/main-layout/main-layout.component';

export const NOTES_ROUTES: Routes = [
  {
    path: '',
    component: MainLayoutComponent,
    children: [
      {
        path: '',
        loadComponent: () => import('./pages/note-list/note-list.component').then(m => m.NoteListComponent)
      },
      {
        path: 'new',
        loadComponent: () => import('./pages/note-editor/note-editor.component').then(m => m.NoteEditorComponent)
      },
      {
        path: ':id',
        loadComponent: () => import('./pages/note-detail/note-detail.component').then(m => m.NoteDetailComponent)
      },
      {
        path: ':id/edit',
        loadComponent: () => import('./pages/note-editor/note-editor.component').then(m => m.NoteEditorComponent)
      }
    ]
  }
];