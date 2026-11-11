import 'package:flutter/material.dart';
import 'tiksave-theme.dart';

class UrlInputSection extends StatelessWidget {
  final TextEditingController textController;
  final bool busy;
  final bool autoDownloadOnShare;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final VoidCallback onPasteAndParse;
  final VoidCallback onDownloadImmediate;
  final ValueChanged<bool> onToggleAutoDownload;

  const UrlInputSection({
    super.key,
    required this.textController,
    required this.busy,
    required this.autoDownloadOnShare,
    required this.onChanged,
    required this.onClear,
    required this.onPasteAndParse,
    required this.onDownloadImmediate,
    required this.onToggleAutoDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: TikSaveTheme.bentoCardDecoration(
            borderColor: TikSaveTheme.neonCyan.withValues(alpha: 0.28),
            glowColor: TikSaveTheme.neonCyan,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  TikSaveTheme.pillBadge('COMMAND CONSOLE', TikSaveTheme.neonCyan),
                  const Spacer(),
                  const Text(
                    'Video & Photo Slide',
                    style: TextStyle(
                      color: TikSaveTheme.textMuted,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: textController,
                onChanged: onChanged,
                style: const TextStyle(
                  color: TikSaveTheme.textPrimary,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Dán link TikTok tại đây...',
                  hintStyle: const TextStyle(color: TikSaveTheme.textMuted, fontSize: 13),
                  prefixIcon: const Icon(
                    Icons.link_rounded,
                    color: TikSaveTheme.neonCyan,
                    size: 19,
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 40),
                  filled: true,
                  fillColor: TikSaveTheme.surfaceRecessed,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: TikSaveTheme.borderGlass),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: TikSaveTheme.neonCyan, width: 1.4),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: TikSaveTheme.textSecondary,
                      size: 18,
                    ),
                    onPressed: onClear,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: busy ? null : onPasteAndParse,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: TikSaveTheme.neonCyan,
                        backgroundColor: TikSaveTheme.surfaceRecessed,
                        side: BorderSide(
                          color: TikSaveTheme.neonCyan.withValues(alpha: 0.55),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.content_paste_rounded, size: 17),
                            SizedBox(width: 6),
                            Text(
                              'Dán & Phân Tích',
                              maxLines: 1,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TikSaveGradientButton(
                      onPressed: busy ? null : onDownloadImmediate,
                      icon: Icons.bolt_rounded,
                      label: 'Tải Gốc Ngay',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: TikSaveTheme.bentoCardDecoration(radius: 18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: TikSaveTheme.neonCyan.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.ios_share_rounded,
                  color: TikSaveTheme.neonCyan,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tự động tải khi Share',
                      maxLines: 1,
                      style: TextStyle(
                        color: TikSaveTheme.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                      ),
                    ),
                    SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Chia sẻ từ TikTok để lưu thẳng vào máy',
                        maxLines: 1,
                        style: TextStyle(
                          color: TikSaveTheme.textSecondary,
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: autoDownloadOnShare,
                activeThumbColor: TikSaveTheme.neonCyan,
                activeTrackColor: TikSaveTheme.neonCyan.withValues(alpha: 0.25),
                onChanged: onToggleAutoDownload,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
