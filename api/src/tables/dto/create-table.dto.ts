import { IsNotEmpty, IsNumber, IsString, Length, Min } from 'class-validator';

export class CreateTableDto {
  @IsString()
  @IsNotEmpty()
  @Length(1, 120)
  name!: string;

  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0)
  minBuyIn!: number;
}
