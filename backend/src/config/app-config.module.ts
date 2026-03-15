// src/config/app-config.module.ts
import { Global, Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AppConfigService } from './app-config.service';

@Global()
@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: getEnvPath(),
    }),
  ],
  providers: [AppConfigService],
  exports: [AppConfigService],
})
export class AppConfigModule {}

function getEnvPath(): string {
  switch (process.env.NODE_ENV) {
    case 'production':
      return '.env.production';
    case 'development':
      return '.env.development';
    default:
      return '.env.local';
  }
}
