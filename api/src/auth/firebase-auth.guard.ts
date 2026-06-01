import {
  Injectable,
  UnauthorizedException,
  type CanActivate,
  type ExecutionContext,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import type { Request } from 'express';
import type { DecodedIdToken } from 'firebase-admin/auth';
import { AuthService } from './auth.service.js';
import { IS_PUBLIC_KEY } from './decorators/public.decorator.js';

type AuthedRequest = Request & { firebaseUser?: DecodedIdToken };

@Injectable()
export class FirebaseAuthGuard implements CanActivate {
  constructor(
    private readonly reflector: Reflector,
    private readonly authService: AuthService,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (isPublic) return true;

    const req = context.switchToHttp().getRequest<AuthedRequest>();
    const header = req.headers.authorization;
    if (!header?.startsWith('Bearer ')) {
      throw new UnauthorizedException(
        'Authorization header ausente ou inválido',
      );
    }
    const idToken = header.slice('Bearer '.length).trim();
    if (!idToken) {
      throw new UnauthorizedException('Token vazio');
    }

    req.firebaseUser = await this.authService.verifyIdToken(idToken);
    return true;
  }
}
