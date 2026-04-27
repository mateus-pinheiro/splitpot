import { Module } from '@nestjs/common';
import { TablesModule } from '../tables/tables.module.js';
import { UsersModule } from '../users/users.module.js';
import { ParticipationsController } from './participations.controller.js';
import { ParticipationsService } from './participations.service.js';

@Module({
  imports: [UsersModule, TablesModule],
  controllers: [ParticipationsController],
  providers: [ParticipationsService],
  exports: [ParticipationsService],
})
export class ParticipationsModule {}
