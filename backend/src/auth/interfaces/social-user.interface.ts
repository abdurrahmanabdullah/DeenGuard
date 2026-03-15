// src/auth/interfaces/social-user.interface.ts

export type SocialProvider = 'google';

export interface SocialUser {
  id: string | number; // Allow both string and number
  name: string;
  email: string;
  photo?: string;
  accessToken: string;
  provider: SocialProvider;
}
