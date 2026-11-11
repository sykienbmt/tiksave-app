import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tiktok-media-item.dart';
import '../services/gallery-saver-service.dart';
import '../services/media-downloader-service.dart';
import '../services/share-intent-service.dart';
import '../services/tiktok-parser-orchestrator.dart';
import '../services/tiktok-url-extractor.dart';

class HomeDownloadController extends ChangeNotifier {
  static const String _prefAutoDownloadKey = 'auto_download_on_share';

  final TiktokParserOrchestrator _parser;
  final MediaDownloaderService _downloader;
  final GallerySaverService _gallerySaver;
  final ShareIntentService _shareIntentService;

  StreamSubscription<String>? _shareSubscription;

  String inputText = '';
  bool isParsing = false;
  bool isDownloading = false;
  double downloadProgress = 0.0;
  String statusMessage = '';
  String? errorMessage;
  String? successMessage;
  bool autoDownloadOnShare = true;
  TikTokMediaItem? currentItem;
  final Set<int> savedSlideIndices = <int>{};
  int? activeSlideDownloadingIndex;

  HomeDownloadController({
    TiktokParserOrchestrator? parser,
    MediaDownloaderService? downloader,
    GallerySaverService? gallerySaver,
    ShareIntentService? shareIntentService,
  })  : _parser = parser ?? TiktokParserOrchestrator(),
        _downloader = downloader ?? MediaDownloaderService(),
        _gallerySaver = gallerySaver ?? GallerySaverService(),
        _shareIntentService = shareIntentService ?? ShareIntentService();

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    autoDownloadOnShare = prefs.getBool(_prefAutoDownloadKey) ?? true;
    notifyListeners();

    _shareSubscription = _shareIntentService.sharedUrlStream.listen((sharedUrl) {
      inputText = sharedUrl;
      notifyListeners();
      processUrl(sharedUrl, triggerAutoDownload: autoDownloadOnShare);
    });
    await _shareIntentService.initialize();
  }

  Future<void> toggleAutoDownload(bool enabled) async {
    autoDownloadOnShare = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefAutoDownloadKey, enabled);
  }

  void updateInputText(String value) => inputText = value;

  Future<void> pasteFromClipboardAndParse() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final raw = data?.text ?? '';
    final extracted = TiktokUrlExtractor.extract(raw) ?? raw.trim();
    if (extracted.isEmpty) {
      errorMessage = 'Clipboard trống hoặc không chứa link TikTok.';
      notifyListeners();
      return;
    }
    inputText = extracted;
    notifyListeners();
    await processUrl(extracted, triggerAutoDownload: false);
  }

  Future<void> processUrl(String rawInput, {bool triggerAutoDownload = false}) async {
    if (isParsing || isDownloading) return;
    errorMessage = null;
    successMessage = null;
    isParsing = true;
    statusMessage = 'Đang phân tích link & lấy luồng gốc không logo...';
    savedSlideIndices.clear();
    notifyListeners();

    try {
      final item = await _parser.parseFromText(rawInput);
      currentItem = item;
      isParsing = false;
      statusMessage = 'Đã lấy thành công từ ${item.providerName}';
      notifyListeners();

      if (triggerAutoDownload) {
        await (item.isPhotoSlide ? downloadAllSlides() : downloadOriginalVideo());
      }
    } catch (err) {
      isParsing = false;
      statusMessage = '';
      errorMessage = err.toString().replaceFirst('FormatException: ', '');
      notifyListeners();
    }
  }

  Future<void> downloadOriginalVideo() async {
    final item = currentItem;
    if (item == null || item.isPhotoSlide || isDownloading) return;
    await _runDownloadTask(
      action: () async {
        final file = await _downloader.downloadVideo(item, onProgress: _onProgress);
        statusMessage = 'Đang lưu vào Thư viện ảnh (Album TikSave)...';
        notifyListeners();
        await _gallerySaver.saveVideoFile(file);
        return 'Đã lưu video chất lượng gốc (Không Logo) vào Album TikSave!';
      },
    );
  }

  Future<void> downloadSingleSlide(int index) async {
    final item = currentItem;
    if (item == null || !item.isPhotoSlide || isDownloading) return;
    activeSlideDownloadingIndex = index;
    await _runDownloadTask(
      action: () async {
        final file = await _downloader.downloadSingleImage(
          item,
          index,
          onProgress: _onProgress,
        );
        await _gallerySaver.saveImageFile(file);
        savedSlideIndices.add(index);
        return 'Đã lưu ảnh lẻ #${index + 1} (Chất lượng gốc) vào Album TikSave!';
      },
    );
    activeSlideDownloadingIndex = null;
    notifyListeners();
  }

  Future<void> downloadAllSlides() async {
    final item = currentItem;
    if (item == null || !item.isPhotoSlide || isDownloading) return;
    await _runDownloadTask(
      action: () async {
        final files = await _downloader.downloadAllImages(item, onProgress: _onProgress);
        statusMessage = 'Đang lưu ${files.length} ảnh vào Album TikSave...';
        notifyListeners();
        await _gallerySaver.saveImageFiles(files);
        for (var i = 0; i < item.imageUrls.length; i++) {
          savedSlideIndices.add(i);
        }
        return 'Đã lưu trọn bộ ${files.length} ảnh gốc (Không Logo) vào Album TikSave!';
      },
    );
  }

  Future<void> _runDownloadTask({required Future<String> Function() action}) async {
    isDownloading = true;
    errorMessage = null;
    successMessage = null;
    downloadProgress = 0.02;
    notifyListeners();
    try {
      successMessage = await action();
      downloadProgress = 1.0;
    } catch (err) {
      errorMessage = 'Lỗi tải: $err';
    } finally {
      isDownloading = false;
      statusMessage = '';
      notifyListeners();
    }
  }

  void _onProgress(double progress, String msg) {
    downloadProgress = progress;
    statusMessage = msg;
    notifyListeners();
  }

  @override
  void dispose() {
    _shareSubscription?.cancel();
    _shareIntentService.dispose();
    super.dispose();
  }
}
