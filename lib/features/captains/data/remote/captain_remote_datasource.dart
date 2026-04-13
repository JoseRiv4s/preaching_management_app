import 'package:dio/dio.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/network/api_constants.dart';
import 'captain_dto.dart';

class CaptainRemoteDatasource {
  final Dio _dio;
  CaptainRemoteDatasource(this._dio);

  Future<List<CaptainDto>> getAll() async {
    try {
      final response = await _dio.get(ApiConstants.captains);
      final list = response.data as List<dynamic>;
      return list.map((e) => CaptainDto.fromJson(e)).toList();
    } on DioException catch (e) {
      throw e.error as AppException? ??
          const AppException('Error al obtener capitanes');
    }
  }

  Future<CaptainDto> create(
      String name, String? phone, String? email) async {
    try {
      final response = await _dio.post(
        ApiConstants.captains,
        data: {'name': name, 'phone': phone, 'email': email},
      );
      return CaptainDto.fromJson(response.data);
    } on DioException catch (e) {
      throw e.error as AppException? ??
          const AppException('Error al crear capitán');
    }
  }

  Future<CaptainDto> update(
      String id, String name, String? phone, String? email) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.captains}/$id',
        data: {'name': name, 'phone': phone, 'email': email},
      );
      return CaptainDto.fromJson(response.data);
    } on DioException catch (e) {
      throw e.error as AppException? ??
          const AppException('Error al actualizar capitán');
    }
  }

  Future<void> delete(String id) async {
    try {
      await _dio.delete('${ApiConstants.captains}/$id');
    } on DioException catch (e) {
      throw e.error as AppException? ??
          const AppException('Error al eliminar capitán');
    }
  }
}