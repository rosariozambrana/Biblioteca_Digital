export const NOTIFICATIONS_STATUS_PATTERN = 'notifications.status';

export type NotificationType = 'LOAN_CONFIRMED' | 'LOAN_REJECTED';

export interface NotificationsStatusRequest {
  userId: string;
}

export interface NotificationsStatusResponse {
  userId: string;
  totalSent: number;
  lastSentAt: string | null;
}
