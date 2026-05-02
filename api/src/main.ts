import { NestFactory } from '@nestjs/core';
import { ValidationPipe, Logger } from '@nestjs/common';
import { ExpressAdapter } from '@nestjs/platform-express';
import { AppModule } from './app.module.js';
import express from 'express';

const server = express();

async function bootstrap() {
  const app = await NestFactory.create(AppModule, new ExpressAdapter(server), {
    logger: ['log', 'error', 'warn', 'debug'],
  });

  app.setGlobalPrefix('api');

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: { enableImplicitConversion: true },
    }),
  );

  app.enableCors({
    origin: true,
    credentials: true,
  });

  await app.init();

  if (!process.env.VERCEL) {
    const port = process.env.PORT ?? 3000;
    server.listen(port, () => {
      Logger.log(`SplitPot API listening on http://localhost:${port}/api`, 'Bootstrap');
    });
  }
}

const bootstrapPromise = bootstrap();

export default async (req: express.Request, res: express.Response) => {
  await bootstrapPromise;
  server(req, res);
};
