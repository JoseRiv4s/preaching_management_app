import '../../../../core/database/app_database.dart' as db;
import '../../domain/model/block.dart';
import '../remote/block_dto.dart';

class BlockMapper {
  BlockMapper._();

  static Block fromRow(db.Block row) => Block(
    id:          row.id,
    blockNumber: row.blockNumber,
    status:      BlockStatusX.fromValue(row.status),
    notes:       row.notes,
    territoryId: row.territoryId,
    createdAt:   row.createdAt,
  );

  static Block fromDto(BlockDto dto) => Block(
    id:          dto.id,
    blockNumber: dto.blockNumber,
    status:      BlockStatusX.fromValue(dto.status),
    notes:       dto.notes,
    territoryId: dto.territoryId,
    createdAt:   DateTime.parse(dto.createdAt),
  );
}