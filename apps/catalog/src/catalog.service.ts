import { Inject, Injectable, Logger, NotFoundException, OnModuleInit } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ClientProxy } from '@nestjs/microservices';
import { randomUUID } from 'node:crypto';
import {
  NATS_SERVICE,
  LOAN_REQUESTED_EVENT,
  Book,
  CreateBookDto,
  LoanRequestedEvent,
} from '@app/contracts';

@Injectable()
export class CatalogService implements OnModuleInit {
  private readonly logger = new Logger(CatalogService.name);

  constructor(
    @InjectRepository(Book)
    private readonly bookRepo: Repository<Book>,
    @Inject(NATS_SERVICE)
    private readonly nats: ClientProxy,
  ) {}

  async onModuleInit() {
    await this.nats.connect();
    this.logger.log('Conectado a broker NATS');
  }

  async createBook(dto: CreateBookDto): Promise<Book> {
    const book = this.bookRepo.create({
      ...dto,
      availableCopies: dto.totalCopies,
    });
    const saved = await this.bookRepo.save(book);
    this.logger.log(`Libro creado: ${saved.id} — "${saved.title}"`);
    return saved;
  }

  findAllBooks(): Promise<Book[]> {
    return this.bookRepo.find();
  }

  findBook(id: string): Promise<Book | null> {
    return this.bookRepo.findOneBy({ id });
  }

  async updateBook(id: string, dto: Partial<CreateBookDto>): Promise<Book | null> {
    const book = await this.bookRepo.findOneBy({ id });
    if (!book) return null;
    Object.assign(book, dto);
    return this.bookRepo.save(book);
  }

  async removeBook(id: string): Promise<boolean> {
    const result = await this.bookRepo.delete(id);
    return (result.affected ?? 0) > 0;
  }
 // dispara evento NATS para solicitar prestamo de libro
  async requestLoan(bookId: string, userId: string): Promise<{ loanId: string; message: string }> { // dispara evento NATS para solicitar préstamo de libro
    const book = await this.bookRepo.findOneBy({ id: bookId });
    if (!book) throw new NotFoundException(`Libro ${bookId} no encontrado`);

    const event: LoanRequestedEvent = {
      loanId: randomUUID(),
      bookId,
      userId,
      requestedAt: new Date().toISOString(),
    };

    this.nats.emit<void, LoanRequestedEvent>(LOAN_REQUESTED_EVENT, event);
    this.logger.log(`Publicado ${LOAN_REQUESTED_EVENT} — préstamo ${event.loanId}`);

    return { loanId: event.loanId, message: 'Solicitud de préstamo recibida, en proceso' };
  }
}
