import 'package:dio/dio.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/network/api_constants.dart';
import 'territory_dto.dart';

class TerritoryRemoteDatasource {
  final Dio _dio;
  TerritoryRemoteDatasource(this._dio);

  Future<List<TerritoryDto>> getAll() async {
    try {
      final response = await _dio.get(ApiConstants.territories);
      return (response.data as List)
          .map((e) => TerritoryDto.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw e.error as AppException? ??
          const AppException('Error al obtener territorios');
    }
  }

  Future<TerritoryDto> create(String name) async {
    try {
      final response = await _dio.post(
        ApiConstants.territories,
        data: {'name': name},
      );
      return TerritoryDto.fromJson(response.data);
    } on DioException catch (e) {
      throw e.error as AppException? ??
          const AppException('Error al crear territorio');
    }
  }

  Future<TerritoryDto> update(String id, String name) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.territories}/$id',
        data: {'name': name},
      );
      return TerritoryDto.fromJson(response.data);
    } on DioException catch (e) {
      throw e.error as AppException? ??
          const AppException('Error al actualizar territorio');
    }
  }

  Future<void> delete(String id) async {
    try {
      await _dio.delete('${ApiConstants.territories}/$id');
    } on DioException catch (e) {
      throw e.error as AppException? ??
          const AppException('Error al eliminar territorio');
    }
  }
}