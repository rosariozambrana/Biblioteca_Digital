import { Controller } from '@nestjs/common';
import { EventPattern, MessagePattern, Payload } from '@nestjs/microservices';
import {
  LOAN_CONFIRMED_EVENT,
  LOAN_REJECTED_EVENT,
  NOTIFICATIONS_STATUS_PATTERN,
  LoanConfirmedEvent,
  LoanRejectedEvent,
  NotificationsStatusRequest,
  NotificationsStatusResponse,
} from '@app/contracts';
import { NotificationsService } from './notifications.service';

@Controller()
export class NotificationsController {
  constructor(private readonly notificationsService: NotificationsService) {}

  @EventPattern(LOAN_CONFIRMED_EVENT)
  onLoanConfirmed(@Payload() event: LoanConfirmedEvent): void {
    this.notificationsService.handleLoanConfirmed(event);
  }

  @EventPattern(LOAN_REJECTED_EVENT)
  onLoanRejected(@Payload() event: LoanRejectedEvent): void {
    this.notificationsService.handleLoanRejected(event);
  }

  @MessagePattern(NOTIFICATIONS_STATUS_PATTERN)
  getStatus(@Payload() payload: NotificationsStatusRequest): Promise<NotificationsStatusResponse> {
    return this.notificationsService.getStatus(payload.userId);
  }
}
