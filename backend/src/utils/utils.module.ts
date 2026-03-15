// src/utils/utils.module.ts

import { Module } from '@nestjs/common';
import { StringUtilsService } from './string-utils.service';

@Module({
  providers: [StringUtilsService],
  exports: [StringUtilsService],
})
export class UtilsModule {}
