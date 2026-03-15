// src/auth/interfaces/auth-response.interface.ts

export interface UserResponse {
  id: string;
  email: string;
  name: string;
  role: string;
  username: string;
  firstName: string; // Now required in the response
  lastName: string; // Now required in the response
  photo?: string; // Optional
  isActive?: boolean;
}

export interface AuthResponse {
  user: UserResponse;
  tokens: {
    accessToken: string;
    refreshToken: string;
  };
}
