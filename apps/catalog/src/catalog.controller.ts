import {
  Body,
  Controller,
  Delete,
  Get,
  NotFoundException,
  Param,
  Post,
  Put,
} from '@nestjs/common';
import { CatalogService } from './catalog.service';
import { CreateBookDto } from '@app/contracts';

@Controller('books')
export class CatalogController {
  constructor(private readonly catalogService: CatalogService) {}

  @Post()
  create(@Body() dto: CreateBookDto) {
    return this.catalogService.createBook(dto);
  }

  @Get()
  findAll() {
    return this.catalogService.findAllBooks();
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    const book = await this.catalogService.findBook(id);
    if (!book) throw new NotFoundException(`Libro ${id} no encontrado`);
    return book;
  }

  @Put(':id')
  async update(@Param('id') id: string, @Body() dto: Partial<CreateBookDto>) {
    const book = await this.catalogService.updateBook(id, dto);
    if (!book) throw new NotFoundException(`Libro ${id} no encontrado`);
    return book;
  }

  @Delete(':id')
  async remove(@Param('id') id: string) {
    const removed = await this.catalogService.removeBook(id);
    if (!removed) throw new NotFoundException(`Libro ${id} no encontrado`);
    return { message: `Libro ${id} eliminado` };
  }

  @Post(':id/loan') // dispara evento NATS para solicitar préstamo de libro
  requestLoan(
    @Param('id') bookId: string,
    @Body('userId') userId: string,
  ) {
    return this.catalogService.requestLoan(bookId, userId);
  }
}
