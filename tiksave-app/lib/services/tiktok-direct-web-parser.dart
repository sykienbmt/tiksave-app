import 'dart:convert';
import 'dart:math' as math;
import 'package:dio/dio.dart';
import '../models/tiktok-media-item.dart';

class TiktokDirectWebParser {
  static const String desktopUserAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36';

  static final RegExp _rehydrationRegex = RegExp(
    r'<script[^>]+id="__UNIVERSAL_DATA_FOR_REHYDRATION__"[^>]*>([\s\S]*?)<\/script>',
    caseSensitive: false,
  );

  final Dio _dio;

  TiktokDirectWebParser({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 20),
              followRedirects: false,
              validateStatus: (status) => status != null && status < 500,
            ));

  Future<TikTokMediaItem> parse(String inputUrl) async {
    final cookies = <String, String>{};
    var currentUrl = inputUrl;
    for (var hop = 0; hop < 6; hop++) {
      final response = await _dio.get<String>(
        currentUrl,
        options: Options(responseType: ResponseType.plain, headers: _buildHtmlHeaders(cookies)),
      );
      _collectCookies(response.headers['set-cookie'], cookies);
      final status = response.statusCode ?? 0;
      if (status >= 300 && status < 400) {
        final location = response.headers.value('location');
        if (location == null || location.isEmpty) break;
        currentUrl = Uri.parse(currentUrl).resolve(location).toString();
        continue;
      }
      return parseHtml(response.data ?? '', cookies: cookies);
    }
    throw const FormatException('Quá số lần chuyển hướng khi mở link TikTok.');
  }

  TikTokMediaItem parseHtml(String html, {Map<String, String> cookies = const {}}) {
    final match = _rehydrationRegex.firstMatch(html);
    if (match == null) throw const FormatException('Không tìm thấy dữ liệu SSR trong HTML.');

    final decoded = jsonDecode(match.group(1)!) as Map<String, dynamic>;
    final scope = (decoded['__DEFAULT_SCOPE__'] as Map<String, dynamic>?) ?? const {};
    final detail = (scope['webapp.video-detail'] ?? scope['webapp.reflow.video.detail'])
        as Map<String, dynamic>?;
    final itemStruct =
        (detail?['itemInfo'] as Map<String, dynamic>?)?['itemStruct'] as Map<String, dynamic>?;
    if (itemStruct == null || itemStruct.isEmpty) {
      throw const FormatException('Không tìm thấy itemStruct trong dữ liệu web.');
    }
    return parseItemStruct(itemStruct, cookies: cookies);
  }

  TikTokMediaItem parseItemStruct(
    Map<String, dynamic> itemStruct, {
    Map<String, String> cookies = const {},
  }) {
    final id = (itemStruct['id'] ?? '').toString();
    final desc = (itemStruct['desc'] ?? '').toString();
    final author = (itemStruct['author'] as Map<String, dynamic>?) ?? const {};
    final authorName = (author['nickname'] ?? author['uniqueId'] ?? 'TikTok').toString();
    final authorHandle = (author['uniqueId'] ?? '').toString();
    final authorAvatar = (author['avatarLarger'] ?? author['avatarThumb'] ?? '').toString();
    final headers = <String, String>{
      'User-Agent': desktopUserAgent,
      'Referer': 'https://www.tiktok.com/',
      if (cookies.isNotEmpty)
        'Cookie': cookies.entries.map((e) => '${e.key}=${e.value}').join('; '),
    };

    final imageUrls = _extractSlideUrls(itemStruct['imagePost'] as Map<String, dynamic>?);
    if (imageUrls.isNotEmpty) {
      return TikTokMediaItem(
        id: id,
        authorName: authorName,
        authorHandle: authorHandle,
        authorAvatar: authorAvatar,
        description: desc,
        coverUrl: imageUrls.first,
        mediaType: TikTokMediaType.photoSlide,
        imageUrls: imageUrls,
        musicUrl: (itemStruct['music']?['playUrl'] ?? '').toString(),
        headers: headers,
        providerName: 'TikTok Direct Original',
      );
    }

    final videoNode = (itemStruct['video'] as Map<String, dynamic>?) ?? const {};
    final best = selectBestVideoStream(videoNode);
    if (best == null || best.url.isEmpty) {
      throw const FormatException('Không tìm thấy luồng video không logo.');
    }
    return TikTokMediaItem(
      id: id,
      authorName: authorName,
      authorHandle: authorHandle,
      authorAvatar: authorAvatar,
      description: desc,
      coverUrl: (videoNode['originCover'] ?? videoNode['cover'] ?? '').toString(),
      mediaType: TikTokMediaType.video,
      bestVideoUrl: best.url,
      videoMirrorUrls: best.mirrorUrls,
      videoWidth: best.width,
      videoHeight: best.height,
      videoBitrate: best.bitrate,
      videoSize: best.dataSize,
      headers: headers,
      providerName: 'TikTok Direct Original',
    );
  }

  static List<String> _extractSlideUrls(Map<String, dynamic>? imagePost) {
    final rawImages = (imagePost?['images'] as List<dynamic>?) ?? const [];
    return [
      for (final img in rawImages.whereType<Map<String, dynamic>>())
        if (((img['imageURL']?['urlList'] as List<dynamic>?) ?? const []).isNotEmpty)
          (img['imageURL']['urlList'] as List<dynamic>).first.toString(),
    ];
  }

  static TikTokVideoStream? selectBestVideoStream(Map<String, dynamic> videoNode) {
    final gears = (videoNode['bitrateInfo'] as List<dynamic>?) ?? const [];
    final streams = <TikTokVideoStream>[];
    for (final rawGear in gears.whereType<Map<String, dynamic>>()) {
      final playAddr = rawGear['PlayAddr'] as Map<String, dynamic>?;
      final urlList = (playAddr?['UrlList'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .where((u) => u.isNotEmpty)
              .toList() ??
          const [];
      if (urlList.isEmpty) continue;
      streams.add(TikTokVideoStream(
        url: urlList.first,
        mirrorUrls: urlList,
        width: _toInt(playAddr?['Width']) ?? _toInt(videoNode['width']) ?? 0,
        height: _toInt(playAddr?['Height']) ?? _toInt(videoNode['height']) ?? 0,
        bitrate: _toInt(rawGear['Bitrate']) ?? 0,
        dataSize: _toInt(playAddr?['DataSize']) ?? 0,
        gearName: (rawGear['GearName'] ?? '').toString(),
        codecType: (rawGear['CodecType'] ?? '').toString(),
      ));
    }

    if (streams.isNotEmpty) {
      streams.sort((a, b) {
        final resCmp = math.max(a.width, a.height).compareTo(math.max(b.width, b.height));
        if (resCmp != 0) return resCmp;
        final bitCmp = a.bitrate.compareTo(b.bitrate);
        return bitCmp != 0 ? bitCmp : a.dataSize.compareTo(b.dataSize);
      });
      return streams.last;
    }

    final directPlay = (videoNode['playAddr'] ?? '').toString();
    return directPlay.isEmpty
        ? null
        : TikTokVideoStream(
            url: directPlay,
            mirrorUrls: [directPlay],
            width: _toInt(videoNode['width']) ?? 0,
            height: _toInt(videoNode['height']) ?? 0,
            bitrate: _toInt(videoNode['bitrate']) ?? 0,
            dataSize: _toInt(videoNode['size']) ?? 0,
          );
  }

  static int? _toInt(dynamic v) =>
      v is int ? v : (v is num ? v.toInt() : (v is String ? int.tryParse(v) : null));

  static Map<String, String> _buildHtmlHeaders(Map<String, String> cookies) => {
        'User-Agent': desktopUserAgent,
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.9',
        'Referer': 'https://www.tiktok.com/',
        if (cookies.isNotEmpty)
          'Cookie': cookies.entries.map((e) => '${e.key}=${e.value}').join('; '),
      };

  static void _collectCookies(List<String>? rawCookies, Map<String, String> jar) {
    for (final header in rawCookies ?? const <String>[]) {
      final pair = header.split(';').first.trim();
      final idx = pair.indexOf('=');
      if (idx > 0) jar[pair.substring(0, idx).trim()] = pair.substring(idx + 1).trim();
    }
  }
}
