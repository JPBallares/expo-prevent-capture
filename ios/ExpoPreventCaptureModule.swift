import ExpoModulesCore

let onScreenshotEventName = "onScreenshot"

public class ExpoPreventCaptureModule: Module {
  private var isListening = false
  private var isEnabled = false
  private var blockView = UIView()
  private var obfuscatingView: UIImageView?
  private var secureField: UITextField?


  public func definition() -> ModuleDefinition {
    Name("ExpoPreventCapture")

    Events(onScreenshotEventName)

    OnCreate {
      let boundLength = max(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
      blockView.frame = CGRect(x: 0, y: 0, width: boundLength, height: boundLength)
      blockView.backgroundColor = .black
    }

    OnStartObserving {
      let center = NotificationCenter.default
      // handle inactive event
      center.addObserver(self, selector: #selector(self.handleAppStateResignActive),
                        name: UIApplication.willResignActiveNotification,
                        object: nil)
      // handle active event
      center.addObserver(self, selector: #selector(self.handleAppStateActive),
                        name: UIApplication.didBecomeActiveNotification,
                        object: nil)
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

    AsyncFunction("enable") { (enabled: Bool) in
      self.isEnabled = enabled
    }

    AsyncFunction("enableSecureView") {
      // self.handleAppStateResignActive()
      // if self.secureField?.isSecureTextEntry == false {
      //   guard let rootView = UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.rootViewController?.view else { return }
      //   for subview in rootView.subviews {
      //     self.addSecureTextField(subview)
      //   }
      // }

      guard let keyWindow = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else {
        return
      }

      self.makeSecure(window: keyWindow)
    }.runOnQueue(.main)

    AsyncFunction("disableSecureView") {
      self.secureField?.isSecureTextEntry = false
      guard let rootView = UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.rootViewController?.view else { return }
      for subview in rootView.subviews {
        self.removeSecureTextFieldFromView(subview)
      }
    }

    // AsyncFunction("preventScreenCapture") {
    //   // If already recording, block it
    //   self.preventScreenRecording()

    //   NotificationCenter.default.addObserver(self, selector: #selector(self.preventScreenRecording), name: UIScreen.capturedDidChangeNotification, object: nil)
    // }.runOnQueue(.main)

    // AsyncFunction("allowScreenCapture") {
    //   NotificationCenter.default.removeObserver(self, name: UIScreen.capturedDidChangeNotification, object: nil)
    // }
  }

  // private func setIsBeing(observed: Bool) {
  //   self.isBeingObserved = observed
  //   let shouldListen = self.isBeingObserved

  //   if shouldListen && !isListening {
  //     // swiftlint:disable:next line_length
  //     NotificationCenter.default.addObserver(self, selector: #selector(self.listenForScreenCapture), name: UIApplication.userDidTakeScreenshotNotification, object: nil)
  //     isListening = true
  //   } else if !shouldListen && isListening {
  //     NotificationCenter.default.removeObserver(self, name: UIApplication.userDidTakeScreenshotNotification, object: nil)
  //     isListening = false
  //   }
  // }

  // @objc
  // func preventScreenRecording() {
  //   let isCaptured = UIScreen.main.isCaptured
  //   let isMirrored = UIScreen.main.mirrored != nil

  //   if (isCaptured || isMirrored) {
  //     UIApplication.shared.keyWindow?.subviews.first?.addSubview(blockView)
  //   } else {
  //     blockView.removeFromSuperview()
  //   }
  // }

  /** Displays blurry view when app becomes inactive */
  @objc 
  func handleAppStateResignActive() {
    if self.isEnabled {
      guard let keyWindow = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else {
        return
      }
      
      let blurredScreenImageView = UIImageView(frame: keyWindow.bounds)
      
      UIGraphicsBeginImageContextWithOptions(keyWindow.bounds.size, false, UIScreen.main.scale)
      keyWindow.drawHierarchy(in: keyWindow.bounds, afterScreenUpdates: false)
      guard let viewImage = UIGraphicsGetImageFromCurrentImageContext() else {
        UIGraphicsEndImageContext()
        return
      }
      UIGraphicsEndImageContext()
      
      let imageToBlur = CIImage(image: viewImage)
      let blurfilter = CIFilter(name: "CIGaussianBlur")
      blurfilter?.setValue(imageToBlur, forKey: "inputImage")
      let resultImage = blurfilter?.value(forKey: "outputImage") as? CIImage
      let blurredImage = UIImage(ciImage: resultImage!)

      blurredScreenImageView.image = blurredImage

      self.obfuscatingView = blurredScreenImageView

      if let obfuscatingView = self.obfuscatingView {
        keyWindow.addSubview(obfuscatingView)
      }
    }
  }

  /** Removes blurry view when app becomes active */
  @objc
  func handleAppStateActive() {
    if self.obfuscatingView != nil {
      UIView.animate(withDuration: 0.3, animations: {
        self.obfuscatingView?.alpha = 0
      }, completion: { _ in
        self.obfuscatingView?.removeFromSuperview()
        self.obfuscatingView = nil
      })
    }
  }

  @objc
  func listenForScreenCapture() {
    if isListening {
      sendEvent(onScreenshotEventName, [
        "body": nil
      ])
    }
  }

  /**
  * Creates secure text field inside rootView of the app
  * Taken from https://stackoverflow.com/questions/18680028/prevent-screen-capture-in-an-ios-app
  *
  * Converted to Swift and modified to get it working with React Native
  */
  @objc
  func addSecureTextField(_ view: UIView) {
    guard let rootView = UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.rootViewController?.view else { return }
    let secureField = UITextField(frame: rootView.frame)
    secureField.isSecureTextEntry = true
    secureField.isUserInteractionEnabled = false
    secureField.font = UIFont.systemFont(ofSize: 25)
    let color = UIColor.black
    let alignment = NSTextAlignment.center
    let alignmentSetting = NSMutableParagraphStyle()
    alignmentSetting.alignment = alignment
    secureField.attributedPlaceholder = NSAttributedString(string: "PlaceHolder Text", attributes: [NSAttributedString.Key.foregroundColor: color, NSAttributedString.Key.paragraphStyle: alignmentSetting])
    secureField.adjustsFontSizeToFitWidth = true
    secureField.placeholder = "This action has been restricted by your app."
    view.sendSubviewToBack(secureField)
    view.addSubview(secureField)
    view.layer.superlayer?.addSublayer(secureField.layer)
    secureField.layer.sublayers?.last?.addSublayer(view.layer)
    self.secureField = secureField
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

    let image = UIImageView(image: UIImage(named: "whiteImage"))
    image.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)

    field.isSecureTextEntry = true

    window.addSubview(field)
    view.addSubview(image)

    window.layer.superlayer?.addSublayer(field.layer)
    field.layer.sublayers?.last!.addSublayer(window.layer)

    field.leftView = view
    field.leftViewMode = .always
  }
}
