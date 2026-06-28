import { Controller } from '@nestjs/common';
import { EventPattern, MessagePattern, Payload } from '@nestjs/microservices';
import {
  LOAN_REQUESTED_EVENT,
  LOANS_STATUS_PATTERN,
  LoanRequestedEvent,
  LoansStatusRequest,
  LoansStatusResponse,
} from '@app/contracts';
import { LoansService } from './loans.service';

@Controller()
export class LoansController {
  constructor(private readonly loansService: LoansService) {}

  @EventPattern(LOAN_REQUESTED_EVENT)
  onLoanRequested(@Payload() event: LoanRequestedEvent): void {
    this.loansService.handleLoanRequested(event);
  }

  @MessagePattern(LOANS_STATUS_PATTERN)
  getStatus(@Payload() payload: LoansStatusRequest): Promise<LoansStatusResponse> {
    return this.loansService.getStatus(payload.userId);
  }
}
