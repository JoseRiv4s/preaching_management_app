import '../../domain/model/publisher.dart' as domain;
import '../../../../../core/database/app_database.dart' as db;
import '../remote/publisher_dto.dart';

class PublisherMapper {
  PublisherMapper._();

  // Fila de Drift → dominio
  static domain.Publisher fromRow(db.Publisher row) => domain.Publisher(
        id:        row.id,
        name:      row.name,
        phone:     row.phone,
        createdAt: row.createdAt,
      );

  // DTO del backend → dominio
  static domain.Publisher fromDto(PublisherDto dto) => domain.Publisher(
        id:        dto.id,
        name:      dto.name,
        phone:     dto.phone,
        createdAt: DateTime.parse(dto.createdAt),
      );
}