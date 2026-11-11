import 'dart:async';
import 'package:flutter/services.dart';
import 'tiktok-url-extractor.dart';

class ShareIntentService {
  static const MethodChannel _methodChannel =
      MethodChannel('com.tiksave.app/share_method');
  static const EventChannel _eventChannel =
      EventChannel('com.tiksave.app/share_event');

  final StreamController<String> _sharedUrlController =
      StreamController<String>.broadcast();
  StreamSubscription<dynamic>? _eventSubscription;

  Stream<String> get sharedUrlStream => _sharedUrlController.stream;

  Future<void> initialize() async {
    try {
      final initialText =
          await _methodChannel.invokeMethod<String>('getInitialSharedText');
      _handleIncomingText(initialText);
    } catch (_) {}

    _eventSubscription =
        _eventChannel.receiveBroadcastStream().listen((dynamic event) {
      if (event is String) {
        _handleIncomingText(event);
      }
    }, onError: (_) {});
  }

  void _handleIncomingText(String? rawText) {
    final extractedUrl = TiktokUrlExtractor.extract(rawText);
    if (extractedUrl != null && extractedUrl.isNotEmpty) {
      _sharedUrlController.add(extractedUrl);
    }
  }

  void dispose() {
    _eventSubscription?.cancel();
    _sharedUrlController.close();
  }
}

