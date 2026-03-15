import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

interface MailConfig {
  mailer: string;
  host: string;
  port: number;
  username: string;
  password: string;
  encryption: string;
  fromAddress: string;
  fromName: string;
}

@Injectable()
export class AppConfigService {
  constructor(private configService: ConfigService) {}

  get isProduction(): boolean {
    return this.configService.get<string>('NODE_ENV') === 'production';
  }

  get mail(): MailConfig {
    return {
      mailer: this.configService.get<string>('MAIL_MAILER') || 'smtp',
      host: this.configService.get<string>('MAIL_HOST') || '',
      port: this.configService.get<number>('MAIL_PORT') || 587,
      username: this.configService.get<string>('MAIL_USERNAME') || '',
      password: this.configService.get<string>('MAIL_PASSWORD') || '',
      encryption: this.configService.get<string>('MAIL_ENCRYPTION') || 'tls',
      fromAddress: this.configService.get<string>('MAIL_FROM_ADDRESS') || '',
      fromName: this.configService.get<string>('MAIL_FROM_NAME') || 'KTTravel',
    };
  }

  get jwt() {
    return {
      secret: this.configService.get<string>('JWT_SECRET') || '',
      refreshSecret: this.configService.get<string>('JWT_REFRESH_SECRET') || '',
      expiration: this.configService.get<string>('JWT_EXPIRATION') || '1d',
      refreshExpiration: this.configService.get<string>('JWT_REFRESH_EXPIRATION') || '7d',
    };
  }
}
