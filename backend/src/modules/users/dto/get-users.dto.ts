import { ApiProperty } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import { IsNumber, IsOptional, IsString, Min } from 'class-validator';

export class FindAllUsersDto {
  @ApiProperty({
    description: 'Page number for pagination',
    example: 1,
    required: false,
  })
  @Transform(({ value }) => Number(value))
  @IsNumber()
  @Min(1)
  @IsOptional()
  page: number = 1;

  @ApiProperty({
    description: 'Number of users per page',
    example: 10,
    required: false,
  })
  @Transform(({ value }) => Number(value))
  @IsNumber()
  @Min(1)
  @IsOptional()
  limit: number = 10;

  @ApiProperty({
    description: 'Search query for filtering users',
    example: 'john',
    required: false,
  })
  @IsString()
  @IsOptional()
  search?: string;
}
