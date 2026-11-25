import Flutter
import UIKit
import UserNotifications
import workmanager_apple

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Shows local notifications while the app is open too (spike 0.9).
    UNUserNotificationCenter.current().delegate = self
    // Nightly backup (S42): the task id matches Info.plist and
    // nightly_backup.dart; its background engine gets the plugins.
    WorkmanagerPlugin.registerBGProcessingTask(
      withIdentifier: "com.brendanltw.ctrltask.backup")
    WorkmanagerPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
