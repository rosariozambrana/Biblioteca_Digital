import { Inject, Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ClientProxy } from '@nestjs/microservices';
import {
  NATS_SERVICE,
  LOAN_CONFIRMED_EVENT,
  LOAN_REJECTED_EVENT,
  Book,
  Loan,
  LoanRequestedEvent,
  LoanConfirmedEvent,
  LoanRejectedEvent,
  LoansStatusResponse,
} from '@app/contracts';

@Injectable()
export class LoansService implements OnModuleInit {
  private readonly logger = new Logger(LoansService.name);

  constructor(
    @InjectRepository(Book)
    private readonly bookRepo: Repository<Book>,
    @InjectRepository(Loan)
    private readonly loanRepo: Repository<Loan>,
    @Inject(NATS_SERVICE)
    private readonly nats: ClientProxy,
  ) {}

  async onModuleInit() {
    await this.nats.connect();
    this.logger.log('Conectado al broker NATS');
  }

  async handleLoanRequested(event: LoanRequestedEvent): Promise<void> {
    this.logger.log(`Procesando préstamo ${event.loanId} — libro ${event.bookId}`);

    const book = await this.bookRepo.findOneBy({ id: event.bookId });

    if (!book || book.availableCopies <= 0) {
      const loan = this.loanRepo.create({
        id: event.loanId,
        bookId: event.bookId,
        userId: event.userId,
        status: 'REJECTED',
        reason: !book ? 'Libro no encontrado' : 'No hay ejemplares disponibles',
      });
      await this.loanRepo.save(loan);

      const rejected: LoanRejectedEvent = {
        loanId: event.loanId,
        bookId: event.bookId,
        userId: event.userId,
        reason: loan.reason!,
        rejectedAt: new Date().toISOString(),
      };

      this.nats.emit<void, LoanRejectedEvent>(LOAN_REJECTED_EVENT, rejected);
      this.logger.warn(`Préstamo ${event.loanId} rechazado — ${loan.reason}`);
      return;
    }

    const dueDate = new Date();
    dueDate.setDate(dueDate.getDate() + 14);

    const loan = this.loanRepo.create({
      id: event.loanId,
      bookId: event.bookId,
      userId: event.userId,
      status: 'ACTIVE',
      dueDate,
      confirmedAt: new Date(),
    });
    await this.loanRepo.save(loan);

    book.availableCopies -= 1;
    await this.bookRepo.save(book);

    const confirmed: LoanConfirmedEvent = {
      loanId: event.loanId,
      bookId: event.bookId,
      userId: event.userId,
      dueDate: dueDate.toISOString(),
      confirmedAt: new Date().toISOString(),
    };

    this.nats.emit<void, LoanConfirmedEvent>(LOAN_CONFIRMED_EVENT, confirmed);
    this.logger.log(`Préstamo ${event.loanId} confirmado — devolver antes de ${dueDate.toDateString()}`);
  }

  async getStatus(userId: string): Promise<LoansStatusResponse> {
    const loans = await this.loanRepo.findBy({ userId });
    const activeLoans = loans.filter((l) => l.status === 'ACTIVE').length;
    const lastActivity = loans
      .map((l) => l.requestedAt)
      .sort((a, b) => b.getTime() - a.getTime())[0] ?? null;

    return {
      userId,
      totalLoans: loans.length,
      activeLoans,
      lastActivityAt: lastActivity ? lastActivity.toISOString() : null,
    };
  }
}
