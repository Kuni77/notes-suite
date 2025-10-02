export interface ApiResponse<T> {
  status: number;
  data?: T;
  message?: string;
  errors?: any;
  metadata?: PageMetadata;
}

export interface PageMetadata {
  size: number;
  totalElements: number;
  totalPages: number;
  number: number;
}