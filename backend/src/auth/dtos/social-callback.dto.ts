// src/auth/dto/social-callback.dto.ts
import { IsIn, IsObject } from 'class-validator';
import { SocialProvider } from '../interfaces/social-user.interface';

export class SocialCallbackDto {
  @IsIn(['google'])
  provider: SocialProvider;

  @IsObject()
  profile: {
    id?: string;
    sub?: string;
    email: string;
    name?: string;
    given_name?: string;
    family_name?: string;
    avatar_url?: string;
    picture?: string;
  };

  @IsObject()
  tokens: {
    access_token: string;
    token_type?: string;
  };
}
