import 'package:dio/dio.dart';
import '../models/tiktok-media-item.dart';

class TiktokTikwmParser {
  static const String _apiUrl = 'https://www.tikwm.com/api/';
  static const String _userAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36';

  final Dio _dio;

  TiktokTikwmParser({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 20),
              headers: {
                'User-Agent': _userAgent,
                'Referer': 'https://www.tikwm.com/',
              },
            ));

  Future<TikTokMediaItem> parse(String sharedUrl) async {
    final response = await _dio.get<Map<String, dynamic>>(
      _apiUrl,
      queryParameters: {
        'url': sharedUrl,
        'hd': '1',
      },
    );

    final body = response.data;
    if (body == null) {
      throw const FormatException('Phản hồi rỗng từ TikWM API.');
    }

    return parseResponse(body);
  }

  TikTokMediaItem parseResponse(Map<String, dynamic> body) {
    final code = body['code'];
    final data = body['data'] as Map<String, dynamic>?;
    if (code != 0 || data == null) {
      final msg = (body['msg'] ?? 'Không thể phân tích link TikTok này.').toString();
      throw FormatException(msg);
    }

    final id = (data['id'] ?? DateTime.now().millisecondsSinceEpoch).toString();
    final title = (data['title'] ?? '').toString();
    final author = (data['author'] as Map<String, dynamic>?) ?? const {};
    final authorName = (author['nickname'] ?? author['unique_id'] ?? 'TikTok').toString();
    final authorHandle = (author['unique_id'] ?? '').toString();
    final authorAvatar = (author['avatar'] ?? '').toString();
    final coverUrl = (data['origin_cover'] ?? data['cover'] ?? '').toString();

    final images = (data['images'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .where((u) => u.isNotEmpty)
            .toList() ??
        const [];

    final headers = const <String, String>{
      'User-Agent': _userAgent,
      'Referer': 'https://www.tikwm.com/',
    };

    if (images.isNotEmpty) {
      return TikTokMediaItem(
        id: id,
        authorName: authorName,
        authorHandle: authorHandle,
        authorAvatar: authorAvatar,
        description: title,
        coverUrl: coverUrl.isNotEmpty ? coverUrl : images.first,
        mediaType: TikTokMediaType.photoSlide,
        imageUrls: images,
        musicUrl: (data['music'] ?? '').toString(),
        headers: headers,
        providerName: 'TikWM Original HD',
      );
    }

    final hdPlay = (data['hdplay'] ?? '').toString();
    final normalPlay = (data['play'] ?? '').toString();
    final bestUrl = hdPlay.isNotEmpty ? hdPlay : normalPlay;

    if (bestUrl.isEmpty) {
      throw const FormatException('Không tìm thấy URL tải video không logo.');
    }

    final hdSize = _toInt(data['hd_size']) ?? _toInt(data['size']) ?? 0;

    return TikTokMediaItem(
      id: id,
      authorName: authorName,
      authorHandle: authorHandle,
      authorAvatar: authorAvatar,
      description: title,
      coverUrl: coverUrl,
      mediaType: TikTokMediaType.video,
      bestVideoUrl: bestUrl,
      videoMirrorUrls: [
        if (hdPlay.isNotEmpty) hdPlay,
        if (normalPlay.isNotEmpty && normalPlay != hdPlay) normalPlay,
      ],
      videoSize: hdSize,
      musicUrl: (data['music'] ?? '').toString(),
      headers: headers,
      providerName: 'TikWM Original HD',
    );
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}

