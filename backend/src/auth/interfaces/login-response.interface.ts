// src/auth/interfaces/login-response.interface.ts
import { AuthTokens } from '@/auth/interfaces/auth-tokens.interface';

export interface LoginResponse {
  user: {
    id: string;
    email: string;
    name: string;
    role: string;
    photo?: string;
    isActive?: boolean;
  };
  tokens: AuthTokens;
}
