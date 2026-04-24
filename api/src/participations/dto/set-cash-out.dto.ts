import { IsNumber, Min } from 'class-validator';

export class SetCashOutDto {
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0)
  amount!: number;
}
