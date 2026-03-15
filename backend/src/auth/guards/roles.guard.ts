import { Injectable, CanActivate, ExecutionContext, Logger } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { ROLES_KEY } from '@/auth/decorators/roles.decorator';
import { Role } from '@/auth/enums/role.enum';

@Injectable()
export class RolesGuard implements CanActivate {
  private readonly logger = new Logger(RolesGuard.name);
  constructor(private reflector: Reflector) { }

  canActivate(context: ExecutionContext): boolean {
    const requiredRoles = this.reflector.getAllAndOverride<Role[]>(ROLES_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);

    if (!requiredRoles) {
      return true;
    }

    const { user } = context.switchToHttp().getRequest();

    if (!user) {
      this.logger.error('No user found in request. Ensure JwtAuthGuard is applied before RolesGuard.');
      return false;
    }

    this.logger.debug(`Required Roles: ${requiredRoles.join(', ')}`);
    this.logger.debug(`User Role: ${user.role}`);

    const hasRole = requiredRoles.some((role) => user.role === role);

    if (!hasRole) {
      this.logger.warn(`User with role ${user.role} attempted to access resource requiring ${requiredRoles.join(', ')}`);
    }

    return hasRole;
  }
}
