import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/course_model.dart';

class CourseRemoteDataSource {
  final Dio _dio;

  CourseRemoteDataSource({Dio? dio})
      : _dio = dio ?? DioClient.instance.dio;

  Future<List<CourseModel>> getCourses({
    String? category,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.courses,
        queryParameters: {
          if (category != null && category != 'Barchasi')
            'category': category,
          'page': page,
          'pageSize': pageSize,
        },
      );
      // Backend: { success, data: [...], message }
      final body = response.data as Map<String, dynamic>;
      final list = body['data'] as List<dynamic>? ?? [];
      return list
          .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.error ?? ServerException(message: e.message ?? 'Xatolik');
    }
  }

  Future<CourseModel> getCourseById(String id) async {
    try {
      final response = await _dio.get(ApiConstants.courseById(id));
      final body = response.data as Map<String, dynamic>;
      return CourseModel.fromJson(body['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error ?? ServerException(message: e.message ?? 'Xatolik');
    }
  }

  Future<List<ModuleModel>> getCourseModules(String courseId) async {
    try {
      final response =
          await _dio.get(ApiConstants.courseModules(courseId));
      final body = response.data as Map<String, dynamic>;
      final list = body['data'] as List<dynamic>? ?? [];
      return list
          .map((e) => ModuleModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.error ?? ServerException(message: e.message ?? 'Xatolik');
    }
  }

  Future<LessonModel> getLessonById(String id) async {
    try {
      final response = await _dio.get(ApiConstants.lessonById(id));
      final body = response.data as Map<String, dynamic>;
      return LessonModel.fromJson(body['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error ?? ServerException(message: e.message ?? 'Xatolik');
    }
  }
}
