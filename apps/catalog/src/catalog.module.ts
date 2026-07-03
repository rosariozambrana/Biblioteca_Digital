import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ClientsModule, Transport } from '@nestjs/microservices';
import { NATS_SERVICE, DEFAULT_NATS_URL, Book } from '@app/contracts';
import { CatalogController } from './catalog.controller';
import { CatalogService } from './catalog.service';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),

    TypeOrmModule.forRoot({
      type: 'postgres',

      url:
        process.env.DATABASE_URL ??
        'postgres://postgres:postgres@localhost:5432/biblioteca',

      ssl: process.env.DATABASE_URL
        ? {
            rejectUnauthorized: false,
          }
        : false,

      entities: [Book],

      synchronize: true,
    }),

    TypeOrmModule.forFeature([Book]),

    ClientsModule.register([
      {
        name: NATS_SERVICE,
        transport: Transport.NATS,
        options: {
          servers: [process.env.NATS_URL ?? DEFAULT_NATS_URL],
        },
      },
    ]),
  ],

  controllers: [CatalogController],
  providers: [CatalogService],
})
export class CatalogModule {}