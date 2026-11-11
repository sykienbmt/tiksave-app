import 'package:flutter/material.dart';
import 'tiksave-theme.dart';

class UrlInputSection extends StatelessWidget {
  final TextEditingController textController;
  final bool busy;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final VoidCallback onPasteAndParse;
  final VoidCallback onDownloadImmediate;

  const UrlInputSection({
    super.key,
    required this.textController,
    required this.busy,
    required this.onChanged,
    required this.onClear,
    required this.onPasteAndParse,
    required this.onDownloadImmediate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
