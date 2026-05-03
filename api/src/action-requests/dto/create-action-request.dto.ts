import { IsEnum, IsNumber, IsOptional, IsString, Min } from 'class-validator';
import { ActionType } from '@prisma/client';

export class CreateActionRequestDto {
  @IsString()
  participationId!: string;

  @IsEnum(ActionType)
  type!: ActionType;

  @IsOptional()
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0)
  amount?: number;
}
