import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';
import { 
  Note, 
  CreateNoteRequest, 
  UpdateNoteRequest, 
  NoteSearchCriteria 
} from '../models/note.model';
import { ApiResponse } from '../models/api-response.model';

@Injectable({
  providedIn: 'root'
})
export class NoteService {
  private readonly API_URL = `${environment.apiUrl}/notes`;

  constructor(private http: HttpClient) {}

  searchNotes(criteria: NoteSearchCriteria = {}): Observable<ApiResponse<Note[]>> {
    let params = new HttpParams();
    
    if (criteria.query) params = params.set('query', criteria.query);
    if (criteria.visibility) params = params.set('visibility', criteria.visibility);
    if (criteria.tag) params = params.set('tag', criteria.tag);
    if (criteria.page !== undefined) params = params.set('page', criteria.page.toString());
    if (criteria.size !== undefined) params = params.set('size', criteria.size.toString());
    if (criteria.sortBy) params = params.set('sortBy', criteria.sortBy);
    if (criteria.sortDirection) params = params.set('sortDirection', criteria.sortDirection);

    return this.http.get<ApiResponse<Note[]>>(this.API_URL, { params });
  }

  getSharedNotes(page: number = 0, size: number = 10, query?: string, tag?: string): Observable<ApiResponse<Note[]>> {
    let params = new HttpParams()
      .set('page', page.toString())
      .set('size', size.toString());
    
    // Ajouter les filtres optionnels
    if (query) params = params.set('query', query);
    if (tag) params = params.set('tag', tag);

    return this.http.get<ApiResponse<Note[]>>(`${this.API_URL}/shared`, { params });
  }

  getNoteById(id: number): Observable<ApiResponse<Note>> {
    return this.http.get<ApiResponse<Note>>(`${this.API_URL}/${id}`);
  }

  createNote(request: CreateNoteRequest): Observable<ApiResponse<Note>> {
    return this.http.post<ApiResponse<Note>>(this.API_URL, request);
  }

  updateNote(id: number, request: UpdateNoteRequest): Observable<ApiResponse<Note>> {
    return this.http.put<ApiResponse<Note>>(`${this.API_URL}/${id}`, request);
  }

  deleteNote(id: number): Observable<ApiResponse<void>> {
    return this.http.delete<ApiResponse<void>>(`${this.API_URL}/${id}`);
  }
}