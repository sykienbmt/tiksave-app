import 'package:flutter_test/flutter_test.dart';
import 'package:tiksave_app/models/tiktok-media-item.dart';
import 'package:tiksave_app/services/tiktok-direct-web-parser.dart';
import 'package:tiksave_app/services/tiktok-parser-orchestrator.dart';
import 'package:tiksave_app/services/tiktok-tikwm-parser.dart';

class _FailingDirectParser extends TiktokDirectWebParser {
  @override
  Future<TikTokMediaItem> parse(String inputUrl) async {
    throw const FormatException('Simulated WAF challenge on direct HTML');
  }
}

class _FakeTikwmParser extends TiktokTikwmParser {
  @override
  Future<TikTokMediaItem> parse(String sharedUrl) async {
    return parseResponse({
      'code': 0,
      'msg': 'success',
      'data': {
        'id': '7411111111111111111',
        'title': 'Fallback HD Video',
        'author': {
          'nickname': 'Fallback User',
          'unique_id': 'fallback_user',
        },
        'hdplay': 'https://cdn.tikwm.com/original_hd_no_wm.mp4',
        'play': 'https://cdn.tikwm.com/normal_no_wm.mp4',
        'hd_size': 10485760,
      },
    });
  }
}

void main() {
  group('TiktokParserOrchestrator', () {
    test('automatically falls back to TikWM HD parser when Direct parser fails', () async {
      final orchestrator = TiktokParserOrchestrator(
        directParser: _FailingDirectParser(),
        tikwmParser: _FakeTikwmParser(),
      );

      final item = await orchestrator.parseFromText(
        'Check this out https://vt.tiktok.com/ZSjTest123/',
      );

      expect(item.id, equals('7411111111111111111'));
      expect(item.mediaType, equals(TikTokMediaType.video));
      expect(
        item.bestVideoUrl,
        equals('https://cdn.tikwm.com/original_hd_no_wm.mp4'),
      );
      expect(item.providerName, equals('TikWM Original HD'));
    });
  });
}

