import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
} from 'typeorm';

export type LoanStatus = 'PENDING' | 'ACTIVE' | 'REJECTED' | 'RETURNED';

@Entity('loans')
export class Loan {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'book_id', type: 'uuid' })
  bookId: string;

  @Column({ name: 'user_id', length: 255 })
  userId: string;

  @Column({ default: 'PENDING', length: 20 })
  status: LoanStatus;

  @Column({ name: 'due_date', type: 'timestamp', nullable: true })
  dueDate: Date | null;

  @Column({ nullable: true, type: 'text' })
  reason: string | null;

  @CreateDateColumn({ name: 'requested_at' })
  requestedAt: Date;

  @Column({ name: 'confirmed_at', type: 'timestamp', nullable: true })
  confirmedAt: Date | null;
}
