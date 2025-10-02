import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';
import { 
  ShareWithUserRequest, 
  ShareResponse, 
  PublicLinkResponse 
} from '../models/share.model';
import { ApiResponse } from '../models/api-response.model';
import { Note } from '../models/note.model';

@Injectable({
  providedIn: 'root'
})
export class ShareService {
  private readonly API_URL = `${environment.apiUrl}`;

  constructor(private http: HttpClient) {}

  // Share with user
  shareNoteWithUser(noteId: number, request: ShareWithUserRequest): Observable<ApiResponse<ShareResponse>> {
    return this.http.post<ApiResponse<ShareResponse>>(
      `${this.API_URL}/notes/${noteId}/share/user`, 
      request
    );
  }

  getSharesForNote(noteId: number): Observable<ApiResponse<ShareResponse[]>> {
    return this.http.get<ApiResponse<ShareResponse[]>>(
      `${this.API_URL}/notes/${noteId}/shares`
    );
  }

  removeShare(shareId: number): Observable<ApiResponse<void>> {
    return this.http.delete<ApiResponse<void>>(
      `${this.API_URL}/shares/${shareId}`
    );
  }

  // Public links
  createPublicLink(noteId: number): Observable<ApiResponse<PublicLinkResponse>> {
    return this.http.post<ApiResponse<PublicLinkResponse>>(
      `${this.API_URL}/notes/${noteId}/share/public`,
      {}
    );
  }

  getPublicLinksForNote(noteId: number): Observable<ApiResponse<PublicLinkResponse[]>> {
    return this.http.get<ApiResponse<PublicLinkResponse[]>>(
      `${this.API_URL}/notes/${noteId}/public-links`
    );
  }

  deletePublicLink(publicLinkId: number): Observable<ApiResponse<void>> {
    return this.http.delete<ApiResponse<void>>(
      `${this.API_URL}/public-links/${publicLinkId}`
    );
  }

  getNoteByPublicToken(urlToken: string): Observable<ApiResponse<Note>> {
    return this.http.get<ApiResponse<Note>>(
      `${this.API_URL}/p/${urlToken}`
    );
  }
}