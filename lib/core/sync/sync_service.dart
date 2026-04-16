import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../network/api_constants.dart';
import '../network/dio_client.dart';
import 'connectivity_service.dart';
import 'sync_operation.dart';

class SyncService {
  final AppDatabase _db;
  final ConnectivityService _connectivity;

  SyncService(this._db, this._connectivity);

  // ── Encolar operación ────────────────────────────────────
  Future<void> enqueue({
    required SyncEntity entity,
    required SyncOperation operation,
    required Map<String, dynamic> payload,
  }) async {
    await _db.syncQueueDao.enqueue(
      SyncQueueCompanion(
        id:        Value(const Uuid().v4()),
        entity:    Value(entity.name),
        operation: Value(operation.name),
        payload:   Value(jsonEncode(payload)),
        createdAt: Value(DateTime.now()),
      ),
    );
  }

  // ── Procesar toda la cola ─────────────────────────────────
  Future<SyncResult> processQueue() async {
    final online = await _connectivity.isConnected;
    if (!online) {
      return SyncResult(
          success: 0, failed: 0, message: 'Sin conexión');
    }

    final items = await _db.syncQueueDao.getPending();
    int success = 0;
    int failed  = 0;

    for (final item in items) {
      try {
        await _processItem(item);
        await _db.syncQueueDao.deleteById(item.id);
        success++;
      } catch (e) {
        await _db.syncQueueDao.incrementAttempts(item.id);
        failed++;

        // Si falló más de 3 veces, eliminar de la cola
        if (item.attempts >= 3) {
          await _db.syncQueueDao.deleteById(item.id);
        }
      }
    }

    return SyncResult(
      success: success,
      failed: failed,
      message: success > 0
          ? '$success operaciones sincronizadas'
          : 'Sin cambios pendientes',
    );
  }

  Future<void> _processItem(SyncQueueData item) async {
    final dio     = DioClient.create(baseUrl: ApiConstants.baseUrl);
    final payload = jsonDecode(item.payload) as Map<String, dynamic>;
    final entity  = item.entity;
    final op      = item.operation;
    final id      = payload['id'] as String?;

    final endpoint = switch (entity) {
      'publisher'   => ApiConstants.publishers,
      'captain'     => ApiConstants.captains,
      'territory'   => ApiConstants.territories,
      'block'       => ApiConstants.blocks,
      'preachingDay'=> ApiConstants.preachingDays,
      _             => throw Exception('Entidad desconocida: $entity'),
    };

    switch (op) {
      case 'create':
        await dio.post(endpoint, data: payload);
      case 'update':
        await dio.put('$endpoint/$id', data: payload);
      case 'delete':
        await dio.delete('$endpoint/$id');
    }
  }

  // ── Sincronización completa (pull del backend) ────────────
  Future<void> fullSync(Ref ref) async {
    final online = await _connectivity.isConnected;
    if (!online) return;

    // Primero sube los cambios pendientes
    await processQueue();

    // Luego descarga todos los datos actualizados
    final dio = DioClient.create(baseUrl: ApiConstants.baseUrl);

    await _syncEntity(
      dio:      dio,
      endpoint: ApiConstants.publishers,
      save: (data) async {
        await _db.publishersDao.replaceAll(
          (data as List).map((e) {
            final m = e as Map<String, dynamic>;
            return PublishersCompanion(
              id:        Value(m['id'] as String),
              name:      Value(m['name'] as String),
              phone:     Value(m['phone'] as String?),
              createdAt: Value(DateTime.parse(
                  m['createdAt'] as String)),
            );
          }).toList(),
        );
      },
    );

    await _syncEntity(
      dio:      dio,
      endpoint: ApiConstants.captains,
      save: (data) async {
        await _db.captainsDao.replaceAll(
          (data as List).map((e) {
            final m = e as Map<String, dynamic>;
            return CaptainsCompanion(
              id:        Value(m['id'] as String),
              name:      Value(m['name'] as String),
              phone:     Value(m['phone'] as String?),
              email:     Value(m['email'] as String?),
              createdAt: Value(DateTime.parse(
                  m['createdAt'] as String)),
            );
          }).toList(),
        );
      },
    );

    await _syncEntity(
      dio:      dio,
      endpoint: ApiConstants.territories,
      save: (data) async {
        await _db.territoriesDao.replaceAll(
          (data as List).map((e) {
            final m = e as Map<String, dynamic>;
            return TerritoriesCompanion(
              id:        Value(m['id'] as String),
              name:      Value(m['name'] as String),
              createdAt: Value(DateTime.parse(
                  m['createdAt'] as String)),
            );
          }).toList(),
        );
      },
    );

    await _syncEntity(
      dio:      dio,
      endpoint: ApiConstants.blocks,
      save: (data) async {
        await _db.blocksDao.replaceAll(
          (data as List).map((e) {
            final m = e as Map<String, dynamic>;
            return BlocksCompanion(
              id:          Value(m['id'] as String),
              blockNumber: Value(m['blockNumber'] as String),
              status:      Value(m['status'] as String),
              notes:       Value(m['notes'] as String?),
              territoryId: Value(m['territoryId'] as String),
              createdAt:   Value(DateTime.parse(
                  m['createdAt'] as String)),
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> _syncEntity({
    required dynamic dio,
    required String endpoint,
    required Future<void> Function(dynamic data) save,
  }) async {
    try {
      final response = await dio.get(endpoint);
      await save(response.data);
    } catch (_) {
      // Silencioso — mantiene datos locales
    }
  }

  Future<int> getPendingCount() =>
      _db.syncQueueDao.getPendingCount();
}

class SyncResult {
  final int success;
  final int failed;
  final String message;

  const SyncResult({
    required this.success,
    required this.failed,
    required this.message,
  });
}

// Provider
final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    ref.watch(appDatabaseProvider),
    ref.watch(connectivityServiceProvider),
  );
});