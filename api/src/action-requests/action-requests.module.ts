import { Module } from '@nestjs/common';
import { ParticipationsModule } from '../participations/participations.module.js';
import { UsersModule } from '../users/users.module.js';
import { ActionRequestsController } from './action-requests.controller.js';
import { ActionRequestsService } from './action-requests.service.js';

@Module({
  imports: [UsersModule, ParticipationsModule],
  controllers: [ActionRequestsController],
  providers: [ActionRequestsService],
})
export class ActionRequestsModule {}
