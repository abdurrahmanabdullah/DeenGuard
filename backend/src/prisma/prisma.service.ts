import {
  INestApplication,
  Injectable,
  OnModuleDestroy,
  OnModuleInit,
} from '@nestjs/common';
import { Prisma, PrismaClient } from '@prisma/client';

@Injectable()
export class PrismaService
  extends PrismaClient
  implements OnModuleInit, OnModuleDestroy {
  private isShutdownHandlerRegistered = false;

  constructor() {
    super({
      log: ['error', 'warn'],
      datasources: {
        db: {
          url: process.env.DATABASE_URL,
        },
      },
    });
  }

  async onModuleInit() {
    await this.$connect();
  }

  async onModuleDestroy() {
    await this.$disconnect();
  }

  async enableShutdownHooks(app: INestApplication) {
    if (this.isShutdownHandlerRegistered) return;

    const signals = ['SIGINT', 'SIGTERM', 'SIGUSR2'] as const;
    for (const signal of signals) {
      process.on(signal, async () => {
        await this.$disconnect();
        await app.close();
        process.exit(0);
      });
    }

    this.isShutdownHandlerRegistered = true;
  }

  async cleanDatabase() {
    if (process.env.NODE_ENV === 'production') return;

    try {
      const modelNames = Reflect.ownKeys(PrismaClient.prototype).filter(
        (key) => {
          return (
            typeof key === 'string' &&
            !key.startsWith('$') &&
            !['_', 'constructor'].includes(key) &&
            typeof (this as any)[key] === 'object' &&
            (this as any)[key] !== null &&
            'deleteMany' in (this as any)[key]
          );
        },
      );

      return Promise.all(
        modelNames.map((modelName) => (this as any)[modelName as string].deleteMany()),
      );
    } catch (error) {
      console.error('Error cleaning database:', error);
      throw error;
    }
  }
}
