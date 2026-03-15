import { IsNotEmpty, IsString, IsOptional } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateProductDto {
  @ApiProperty({ example: 'Wireless Headphones' })
  @IsNotEmpty()
  @IsString()
  name: string;

  @ApiProperty({ example: 'High-quality noise-canceling headphones.' })
  @IsOptional()
  @IsString()
  details?: string;
}
