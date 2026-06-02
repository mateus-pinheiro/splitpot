import { BadRequestException, Controller, Get, Query } from '@nestjs/common';
import type { DecodedIdToken } from 'firebase-admin/auth';
import { AuthService } from './auth.service.js';
import { FirebaseUser } from './decorators/firebase-user.decorator.js';
import { Public } from './decorators/public.decorator.js';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Get('me')
  me(@FirebaseUser() user: DecodedIdToken): {
    uid: string;
    email: string | undefined;
    name: string | undefined;
  } {
    return {
      uid: user.uid,
      email: user.email,
      name: user.name as string | undefined,
    };
  }

  /**
   * Lookup público dos providers de um email. O app usa isso no login para
   * decidir o destino (Google/Apple/senha/cadastro) sem depender do
   * `createAuthUri`, que mente quando a Email Enumeration Protection está
   * ligada. Fonte de verdade: Firebase Admin (ver `lookupProviders`).
   */
  @Public()
  @Get('providers')
  providers(
    @Query('email') email?: string,
  ): Promise<{ registered: boolean; providers: string[] }> {
    const normalized = email?.trim().toLowerCase();
    if (!normalized) {
      throw new BadRequestException('Parâmetro "email" é obrigatório');
    }
    return this.authService.lookupProviders(normalized);
  }
}
