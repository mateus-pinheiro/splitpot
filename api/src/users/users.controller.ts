import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Patch,
  Post,
  Query,
} from '@nestjs/common';
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

  @Get('me/stats')
  async stats(@FirebaseUser() token: DecodedIdToken) {
    return this.users.getStats(token.uid);
  }

  /// Busca usuários cadastrados pra adicionar como participante. Retorna no
  /// máximo 10 resultados, ordenados por nome. Não expõe PIX (host só precisa
  /// do id pra `join`; backend resolve o resto). Query vazia retorna lista
  /// vazia em vez de tudo — evita scan acidental.
  @Get('search')
  async search(
    @FirebaseUser() token: DecodedIdToken,
    @Query('q') q?: string,
  ) {
    await this.users.requireByFirebaseUid(token.uid);
    return this.users.search(q ?? '');
  }

  @Patch('me')
  async update(
    @FirebaseUser() token: DecodedIdToken,
    @Body() dto: UpdateUserDto,
  ) {
    return this.users.update(token.uid, dto);
  }
}
