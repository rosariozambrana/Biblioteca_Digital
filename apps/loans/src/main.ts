import { NestFactory } from '@nestjs/core';
import { Logger } from '@nestjs/common';
import { MicroserviceOptions, Transport } from '@nestjs/microservices';
import { LoansModule } from './loans.module';
import { DEFAULT_NATS_URL } from '@app/contracts';

async function bootstrap() {
  const app = await NestFactory.createMicroservice<MicroserviceOptions>(LoansModule, {
    transport: Transport.NATS,
    options: {
      servers: [process.env.NATS_URL ?? DEFAULT_NATS_URL],
    },
  });

  await app.listen();
  Logger.log('loans escuchando eventos NATS', 'Bootstrap');
}

bootstrap();
