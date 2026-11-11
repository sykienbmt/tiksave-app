import 'package:flutter/material.dart';
import '../models/tiktok-media-item.dart';
import 'tiksave-theme.dart';

class PhotoSlideGrid extends StatelessWidget {
  final TikTokMediaItem item;
  final bool isDownloading;
  final Set<int> savedIndices;
  final int? activeDownloadingIndex;
  final ValueChanged<int> onDownloadSingle;
  final VoidCallback onDownloadAll;

  const PhotoSlideGrid({
    super.key,
    required this.item,
    required this.isDownloading,
    required this.savedIndices,
    required this.activeDownloadingIndex,
    required this.onDownloadSingle,
    required this.onDownloadAll,
  });

  @override
  Widget build(BuildContext context) {
    final total = item.imageUrls.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TikSaveGradientButton(
          onPressed: isDownloading ? null : onDownloadAll,
          icon: Icons.collections_bookmark_rounded,
          label: 'Tải tất cả $total ảnh gốc (Không Logo)',
          verticalPadding: 15,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            const Icon(Icons.touch_app_rounded, color: TikSaveTheme.neonCyan, size: 16),
            const SizedBox(width: 6),
            Text(
              'Hoặc chọn tải lẻ từng tấm ảnh ($total tấm):',
              style: const TextStyle(
                color: TikSaveTheme.textSecondary,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: total,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.75,
          ),
          itemBuilder: (context, index) => _buildSlideTile(index),
        ),
      ],
    );
  }

  Widget _buildSlideTile(int index) {
    final imageUrl = item.imageUrls[index];
    final isSaved = savedIndices.contains(index);
    final isCurrentLoading = activeDownloadingIndex == index;
    final badgeNum = (index + 1).toString().padLeft(2, '0');

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSaved
              ? TikSaveTheme.neonEmerald.withValues(alpha: 0.65)
              : TikSaveTheme.borderGlass,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              color: TikSaveTheme.surfaceRecessed,
              child: Image.network(
                imageUrl,
                headers: item.headers,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: TikSaveTheme.textMuted,
                    size: 36,
                  ),
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.35),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.82),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 9,
              left: 9,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: TikSaveTheme.bgObsidian.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: TikSaveTheme.borderGlass),
                ),
                child: Text(
                  '#$badgeNum',
                  style: const TextStyle(
                    color: TikSaveTheme.neonCyan,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 9,
              left: 9,
              right: 9,
              child: ElevatedButton.icon(
                onPressed: isDownloading ? null : () => onDownloadSingle(index),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSaved
                      ? TikSaveTheme.neonEmerald
                      : TikSaveTheme.bgObsidian.withValues(alpha: 0.88),
                  foregroundColor: isSaved ? Colors.black : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: isSaved
                          ? TikSaveTheme.neonEmerald
                          : TikSaveTheme.neonCyan.withValues(alpha: 0.45),
                    ),
                  ),
                ),
                icon: isCurrentLoading
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: TikSaveTheme.neonCyan,
                        ),
                      )
                    : Icon(
                        isSaved ? Icons.check_circle_rounded : Icons.download_rounded,
                        size: 16,
                      ),
                label: Text(
                  isSaved ? 'Đã lưu' : 'Tải ảnh lẻ',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
