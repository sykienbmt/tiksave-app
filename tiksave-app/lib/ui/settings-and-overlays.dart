import 'package:flutter/material.dart';
import '../controllers/home-download-controller.dart';
import 'tiksave-theme.dart';

class TikSaveOverlays {
  static void showFloatingToast(
    BuildContext context, {
    required String message,
    required bool isError,
  }) {
    final accent = isError ? const Color(0xFFFF4D6D) : TikSaveTheme.neonEmerald;
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: TikSaveTheme.cardTop.withValues(alpha: 0.96),
        elevation: 12,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: accent.withValues(alpha: 0.65), width: 1.2),
        ),
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline_rounded : Icons.check_circle_rounded,
              color: accent,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: TikSaveTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void showSettingsSheet(
    BuildContext context,
    HomeDownloadController controller,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: TikSaveTheme.cardTop,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: TikSaveTheme.borderGlass,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Cài đặt TikSave',
                    style: TextStyle(
                      color: TikSaveTheme.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: TikSaveTheme.surfaceRecessed,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: TikSaveTheme.borderGlass),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.ios_share_rounded,
                          color: TikSaveTheme.neonCyan,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tự động tải Video khi Share',
                                style: TextStyle(
                                  color: TikSaveTheme.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13.5,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Video tự lưu ngay; Album ảnh sẽ mở màn hình chọn ảnh',
                                style: TextStyle(
                                  color: TikSaveTheme.textSecondary,
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: controller.autoDownloadOnShare,
                          activeThumbColor: TikSaveTheme.neonCyan,
                          onChanged: (val) {
                            controller.toggleAutoDownload(val);
                            setModalState(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class FloatingProgressPill extends StatelessWidget {
  final String message;
  final double? progress;

  const FloatingProgressPill({
    super.key,
    required this.message,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: TikSaveTheme.bentoCardDecoration(
        radius: 16,
        borderColor: TikSaveTheme.neonCyan.withValues(alpha: 0.45),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.isNotEmpty ? message : 'Đang xử lý...',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: TikSaveTheme.textPrimary,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white12,
            color: TikSaveTheme.neonCyan,
            minHeight: 5,
            borderRadius: BorderRadius.circular(6),
          ),
        ],
      ),
    );
  }
}
