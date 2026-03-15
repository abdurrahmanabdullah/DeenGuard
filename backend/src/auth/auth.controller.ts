import {
  Body,
  Controller,
  HttpCode,
  HttpStatus,
  Logger,
  Post,
} from '@nestjs/common';
import {
  ApiBody,
  ApiOperation,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { Public } from './decorators/public.decorator';
import {
  LoginDto,
  RegisterDto,
} from './dtos';
import { LoginResponse } from './interfaces';

@ApiTags('Authentication') // Swagger Tag
@Controller('auth')
export class AuthController {
  private readonly logger = new Logger(AuthController.name);
  constructor(private readonly authService: AuthService) { }

  /**
   * Endpoint for user login.
   * Standard Practice: 
   * 200 OK for successful login (POST is often used for security).
   * 401 Unauthorized for invalid credentials.
   */
  @Public()
  @Post('login')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Authenticate user and return JWT tokens' })
  @ApiBody({ type: LoginDto })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'User successfully authenticated.',
    schema: {
      example: {
        user: {
          id: 'uuid-v4-string',
          email: 'user@example.com',
          name: 'John Doe',
          role: 'user',
          photo: null,
          isActive: true,
        },
        tokens: {
          accessToken: 'jwt.access.token',
          refreshToken: 'jwt.refresh.token',
        },
      },
    },
  })
  @ApiResponse({ status: HttpStatus.UNAUTHORIZED, description: 'Invalid email or password.' })
  @ApiResponse({ status: HttpStatus.BAD_REQUEST, description: 'Invalid input.' })
  async login(@Body() loginDto: LoginDto): Promise<LoginResponse> {
    return this.authService.login(loginDto);
  }

  /**
   * Endpoint for user registration with automatic login.
   * Returns user profile and authentication tokens.
   */
  @Public()
  @Post('register')
  @ApiOperation({ summary: 'Register a new user and return JWT tokens' })
  @ApiBody({ type: RegisterDto })
  @ApiResponse({
    status: HttpStatus.CREATED,
    description: 'User registered and authenticated successfully.',
    schema: {
      example: {
        user: {
          id: 'uuid-v4-string',
          email: 'user@example.com',
          name: 'John Doe',
          role: 'user',
          photo: 'https://example.com/photo.jpg',
          isActive: true,
        },
        tokens: {
          accessToken: 'jwt.access.token',
          refreshToken: 'jwt.refresh.token',
        },
      },
    }
  })
  async register(@Body() registerDto: RegisterDto): Promise<LoginResponse> {
    return this.authService.register(registerDto);
  }
}
