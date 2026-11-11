enum TikTokMediaType {
  video,
  photoSlide,
}

class TikTokVideoStream {
  final String url;
  final List<String> mirrorUrls;
  final int width;
  final int height;
  final int bitrate;
  final int dataSize;
  final String gearName;
  final String codecType;

  const TikTokVideoStream({
    required this.url,
    this.mirrorUrls = const [],
    this.width = 0,
    this.height = 0,
    this.bitrate = 0,
    this.dataSize = 0,
    this.gearName = '',
    this.codecType = '',
  });

  int get maxDimension => width > height ? width : height;

  String get resolutionLabel {
    if (width <= 0 || height <= 0) return 'Original HD';
    return '${width}x$height';
  }
}

class TikTokMediaItem {
  final String id;
  final String authorName;
  final String authorHandle;
  final String authorAvatar;
  final String description;
  final String coverUrl;
  final TikTokMediaType mediaType;
  final String? bestVideoUrl;
  final List<String> videoMirrorUrls;
  final int videoWidth;
  final int videoHeight;
  final int videoBitrate;
  final int videoSize;
  final List<String> imageUrls;
  final String? musicUrl;
  final Map<String, String> headers;
  final String providerName;

  const TikTokMediaItem({
    required this.id,
    required this.authorName,
    this.authorHandle = '',
    this.authorAvatar = '',
    required this.description,
    this.coverUrl = '',
    required this.mediaType,
    this.bestVideoUrl,
    this.videoMirrorUrls = const [],
    this.videoWidth = 0,
    this.videoHeight = 0,
    this.videoBitrate = 0,
    this.videoSize = 0,
    this.imageUrls = const [],
    this.musicUrl,
    this.headers = const {},
    required this.providerName,
  });

  bool get isPhotoSlide => mediaType == TikTokMediaType.photoSlide;

  String get qualityBadge {
    if (isPhotoSlide) {
      return '${imageUrls.length} ảnh gốc (No Logo)';
    }
    final parts = <String>[];
    if (videoWidth > 0 && videoHeight > 0) {
      parts.add('${videoWidth}x$videoHeight');
    } else {
      parts.add('Original HD');
    }
    if (videoBitrate > 0) {
      final mbps = (videoBitrate / 1000000).toStringAsFixed(1);
      parts.add('$mbps Mbps');
    }
    if (videoSize > 0) {
      final mb = (videoSize / (1024 * 1024)).toStringAsFixed(1);
      parts.add('$mb MB');
    }
    return parts.join(' • ');
  }
}

