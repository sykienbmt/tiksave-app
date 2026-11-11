import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiksave_app/models/tiktok-media-item.dart';
import 'package:tiksave_app/services/tiktok-direct-web-parser.dart';

void main() {
  group('TiktokDirectWebParser', () {
    final parser = TiktokDirectWebParser();

    test('selects highest resolution and bitrate original stream from bitrateInfo', () {
      final itemStruct = <String, dynamic>{
        'id': '7400000000000000001',
        'desc': 'Test 1080p Original Video',
        'author': {
          'nickname': 'Kien Dev',
          'uniqueId': 'kiendev',
          'avatarLarger': 'https://cdn.tiktok.com/avatar.jpg',
        },
        'video': {
          'originCover': 'https://cdn.tiktok.com/cover.jpg',
          'bitrateInfo': [
            {
              'GearName': 'normal_540_0',
              'Bitrate': 850000,
              'CodecType': 'h264',
              'PlayAddr': {
                'Width': 540,
                'Height': 960,
                'DataSize': '2100000',
                'UrlList': ['https://v16.tiktokcdn.com/540p_no_wm.mp4'],
              },
            },
            {
              'GearName': 'adapt_lowest_1080_1',
              'Bitrate': 3200000,
              'CodecType': 'h265_hvc1',
              'PlayAddr': {
                'Width': 1080,
                'Height': 1920,
                'DataSize': '8900000',
                'UrlList': [
                  'https://v16.tiktokcdn.com/1080p_original_high.mp4',
                  'https://v19.tiktokcdn.com/1080p_original_mirror.mp4',
                ],
              },
            },
            {
              'GearName': 'lower_720_0',
              'Bitrate': 1500000,
              'CodecType': 'h264',
              'PlayAddr': {
                'Width': 720,
                'Height': 1280,
                'DataSize': '4200000',
                'UrlList': ['https://v16.tiktokcdn.com/720p_no_wm.mp4'],
              },
            },
          ],
        },
      };

      final htmlPayload = jsonEncode({
        '__DEFAULT_SCOPE__': {
          'webapp.video-detail': {
            'itemInfo': {'itemStruct': itemStruct},
          },
        },
      });
      final html = '''
      <html><body>
      <script id="__UNIVERSAL_DATA_FOR_REHYDRATION__" type="application/json">$htmlPayload</script>
      </body></html>
      ''';

      final result = parser.parseHtml(
        html,
        cookies: {'tt_chain_token': 'token_abc', 'ttwid': 'wid_123'},
      );

      expect(result.mediaType, equals(TikTokMediaType.video));
      expect(
        result.bestVideoUrl,
        equals('https://v16.tiktokcdn.com/1080p_original_high.mp4'),
      );
      expect(result.videoWidth, equals(1080));
      expect(result.videoHeight, equals(1920));
      expect(result.videoBitrate, equals(3200000));
      expect(result.videoSize, equals(8900000));
      expect(result.videoMirrorUrls.length, equals(2));
      expect(result.headers['Cookie'], contains('tt_chain_token=token_abc'));
      expect(result.headers['Referer'], equals('https://www.tiktok.com/'));
    });

    test('parses Photo Slide (imagePost.images) without watermark', () {
      final itemStruct = <String, dynamic>{
        'id': '7400000000000000002',
        'desc': 'Photo Album Post',
        'author': {'nickname': 'Slide Author', 'uniqueId': 'slide_author'},
        'imagePost': {
          'images': [
            {
              'imageWidth': 1080,
              'imageHeight': 1440,
              'imageURL': {
                'urlList': [
                  'https://p16.tiktokcdn.com/slide_1_original.jpeg',
                  'https://p19.tiktokcdn.com/slide_1_mirror.jpeg',
                ],
              },
            },
            {
              'imageWidth': 1080,
              'imageHeight': 1440,
              'imageURL': {
                'urlList': [
                  'https://p16.tiktokcdn.com/slide_2_original.jpeg',
                ],
              },
            },
          ],
        },
      };

      final result = parser.parseItemStruct(itemStruct);
      expect(result.isPhotoSlide, isTrue);
      expect(result.imageUrls, equals([
        'https://p16.tiktokcdn.com/slide_1_original.jpeg',
        'https://p16.tiktokcdn.com/slide_2_original.jpeg',
      ]));
    });
  });
}

