import 'package:dio/dio.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/network/api_constants.dart';
import 'block_dto.dart';

class BlockRemoteDatasource {
  final Dio _dio;
  BlockRemoteDatasource(this._dio);

  Future<List<BlockDto>> getAll() async {
    try {
      final response = await _dio.get(ApiConstants.blocks);
      return (response.data as List)
          .map((e) => BlockDto.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw e.error as AppException? ??
          const AppException('Error al obtener bloques');
    }
  }

  Future<BlockDto> create({
    required String blockNumber,
    required String territoryId,
    String? notes,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.blocks,
        data: {
          'blockNumber': blockNumber,
          'territoryId': territoryId,
          'notes': notes,
        },
      );
      return BlockDto.fromJson(response.data);
    } on DioException catch (e) {
      throw e.error as AppException? ??
          const AppException('Error al crear bloque');
    }
  }

  Future<BlockDto> update(String id, String blockNumber,
      String status, String? notes) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.blocks}/$id',
        data: {
          'blockNumber': blockNumber,
          'status': status,
          'notes': notes,
        },
      );
      return BlockDto.fromJson(response.data);
    } on DioException catch (e) {
      throw e.error as AppException? ??
          const AppException('Error al actualizar bloque');
    }
  }

  Future<void> delete(String id) async {
    try {
      await _dio.delete('${ApiConstants.blocks}/$id');
    } on DioException catch (e) {
      throw e.error as AppException? ??
          const AppException('Error al eliminar bloque');
    }
  }
}