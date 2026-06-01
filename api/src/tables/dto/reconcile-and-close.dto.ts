import { IsEnum } from 'class-validator';

export enum ReconcileStrategy {
  HOST_ABSORB = 'HOST_ABSORB',
  SPLIT_EVENLY = 'SPLIT_EVENLY',
}

export class ReconcileAndCloseDto {
  @IsEnum(ReconcileStrategy)
  strategy!: ReconcileStrategy;
}
