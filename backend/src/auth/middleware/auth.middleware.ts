// src/auth/middleware/auth.middleware.ts
import { UserService } from '@/modules/users/services/user.service';
import {
  Injectable,
  NestMiddleware,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { NextFunction, Request, Response } from 'express';

@Injectable()
export class AuthMiddleware implements NestMiddleware {
  constructor(
    private readonly jwtService: JwtService,
    private readonly userService: UserService,
  ) {}

  async use(req: Request, res: Response, next: NextFunction) {
    const authHeader = req.headers.authorization;
    if (!authHeader) {
      next();
      return;
    }

    try {
      const token = authHeader.split(' ')[1];
      const payload = this.jwtService.verify(token);

      const user = await this.userService.findById(payload.sub);

      if (!user) {
        throw new UnauthorizedException('User not found');
      }

      req['user'] = user;
      next();
    } catch (error) {
      next();
    }
  }
}
