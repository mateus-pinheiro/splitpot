import { Module } from '@nestjs/common';
import { APP_GUARD } from '@nestjs/core';
import { AuthController } from './auth.controller.js';
import { AuthService } from './auth.service.js';
import { FirebaseAuthGuard } from './firebase-auth.guard.js';

@Module({
  controllers: [AuthController],
  providers: [
    AuthService,
    FirebaseAuthGuard,
    { provide: APP_GUARD, useClass: FirebaseAuthGuard },
  ],
  exports: [AuthService],
})
export class AuthModule {}
