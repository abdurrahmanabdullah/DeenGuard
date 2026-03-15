// src/app.module.ts
import { Module, MiddlewareConsumer, NestModule } from '@nestjs/common';
import { APP_GUARD } from '@nestjs/core';

// Core and Existing Modules
import { PrismaModule } from '@/prisma/prisma.module';

// New Feature Modules
import { AuthModule } from '@/auth/auth.module';
import { UserModule } from '@/modules/users/user.module';

// Authentication
import { JwtAuthGuard } from '@/auth/guards/jwt-auth.guard';
import { AuthMiddleware } from '@/auth/middleware/auth.middleware';
import { AppConfigService } from '@/config/app-config.service';
import { AppConfigModule } from '@/config/app-config.module';
import { ProductsModule } from './modules/products/products.module';
import { MailModule } from './modules/mail/mail.module';
import { ReportsModule } from './modules/reports/reports.module';
@Module({
  imports: [
    // Core modules first
    AppConfigModule,
    PrismaModule,

    // Feature modules
    AuthModule,
    UserModule,
    ProductsModule,
    MailModule,
    ReportsModule,
  ],
  providers: [
    {
      provide: APP_GUARD,
      useClass: JwtAuthGuard,
    },
    AppConfigService,
  ],
  exports: [],
})
export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    consumer.apply(AuthMiddleware).forRoutes('*');
  }
}
