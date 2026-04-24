import { IsNotEmpty, IsOptional, IsString } from 'class-validator';

export class CreateParticipationDto {
  @IsString()
  @IsNotEmpty()
  tableId!: string;

  @IsOptional()
  @IsString()
  userId?: string;
}
