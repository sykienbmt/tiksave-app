import 'package:flutter/material.dart';
import '../controllers/home-download-controller.dart';
import 'media-result-card.dart';
import 'settings-and-overlays.dart';
import 'studio-guide-bento.dart';
import 'tiksave-theme.dart';
import 'url-input-section.dart';

class HomeScreen extends StatefulWidget {
  final HomeDownloadController? controller;
  const HomeScreen({super.key, this.controller});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeDownloadController _controller;
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? HomeDownloadController();
    _textController = TextEditingController();
    _controller.addListener(_onControllerUpdated);
    _controller.initialize();
  }

  void _onControllerUpdated() {
    if (_textController.text != _controller.inputText) {
      _textController.text = _controller.inputText;
      _textController.selection = TextSelection.fromPosition(
        TextPosition(offset: _textController.text.length),
      );
    }
    final err = _controller.errorMessage;
    final ok = _controller.successMessage;
    if ((err != null || ok != null) && mounted) {
      _controller.clearMessages();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        TikSaveOverlays.showFloatingToast(
          context,
          message: err ?? ok!,
          isError: err != null,
        );
      });
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdated);
    if (widget.controller == null) _controller.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = _controller.currentItem;
    final busy = _controller.isParsing || _controller.isDownloading;

    return Scaffold(
      backgroundColor: TikSaveTheme.bgObsidian,
      body: Stack(
        children: [
          Positioned(top: -90, left: -70, child: _glowOrb(TikSaveTheme.neonCyan)),
          Positioned(top: -60, right: -80, child: _glowOrb(TikSaveTheme.neonRose)),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildStudioHeader(),
                  const SizedBox(height: 16),
                  UrlInputSection(
                    textController: _textController,
                    busy: busy,
                    onChanged: _controller.updateInputText,
                    onClear: () {
                      _textController.clear();
                      _controller.updateInputText('');
                    },
                    onPasteAndParse: _controller.pasteFromClipboardAndParse,
                    onDownloadImmediate: () => _controller.processUrl(
                      _textController.text,
                      triggerAutoDownload: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (item != null) ...[
                    MediaResultCard(
                      item: item,
                      isDownloading: _controller.isDownloading,
                      savedSlideIndices: _controller.savedSlideIndices,
                      activeSlideDownloadingIndex:
                          _controller.activeSlideDownloadingIndex,
                      onDownloadVideo: _controller.downloadOriginalVideo,
                      onDownloadSingleSlide: _controller.downloadSingleSlide,
                      onDownloadAllSlides: _controller.downloadAllSlides,
                    ),
                    const SizedBox(height: 16),
                  ],
                  const StudioGuideBento(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (busy && _controller.activeSlideDownloadingIndex == null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 18,
              child: FloatingProgressPill(
                message: _controller.statusMessage,
                progress: _controller.isParsing
                    ? null
                    : _controller.downloadProgress,
              ),
            ),
        ],
      ),
    );
  }

  Widget _glowOrb(Color color) => IgnorePointer(
        child: Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color.withValues(alpha: 0.16), Colors.transparent],
            ),
          ),
        ),
      );

  Widget _buildStudioHeader() {
    return Row(
      children: [
        const TikSaveLogoMark(size: 46),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TikSave Original',
                style: TextStyle(
                  color: TikSaveTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'CYBER STUDIO • NO WATERMARK HD',
                style: TextStyle(
                  color: TikSaveTheme.textSecondary,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
        Material(
          color: TikSaveTheme.surfaceRecessed,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: () => TikSaveOverlays.showSettingsSheet(context, _controller),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: TikSaveTheme.borderGlass),
              ),
              child: const Icon(
                Icons.settings_rounded,
                color: TikSaveTheme.neonCyan,
                size: 21,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
