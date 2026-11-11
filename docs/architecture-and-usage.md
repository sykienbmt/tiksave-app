# TikSave — Kiến trúc & Hướng dẫn Sử dụng (Android APK & iOS IPA)

## 1. Tính năng cốt lõi
1. **Tải Video TikTok chất lượng gốc (Original Quality) không dính logo**:
   - **Provider 1 (`tiktok-direct-web-parser.dart`)**: Mở link rút gọn (`vt.tiktok.com` / `vm.tiktok.com`), giữ `tt_chain_token` cookie, đọc `<script id="__UNIVERSAL_DATA_FOR_REHYDRATION__">`, lấy danh sách `video.bitrateInfo` và sắp xếp theo `(max(width, height), bitrate, dataSize)` để chọn luồng gốc nét nhất (1080p/2K H.265/H.264) không watermark.
   - **Provider 2 (`tiktok-tikwm-parser.dart`)**: Tự động fallback sang `https://www.tikwm.com/api/?hd=1` (`hdplay`) nếu mạng bị chặn WAF/Captcha.
2. **Tải Album ảnh (Photo Slide) hoặc 1 hình lẻ chất lượng gốc**:
   - Tự động nhận diện bài đăng dạng ảnh (`imagePost.images` / `images`).
   - Hỗ trợ nút **"Tải tất cả X ảnh gốc (Không Logo)"** hoặc bấm vào từng ảnh để **"Tải ảnh lẻ"**.
   - Lưu trực tiếp vào Thư viện ảnh của điện thoại trong Album **`TikSave`**.
3. **Chia sẻ trực tiếp từ App TikTok ("Share to TikSave") và Tự động tải**:
   - **Android**: Đăng ký `android.intent.action.SEND` (`text/plain`) trong `AndroidManifest.xml` và nhận qua `MainActivity.kt`.
   - **iOS**: Tích hợp `ShareExtension` (`ShareViewController.swift`) chuyển tiếp qua URL Scheme `tiksave://share?text=...` + `AppGroup` tới `AppDelegate.swift` & `SceneDelegate.swift`.

## 2. Chạy kiểm tra & Unit Test tại máy Local
```powershell
cd d:\my-projects\tiktok-download\tiksave-app
D:\flutter\bin\flutter.bat analyze
D:\flutter\bin\flutter.bat test
```

## 3. Cách xuất file `.apk` (Android) và `.ipa` (iOS)
- **Tự động qua GitHub Actions (`.github/workflows/build-release.yml`)**:
  - Khi push code lên GitHub (hoặc bấm **Run workflow** trong tab Actions), GitHub Actions sẽ tự động chạy 2 máy ảo (`ubuntu-latest` và `macos-14`) để xuất ra:
    - **`TikSave-Android-APK`** (`app-release.apk` & `app-arm64-v8a-release.apk`)
    - **`TikSave-iOS-Unsigned-IPA`** (`TikSave-unsigned.ipa` — cài đặt trực tiếp vào iPhone/iPad qua **Sideloadly**, **AltStore**, **Feather**, hoặc **TrollStore**).

