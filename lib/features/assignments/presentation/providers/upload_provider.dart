import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../data/datasources/assignment_remote_datasource.dart';
import '../../domain/entities/assignment_entity.dart';


// ─── States ───────────────────────────────────────────────────────────────────

enum UploadStatus { idle, picking, uploading, success, error, cancelled }

class UploadState {
  final UploadStatus status;
  final List<PlatformFile> selectedFiles;
  final double progress; // 0.0 to 1.0
  final String? errorMessage;
  final SubmissionEntity? submission;

  const UploadState({
    this.status = UploadStatus.idle,
    this.selectedFiles = const [],
    this.progress = 0.0,
    this.errorMessage,
    this.submission,
  });

  UploadState copyWith({
    UploadStatus? status,
    List<PlatformFile>? selectedFiles,
    double? progress,
    String? errorMessage,
    SubmissionEntity? submission,
  }) {
    return UploadState(
      status: status ?? this.status,
      selectedFiles: selectedFiles ?? this.selectedFiles,
      progress: progress ?? this.progress,
      errorMessage: errorMessage ?? this.errorMessage,
      submission: submission ?? this.submission,
    );
  }
}

// ─── Providers ───────────────────────────────────────────────────────────────

final assignmentRemoteDataSourceProvider =
    Provider<AssignmentRemoteDataSource>((ref) => AssignmentRemoteDataSource());

final assignmentProvider =
    FutureProvider.family<AssignmentEntity, String>((ref, lessonId) async {
  final ds = ref.read(assignmentRemoteDataSourceProvider);
  return ds.getAssignmentByLessonId(lessonId);
});

final submissionProvider =
    FutureProvider.family<SubmissionEntity?, String>((ref, assignmentId) async {
  final ds = ref.read(assignmentRemoteDataSourceProvider);
  return ds.getMySubmission(assignmentId);
});

final uploadNotifierProvider =
    NotifierProvider.autoDispose<UploadNotifier, UploadState>(() {
  return UploadNotifier();
});

// ─── Notifier ─────────────────────────────────────────────────────────────────

class UploadNotifier extends Notifier<UploadState> {
  @override
  UploadState build() {
    return const UploadState();
  }

  // ─── Fayllarni tanlash ────────────────────────────────────────────────────
  // file_picker v13+:
  //   - FilePicker.pickFiles() → List<PlatformFile>
  //   - file.lengthSync() → int? (I/O yo'q, null bo'lishi mumkin)
  //   - await file.length() → Future<int?> (diskdan o'qiydi)
  //   - await file.readAsBytes() → Future<Uint8List> (fayl ma'lumotlari)
  Future<void> pickFiles() async {
    state = state.copyWith(status: UploadStatus.picking);
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.any,
      );

      if (result.isNotEmpty) {
        int totalSize = 0;
        for (final file in result) {
          // lengthSync() — null bo'lishi mumkin, shuning uchun ?? 0
          totalSize += file.lengthSync() ?? 0;
        }

        if (totalSize > AppConstants.maxFileSizeBytes) {
          state = state.copyWith(
            status: UploadStatus.error,
            errorMessage:
                'Fayllar umumiy hajmi ${AppConstants.maxFileSizeMB}MB dan oshmasligi kerak',
          );
          return;
        }

        if (result.length > AppConstants.maxFilesPerUpload) {
          state = state.copyWith(
            status: UploadStatus.error,
            errorMessage:
                'Bir vaqtda faqat ${AppConstants.maxFilesPerUpload} ta fayl yuklash mumkin',
          );
          return;
        }

        state = state.copyWith(
          status: UploadStatus.idle,
          selectedFiles: result,
          errorMessage: null,
        );
      } else {
        state = state.copyWith(status: UploadStatus.idle);
      }
    } catch (e) {
      state = state.copyWith(
        status: UploadStatus.error,
        errorMessage: 'Fayl tanlashda xatolik yuz berdi',
      );
    }
  }

  // ─── Fayllarni tozalash ───────────────────────────────────────────────────

  void clearFiles() {
    state = const UploadState();
  }

  void removeFile(PlatformFile file) {
    final newList = List<PlatformFile>.from(state.selectedFiles)..remove(file);
    state = state.copyWith(selectedFiles: newList);
  }

  // ─── Serverga (Firebase Storage + backend API) yuklash ──────────────────
  // Fayllar Firebase Storage ga yuklanadi, URL lar backend ga yuboriladi.

  Future<void> uploadFiles(String assignmentId) async {
    if (state.selectedFiles.isEmpty) return;

    state = state.copyWith(status: UploadStatus.uploading, progress: 0.0);

    // JWT bilan saqlangan userId ni olish
    final uid = await SecureStorageService.instance.getUserId();
    if (uid == null || uid.isEmpty) {
      state = state.copyWith(
        status: UploadStatus.error,
        errorMessage: 'Tizimga kiring',
      );
      return;
    }

    final List<String> downloadUrls = [];

    try {
      final files = state.selectedFiles;
      for (int i = 0; i < files.length; i++) {
        final file = files[i];
        final fileName = file.name;
        final ref = FirebaseStorage.instance
            .ref('submissions/$uid/$assignmentId/$fileName');

        // readAsBytes() — web va native uchun bir xil ishleydi (v13+ API)
        final bytes = await file.readAsBytes();
        final uploadTask = ref.putData(bytes);

        uploadTask.snapshotEvents.listen((snapshot) {
          final fileProgress = snapshot.bytesTransferred / snapshot.totalBytes;
          final totalProgress = (i + fileProgress) / files.length;
          state = state.copyWith(progress: totalProgress);
        });

        final snapshot = await uploadTask;
        final url = await snapshot.ref.getDownloadURL();
        downloadUrls.add(url);
      }

      // Firebase Storage URL larini backend ga yuborish
      final ds = ref.read(assignmentRemoteDataSourceProvider);
      await ds.submitAssignment(
        assignmentId: assignmentId,
        fileUrls: downloadUrls,
      );

      state = state.copyWith(
        status: UploadStatus.success,
        progress: 1.0,
      );
    } catch (e) {
      state = state.copyWith(
        status: UploadStatus.error,
        errorMessage: 'Yuklashda xatolik: $e',
      );
    }
  }

  // ─── Yuklashni bekor qilish ───────────────────────────────────────────────

  void cancelUpload() {
    if (state.status == UploadStatus.uploading) {
      state = state.copyWith(status: UploadStatus.cancelled, progress: 0.0);
    }
  }
}
