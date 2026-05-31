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
  /// Se vier acompanhado de `initialBuyIn`, o buy-in inicial é gravado na
  /// mesma transação — caso contrário ele declara depois.
  @IsOptional()
  @IsBoolean()
  joinAsPlayer?: boolean;

  /// Aporte inicial do owner. Só usado se `joinAsPlayer === true`. Tem que
  /// ser >= `minBuyIn` (validado no serviço, não no DTO, porque precisa do
  /// outro campo).
  @IsOptional()
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0)
  initialBuyIn?: number;
}
