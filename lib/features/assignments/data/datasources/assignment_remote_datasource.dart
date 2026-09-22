import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/assignment_model.dart';

class AssignmentRemoteDataSource {
  final Dio _dio;
  final Dio _uploadDio;

  AssignmentRemoteDataSource({Dio? dio, Dio? uploadDio})
      : _dio = dio ?? DioClient.instance.dio,
        _uploadDio = uploadDio ?? DioClient.instance.uploadDio;

  Future<AssignmentModel> getAssignmentByLessonId(String lessonId) async {
    try {
      final response =
          await _dio.get(ApiConstants.assignmentByLesson(lessonId));
      final body = response.data as Map<String, dynamic>;
      return AssignmentModel.fromJson(body['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const NotFoundException(
            message: 'Bu dars uchun vazifa biriktirilmagan');
      }
      throw e.error ?? ServerException(message: e.message ?? 'Xatolik');
    }
  }

  Future<SubmissionModel?> getMySubmission(String assignmentId) async {
    try {
      final response =
          await _dio.get(ApiConstants.mySubmission(assignmentId));
      final body = response.data as Map<String, dynamic>;
      if (body['data'] == null) return null;
      return SubmissionModel.fromJson(body['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw e.error ?? ServerException(message: e.message ?? 'Xatolik');
    }
  }

  Future<SubmissionModel> submitAssignmentWithFiles({
    required String assignmentId,
    required List<File> files,
    required CancelToken cancelToken,
    required void Function(int sent, int total) onProgress,
  }) async {
    try {
      final formData = FormData();

      for (int i = 0; i < files.length; i++) {
        final file = files[i];
        formData.files.add(
          MapEntry(
            'files[]',
            await MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
            ),
          ),
        );
      }

      final response = await _uploadDio.post(
        ApiConstants.submitAssignment(assignmentId),
        data: formData,
        cancelToken: cancelToken,
        onSendProgress: onProgress,
      );

      final body = response.data as Map<String, dynamic>;
      return SubmissionModel.fromJson(body['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        throw const UploadCancelledException();
      }
      throw e.error ??
          ServerException(message: e.message ?? 'Yuklashda xatolik');
    }
  }

  /// Firebase Storage dan olingan URL larni backend ga yuborish
  Future<void> submitAssignment({
    required String assignmentId,
    required List<String> fileUrls,
  }) async {
    try {
      await _dio.post(
        ApiConstants.submitAssignment(assignmentId),
        data: {'fileUrls': fileUrls},
      );
    } on DioException catch (e) {
      throw e.error ?? ServerException(message: e.message ?? 'Yuklashda xatolik');
    }
  }
}

