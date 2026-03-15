import {
  BadRequestException,
  Injectable,
  Logger,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcryptjs';
import { UserRegistrationService } from '@/modules/users/services/user-registration.service';
import { LoginDto, RegisterDto } from './dtos';
import { LoginResponse } from './interfaces';
import { UserService } from '@/modules/users/services/user.service';

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);

  constructor(
    private readonly jwtService: JwtService,
    private readonly userRegistrationService: UserRegistrationService,
    private readonly userService: UserService,
  ) { }

  /**
   * Main login method following best practices.
   */
  async login(loginDto: LoginDto): Promise<LoginResponse> {
    const { email, password } = loginDto;
    this.logger.log(`Login attempt for email: ${email}`);

    const user = await this.userService.findByEmail(email);

    if (!user) {
      this.logger.warn(`Login failed: User with email ${email} not found.`);
      throw new UnauthorizedException('Invalid email or password');
    }

    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      this.logger.warn(`Login failed: Invalid password for email ${email}.`);
      throw new UnauthorizedException('Invalid email or password');
    }

    if (!user.isActive) {
      this.logger.warn(`Login failed: Account is inactive for email ${email}.`);
      throw new UnauthorizedException('Account is inactive. Please contact support.');
    }

    const tokens = await this.generateAuthTokens(user.id, user.email, user.role);

    this.logger.log(`User successfully logged in: ${email}`);

    return {
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        role: user.role,
        photo: user.photo,
        isActive: user.isActive,
      },
      tokens,
    };
  }

  /**
   * Registers a new user and automatically logs them in.
   */
  async register(registerDto: RegisterDto): Promise<LoginResponse> {
    this.logger.log(`Registering new user: ${registerDto.email}`);

    const user = await this.userRegistrationService.registerUser(
      {
        name: registerDto.name,
        email: registerDto.email,
        password: registerDto.password,
      },
      'form',
    );

    const tokens = await this.generateAuthTokens(
      user.id,
      user.email,
      user.role,
    );

    this.logger.log(`User registered and auto-logged in: ${user.email}`);

    return {
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        role: user.role,
        photo: user.photo,
        isActive: user.isActive,
      },
      tokens,
    };
  }

  /**
   * Generates Access and Refresh tokens.
   */
  async generateAuthTokens(userId: string, email: string, role: string) {
    const payload = { sub: userId, email, role };
    const [accessToken, refreshToken] = await Promise.all([
      this.jwtService.signAsync(payload, { expiresIn: '1d' }),
      this.jwtService.signAsync(payload, { expiresIn: '7d' }),
    ]);

    return { accessToken, refreshToken };
  }
}
