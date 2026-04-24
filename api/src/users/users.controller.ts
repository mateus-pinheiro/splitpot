import { Body, Controller, Get, HttpCode, HttpStatus, Patch, Post } from '@nestjs/common';
import type { DecodedIdToken } from 'firebase-admin/auth';
import { FirebaseUser } from '../auth/decorators/firebase-user.decorator.js';
import { ProvisionUserDto } from './dto/provision-user.dto.js';
import { UpdateUserDto } from './dto/update-user.dto.js';
import { UsersService } from './users.service.js';

@Controller('users')
export class UsersController {
  constructor(private readonly users: UsersService) {}

  @Post('me')
  @HttpCode(HttpStatus.OK)
  async provision(
    @FirebaseUser() token: DecodedIdToken,
    @Body() dto: ProvisionUserDto,
  ) {
    const user = await this.users.provision(token.uid, token.email, dto);
    return user;
  }

  @Get('me')
  async me(@FirebaseUser() token: DecodedIdToken) {
    return this.users.requireByFirebaseUid(token.uid);
  }

  @Patch('me')
  async update(
    @FirebaseUser() token: DecodedIdToken,
    @Body() dto: UpdateUserDto,
  ) {
    return this.users.update(token.uid, dto);
  }
}
