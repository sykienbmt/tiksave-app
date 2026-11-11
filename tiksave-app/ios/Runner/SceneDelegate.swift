import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)
    if let urlContext = connectionOptions.urlContexts.first {
      ShareBridgeCenter.shared.handleIncoming(url: urlContext.url, isColdStart: true)
    } else {
      ShareBridgeCenter.shared.pullFromAppGroupIfEmpty()
    }
  }

  override func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    super.scene(scene, openURLContexts: URLContexts)
    if let urlContext = URLContexts.first {
      ShareBridgeCenter.shared.handleIncoming(url: urlContext.url, isColdStart: false)
    }
  }
}
