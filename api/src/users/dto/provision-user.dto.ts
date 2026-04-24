import { IsNotEmpty, IsOptional, IsString, Length } from 'class-validator';

export class ProvisionUserDto {
  @IsString()
  @IsNotEmpty()
  @Length(1, 120)
  name!: string;

  @IsString()
  @IsNotEmpty()
  @Length(1, 140)
  pixKey!: string;

  @IsOptional()
  @IsString()
  email?: string;
}
