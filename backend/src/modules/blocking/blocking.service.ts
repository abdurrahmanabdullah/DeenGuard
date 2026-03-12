import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../database/prisma/prisma.service';

@Injectable()
export class BlockingService {
  constructor(private prisma: PrismaService) {}

  async getDomains(userId?: string) {
    return this.prisma.blockedDomain.findMany({
      where: userId ? { OR: [{ userId }, { isDefault: true }] } : { isDefault: true },
      orderBy: { domain: 'asc' },
    });
  }

  async addDomain(domain: string, category: string, userId?: string) {
    return this.prisma.blockedDomain.create({
      data: { domain, category, userId, isDefault: false },
    });
  }

  async removeDomain(id: string) {
    return this.prisma.blockedDomain.delete({ where: { id } });
  }

  async getApps() {
    return this.prisma.blockedApp.findMany({ where: { isActive: true } });
  }

  async addApp(packageName: string, appName: string, category: string) {
    return this.prisma.blockedApp.create({
      data: { packageName, appName, category, isDefault: false },
    });
  }
}
