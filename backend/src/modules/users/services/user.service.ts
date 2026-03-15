import { PrismaService } from '@/prisma/prisma.service';
import { FindAllUsersDto } from '../dto/';
import { Injectable, Logger } from '@nestjs/common';

@Injectable()
export class UserService {
  private readonly logger = new Logger(UserService.name);

  constructor(private prisma: PrismaService) { }

  /**
   * Retrieves a paginated list of users with optional searching.
   */
  async findAll(findAllUsersDto: FindAllUsersDto) {
    const { page = 1, limit = 10, search } = findAllUsersDto;
    const skip = (page - 1) * limit;

    const whereClause = search
      ? {
        OR: [
          { name: { contains: search, mode: 'insensitive' } },
          { email: { contains: search, mode: 'insensitive' } },
          { username: { contains: search, mode: 'insensitive' } },
        ],
      }
      : {};

    const [users, total] = await Promise.all([
      this.prisma.user.findMany({
        where: whereClause as any,
        select: {
          id: true,
          name: true,
          email: true,
          role: true,
          photo: true,
          createdAt: true,
          isActive: true,
        },
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.user.count({ where: whereClause as any }),
    ]);

    return {
      users,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  /**
   * Finds a user by ID.
   */
  async findById(id: string) {
    return this.prisma.user.findUnique({
      where: { id },
    });
  }

  /**
   * Finds a user by email.
   */
  async findByEmail(email: string) {
    return this.prisma.user.findUnique({
      where: { email },
    });
  }
}
