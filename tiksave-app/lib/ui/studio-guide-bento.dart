import 'package:flutter/material.dart';
import 'tiksave-theme.dart';

class StudioGuideBento extends StatelessWidget {
  const StudioGuideBento({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: TikSaveTheme.bentoCardDecoration(radius: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  TikSaveTheme.pillBadge('ONE-TAP WORKFLOW', TikSaveTheme.neonCyan),
                  const Spacer(),
                  const Text(
                    'Chia sẻ từ TikTok',
                    maxLines: 1,
                    style: TextStyle(
                      color: TikSaveTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _stepTile(
                '01',
                'Bấm nút Chia sẻ trên TikTok',
                'Hỗ trợ cả Video và Album ảnh (Slide)',
                TikSaveTheme.neonCyan,
              ),
              const SizedBox(height: 9),
              _stepTile(
                '02',
                'Chọn biểu tượng ứng dụng TikSave',
                'Không cần tự copy hay dán link thủ công',
                const Color(0xFFA855F7),
              ),
              const SizedBox(height: 9),
              _stepTile(
                '03',
                'Tự động lưu bản gốc Không Logo',
                'Lưu trực tiếp vào Album TikSave trên máy',
                TikSaveTheme.neonRose,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _bentoTile(
                Icons.hd_rounded,
                TikSaveTheme.neonCyan,
                'Original Bitrate',
                'Chuẩn 1080p/2K nguyên bản',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _bentoTile(
                Icons.auto_awesome_mosaic_rounded,
                TikSaveTheme.neonRose,
                'Photo Slide & Lẻ',
                'Tải cả album hoặc từng tấm',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _bentoTile(
                Icons.hide_source_rounded,
                TikSaveTheme.neonEmerald,
                'No Watermark',
                'Sạch 100% logo & ID TikTok',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _bentoTile(
                Icons.shield_moon_rounded,
                const Color(0xFF38BDF8),
                'Dual-Engine Core',
                'Direct SSR & TikWM HD',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _stepTile(String step, String title, String subtitle, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: TikSaveTheme.surfaceRecessed,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TikSaveTheme.borderGlass),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: accent.withValues(alpha: 0.45)),
            ),
            child: Text(
              step,
              style: TextStyle(color: accent, fontWeight: FontWeight.w900, fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    maxLines: 1,
                    style: const TextStyle(
                      color: TikSaveTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    subtitle,
                    maxLines: 1,
                    style: const TextStyle(color: TikSaveTheme.textSecondary, fontSize: 11.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bentoTile(IconData icon, Color accent, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: TikSaveTheme.bentoCardDecoration(radius: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              maxLines: 1,
              style: const TextStyle(
                color: TikSaveTheme.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 13.5,
              ),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              subtitle,
              maxLines: 1,
              style: const TextStyle(color: TikSaveTheme.textSecondary, fontSize: 11.5),
            ),
          ),
        ],
      ),
    );
  }
}
