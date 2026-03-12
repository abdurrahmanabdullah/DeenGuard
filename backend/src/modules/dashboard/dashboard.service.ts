import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../database/prisma/prisma.service';

@Injectable()
export class DashboardService {
  constructor(private prisma: PrismaService) {}

  async getStats(userId?: string) {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const [domainsCount, appsCount, blocksToday] = await Promise.all([
      this.prisma.blockedDomain.count({ where: { OR: [{ userId }, { isDefault: true }] } }),
      this.prisma.blockedApp.count({ where: { isActive: true } }),
      this.prisma.blockLog.count({
        where: { userId, timestamp: { gte: today } },
      }),
    ]);

    return {
      blockedDomainsCount: domainsCount,
      blockedAppsCount: appsCount,
      blocksToday,
      isProtectionActive: true,
    };
  }
}
