import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  var privacyView: UIView?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Register for background/foreground transitions
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(appDidEnterBackground),
      name: UIApplication.didEnterBackgroundNotification,
      object: nil
    )

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(appWillEnterForeground),
      name: UIApplication.willEnterForegroundNotification,
      object: nil
    )

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  @objc func appDidEnterBackground() {
    // Show privacy view when app goes to background to hide from task switcher
    guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
    guard let windowToModify = window.windows.first else { return }

    let privacyOverlay = UIView(frame: windowToModify.bounds)
    privacyOverlay.backgroundColor = UIColor(red: 0x25 / 255.0, green: 0x81 / 255.0, blue: 0x81 / 255.0, alpha: 1.0)
    privacyOverlay.tag = 999

    windowToModify.addSubview(privacyOverlay)
    self.privacyView = privacyOverlay
  }

  @objc func appWillEnterForeground() {
    // Remove privacy view when app returns to foreground
    privacyView?.removeFromSuperview()
    privacyView = nil
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}
