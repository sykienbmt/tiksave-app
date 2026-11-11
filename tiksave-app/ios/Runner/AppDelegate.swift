import Flutter
import UIKit

final class ShareBridgeCenter: NSObject, FlutterStreamHandler {
  static let shared = ShareBridgeCenter()

  private let methodChannelName = "com.tiksave.app/share_method"
  private let eventChannelName = "com.tiksave.app/share_event"
  private let appGroupId = "group.com.tiksave.app"
  private let sharedKey = "SharedTextKey"

  private var initialSharedText: String?
  private var eventSink: FlutterEventSink?
  private var isRegistered = false

  func register(with messenger: FlutterBinaryMessenger) {
    guard !isRegistered else { return }
    isRegistered = true

    let methodChannel = FlutterMethodChannel(
      name: methodChannelName,
      binaryMessenger: messenger
    )
    methodChannel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { return }
      if call.method == "getInitialSharedText" {
        self.pullFromAppGroupIfEmpty()
        result(self.initialSharedText)
        self.initialSharedText = nil
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    let eventChannel = FlutterEventChannel(
      name: eventChannelName,
      binaryMessenger: messenger
    )
    eventChannel.setStreamHandler(self)
  }

  func handleIncoming(url: URL, isColdStart: Bool) {
    guard url.scheme?.lowercased() == "tiksave" else { return }
    let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
    let textParam = components?.queryItems?.first(where: { $0.name == "text" })?.value
    let resolved = textParam ?? consumeAppGroupText()
    guard let finalText = resolved, !finalText.isEmpty else { return }

    if !isColdStart, let sink = eventSink {
      sink(finalText)
    } else {
      initialSharedText = finalText
    }
  }

  func pullFromAppGroupIfEmpty() {
    if initialSharedText == nil {
      initialSharedText = consumeAppGroupText()
    }
  }

  private func consumeAppGroupText() -> String? {
    guard let defaults = UserDefaults(suiteName: appGroupId),
          let text = defaults.string(forKey: sharedKey) else {
      return nil
    }
    defaults.removeObject(forKey: sharedKey)
    defaults.synchronize()
    return text
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.eventSink = events
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    self.eventSink = nil
    return nil
  }
}

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let url = launchOptions?[.url] as? URL {
      ShareBridgeCenter.shared.handleIncoming(url: url, isColdStart: true)
    } else {
      ShareBridgeCenter.shared.pullFromAppGroupIfEmpty()
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    ShareBridgeCenter.shared.register(with: engineBridge.applicationRegistrar.messenger())
  }

  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    ShareBridgeCenter.shared.handleIncoming(url: url, isColdStart: false)
    return true
  }
}
