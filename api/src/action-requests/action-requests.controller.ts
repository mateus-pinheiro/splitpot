import { Body, Controller, HttpCode, HttpStatus, Param, Post } from '@nestjs/common';
import type { DecodedIdToken } from 'firebase-admin/auth';
import { FirebaseUser } from '../auth/decorators/firebase-user.decorator.js';
import { ActionRequestsService } from './action-requests.service.js';
import { CreateActionRequestDto } from './dto/create-action-request.dto.js';

@Controller('action-requests')
export class ActionRequestsController {
  constructor(private readonly service: ActionRequestsService) {}

  @Post()
  create(
    @FirebaseUser() token: DecodedIdToken,
    @Body() dto: CreateActionRequestDto,
  ) {
    return this.service.create(token.uid, dto);
  }

  @Post(':id/approve')
  @HttpCode(HttpStatus.OK)
  approve(@FirebaseUser() token: DecodedIdToken, @Param('id') id: string) {
    return this.service.approve(token.uid, id);
  }

  @Post(':id/reject')
  @HttpCode(HttpStatus.OK)
  reject(@FirebaseUser() token: DecodedIdToken, @Param('id') id: string) {
    return this.service.reject(token.uid, id);
  }
}
