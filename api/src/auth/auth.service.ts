import {
  Injectable,
  Logger,
  OnModuleInit,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { cert, getApps, initializeApp, type App } from 'firebase-admin/app';
import { getAuth, type DecodedIdToken } from 'firebase-admin/auth';

@Injectable()
export class AuthService implements OnModuleInit {
  private readonly logger = new Logger(AuthService.name);
  private app: App | null = null;

  constructor(private readonly config: ConfigService) {}

  onModuleInit(): void {
    const projectId = this.config.get<string>('FIREBASE_PROJECT_ID');
    const clientEmail = this.config.get<string>('FIREBASE_CLIENT_EMAIL');
    const privateKey = this.config
      .get<string>('FIREBASE_PRIVATE_KEY')
      ?.replace(/\\n/g, '\n');

    if (!projectId || !clientEmail || !privateKey) {
      this.logger.warn(
        'Firebase Admin não inicializado: defina FIREBASE_PROJECT_ID, FIREBASE_CLIENT_EMAIL e FIREBASE_PRIVATE_KEY no .env',
      );
      return;
    }

    this.app =
      getApps()[0] ??
      initializeApp({
        credential: cert({ projectId, clientEmail, privateKey }),
      });
    this.logger.log(`Firebase Admin inicializado (project ${projectId})`);
  }

  async verifyIdToken(idToken: string): Promise<DecodedIdToken> {
    if (!this.app) {
      throw new UnauthorizedException('Firebase Admin não configurado');
    }
    try {
      return await getAuth(this.app).verifyIdToken(idToken);
    } catch {
      throw new UnauthorizedException('Token inválido');
    }
  }

  /**
   * Descobre quais providers (password/google.com/apple.com) estão
   * vinculados a um email. Usa o Admin SDK (`getUserByEmail`), que — ao
   * contrário do `accounts:createAuthUri` do client — **não** é afetado
   * pela Email Enumeration Protection do Firebase e devolve os providers
   * reais. É a fonte de verdade para o roteamento de login no app.
   *
   * Retorna `registered: false` quando o email não existe.
   */
  async lookupProviders(
    email: string,
  ): Promise<{ registered: boolean; providers: string[] }> {
    if (!this.app) {
      throw new UnauthorizedException('Firebase Admin não configurado');
    }
    try {
      const user = await getAuth(this.app).getUserByEmail(email);
      const providers = user.providerData
        .map((p) => p.providerId)
        .filter((id): id is string => Boolean(id));
      return { registered: true, providers };
    } catch (err) {
      if (
        err instanceof Error &&
        (err as { code?: string }).code === 'auth/user-not-found'
      ) {
        return { registered: false, providers: [] };
      }
      throw err;
    }
  }
}
