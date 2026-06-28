export interface CreateBookDto {
  title: string;
  author: string;
  isbn: string;
  totalCopies: number;
} // ingresa por el HTTP POST y se valida en el DTO, luego se persiste en la base de datos

export interface BookResponse {
  id: string;
  title: string;
  author: string;
  isbn: string;
  totalCopies: number;
  availableCopies: number;
  createdAt: string;
}
// ingresa por el HTTP GET y se valida en el DTO, luego se persiste en la base de datos