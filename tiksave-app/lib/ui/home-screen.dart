import 'package:flutter/material.dart';
import '../controllers/home-download-controller.dart';
import 'media-result-card.dart';
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
    _controller.addListener(_syncTextController);
    _controller.initialize();
  }

  void _syncTextController() {
    if (_textController.text != _controller.inputText) {
      _textController.text = _controller.inputText;
      _textController.selection = TextSelection.fromPosition(
        TextPosition(offset: _textController.text.length),
      );
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_syncTextController);
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
                  _buildStudioHeader(busy),
                  const SizedBox(height: 16),
                  UrlInputSection(
                    textController: _textController,
                    busy: busy,
                    autoDownloadOnShare: _controller.autoDownloadOnShare,
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
                    onToggleAutoDownload: _controller.toggleAutoDownload,
                  ),
                  if (busy) ...[const SizedBox(height: 14), _buildProgressBanner()],
                  if (_controller.errorMessage != null) ...[
                    const SizedBox(height: 14),
                    _buildAlertBox(
                      _controller.errorMessage!,
                      const Color(0xFFFF4D6D),
                      Icons.error_outline_rounded,
                    ),
                  ],
                  if (_controller.successMessage != null) ...[
                    const SizedBox(height: 14),
                    _buildAlertBox(
                      _controller.successMessage!,
                      TikSaveTheme.neonEmerald,
                      Icons.check_circle_outline_rounded,
                    ),
                  ],
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

  Widget _buildStudioHeader(bool busy) {
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
        TikSaveTheme.pillBadge(
          busy ? 'ACTIVE' : 'READY',
          busy ? TikSaveTheme.neonCyan : TikSaveTheme.neonEmerald,
        ),
      ],
    );
  }

  Widget _buildProgressBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: TikSaveTheme.bentoCardDecoration(radius: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _controller.statusMessage,
            style: const TextStyle(color: TikSaveTheme.textPrimary, fontSize: 13),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: _controller.isParsing ? null : _controller.downloadProgress,
            backgroundColor: Colors.white12,
            color: TikSaveTheme.neonCyan,
            minHeight: 6,
            borderRadius: BorderRadius.circular(6),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertBox(String message, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: TextStyle(color: color, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
