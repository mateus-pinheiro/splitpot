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

  /// Nome do convidado quando o host adiciona alguém sem conta. Mutuamente
  /// exclusivo com `userId` — o service valida XOR.
  @IsOptional()
  @IsString()
  guestName?: string;

  /// Chave PIX do convidado (obrigatória junto com `guestName`).
  @IsOptional()
  @IsString()
  guestPixKey?: string;

  /// Aporte inicial opcional. Se informado, validado contra `minBuyIn` da
  /// mesa e gravado como o primeiro `BuyIn` da participation, na mesma
  /// transação.
  @IsOptional()
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0)
  initialBuyIn?: number;
}
