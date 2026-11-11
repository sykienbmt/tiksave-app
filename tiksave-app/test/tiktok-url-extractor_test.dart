import 'package:flutter_test/flutter_test.dart';
import 'package:tiksave_app/services/tiktok-url-extractor.dart';

void main() {
  group('TiktokUrlExtractor', () {
    test('extracts short vt.tiktok.com link from share text with emoji and punctuation', () {
      const shareText =
          'Xem video siêu nét này nhé! 😍 https://vt.tiktok.com/ZSjAbCdEf/。';
      expect(
        TiktokUrlExtractor.extract(shareText),
        equals('https://vt.tiktok.com/ZSjAbCdEf/'),
      );
    });

    test('extracts vm.tiktok.com and prepends https for bare links', () {
      const bareText = 'Copy từ TikTok: vm.tiktok.com/ZM1234567/';
      expect(
        TiktokUrlExtractor.extract(bareText),
        equals('https://vm.tiktok.com/ZM1234567/'),
      );
    });

    test('extracts canonical video and photo slide links and post IDs', () {
      const videoUrl = 'https://www.tiktok.com/@creator/video/7412345678901234567?is_from_webapp=1';
      const photoUrl = 'https://www.tiktok.com/@creator/photo/7498765432109876543';

      expect(TiktokUrlExtractor.extract(videoUrl), equals(videoUrl));
      expect(
        TiktokUrlExtractor.extractPostId(videoUrl),
        equals('7412345678901234567'),
      );
      expect(
        TiktokUrlExtractor.extractPostId(photoUrl),
        equals('7498765432109876543'),
      );
    });

    test('identifies short links vs canonical links', () {
      expect(TiktokUrlExtractor.isShortLink('https://vt.tiktok.com/ZSjAbCdEf/'), isTrue);
      expect(TiktokUrlExtractor.isShortLink('https://www.tiktok.com/t/ZP812345/'), isTrue);
      expect(
        TiktokUrlExtractor.isShortLink(
          'https://www.tiktok.com/@user/video/7412345678901234567',
        ),
        isFalse,
      );
    });

    test('returns null when text has no TikTok URL', () {
      expect(TiktokUrlExtractor.extract('Hello world https://example.com'), isNull);
      expect(TiktokUrlExtractor.extract(''), isNull);
      expect(TiktokUrlExtractor.extract(null), isNull);
    });
  });
}

