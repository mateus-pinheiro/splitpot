import { IsNumber, IsOptional, IsString, Length, Min } from 'class-validator';

export class UpdateTableDto {
  @IsOptional()
  @IsString()
  @Length(1, 120)
  name?: string;

  @IsOptional()
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0)
  minBuyIn?: number;
}
