import { createParamDecorator, type ExecutionContext } from '@nestjs/common';
import type { DecodedIdToken } from 'firebase-admin/auth';

export const FirebaseUser = createParamDecorator(
  (_data: unknown, ctx: ExecutionContext): DecodedIdToken => {
    const req = ctx.switchToHttp().getRequest<{ firebaseUser: DecodedIdToken }>();
    return req.firebaseUser;
  },
);
