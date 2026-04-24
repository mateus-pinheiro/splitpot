import {
  Body,
  Controller,
  Delete,
  HttpCode,
  HttpStatus,
  Param,
  Post,
  Put,
} from '@nestjs/common';
import type { DecodedIdToken } from 'firebase-admin/auth';
import { FirebaseUser } from '../auth/decorators/firebase-user.decorator.js';
import { AddBuyInDto } from './dto/add-buy-in.dto.js';
import { CreateParticipationDto } from './dto/create-participation.dto.js';
import { SetCashOutDto } from './dto/set-cash-out.dto.js';
import { ParticipationsService } from './participations.service.js';

@Controller('participations')
export class ParticipationsController {
  constructor(private readonly participations: ParticipationsService) {}

  @Post()
  join(@FirebaseUser() token: DecodedIdToken, @Body() dto: CreateParticipationDto) {
    return this.participations.join(token.uid, dto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  leave(@FirebaseUser() token: DecodedIdToken, @Param('id') id: string) {
    return this.participations.leave(token.uid, id);
  }

  @Post(':id/buy-ins')
  addBuyIn(
    @FirebaseUser() token: DecodedIdToken,
    @Param('id') id: string,
    @Body() dto: AddBuyInDto,
  ) {
    return this.participations.addBuyIn(token.uid, id, dto);
  }

  @Delete(':id/buy-ins/:buyInId')
  @HttpCode(HttpStatus.NO_CONTENT)
  async removeBuyIn(
    @FirebaseUser() token: DecodedIdToken,
    @Param('id') id: string,
    @Param('buyInId') buyInId: string,
  ) {
    await this.participations.removeBuyIn(token.uid, id, buyInId);
  }

  @Put(':id/cash-out')
  setCashOut(
    @FirebaseUser() token: DecodedIdToken,
    @Param('id') id: string,
    @Body() dto: SetCashOutDto,
  ) {
    return this.participations.setCashOut(token.uid, id, dto);
  }
}
