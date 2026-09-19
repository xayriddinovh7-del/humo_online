import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';

// ─── Video State ──────────────────────────────────────────────────────────────

class VideoPlayerState {
  final bool isInitialized;
  final bool isLoading;
  final String? error;
  final double speed;
  final int watchedPercent;
  final Duration? startPosition;

  const VideoPlayerState({
    this.isInitialized = false,
    this.isLoading = true,
    this.error,
    this.speed = AppConstants.defaultVideoSpeed,
    this.watchedPercent = 0,
    this.startPosition,
  });

  VideoPlayerState copyWith({
    bool? isInitialized,
    bool? isLoading,
    String? error,
    double? speed,
    int? watchedPercent,
    Duration? startPosition,
  }) {
    return VideoPlayerState(
      isInitialized: isInitialized ?? this.isInitialized,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      speed: speed ?? this.speed,
      watchedPercent: watchedPercent ?? this.watchedPercent,
      startPosition: startPosition ?? this.startPosition,
    );
  }
}

// ─── Provider ────────────────────────────────────────────────────────────────

final videoPlayerNotifierProvider =
    NotifierProvider.autoDispose.family<VideoPlayerNotifier, VideoPlayerState, String>(
  VideoPlayerNotifier.new,
);

// ─── Notifier ─────────────────────────────────────────────────────────────────

class VideoPlayerNotifier
    extends Notifier<VideoPlayerState> {
  final String videoUrl;
  VideoPlayerNotifier(this.videoUrl);

  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  @override
  VideoPlayerState build() {
    ref.onDispose(() {
      _videoController?.removeListener(_onVideoProgress);
      _chewieController?.dispose();
      _videoController?.dispose();
    });
    _initPlayer();
    return const VideoPlayerState();
  }

  VideoPlayerController? get videoController => _videoController;
  ChewieController? get chewieController => _chewieController;

  Future<void> _initPlayer() async {
    try {
      state = state.copyWith(isLoading: true);

      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
      );

      await _videoController!.initialize();

      // Ko'rilgan pozitsiyadan boshlash
      if (state.startPosition != null) {
        await _videoController!.seekTo(state.startPosition!);
      }

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
        allowPlaybackSpeedChanging: true,
        playbackSpeeds: AppConstants.videoSpeeds,
        deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.primary,
          handleColor: AppColors.primary,
          backgroundColor: Colors.white24,
          bufferedColor: AppColors.primaryLight.withValues(alpha: 0.5),
        ),
        placeholder: Container(color: Colors.black),
        autoInitialize: true,
      );

      // Progress kuzatish
      _videoController!.addListener(_onVideoProgress);

      state = state.copyWith(isInitialized: true, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Videoni yuklashda xatolik: ${e.toString()}',
      );
    }
  }

  void _onVideoProgress() {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) return;

    final position = controller.value.position;
    final duration = controller.value.duration;
    if (duration.inSeconds == 0) return;

    final percent =
        ((position.inSeconds / duration.inSeconds) * 100).round();

    if ((percent - state.watchedPercent).abs() >=
        AppConstants.progressSaveThreshold) {
      state = state.copyWith(watchedPercent: percent);
      // TODO: Save progress to backend
    }
  }

  Future<void> setSpeed(double speed) async {
    await _videoController?.setPlaybackSpeed(speed);
    state = state.copyWith(speed: speed);
  }

  void setStartPosition(Duration position) {
    state = state.copyWith(startPosition: position);
  }

}

// ─── Video Player Page ───────────────────────────────────────────────────────

class VideoPlayerPage extends ConsumerWidget {
  const VideoPlayerPage({
    super.key,
    required this.lessonId,
    required this.videoUrl,
    required this.title,
    this.watchedPercent = 0,
  });

  final String lessonId;
  final String videoUrl;
  final String title;
  final int watchedPercent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(videoPlayerNotifierProvider(videoUrl));
    final notifier = ref.read(videoPlayerNotifierProvider(videoUrl).notifier);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          title,
          style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // Tezlik tanlash
          if (state.isInitialized)
            PopupMenuButton<double>(
              icon: const Icon(Icons.speed_rounded, color: Colors.white),
              tooltip: 'Video tezligi',
              initialValue: state.speed,
              onSelected: notifier.setSpeed,
              itemBuilder: (context) => AppConstants.videoSpeeds
                  .map(
                    (s) => PopupMenuItem(
                      value: s,
                      child: Row(
                        children: [
                          if (state.speed == s)
                            const Icon(Icons.check, size: 16,
                                color: AppColors.primary)
                          else
                            const SizedBox(width: 16),
                          const SizedBox(width: 8),
                          Text('${s}x'),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
      body: Column(
        children: [
          // ─── Video Player ─────────────────────────────────────────────
          AspectRatio(
            aspectRatio: 16 / 9,
            child: _buildPlayer(state, notifier),
          ),

          // ─── Progress ─────────────────────────────────────────────────
          if (state.watchedPercent > 0)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Ko\'rildi: ',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: state.watchedPercent / 100,
                        backgroundColor: Colors.white12,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${state.watchedPercent}%',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlayer(
      VideoPlayerState state, VideoPlayerNotifier notifier) {
    if (state.isLoading) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(
          child: CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      );
    }

    if (state.error != null) {
      return ColoredBox(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: AppColors.error, size: 48),
              const SizedBox(height: 12),
              Text(
                state.error!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => notifier._initPlayer(),
                icon: const Icon(Icons.refresh_rounded,
                    color: AppColors.primary),
                label: const Text('Qayta urinish',
                    style: TextStyle(color: AppColors.primary)),
              ),
            ],
          ),
        ),
      );
    }

    if (!state.isInitialized || notifier.chewieController == null) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Chewie(controller: notifier.chewieController!);
  }
}
