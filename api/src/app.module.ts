import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { PrismaModule } from './prisma/prisma.module.js';
import { AuthModule } from './auth/auth.module.js';
import { UsersModule } from './users/users.module.js';
import { TablesModule } from './tables/tables.module.js';
import { ParticipationsModule } from './participations/participations.module.js';
import { SettlementsModule } from './settlements/settlements.module.js';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    PrismaModule,
    AuthModule,
    UsersModule,
    TablesModule,
    ParticipationsModule,
    SettlementsModule,
  ],
})
export class AppModule {}
