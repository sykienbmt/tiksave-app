class TiktokUrlExtractor {
  static final RegExp _urlWithSchemeRegex = RegExp(
    r'https?:\/\/(?:www\.|vm\.|vt\.|m\.|t\.)?tiktok\.com\/[^\s<>\"'
    r"'"
    r'`\\\u3000-\u303f\uff00-\uffef]+',
    caseSensitive: false,
  );

  static final RegExp _bareHostRegex = RegExp(
    r'(?<![/\w.-])(?:www\.|vm\.|vt\.|m\.)?tiktok\.com\/[^\s<>\"'
    r"'"
    r'`\\\u3000-\u303f\uff00-\uffef]+',
    caseSensitive: false,
  );

  static final RegExp _trailingPunctRegex = RegExp(
    r'[.,;:!?)\]}>\"\x27\u3001\u3002\uff0c\uff01\uff1f\uff09\u3011\u300b\u201d\u2019]+$',
  );

  static final RegExp _postIdRegex = RegExp(
    r'/(?:video|photo|v|embed(?:/v2)?)/(\d{15,22})',
    caseSensitive: false,
  );

  static final RegExp _queryItemIdRegex = RegExp(
    r'[?&]item_id=(\d{15,22})',
    caseSensitive: false,
  );

  /// Extracts the first valid TikTok URL from arbitrary share text or clipboard content.
  static String? extract(String? rawText) {
    if (rawText == null || rawText.trim().isEmpty) return null;

    final schemeMatch = _urlWithSchemeRegex.firstMatch(rawText);
    if (schemeMatch != null) {
      return _cleanTrailing(schemeMatch.group(0)!);
    }

    final bareMatch = _bareHostRegex.firstMatch(rawText);
    if (bareMatch != null) {
      final cleaned = _cleanTrailing(bareMatch.group(0)!);
      return 'https://$cleaned';
    }

    return null;
  }

  /// Extracts numeric post ID if already present in the URL.
  static String? extractPostId(String url) {
    final pathMatch = _postIdRegex.firstMatch(url);
    if (pathMatch != null) return pathMatch.group(1);

    final queryMatch = _queryItemIdRegex.firstMatch(url);
    if (queryMatch != null) return queryMatch.group(1);

    return null;
  }

  static bool isShortLink(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    final host = uri.host.toLowerCase();
    if (host == 'vt.tiktok.com' || host == 'vm.tiktok.com') return true;
    return uri.path.startsWith('/t/');
  }

  static String _cleanTrailing(String input) {
    return input.replaceFirst(_trailingPunctRegex, '');
  }
}

