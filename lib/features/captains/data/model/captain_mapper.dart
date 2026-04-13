import '../../../../core/database/app_database.dart' as db;
import '../../domain/model/captain.dart' as domain;
import '../remote/captain_dto.dart';

class CaptainMapper {
  CaptainMapper._();

  static domain.Captain fromRow(db.Captain row) => domain.Captain(
    id:        row.id,
    name:      row.name,
    phone:     row.phone,
    email:     row.email,
    createdAt: row.createdAt,
  );

  static domain.Captain fromDto(CaptainDto dto) => domain.Captain(
    id:        dto.id,
    name:      dto.name,
    phone:     dto.phone,
    email:     dto.email,
    createdAt: DateTime.parse(dto.createdAt),
  );
}