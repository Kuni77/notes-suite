export enum Visibility {
  PRIVATE = 'PRIVATE',
  SHARED = 'SHARED',
  PUBLIC = 'PUBLIC'
}

export interface Note {
  id: number;
  title: string;
  contentMd: string;
  visibility: Visibility;
  ownerEmail: string;
  tags: string[];
  createdAt: string;
  updatedAt: string;
}

export interface CreateNoteRequest {
  title: string;
  contentMd: string;
  tags: string[];
}

export interface UpdateNoteRequest {
  title?: string;
  contentMd?: string;
  visibility?: Visibility;
  tags?: string[];
}

export interface NoteSearchCriteria {
  query?: string;
  visibility?: Visibility;
  tag?: string;
  page?: number;
  size?: number;
  sortBy?: string;
  sortDirection?: string;
}