import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
} from 'typeorm';

import { NotificationType } from '../notifications.contracts';

@Entity('notifications')
export class Notification {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'user_id', length: 255 })
  userId: string;

  @Column({ name: 'book_id', type: 'uuid' })
  bookId: string;

  @Column({ name: 'loan_id', type: 'uuid' })
  loanId: string;

  @Column({ length: 20 })
  type: NotificationType;

  @Column({ type: 'text' })
  message: string;

  @CreateDateColumn({ name: 'sent_at' })
  sentAt: Date;
}
