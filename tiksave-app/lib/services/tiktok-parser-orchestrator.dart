import '../models/tiktok-media-item.dart';
import 'tiktok-direct-web-parser.dart';
import 'tiktok-tikwm-parser.dart';
import 'tiktok-url-extractor.dart';

class TiktokParserOrchestrator {
  final TiktokDirectWebParser _directParser;
  final TiktokTikwmParser _tikwmParser;

  TiktokParserOrchestrator({
    TiktokDirectWebParser? directParser,
    TiktokTikwmParser? tikwmParser,
  })  : _directParser = directParser ?? TiktokDirectWebParser(),
        _tikwmParser = tikwmParser ?? TiktokTikwmParser();

  /// Resolves and parses a shared TikTok text/URL using a dual-provider chain:
  /// 1. Direct TikTok Web SSR (`__UNIVERSAL_DATA_FOR_REHYDRATION__` -> `bitrateInfo` highest quality)
  /// 2. Fallback to `tikwm.com` HD API (`hd=1`) if Direct SSR is blocked by WAF/Captcha.
  Future<TikTokMediaItem> parseFromText(String rawTextOrUrl) async {
    final cleanUrl = TiktokUrlExtractor.extract(rawTextOrUrl);
    if (cleanUrl == null || cleanUrl.isEmpty) {
      throw const FormatException(
        'Không tìm thấy đường dẫn TikTok hợp lệ trong nội dung đã nhập.',
      );
    }

    Object? firstError;
    try {
      return await _directParser.parse(cleanUrl);
    } catch (err) {
      firstError = err;
    }

    try {
      return await _tikwmParser.parse(cleanUrl);
    } catch (secondError) {
      throw FormatException(
        'Không thể lấy dữ liệu TikTok (Direct: $firstError | Fallback: $secondError)',
      );
    }
  }
}

