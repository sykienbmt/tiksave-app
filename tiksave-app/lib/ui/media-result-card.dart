import 'package:flutter/material.dart';
import '../models/tiktok-media-item.dart';
import 'photo-slide-grid.dart';
import 'tiksave-theme.dart';

class MediaResultCard extends StatelessWidget {
  final TikTokMediaItem item;
  final bool isDownloading;
  final Set<int> savedSlideIndices;
  final int? activeSlideDownloadingIndex;
  final VoidCallback onDownloadVideo;
  final ValueChanged<int> onDownloadSingleSlide;
  final VoidCallback onDownloadAllSlides;

  const MediaResultCard({
    super.key,
    required this.item,
    required this.isDownloading,
    required this.savedSlideIndices,
    required this.activeSlideDownloadingIndex,
    required this.onDownloadVideo,
    required this.onDownloadSingleSlide,
    required this.onDownloadAllSlides,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: TikSaveTheme.bentoCardDecoration(
        borderColor: TikSaveTheme.neonRose.withValues(alpha: 0.32),
        glowColor: TikSaveTheme.neonRose,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildAuthorHeader(),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              TikSaveTheme.pillBadge(item.qualityBadge, TikSaveTheme.neonCyan),
              TikSaveTheme.pillBadge('NO WATERMARK', TikSaveTheme.neonEmerald),
              TikSaveTheme.pillBadge(item.providerName, const Color(0xFFA855F7)),
            ],
          ),
          if (item.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: TikSaveTheme.surfaceRecessed,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: TikSaveTheme.borderGlass),
              ),
              child: Text(
                item.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: TikSaveTheme.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          if (item.isPhotoSlide)
            PhotoSlideGrid(
              item: item,
              isDownloading: isDownloading,
              savedIndices: savedSlideIndices,
              activeDownloadingIndex: activeSlideDownloadingIndex,
              onDownloadSingle: onDownloadSingleSlide,
              onDownloadAll: onDownloadAllSlides,
            )
          else
            _buildVideoSection(),
        ],
      ),
    );
  }

  Widget _buildAuthorHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            gradient: TikSaveTheme.brandDualGradient,
            shape: BoxShape.circle,
          ),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: TikSaveTheme.surfaceRecessed,
            backgroundImage: item.authorAvatar.isNotEmpty
                ? NetworkImage(item.authorAvatar)
                : null,
            child: item.authorAvatar.isEmpty
                ? const Icon(Icons.person_rounded, color: TikSaveTheme.neonCyan)
                : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.authorName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: TikSaveTheme.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              if (item.authorHandle.isNotEmpty)
                Text(
                  '@${item.authorHandle}',
                  style: const TextStyle(color: TikSaveTheme.textSecondary, fontSize: 12.5),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVideoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (item.coverUrl.isNotEmpty) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 230,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    item.coverUrl,
                    headers: item.headers,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: TikSaveTheme.surfaceRecessed,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.movie_creation_outlined,
                        color: TikSaveTheme.textMuted,
                        size: 46,
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.72)],
                      ),
                    ),
                  ),
                  const Positioned(
                    bottom: 12,
                    left: 12,
                    child: Text(
                      'Original Stream • Không dính ID/Watermark',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
        ],
        TikSaveGradientButton(
          onPressed: isDownloading ? null : onDownloadVideo,
          icon: Icons.file_download_rounded,
          label: 'Tải Video Chất Lượng Gốc (Không Logo)',
          verticalPadding: 16,
        ),
      ],
    );
  }
}
