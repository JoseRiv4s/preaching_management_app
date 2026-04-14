import 'package:preaching_management/features/preaching_days/domain/model/preaching_day.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/app_exception.dart';
import '../../domain/model/preaching_day_summary.dart';
import '../../domain/repository/preaching_day_repository.dart';
import '../local/preaching_day_local_datasource.dart';
import '../remote/preaching_day_remote_datasource.dart';

class PreachingDayRepositoryImpl implements PreachingDayRepository {
  final PreachingDayRemoteDatasource _remote;
  final PreachingDayLocalDatasource  _local;

  PreachingDayRepositoryImpl(this._remote, this._local);

  @override
  Stream<List<PreachingDaySummaryModel>> watchByDate(
      DateTime date) =>
      _local.watchByDate(date);

  @override
  Future<List<PreachingDaySummaryModel>> getHistory({
    int page = 0,
    int pageSize = 20,
  }) =>
      _local.getHistory(page: page, pageSize: pageSize);

  @override
  Future<void> create({
    required DateTime date,
    required String captainId,
    required List<String> publisherIds,
    required List<String> blockIds,
    String? notes,
  }) async {
    String id;
    try {
      // Intenta crear en backend
      final dto = await _remote.create(
        date:         date.toIso8601String().split('T').first,
        captainId:    captainId,
        publisherIds: publisherIds,
        blockIds:     blockIds,
        notes:        notes,
      );
      id = dto.id;
    } on AppException {
      // Offline: genera ID local
      id = const Uuid().v4();
    }

    // Guarda en local
    await _local.savePreachingDay(
      id:           id,
      date:         date,
      captainId:    captainId,
      publisherIds: publisherIds,
      blockIds:     blockIds,
      notes:        notes,
    );
  }

  @override
  Future<void> update({
    required String id,
    required String captainId,
    required List<String> publisherIds,
    required List<String> blockIds,
    String? notes,
  }) async {
    try {
      await _remote.update(
        id:           id,
        captainId:    captainId,
        publisherIds: publisherIds,
        blockIds:     blockIds,
        notes:        notes,
      );
    } on AppException {}

    await _local.savePreachingDay(
      id:           id,
      date:         DateTime.now(),
      captainId:    captainId,
      publisherIds: publisherIds,
      blockIds:     blockIds,
      notes:        notes,
    );
  }

  @override
  Future<void> delete(String id) async {
    await _local.deleteById(id);
    try {
      await _remote.delete(id);
    } on AppException {}
  }

  @override
  Future<void> sync() async {
    try {
      final dtos = await _remote.getAll();
      for (final dto in dtos) {
        await _local.savePreachingDay(
          id:           dto.id,
          date:         DateTime.parse(dto.date),
          captainId:    dto.captainId,
          publisherIds: dto.participantIds,
          blockIds:     dto.blockIds,
          notes:        dto.notes,
        );
      }
    } on AppException {}
  }

  @override
  Future<PreachingDay?> getById(String id) async {
    return null;
  }
}