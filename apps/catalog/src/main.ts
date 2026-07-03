import { NestFactory } from '@nestjs/core';
import { Logger } from '@nestjs/common';
import { CatalogModule } from './catalog.module';

async function bootstrap() {
  const app = await NestFactory.create(CatalogModule);

  app.enableCors({
    origin: '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
  });

  const port = Number(process.env.CATALOG_HTTP_PORT ?? 3000);

  // Escuchar en todas las interfaces para ECS/Fargate
  await app.listen(port, '0.0.0.0');

  Logger.log(
    `Catalog HTTP escuchando en 0.0.0.0:${port}`,
    'Bootstrap',
  );
}

bootstrap();