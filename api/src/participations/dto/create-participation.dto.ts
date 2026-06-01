import {
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  Min,
} from 'class-validator';

export class CreateParticipationDto {
  @IsString()
  @IsNotEmpty()
  tableId!: string;

  @IsOptional()
  @IsString()
  userId?: string;

  /// Aporte inicial opcional. Se informado, validado contra `minBuyIn` da
  /// mesa e gravado como o primeiro `BuyIn` da participation, na mesma
  /// transação.
  @IsOptional()
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0)
  initialBuyIn?: number;
}
