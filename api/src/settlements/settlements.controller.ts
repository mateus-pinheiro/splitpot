import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  Patch,
  Post,
  Query,
} from '@nestjs/common';
import type { DecodedIdToken } from 'firebase-admin/auth';
import { FirebaseUser } from '../auth/decorators/firebase-user.decorator.js';
import { UpdateSettlementPixDto } from './dto/update-settlement-pix.dto.js';
import { SettlementsService } from './settlements.service.js';

@Controller('settlements')
export class SettlementsController {
  constructor(private readonly settlements: SettlementsService) {}

  @Get()
  list(
    @FirebaseUser() token: DecodedIdToken,
    @Query('tableId') tableId?: string,
  ) {
    return this.settlements.list(token.uid, tableId);
  }

  @Post(':id/confirm')
  @HttpCode(HttpStatus.OK)
  confirm(@FirebaseUser() token: DecodedIdToken, @Param('id') id: string) {
    return this.settlements.confirm(token.uid, id);
  }

  @Post(':id/confirm-on-behalf')
  @HttpCode(HttpStatus.OK)
  confirmOnBehalf(
    @FirebaseUser() token: DecodedIdToken,
    @Param('id') id: string,
  ) {
    return this.settlements.confirmOnBehalf(token.uid, id);
  }

  @Patch(':id/pix')
  setPix(
    @FirebaseUser() token: DecodedIdToken,
    @Param('id') id: string,
    @Body() dto: UpdateSettlementPixDto,
  ) {
    return this.settlements.setPix(token.uid, id, dto);
  }
}
