import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, ActivatedRoute } from '@angular/router';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule, FormsModule } from '@angular/forms';
import { NoteService } from '../../../../core/services/note.service';
import { CreateNoteRequest, UpdateNoteRequest, Note } from '../../../../core/models/note.model';
import { ToastrService } from 'ngx-toastr';

@Component({
  selector: 'app-note-editor',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, FormsModule],
  templateUrl: './note-editor.component.html',
  styleUrls: ['./note-editor.component.scss']
})
export class NoteEditorComponent implements OnInit {
  noteForm: FormGroup;
  isLoading = false;
  isEditMode = false;
  noteId?: number;
  tagInput = '';
  showPreview = false;

  constructor(
    private fb: FormBuilder,
    private noteService: NoteService,
    private router: Router,
    private route: ActivatedRoute,
    private toastr: ToastrService
  ) {
    this.noteForm = this.fb.group({
      title: ['', [Validators.required, Validators.minLength(3), Validators.maxLength(255)]],
      contentMd: ['', [Validators.maxLength(50000)]],
      tags: [[]]
    });
  }

  ngOnInit(): void {
    const id = this.route.snapshot.paramMap.get('id');
    if (id) {
      this.isEditMode = true;
      this.noteId = +id;
      this.loadNote();
    }
  }

  loadNote(): void {
    if (!this.noteId) return;

    this.isLoading = true;
    this.noteService.getNoteById(this.noteId).subscribe({
      next: (response) => {
        if (response.data) {
          this.noteForm.patchValue({
            title: response.data.title,
            contentMd: response.data.contentMd,
            tags: response.data.tags
          });
        }
        this.isLoading = false;
      },
      error: (error) => {
        this.isLoading = false;
        this.toastr.error('Failed to load note', 'Error');
        this.router.navigate(['/notes']);
      }
    });
  }

  onSubmit(): void {
    if (this.noteForm.invalid) {
      Object.keys(this.noteForm.controls).forEach(key => {
        this.noteForm.get(key)?.markAsTouched();
      });
      return;
    }

    this.isLoading = true;

    if (this.isEditMode && this.noteId) {
      this.updateNote();
    } else {
      this.createNote();
    }
  }

  createNote(): void {
    const request: CreateNoteRequest = this.noteForm.value;

    this.noteService.createNote(request).subscribe({
      next: (response) => {
        this.toastr.success('Note created successfully!', 'Success');
        this.router.navigate(['/notes']);
      },
      error: (error) => {
        this.isLoading = false;
      }
    });
  }

  updateNote(): void {
    if (!this.noteId) return;

    const request: UpdateNoteRequest = this.noteForm.value;

    this.noteService.updateNote(this.noteId, request).subscribe({
      next: (response) => {
        this.toastr.success('Note updated successfully!', 'Success');
        this.router.navigate(['/notes', this.noteId]);
      },
      error: (error) => {
        this.isLoading = false;
      }
    });
  }

  addTag(): void {
    if (!this.tagInput.trim()) return;

    const tags = this.noteForm.get('tags')?.value || [];
    if (!tags.includes(this.tagInput.trim())) {
      this.noteForm.patchValue({
        tags: [...tags, this.tagInput.trim()]
      });
    }
    this.tagInput = '';
  }

  removeTag(tag: string): void {
    const tags = this.noteForm.get('tags')?.value || [];
    this.noteForm.patchValue({
      tags: tags.filter((t: string) => t !== tag)
    });
  }

  togglePreview(): void {
    this.showPreview = !this.showPreview;
  }

  cancel(): void {
    if (this.isEditMode && this.noteId) {
      this.router.navigate(['/notes', this.noteId]);
    } else {
      this.router.navigate(['/notes']);
    }
  }

  getErrorMessage(fieldName: string): string {
    const control = this.noteForm.get(fieldName);
    if (control?.hasError('required')) {
      return `${fieldName.charAt(0).toUpperCase() + fieldName.slice(1)} is required`;
    }
    if (control?.hasError('minlength')) {
      return `${fieldName} must be at least ${control.errors?.['minlength'].requiredLength} characters`;
    }
    if (control?.hasError('maxlength')) {
      return `${fieldName} must not exceed ${control.errors?.['maxlength'].requiredLength} characters`;
    }
    return '';
  }
}