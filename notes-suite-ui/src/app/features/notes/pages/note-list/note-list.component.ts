import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { NoteService } from '../../../../core/services/note.service';
import { Note, NoteSearchCriteria, Visibility } from '../../../../core/models/note.model';
import { PageMetadata } from '../../../../core/models/api-response.model';
import { ToastrService } from 'ngx-toastr';
import { AuthService } from '../../../../core/services/auth.service';

@Component({
  selector: 'app-note-list',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './note-list.component.html',
  styleUrls: ['./note-list.component.scss']
})
export class NoteListComponent implements OnInit {
  notes: Note[] = [];
  isLoading = false;
  currentUserEmail = '';
  
  // Tab selection
  activeTab: 'my-notes' | 'shared-with-me' = 'my-notes';
  
  // Filters
  searchQuery = '';
  selectedVisibility: Visibility | '' = '';
  selectedTag = '';
  
  // Pagination
  pageMetadata?: PageMetadata;
  currentPage = 0;
  pageSize = 10;

  // Enums for template
  Visibility = Visibility;
  visibilityOptions = [
    { value: '', label: 'All' },
    { value: Visibility.PRIVATE, label: 'Private' },
    { value: Visibility.SHARED, label: 'Shared' },
    { value: Visibility.PUBLIC, label: 'Public' }
  ];

  constructor(
    private noteService: NoteService,
    private router: Router,
    private toastr: ToastrService,
    private authService: AuthService
  ) {
    // Récupérer l'email de l'utilisateur connecté
    this.authService.currentUser$.subscribe(user => {
      if (user) {
        this.currentUserEmail = user.email;
      }
    });
  }

  ngOnInit(): void {
    this.loadNotes();
  }

  switchTab(tab: 'my-notes' | 'shared-with-me'): void {
    this.activeTab = tab;
    this.currentPage = 0;
    this.searchQuery = '';
    this.selectedVisibility = '';
    this.selectedTag = '';
    this.loadNotes();
  }

  loadNotes(): void {
    if (this.activeTab === 'shared-with-me') {
      this.loadSharedNotes();
    } else {
      this.loadMyNotes();
    }
  }

  loadMyNotes(): void {
    this.isLoading = true;
    
    const criteria: NoteSearchCriteria = {
      query: this.searchQuery || undefined,
      visibility: this.selectedVisibility || undefined,
      tag: this.selectedTag || undefined,
      page: this.currentPage,
      size: this.pageSize,
      sortBy: 'updatedAt',
      sortDirection: 'desc'
    };

    this.noteService.searchNotes(criteria).subscribe({
      next: (response) => {
        this.notes = response.data || [];
        this.pageMetadata = response.metadata;
        this.isLoading = false;
      },
      error: (error) => {
        this.isLoading = false;
        this.toastr.error('Failed to load notes', 'Error');
      }
    });
  }

  loadSharedNotes(): void {
    this.isLoading = true;

    // Appliquer les filtres également pour les notes partagées
    const criteria: NoteSearchCriteria = {
      query: this.searchQuery || undefined,
      tag: this.selectedTag || undefined,
      page: this.currentPage,
      size: this.pageSize,
      sortBy: 'updatedAt',
      sortDirection: 'desc'
    };

    this.noteService.getSharedNotes(criteria.page, criteria.size, criteria.query, criteria.tag).subscribe({
      next: (response) => {
        this.notes = response.data || [];
        this.pageMetadata = response.metadata;
        this.isLoading = false;
      },
      error: (error) => {
        this.isLoading = false;
        this.toastr.error('Failed to load shared notes', 'Error');
      }
    });
  }

  onSearch(): void {
    this.currentPage = 0;
    this.loadNotes();
  }

  onFilterChange(): void {
    this.currentPage = 0;
    this.loadNotes();
  }

  onPageChange(page: number): void {
    this.currentPage = page;
    this.loadNotes();
  }

  createNote(): void {
    this.router.navigate(['/notes/new']);
  }

  viewNote(note: Note): void {
    this.router.navigate(['/notes', note.id]);
  }

  editNote(note: Note, event: Event): void {
    event.stopPropagation();
    this.router.navigate(['/notes', note.id, 'edit']);
  }

  deleteNote(note: Note, event: Event): void {
    event.stopPropagation();
    
    if (confirm(`Are you sure you want to delete "${note.title}"?`)) {
      this.noteService.deleteNote(note.id).subscribe({
        next: () => {
          this.toastr.success('Note deleted successfully', 'Success');
          this.loadNotes();
        },
        error: (error) => {
          this.toastr.error('Failed to delete note', 'Error');
        }
      });
    }
  }

  getVisibilityBadgeClass(visibility: Visibility): string {
    switch (visibility) {
      case Visibility.PRIVATE:
        return 'bg-gray-100 text-gray-800';
      case Visibility.SHARED:
        return 'bg-blue-100 text-blue-800';
      case Visibility.PUBLIC:
        return 'bg-green-100 text-green-800';
      default:
        return 'bg-gray-100 text-gray-800';
    }
  }

  formatDate(dateString: string): string {
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', { 
      year: 'numeric', 
      month: 'short', 
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  }

  isOwner(note: Note): boolean {
    return note.ownerEmail === this.currentUserEmail;
  }
}