// src/user/services/user-registration.service.ts
import { PrismaService } from '@/prisma/prisma.service';
import { User } from '../interfaces/user.interface';
import { StringUtilsService } from '@/utils/string-utils.service';
import { faker } from '@faker-js/faker';
import { ConflictException, Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaClientKnownRequestError } from '@prisma/client/runtime/library';
import * as bcrypt from 'bcryptjs';
import { v4 as uuidv4 } from 'uuid';

interface RegisterUserData {
  name: string;
  email: string;
  password?: string;
  photo?: string;
  latitude?: number;
  longitude?: number;
  countryCode?: string;
  timezone?: string;
  ipAddress?: string;
  socialId?: string;
  token?: string;
}

@Injectable()
export class UserRegistrationService {
  private readonly logger = new Logger(UserRegistrationService.name);

  constructor(
    private prisma: PrismaService,
    private configService: ConfigService,
    protected readonly stringUtilsService: StringUtilsService,
    // private readonly giteaService: GiteaService,
  ) { }

  async registerUser(
    data: RegisterUserData,
    provider: 'form' | 'google' = 'form', // only used by form
  ): Promise<User> {
    try {
      const nameParts = data.name.split(' ');
      const firstName = this.stringUtilsService.toTitleCase(nameParts[0]);
      const lastName =
        nameParts.length > 1
          ? this.stringUtilsService.toTitleCase(nameParts.slice(1).join(' '))
          : '';
      const username = await this.generateUniqueUsername(firstName + lastName);

      const isFirstUserAdmin = (await this.prisma.user.count()) === 0;

      const hashedPassword = data.password
        ? await bcrypt.hash(data.password, 10)
        : await bcrypt.hash(this.generateRandomPassword(), 10);

      const gitUsername = `${username}`; //_${Math.random().toString(36).slice(2, 10)}
      const gitPassword = `git_${Math.random().toString(36).slice(2, 10)}`;

      // Create or get user and their credentials
      // const userGitData = await this.giteaService.createUser(
      //   gitUsername,
      //   data.email,
      //   gitPassword,
      // );

      const userData = {
        // gitUsername: userGitData.username, // Gitea API might return either
        // gitDeployPassword: userGitData.password, // Use the password we generated
        accountProvider: provider,
        name: data.name,
        firstName: firstName || '', // Ensure these have default values
        lastName: lastName || '', // Ensure these have default values
        username,
        email: data.email,
        password: hashedPassword,
        role: isFirstUserAdmin ? 'admin' : 'user',
        photo: data.photo || faker.image.avatar(), // Updated faker call
        latitude: data.latitude || Number(faker.location.latitude()), // Fixed type casting
        longitude: data.longitude || Number(faker.location.longitude()), // Fixed type casting
        countryCode: data.countryCode || faker.location.countryCode(),
        timezone: data.timezone || 'UTC',
      };

      // Add social login data if provided
      if (provider !== 'form') {
        Object.assign(userData, {
          socialId: data.socialId,
          [`${provider}Id`]: data.socialId,
          [`${provider}Token`]: data.token,
        });
      }

      // Add IP data if provided
      if (data.ipAddress) {
        Object.assign(userData, {
          signInIpAddress: data.ipAddress,
          ipAddress: data.ipAddress,
          ipHost: await this.getHostByAddr(data.ipAddress),
        });
      }

      const createdUser = await this.prisma.user.create({
        data: userData,
        select: {
          id: true,
          name: true,
          firstName: true,
          lastName: true,
          username: true,
          email: true,
          role: true,
          photo: true,
          createdAt: true,
          updatedAt: true,
          latitude: true,
          longitude: true,
          countryCode: true,
          language: true,
          timezone: true,
          accountProvider: true,
          socialId: true,
          googleId: true,
          googleToken: true,
          signInIpAddress: true,
          ipAddress: true,
          ipHost: true,
          deletedAt: true,
        },
      });

      // Transform the created user to ensure all required fields have values
      return {
        ...createdUser,
        firstName: createdUser.firstName || '',
        lastName: createdUser.lastName || '',
        photo: createdUser.photo || null,
      } as User;
    } catch (error) {
      this.logger.error('Error creating user:', error);
      if (
        error instanceof PrismaClientKnownRequestError &&
        error.code === 'P2002' // Unique constraint violation
      ) {
        throw new ConflictException('Email already exists');
      }
      throw error; // Re-throw other unexpected errors
    }
  }

  private async generateUniqueUsername(baseUsername: string): Promise<string> {
    const username = this.stringUtilsService.toKebabCase(baseUsername);
    let count = 0;
    let exists = true;

    while (exists) {
      const finalUsername = count === 0 ? username : `${username}${count}`;
      exists =
        (await this.prisma.user.findUnique({
          where: { username: finalUsername },
        })) !== null;

      if (exists) count++;
    }

    return count === 0 ? username : `${username}${count}`;
  }

  private generateRandomPassword(): string {
    return uuidv4();
  }

  private async getHostByAddr(ip: string): Promise<string> {
    try {
      // You might want to use a DNS library here
      // For now, returning the IP as a placeholder
      return ip;
    } catch (error) {
      return ip;
    }
  }
}
