import 'dart:io';
import 'package:gal/gal.dart';

class GallerySaverService {
  static const String albumName = 'TikSave';

  Future<void> ensurePermission() async {
    final hasAccess = await Gal.hasAccess(toAlbum: true);
    if (!hasAccess) {
      final granted = await Gal.requestAccess(toAlbum: true);
      if (!granted) {
        throw Exception(
          'Vui lòng cấp quyền truy cập Thư viện Ảnh/Video để lưu nội dung.',
        );
      }
    }
  }

  Future<void> saveVideoFile(File videoFile) async {
    await ensurePermission();
    try {
      await Gal.putVideo(videoFile.path, album: albumName);
    } finally {
      await _safeDelete(videoFile);
    }
  }

  Future<void> saveImageFile(File imageFile) async {
    await ensurePermission();
    try {
      await Gal.putImage(imageFile.path, album: albumName);
    } finally {
      await _safeDelete(imageFile);
    }
  }

  Future<void> saveImageFiles(List<File> imageFiles) async {
    await ensurePermission();
    for (final file in imageFiles) {
      try {
        await Gal.putImage(file.path, album: albumName);
      } finally {
        await _safeDelete(file);
      }
    }
  }

  static Future<void> _safeDelete(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }
}

