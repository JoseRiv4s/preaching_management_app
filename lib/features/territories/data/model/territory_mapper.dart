import '../../../../core/database/app_database.dart' as db;
import '../../domain/model/territory.dart' as domain;
import '../remote/territory_dto.dart';

class TerritoryMapper {
  TerritoryMapper._();

  static domain.Territory fromRow(db.Territory row) => domain.Territory(
    id:        row.id,
    name:      row.name,
    createdAt: row.createdAt,
  );

  static domain.Territory fromDto(TerritoryDto dto) => domain.Territory(
    id:        dto.id,
    name:      dto.name,
    createdAt: DateTime.parse(dto.createdAt),
  );
}