import { Roles } from '@/auth/decorators/roles.decorator';
import { Role } from '@/auth/enums/role.enum';
import { JwtAuthGuard } from '@/auth/guards/jwt-auth.guard';
import { RolesGuard } from '@/auth/guards/roles.guard';
import { FindAllUsersDto } from './dto';
import { UserService } from './services/user.service';
import {
  Controller,
  Get,
  Query,
  UseGuards,
  ValidationPipe,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';

@ApiTags('Users')
@ApiBearerAuth()
@Controller('users')
@UseGuards(JwtAuthGuard, RolesGuard)
export class UserController {
  constructor(private readonly userService: UserService) { }

  @Get()
  @Roles(Role.ADMIN, Role.USER)
  @ApiOperation({
    summary: 'Retrieve a list of users with pagination and search',
  })
  @ApiResponse({
    status: 200,
    description: 'List of users with metadata',
    schema: {
      example: {
        users: [
          {
            id: '1',
            name: 'John Doe',
            email: 'john@example.com',
            role: 'USER',
            photo: null,
            emailVerified: true,
            createdAt: '2023-12-01T10:00:00Z',
            firstName: 'John',
            lastName: 'Doe',
            countryCode: 'US',
            language: 'en',
            timezone: 'America/New_York',
          },
        ],
        meta: {
          total: 100,
          page: 1,
          limit: 10,
          totalPages: 10,
        },
      },
    },
  })
  async findAll(@Query(ValidationPipe) query: FindAllUsersDto) {
    return this.userService.findAll(query);
  }
}
