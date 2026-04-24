import { IsNotEmpty, IsString, MaxLength } from 'class-validator';

export class UpdateSettlementPixDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(512)
  pixCopiaECola!: string;
}
