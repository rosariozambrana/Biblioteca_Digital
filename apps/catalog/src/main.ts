import { NestFactory } from '@nestjs/core';
import { Logger } from '@nestjs/common';
import { CatalogModule } from './catalog.module';

async function bootstrap() {
  const app = await NestFactory.create(CatalogModule); // crea la app de NestJS con el módulo CatalogModule

  // Habilita CORS para que el frontend (S3/CloudFront) pueda consumir la API
  // sin errores de "Cross-Origin Request Blocked" en el navegador.
  // El origen '*' permite cualquier dominio durante desarrollo/pruebas.
  // En producción se puede restringir al dominio del frontend:
  // origin: 'https://mi-frontend.s3-website.us-east-1.amazonaws.com'
  app.enableCors({
    origin: '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
  });

  const port = Number(process.env.CATALOG_HTTP_PORT ?? 3000);

  await app.listen(port); // levanta HTTP en el puerto 3000 o el definido en CATALOG_HTTP_PORT
  Logger.log(`catalog HTTP escuchando en http://localhost:${port}`, 'Bootstrap');
}

bootstrap();
