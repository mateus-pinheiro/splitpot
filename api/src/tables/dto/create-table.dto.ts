import {
  IsBoolean,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  Length,
  Min,
} from 'class-validator';

export class CreateTableDto {
  @IsString()
  @IsNotEmpty()
  @Length(1, 120)
  name!: string;

  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0)
  minBuyIn!: number;

  /// Quando `true`, o owner já entra como participante na criação.
  /// Sem aporte inicial — ele declara o buy-in depois.
  @IsOptional()
  @IsBoolean()
  joinAsPlayer?: boolean;
}
