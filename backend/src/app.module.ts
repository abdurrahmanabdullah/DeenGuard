import { Module } from '@nestjs/common';
import { PrismaModule } from './database/prisma/prisma.module';
import { AuthModule } from './modules/auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { BlockingModule } from './modules/blocking/blocking.module';
import { DashboardModule } from './modules/dashboard/dashboard.module';
import { SubscriptionsModule } from './modules/subscriptions/subscriptions.module';
import { AnalyticsModule } from './modules/analytics/analytics.module';

@Module({
  imports: [
    PrismaModule,
    AuthModule,
    UsersModule,
    BlockingModule,
    DashboardModule,
    SubscriptionsModule,
    AnalyticsModule,
  ],
})
export class AppModule {}
