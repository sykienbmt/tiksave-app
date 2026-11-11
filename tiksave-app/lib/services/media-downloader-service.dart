import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../models/tiktok-media-item.dart';

typedef DownloadProgressCallback = void Function(
  double progress,
  String statusMessage,
);

class MediaDownloaderService {
  final Dio _dio;

  MediaDownloaderService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 25),
              receiveTimeout: const Duration(minutes: 4),
              followRedirects: true,
            ));

  /// Downloads the video of a [TikTokMediaItem] to a temporary `.mp4` file.
  /// Automatically retries mirror URLs if the primary CDN URL fails.
  Future<File> downloadVideo(
    TikTokMediaItem item, {
    required DownloadProgressCallback onProgress,
  }) async {
    final candidates = <String>[
      if (item.bestVideoUrl != null && item.bestVideoUrl!.isNotEmpty)
        item.bestVideoUrl!,
      ...item.videoMirrorUrls.where((u) => u != item.bestVideoUrl),
    ];

    if (candidates.isEmpty) {
      throw const FormatException('Không có URL video hợp lệ để tải.');
    }

    final tempDir = await getTemporaryDirectory();
    final targetPath =
        '${tempDir.path}/tiksave_${item.id}_${DateTime.now().millisecondsSinceEpoch}.mp4';

    Object? lastError;
    for (var i = 0; i < candidates.length; i++) {
      final url = candidates[i];
      try {
        onProgress(0.02, 'Đang kết nối máy chủ tải video gốc...');
        await _dio.download(
          url,
          targetPath,
          options: Options(headers: item.headers),
          onReceiveProgress: (received, total) {
            if (total > 0) {
              final ratio = received / total;
              final pct = (ratio * 100).clamp(0, 100).toStringAsFixed(0);
              onProgress(ratio, 'Đang tải video chất lượng gốc ($pct%)...');
            } else {
              final mb = (received / (1024 * 1024)).toStringAsFixed(1);
              onProgress(0.5, 'Đang tải video ($mb MB)...');
            }
          },
        );
        final file = File(targetPath);
        if (await file.exists() && await file.length() > 1024) {
          onProgress(1.0, 'Đã tải xong video gốc!');
          return file;
        }
      } catch (err) {
        lastError = err;
      }
    }

    throw Exception('Tải video thất bại sau ${candidates.length} mirror: $lastError');
  }

  /// Downloads a single image at [index] from a Photo Slide post.
  Future<File> downloadSingleImage(
    TikTokMediaItem item,
    int index, {
    required DownloadProgressCallback onProgress,
  }) async {
    if (index < 0 || index >= item.imageUrls.length) {
      throw RangeError.index(index, item.imageUrls, 'index');
    }
    final imageUrl = item.imageUrls[index];
    final tempDir = await getTemporaryDirectory();
    final ext = _guessImageExtension(imageUrl);
    final targetPath =
        '${tempDir.path}/tiksave_${item.id}_slide_${index + 1}.$ext';

    onProgress(0.1, 'Đang tải ảnh ${index + 1}/${item.imageUrls.length}...');
    await _dio.download(
      imageUrl,
      targetPath,
      options: Options(headers: item.headers),
      onReceiveProgress: (received, total) {
        if (total > 0) {
          onProgress(
            received / total,
            'Đang tải ảnh ${index + 1}/${item.imageUrls.length}...',
          );
        }
      },
    );
    onProgress(1.0, 'Đã tải xong ảnh ${index + 1}!');
    return File(targetPath);
  }

  /// Downloads all images from a Photo Slide post.
  Future<List<File>> downloadAllImages(
    TikTokMediaItem item, {
    required DownloadProgressCallback onProgress,
  }) async {
    final total = item.imageUrls.length;
    if (total == 0) {
      throw const FormatException('Bài viết không có danh sách ảnh để tải.');
    }

    final files = <File>[];
    try {
      for (var i = 0; i < total; i++) {
        final file = await downloadSingleImage(
          item,
          i,
          onProgress: (subProgress, _) {
            final overall = (i + subProgress) / total;
            onProgress(overall, 'Đang tải ảnh ${i + 1}/$total (Chất lượng gốc)...');
          },
        );
        files.add(file);
      }
      onProgress(1.0, 'Đã tải trọn bộ $total ảnh gốc!');
      return files;
    } catch (_) {
      for (final f in files) {
        try {
          if (await f.exists()) await f.delete();
        } catch (_) {}
      }
      rethrow;
    }
  }

  static String _guessImageExtension(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('.png')) return 'png';
    if (lower.contains('.webp')) return 'webp';
    return 'jpg';
  }
}

