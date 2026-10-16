import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:saris_cosmo_center/core/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:saris_cosmo_center/core/utils/app_snackbar.dart';
import '../../models/enrollment_model.dart';
import '../../controllers/enrollment_detail_controller.dart';

class LessonDetailScreen extends StatefulWidget {
  final Map<String, dynamic> lesson;
  final Enrollment enrollment;
  final LessonProgress? progress;
  final EnrollmentDetailController detailController;

  const LessonDetailScreen({
    super.key,
    required this.lesson,
    required this.enrollment,
    this.progress,
    required this.detailController,
  });

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  YoutubePlayerController? _youtubeController;
  late final int _lessonId;
  late final String _title;
  int? _duration;
  String? _classType;
  String? _content;
  String? _location;
  String? _instructions;
  String? _videoUrl;

  @override
  void initState() {
    super.initState();
    _lessonId = widget.lesson['id'] ?? 0;
    _title = widget.lesson['title']?.toString() ?? 'Lesson Details';
    _duration = widget.lesson['duration_minutes'] as int?;
    _classType = widget.lesson['class_type']?.toString();
    _content = widget.lesson['content']?.toString();
    _location = widget.lesson['location']?.toString();
    _instructions = widget.lesson['instructions']?.toString();
    _videoUrl = widget.lesson['video_url']?.toString();

    _initializeYoutubePlayer();
  }

  String? _extractVideoId(String url) {
    if (url.contains('youtube.com/shorts/')) {
      final match = url.split('youtube.com/shorts/').last;
      return match.split('?').first.split('&').first.trim();
    }
    if (url.contains('youtu.be/')) {
      final match = url.split('youtu.be/').last;
      return match.split('?').first.split('&').first.trim();
    }
    if (url.contains('youtube.com/embed/')) {
      final match = url.split('youtube.com/embed/').last;
      return match.split('?').first.split('&').first.trim();
    }
    return YoutubePlayer.convertUrlToId(url);
  }

  void _initializeYoutubePlayer() {
    if (_videoUrl != null && _videoUrl!.trim().isNotEmpty) {
      final videoId = _extractVideoId(_videoUrl!);
      if (videoId != null && videoId.isNotEmpty) {
        _youtubeController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
            disableDragSeek: false,
            loop: false,
            isLive: false,
            forceHD: false,
            enableCaption: true,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    // Always restore system UI when leaving this screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    super.dispose();
  }

  Future<void> _launchUrl(String urlString) async {
    try {
      final Uri url = Uri.parse(urlString);
      bool launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!launched) {
        launched = await launchUrl(url);
      }
      if (!launched) {
        AppSnackbar.error(
          'Error',
          'Could not open link in browser.',
        );
      }
    } catch (e) {
      debugPrint('Launch Error: $e');
      try {
        final Uri url = Uri.parse(urlString);
        await launchUrl(url);
      } catch (fallbackError) {
        AppSnackbar.error(
          'Error',
          'Failed to open link: $fallbackError',
        );
      }
    }
  }

  String _formatClassType(String? type) {
    if (type == null) return 'Class';
    switch (type.toLowerCase()) {
      case 'online_video':
        return 'Online Video';
      case 'offline_class':
        return 'Offline Class';
      case 'practical':
        return 'Practical';
      default:
        return type.replaceAll('_', ' ').capitalizeFirst ?? type;
    }
  }

  IconData _getClassTypeIcon(String? type) {
    if (type == null) return Icons.class_outlined;
    switch (type.toLowerCase()) {
      case 'online_video':
        return Icons.play_circle_outline_rounded;
      case 'offline_class':
        return Icons.school_outlined;
      case 'practical':
        return Icons.science_outlined;
      default:
        return Icons.book_outlined;
    }
  }

  Widget _buildDetailsBody(BuildContext context) {
    final hasProgress = widget.detailController.enrollment.value?.lessonProgress
        .firstWhereOrNull((p) => p.lessonId == _lessonId);
    final status = (hasProgress?.status ?? widget.progress?.status ?? 'not_started').toLowerCase();
    final isCompleted = status == 'completed';
    final isAttended = status == 'attended';

    return Container(
      color: AppTheme.background,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section inside details
          Text(
            _title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),

          // Tags: Class type & duration & completion status
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getClassTypeIcon(_classType),
                      size: 14,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatClassType(_classType),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              if (_duration != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.textMedium.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: AppTheme.textMedium,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$_duration mins',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green.shade50
                      : isAttended
                          ? Colors.blue.shade50
                          : AppTheme.divider.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isCompleted
                      ? 'Completed'
                      : isAttended
                          ? 'Attended'
                          : 'Not Started',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isCompleted
                        ? Colors.green.shade700
                        : isAttended
                            ? Colors.blue.shade700
                            : AppTheme.textMedium,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Content description section
          if (_content != null && _content!.trim().isNotEmpty) ...[
            const Text(
              'Content Description',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textMedium,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.divider.withValues(alpha: 0.8)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Text(
                _content!,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppTheme.textDark,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Venue/Location Section
          if (_location != null && _location!.trim().isNotEmpty) ...[
            const Text(
              'Location / Venue',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textMedium,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.divider.withValues(alpha: 0.8)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on_rounded, size: 20, color: AppTheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _location!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Instructions Section
          if (_instructions != null && _instructions!.trim().isNotEmpty) ...[
            const Text(
              'Special Instructions',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textMedium,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50.withValues(alpha: 0.3),
                border: Border.all(color: Colors.amber.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, color: Colors.amber.shade900, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _instructions!,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: Colors.amber.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Video Url if YouTube player wasn't loaded but URL is present
          if (_youtubeController == null && _videoUrl != null && _videoUrl!.trim().isNotEmpty) ...[
            const Text(
              'Video Resources',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textMedium,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _launchUrl(_videoUrl!),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.play_circle_outline, color: Colors.blue.shade700, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _videoUrl!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          decoration: TextDecoration.underline,
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_youtubeController == null) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: const Text('Lesson Details'),
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Obx(() => _buildDetailsBody(context)),
                ),
              ),
              _buildBottomActionBar(),
            ],
          ),
        ),
      );
    }

    return YoutubePlayerBuilder(
      onEnterFullScreen: () {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      },
      onExitFullScreen: () {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
        // Restore system UI overlays (status bar + navigation bar)
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: SystemUiOverlay.values,
        );
        // Restore the app's default status bar style
        SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
        );
      },
      player: YoutubePlayer(
        controller: _youtubeController!,
        showVideoProgressIndicator: true,
        progressIndicatorColor: AppTheme.primary,
        progressColors: const ProgressBarColors(
          playedColor: AppTheme.primary,
          handleColor: AppTheme.primary,
        ),
        onEnded: (data) {
          _youtubeController!.seekTo(Duration.zero);
          _youtubeController!.pause();
        },
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            title: const Text('Lesson Player'),
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                player,
                Expanded(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Obx(() => _buildDetailsBody(context)),
                  ),
                ),
                _buildBottomActionBar(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: const Border(
          top: BorderSide(color: AppTheme.divider),
        ),
      ),
      child: Obx(() {
        final isUpdating = widget.detailController.isUpdatingProgress.value;
        final hasProgress = widget.detailController.enrollment.value?.lessonProgress
            .firstWhereOrNull((p) => p.lessonId == _lessonId);
        final status = (hasProgress?.status ?? widget.progress?.status ?? 'not_started').toLowerCase();
        final isCompleted = status == 'completed';
        final nextStatus = isCompleted ? 'not_started' : 'completed';

        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: isUpdating ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.textMedium,
                  side: const BorderSide(color: AppTheme.divider),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isUpdating
                    ? null
                    : () async {
                        await widget.detailController.updateProgress(
                          widget.enrollment.id,
                          _lessonId,
                          nextStatus,
                        );
                      },
                icon: isUpdating
                    ? const SizedBox.shrink()
                    : Icon(
                        isCompleted ? Icons.undo_rounded : Icons.check_circle_outline_rounded,
                        size: 18,
                      ),
                label: isUpdating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        isCompleted ? 'Mark Incomplete' : 'Mark Complete',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCompleted ? AppTheme.primary : AppTheme.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
