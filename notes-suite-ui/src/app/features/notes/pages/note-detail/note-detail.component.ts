import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, ActivatedRoute, RouterLink } from '@angular/router';
import { NoteService } from '../../../../core/services/note.service';
import { ShareService } from '../../../../core/services/share.service';
import { Note, Visibility } from '../../../../core/models/note.model';
import { ShareResponse, PublicLinkResponse } from '../../../../core/models/share.model';
import { ToastrService } from 'ngx-toastr';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-note-detail',
  standalone: true,
  imports: [CommonModule, RouterLink, FormsModule],
  templateUrl: './note-detail.component.html',
  styleUrls: ['./note-detail.component.scss']
})
export class NoteDetailComponent implements OnInit {
  note?: Note;
  isLoading = false;
  showShareDialog = false;
  showPublicLinkDialog = false;
  shares: ShareResponse[] = [];
  publicLinks: PublicLinkResponse[] = [];
  shareEmail = '';

  Visibility = Visibility;

  constructor(
    private noteService: NoteService,
    private shareService: ShareService,
    private router: Router,
    private route: ActivatedRoute,
    private toastr: ToastrService
  ) {}

  ngOnInit(): void {
    const id = this.route.snapshot.paramMap.get('id');
    if (id) {
      this.loadNote(+id);
    }
  }

  loadNote(id: number): void {
    this.isLoading = true;
    this.noteService.getNoteById(id).subscribe({
      next: (response) => {
        this.note = response.data;
        this.isLoading = false;
      },
      error: (error) => {
        this.isLoading = false;
        this.toastr.error('Failed to load note', 'Error');
        this.router.navigate(['/notes']);
      }
    });
  }

  editNote(): void {
    if (this.note) {
      this.router.navigate(['/notes', this.note.id, 'edit']);
    }
  }

  deleteNote(): void {
    if (!this.note) return;

    if (confirm(`Are you sure you want to delete "${this.note.title}"?`)) {
      this.noteService.deleteNote(this.note.id).subscribe({
        next: () => {
          this.toastr.success('Note deleted successfully', 'Success');
          this.router.navigate(['/notes']);
        },
        error: (error) => {
          this.toastr.error('Failed to delete note', 'Error');
        }
      });
    }
  }

  openShareDialog(): void {
    if (!this.note) return;
    this.showShareDialog = true;
    this.loadShares();
  }

  closeShareDialog(): void {
    this.showShareDialog = false;
    this.shareEmail = '';
  }

  loadShares(): void {
    if (!this.note) return;
    this.shareService.getSharesForNote(this.note.id).subscribe({
      next: (response) => {
        this.shares = response.data || [];
      },
      error: (error) => {
        this.toastr.error('Failed to load shares', 'Error');
      }
    });
  }

  shareWithUser(): void {
    if (!this.note || !this.shareEmail.trim()) return;

    this.shareService.shareNoteWithUser(this.note.id, { email: this.shareEmail }).subscribe({
      next: (response) => {
        this.toastr.success('Note shared successfully', 'Success');
        this.shareEmail = '';
        this.loadShares();
      },
      error: (error) => {
        // Error handled by interceptor
      }
    });
  }

  removeShare(shareId: number): void {
    if (confirm('Remove this share?')) {
      this.shareService.removeShare(shareId).subscribe({
        next: () => {
          this.toastr.success('Share removed', 'Success');
          this.loadShares();
        },
        error: (error) => {
          this.toastr.error('Failed to remove share', 'Error');
        }
      });
    }
  }

  openPublicLinkDialog(): void {
    if (!this.note) return;
    this.showPublicLinkDialog = true;
    this.loadPublicLinks();
  }

  closePublicLinkDialog(): void {
    this.showPublicLinkDialog = false;
  }

  loadPublicLinks(): void {
    if (!this.note) return;
    this.shareService.getPublicLinksForNote(this.note.id).subscribe({
      next: (response) => {
        this.publicLinks = response.data || [];
      },
      error: (error) => {
        this.toastr.error('Failed to load public links', 'Error');
      }
    });
  }

  createPublicLink(): void {
    if (!this.note) return;

    this.shareService.createPublicLink(this.note.id).subscribe({
      next: (response) => {
        this.toastr.success('Public link created', 'Success');
        this.loadPublicLinks();
      },
      error: (error) => {
        // Error handled by interceptor
      }
    });
  }

  copyPublicLink(link: PublicLinkResponse): void {
    const fullUrl = `${window.location.origin}/p/${link.urlToken}`;
    navigator.clipboard.writeText(fullUrl).then(() => {
      this.toastr.success('Link copied to clipboard', 'Success');
    });
  }

  deletePublicLink(linkId: number): void {
    if (confirm('Delete this public link?')) {
      this.shareService.deletePublicLink(linkId).subscribe({
        next: () => {
          this.toastr.success('Public link deleted', 'Success');
          this.loadPublicLinks();
        },
        error: (error) => {
          this.toastr.error('Failed to delete link', 'Error');
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
      month: 'long', 
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  }

  goBack(): void {
    this.router.navigate(['/notes']);
  }
}