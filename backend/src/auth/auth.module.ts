// src/auth/auth.module.ts
import { AuthController } from '@/auth/auth.controller';
import { AuthService } from '@/auth/auth.service';
import { JwtStrategy } from '@/auth/strategies/jwt.strategy';
import { AppConfigModule } from '@/config/app-config.module';
import { PrismaModule } from '@/prisma/prisma.module';
import { UserModule } from '@/modules/users/user.module';
import { UserService } from '@/modules/users/services/user.service';
import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { JwtModule, JwtService } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { StringUtilsService } from '../utils/string-utils.service';

@Module({
  imports: [
    PassportModule.register({ defaultStrategy: 'jwt' }),
    JwtModule.registerAsync({
      imports: [ConfigModule],
      useFactory: async (configService: ConfigService) => {
        const secret = configService.get('JWT_SECRET');
        if (!secret) {
          throw new Error('JWT_SECRET must be defined');
        }
        return {
          secret,
          signOptions: { expiresIn: '1d' },
        };
      },
      inject: [ConfigService],
    }),
    PrismaModule,
    AppConfigModule,
    UserModule,
  ],
  controllers: [AuthController],
  providers: [
    AuthService,
    JwtStrategy,
    StringUtilsService,
  ],
  exports: [AuthService, JwtModule],
})
export class AuthModule { }
