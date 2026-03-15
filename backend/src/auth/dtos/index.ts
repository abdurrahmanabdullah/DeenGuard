import { ApiProperty } from '@nestjs/swagger';
import {
  IsEmail,
  IsNotEmpty,
  IsString,
  MinLength,
} from 'class-validator';
import { Transform } from 'class-transformer';
import { Match } from '../../common/decorators/match.decorator';

/**
 * Data Transfer Object for user login.
 */
export class LoginDto {
  @ApiProperty({
    example: 'user@example.com',
    description: 'The email address of the user.',
  })
  @Transform(({ value }) => value?.trim().toLowerCase()) // Sanitize input
  @IsNotEmpty({ message: 'Email is required.' })
  @IsEmail({}, { message: 'Please provide a valid email address.' })
  email: string;

  @ApiProperty({
    example: 'password123',
    description: 'The user password.',
  })
  @IsNotEmpty({ message: 'Password is required.' })
  @IsString()
  password: string;
}

/**
 * Data Transfer Object for user registration.
 */
export class RegisterDto {
  @ApiProperty({
    example: 'John Doe',
    description: 'The full name of the user.',
  })
  @IsNotEmpty({ message: 'Name is required.' })
  @IsString()
  name: string;

  @ApiProperty({
    example: 'john.doe@example.com',
    description: 'The email address for the new account.',
  })
  @Transform(({ value }) => value?.trim().toLowerCase()) // Sanitize input
  @IsNotEmpty({ message: 'Email is required.' })
  @IsEmail({}, { message: 'Please provide a valid email address.' })
  email: string;

  @ApiProperty({
    example: 'password123',
    description: 'Password must be at least 6 characters long.',
  })
  @IsNotEmpty({ message: 'Password is required.' })
  @IsString()
  @MinLength(6, { message: 'Password must be at least 6 characters long.' })
  password: string;

  @ApiProperty({
    example: 'password123',
    description: 'Must match the password field.',
  })
  @IsString()
  @IsNotEmpty({ message: 'Password confirmation is required.' })
  @Match('password', { message: 'Passwords do not match.' })
  passwordConfirmation: string;
}
