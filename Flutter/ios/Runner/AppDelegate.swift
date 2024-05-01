import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    let methodChannel = FlutterMethodChannel(name: "Channel",binaryMessenger: controller as! FlutterBinaryMessenger)
    methodChannel.setMethodCallHandler({
        (call:FlutterMethodCall, result:FlutterResult) -> Void in
        switch call.method {
        case "getHello" :
            result("Hello from Swift!")
        default :
            result(nil)
        }
    })

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
