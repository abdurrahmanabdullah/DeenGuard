// src/user/user.module.ts
import { PrismaModule } from '@/prisma/prisma.module';
import { UserRegistrationService } from './services/user-registration.service';
import { UserController } from './user.controller';
import { UserService } from './services/user.service';
import { Module } from '@nestjs/common';
// import { GiteaModule } from '../git/gitea.module';
import { StringUtilsService } from '@/utils/string-utils.service';
import { UtilsModule } from '@/utils/utils.module';

@Module({
  imports: [PrismaModule, UtilsModule],
  controllers: [UserController],
  providers: [UserService, UserRegistrationService, StringUtilsService],
  exports: [UserService, UserRegistrationService],
})
export class UserModule {}
