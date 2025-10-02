export interface RegisterRequest {
  email: string;
  password: string;
}

export interface LoginRequest {
  email: string;
  password: string;
}

export interface AuthResponse {
  accessToken: string;
  refreshToken: string;
  tokenType: string;
  email: string;
}

export interface RefreshTokenRequest {
  refreshToken: string;
}

export interface User {
  email: string;
}