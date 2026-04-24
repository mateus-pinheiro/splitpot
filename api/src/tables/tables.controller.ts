import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  Patch,
  Post,
} from '@nestjs/common';
import type { DecodedIdToken } from 'firebase-admin/auth';
import { FirebaseUser } from '../auth/decorators/firebase-user.decorator.js';
import { CreateTableDto } from './dto/create-table.dto.js';
import { UpdateTableDto } from './dto/update-table.dto.js';
import { TablesService } from './tables.service.js';

@Controller('tables')
export class TablesController {
  constructor(private readonly tables: TablesService) {}

  @Post()
  create(@FirebaseUser() token: DecodedIdToken, @Body() dto: CreateTableDto) {
    return this.tables.create(token.uid, dto);
  }

  @Get()
  list(@FirebaseUser() token: DecodedIdToken) {
    return this.tables.listForUser(token.uid);
  }

  @Get(':id')
  getById(@FirebaseUser() token: DecodedIdToken, @Param('id') id: string) {
    return this.tables.getById(token.uid, id);
  }

  @Patch(':id')
  update(
    @FirebaseUser() token: DecodedIdToken,
    @Param('id') id: string,
    @Body() dto: UpdateTableDto,
  ) {
    return this.tables.update(token.uid, id, dto);
  }

  @Post(':id/close')
  @HttpCode(HttpStatus.OK)
  close(@FirebaseUser() token: DecodedIdToken, @Param('id') id: string) {
    return this.tables.close(token.uid, id);
  }
}
