export enum Permission {
  READ = 'READ'
}

export interface ShareWithUserRequest {
  email: string;
}

export interface ShareResponse {
  id: number;
  noteId: number;
  sharedWithEmail: string;
  permission: Permission;
}

export interface PublicLinkResponse {
  id: number;
  noteId: number;
  urlToken: string;
  publicUrl: string;
  expiresAt?: string;
}