export const LOAN_REQUESTED_EVENT = 'loan.requested';
export const LOAN_CONFIRMED_EVENT = 'loan.confirmed';
export const LOAN_REJECTED_EVENT = 'loan.rejected';
export const LOANS_STATUS_PATTERN = 'loans.status';

export interface LoanRequestedEvent {
  loanId: string;
  bookId: string;
  userId: string;
  requestedAt: string;
}

export interface LoanConfirmedEvent {
  loanId: string;
  bookId: string;
  userId: string;
  dueDate: string;
  confirmedAt: string;
}

export interface LoanRejectedEvent {
  loanId: string;
  bookId: string;
  userId: string;
  reason: string;
  rejectedAt: string;
}

export interface LoansStatusRequest {
  userId: string;
}

export interface LoansStatusResponse {
  userId: string;
  totalLoans: number;
  activeLoans: number;
  lastActivityAt: string | null;
}
