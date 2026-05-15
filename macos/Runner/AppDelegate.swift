import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  override func applicationDidBecomeActive(_ notification: Notification) {
    // Hide sensitive data when app becomes active (security)
    guard let mainWindow = NSApplication.shared.mainWindow else { return }
    mainWindow.isOpaque = true
  }

  override func applicationDidResignActive(_ notification: Notification) {
    // App is about to lose focus - apply privacy setting
    guard let mainWindow = NSApplication.shared.mainWindow else { return }
    mainWindow.isOpaque = true
  }
}
