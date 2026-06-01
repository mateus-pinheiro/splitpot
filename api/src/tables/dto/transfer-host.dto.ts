import { IsString, MinLength } from 'class-validator';

export class TransferHostDto {
  @IsString()
  @MinLength(1)
  newOwnerId!: string;
}
