import { Controller, Get } from '@nestjs/common';
import type { DecodedIdToken } from 'firebase-admin/auth';
import { FirebaseUser } from './decorators/firebase-user.decorator.js';

@Controller('auth')
export class AuthController {
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
}
