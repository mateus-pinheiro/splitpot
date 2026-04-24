import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import type { User } from '@prisma/client';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service.js';
import type { ProvisionUserDto } from './dto/provision-user.dto.js';
import type { UpdateUserDto } from './dto/update-user.dto.js';

@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

  async provision(
    firebaseUid: string,
    tokenEmail: string | undefined,
    dto: ProvisionUserDto,
  ): Promise<User> {
    const email = dto.email ?? tokenEmail;
    if (!email) {
      throw new ConflictException('Email ausente no token e no payload');
    }

    try {
      return await this.prisma.user.upsert({
        where: { firebaseUid },
        create: { firebaseUid, email, name: dto.name, pixKey: dto.pixKey },
        update: { email, name: dto.name, pixKey: dto.pixKey },
      });
    } catch (err) {
      if (err instanceof Prisma.PrismaClientKnownRequestError && err.code === 'P2002') {
        throw new ConflictException('Email já utilizado por outro usuário');
      }
      throw err;
    }
  }

  async requireByFirebaseUid(firebaseUid: string): Promise<User> {
    const user = await this.prisma.user.findUnique({ where: { firebaseUid } });
    if (!user) {
      throw new NotFoundException('Usuário ainda não provisionado: chame POST /users/me');
    }
    return user;
  }

  async update(firebaseUid: string, dto: UpdateUserDto): Promise<User> {
    const current = await this.requireByFirebaseUid(firebaseUid);
    return this.prisma.user.update({
      where: { id: current.id },
      data: { name: dto.name ?? current.name, pixKey: dto.pixKey ?? current.pixKey },
    });
  }
}
