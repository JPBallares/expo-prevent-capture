import ExpoModulesCore

let onScreenshotEventName = "onScreenshot"

public class ExpoPreventCaptureModule: Module {
  private var isListening = false

  public func definition() -> ModuleDefinition {
    Name("ExpoPreventCapture")

    Events(onScreenshotEventName)

    OnStartObserving {
      let center = NotificationCenter.default
      // handle screenshot taken event
      center.addObserver(self, selector: #selector(self.listenForScreenCapture),
                 name: UIApplication.userDidTakeScreenshotNotification,
                 object: nil)

      self.isListening = true
    }

    OnStopObserving {
      NotificationCenter.default.removeObserver(self)
      self.isListening = false
    }

    AsyncFunction("enableSecureView") {
      guard let keyWindow = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else {
        return
      }

      self.makeSecure(window: keyWindow)
    }.runOnQueue(.main)
  }

  @objc
  func listenForScreenCapture() {
    if isListening {
      sendEvent(onScreenshotEventName, [
        "body": nil
      ])
    }
  }

  @objc
  func removeSecureTextFieldFromView(_ view: UIView) {
    for subview in view.subviews {
      if let subview = subview as? UITextField {
        if subview.isSecureTextEntry {
          subview.removeFromSuperview()
          subview.isSecureTextEntry = false
          subview.isUserInteractionEnabled = true
        }
      }
    }
  }

  @objc
  func makeSecure(window: UIWindow) {
    let field = UITextField()

    let view = UIView(frame: CGRect(x: 0, y: 0, width: field.frame.self.width, height: field.frame.self.height))

    field.isSecureTextEntry = true

    let imageView = UIImageView()

    window.addSubview(field)
    view.addSubview(imageView)

    window.layer.superlayer?.addSublayer(field.layer)
    field.layer.sublayers?.last!.addSublayer(window.layer)

    field.leftView = view
    field.leftViewMode = .always
  }
}
