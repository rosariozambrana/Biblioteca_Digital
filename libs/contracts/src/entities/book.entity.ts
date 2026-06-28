import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
} from 'typeorm';

@Entity('books')
export class Book {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ length: 255 })
  title: string;

  @Column({ length: 255 })
  author: string;

  @Column({ unique: true, length: 20 })
  isbn: string;

  @Column({ name: 'total_copies' })
  totalCopies: number;

  @Column({ name: 'available_copies' })
  availableCopies: number;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}
