import UIKit
import UniformTypeIdentifiers

class ShareViewController: UIViewController {
  private let appGroupId = "group.com.tiksave.app"
  private let sharedKey = "SharedTextKey"

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    extractSharedPayload()
  }

  private func extractSharedPayload() {
    guard let item = extensionContext?.inputItems.first as? NSExtensionItem,
          let attachments = item.attachments else {
      finishExtension()
      return
    }

    let urlType = UTType.url.identifier
    let textType = UTType.plainText.identifier

    for provider in attachments {
      if provider.hasItemConformingToTypeIdentifier(urlType) {
        provider.loadItem(forTypeIdentifier: urlType, options: nil) { [weak self] data, _ in
          if let url = data as? URL {
            self?.forwardToHostApp(text: url.absoluteString)
          } else if let str = data as? String {
            self?.forwardToHostApp(text: str)
          } else {
            self?.finishExtension()
          }
        }
        return
      } else if provider.hasItemConformingToTypeIdentifier(textType) {
        provider.loadItem(forTypeIdentifier: textType, options: nil) { [weak self] data, _ in
          if let str = data as? String {
            self?.forwardToHostApp(text: str)
          } else if let url = data as? URL {
            self?.forwardToHostApp(text: url.absoluteString)
          } else {
            self?.finishExtension()
          }
        }
        return
      }
    }
    finishExtension()
  }

  private func forwardToHostApp(text: String) {
    if let defaults = UserDefaults(suiteName: appGroupId) {
      defaults.set(text, forKey: sharedKey)
      defaults.synchronize()
    }

    let encoded = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    if let deepLink = URL(string: "tiksave://share?text=\(encoded)") {
      DispatchQueue.main.async {
        self.openHostApp(url: deepLink)
        self.finishExtension()
      }
    } else {
      finishExtension()
    }
  }

  @objc private func openURL(_ url: URL) -> Bool {
    var responder: UIResponder? = self
    while let current = responder {
      if let app = current as? UIApplication {
        app.open(url, options: [:], completionHandler: nil)
        return true
      }
      responder = current.next
    }
    return false
  }

  private func openHostApp(url: URL) {
    var responder: UIResponder? = self
    let selector = sel_registerName("openURL:")
    while let current = responder {
      if current.responds(to: selector) {
        _ = current.perform(selector, with: url)
        break
      }
      responder = current.next
    }
  }

  private func finishExtension() {
    DispatchQueue.main.async {
      self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
  }
}

