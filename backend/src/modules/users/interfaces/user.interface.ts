// src/user/interfaces/user.interface.ts
export interface User {
  id: string;
  name: string;
  firstName?: string;
  lastName?: string;
  username: string;
  email: string;
  password?: string;
  role: string;
  photo?: string;
  isActive: boolean;
  latitude?: number;
  longitude?: number;
  countryCode?: string;
  language?: string;
  timezone?: string;
  accountProvider?: string;
  socialId?: string;
  googleId?: string;
  googleToken?: string;
  signInIpAddress?: string;
  ipAddress?: string;
  ipHost?: string;
  createdAt: Date;
  updatedAt: Date;
  deletedAt?: Date;
}
