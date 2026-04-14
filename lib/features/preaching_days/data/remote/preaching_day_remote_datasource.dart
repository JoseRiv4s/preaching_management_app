import 'package:dio/dio.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/network/api_constants.dart';
import 'preaching_day_dto.dart';

class PreachingDayRemoteDatasource {
  final Dio _dio;
  PreachingDayRemoteDatasource(this._dio);

  Future<List<PreachingDayDto>> getAll() async {
    try {
      final response = await _dio.get(ApiConstants.preachingDays);
      return (response.data as List)
          .map((e) => PreachingDayDto.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw e.error as AppException? ??
          const AppException('Error al obtener jornadas');
    }
  }

  Future<PreachingDayDto> create({
    required String date,
    required String captainId,
    required List<String> publisherIds,
    required List<String> blockIds,
    String? notes,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.preachingDays,
        data: {
          'date':         date,
          'captainId':    captainId,
          'publisherIds': publisherIds,
          'blockIds':     blockIds,
          'notes':        notes,
        },
      );
      return PreachingDayDto.fromJson(response.data);
    } on DioException catch (e) {
      throw e.error as AppException? ??
          const AppException('Error al crear jornada');
    }
  }

  Future<PreachingDayDto> update({
    required String id,
    required String captainId,
    required List<String> publisherIds,
    required List<String> blockIds,
    String? notes,
  }) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.preachingDays}/$id',
        data: {
          'captainId':    captainId,
          'publisherIds': publisherIds,
          'blockIds':     blockIds,
          'notes':        notes,
        },
      );
      return PreachingDayDto.fromJson(response.data);
    } on DioException catch (e) {
      throw e.error as AppException? ??
          const AppException('Error al actualizar jornada');
    }
  }

  Future<void> delete(String id) async {
    try {
      await _dio.delete('${ApiConstants.preachingDays}/$id');
    } on DioException catch (e) {
      throw e.error as AppException? ??
          const AppException('Error al eliminar jornada');
    }
  }
}