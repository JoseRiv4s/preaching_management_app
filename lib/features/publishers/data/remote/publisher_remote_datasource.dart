import 'package:dio/dio.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/network/api_constants.dart';
import '../remote/publisher_dto.dart';

class PublisherRemoteDatasource {
  final Dio _dio;
  PublisherRemoteDatasource(this._dio);

  Future<List<PublisherDto>> getAll() async {
    try {
      final response = await _dio.get(ApiConstants.publishers);
      final list = response.data as List<dynamic>;
      return list.map((e) => PublisherDto.fromJson(e)).toList();
    } on DioException catch (e) {
      throw e.error as AppException? ??
          const AppException('Error al obtener publishers');
    }
  }

  Future<PublisherDto> create(String name, String? phone) async {
    try {
      final response = await _dio.post(
        ApiConstants.publishers,
        data: {'name': name, 'phone': phone},
      );
      return PublisherDto.fromJson(response.data);
    } on DioException catch (e) {
      throw e.error as AppException? ??
          const AppException('Error al crear publisher');
    }
  }

  Future<PublisherDto> update(String id, String name, String? phone) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.publishers}/$id',
        data: {'name': name, 'phone': phone},
      );
      return PublisherDto.fromJson(response.data);
    } on DioException catch (e) {
      throw e.error as AppException? ??
          const AppException('Error al actualizar publisher');
    }
  }

  Future<void> delete(String id) async {
    try {
      await _dio.delete('${ApiConstants.publishers}/$id');
    } on DioException catch (e) {
      throw e.error as AppException? ??
          const AppException('Error al eliminar publisher');
    }
  }
}