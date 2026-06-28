import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import {
  Notification,
  LoanConfirmedEvent,
  LoanRejectedEvent,
  NotificationsStatusResponse,
} from '@app/contracts';

@Injectable()
export class NotificationsService {
  private readonly logger = new Logger(NotificationsService.name);

  constructor(
    @InjectRepository(Notification)
    private readonly notificationRepo: Repository<Notification>,
  ) {}

  async handleLoanConfirmed(event: LoanConfirmedEvent): Promise<void> {
    const message = `Préstamo confirmado. Devolver antes del ${new Date(event.dueDate).toLocaleDateString('es-CL')}`;

    const notification = this.notificationRepo.create({
      userId: event.userId,
      bookId: event.bookId,
      loanId: event.loanId,
      type: 'LOAN_CONFIRMED',
      message,
    });

    await this.notificationRepo.save(notification);
    this.logger.log(`Notificación LOAN_CONFIRMED enviada a usuario ${event.userId}`);
  }

  async handleLoanRejected(event: LoanRejectedEvent): Promise<void> {
    const message = `Solicitud de préstamo rechazada. Motivo: ${event.reason}`;

    const notification = this.notificationRepo.create({
      userId: event.userId,
      bookId: event.bookId,
      loanId: event.loanId,
      type: 'LOAN_REJECTED',
      message,
    });

    await this.notificationRepo.save(notification);
    this.logger.warn(`Notificación LOAN_REJECTED enviada a usuario ${event.userId}`);
  }

  async getStatus(userId: string): Promise<NotificationsStatusResponse> {
    const notifications = await this.notificationRepo.findBy({ userId });
    const last = notifications
      .map((n) => n.sentAt)
      .sort((a, b) => b.getTime() - a.getTime())[0] ?? null;

    return {
      userId,
      totalSent: notifications.length,
      lastSentAt: last ? last.toISOString() : null,
    };
  }
}
