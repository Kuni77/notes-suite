import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, Router } from '@angular/router';
import { ShareService } from '../../../../core/services/share.service';
import { Note } from '../../../../core/models/note.model';

@Component({
  selector: 'app-public-note-view',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './public-note-view.component.html',
  styleUrls: ['./public-note-view.component.scss']
})
export class PublicNoteViewComponent implements OnInit {
  note?: Note;
  isLoading = false;
  error = false;

  constructor(
    private shareService: ShareService,
    private route: ActivatedRoute,
    private router: Router
  ) {}

  ngOnInit(): void {
    const token = this.route.snapshot.paramMap.get('token');
    if (token) {
      this.loadPublicNote(token);
    } else {
      this.error = true;
    }
  }

  loadPublicNote(token: string): void {
    this.isLoading = true;
    this.shareService.getNoteByPublicToken(token).subscribe({
      next: (response) => {
        this.note = response.data;
        this.isLoading = false;
      },
      error: (error) => {
        this.error = true;
        this.isLoading = false;
      }
    });
  }

  formatDate(dateString: string): string {
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', { 
      year: 'numeric', 
      month: 'long', 
      day: 'numeric'
    });
  }
}