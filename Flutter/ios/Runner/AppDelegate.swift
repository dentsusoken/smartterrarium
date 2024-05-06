import UIKit
import Flutter


import TabularData
import CoreML
import Vision


@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let batteryChannel = FlutterMethodChannel(name: "test.Channel",
                                              binaryMessenger: controller.binaryMessenger)
    batteryChannel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
      // This method is invoked on the UI thread.
      guard call.method == "getBatteryLevel" else {
        result(FlutterMethodNotImplemented)
        return
      }
      self?.receiveBatteryLevel(result: result)
      print("+++")
      var dataFrame: DataFrame = ["id": [1, 2, 3],
                                  "name": ["Fares", "Elena", "Steven"],
                                  "age" : [32, 23, 40],
                                  "decision" : [true, false, true]]
      print(dataFrame)
      // インスタンスを作成
      let irisClassifierWrapper = IrisClassifierWrapper()

      // 0~1の範囲の4つの特徴量を入力して予測を行う
      let features = [0.1, 0.2, 0.3, 0.4]
      if let prediction = irisClassifierWrapper.predict(features: features) {
          print("予測結果: \(prediction)")
      } else {
          print("予測に失敗しました。")
      }
    })

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }


    private func receiveBatteryLevel(result: FlutterResult) {
      let device = UIDevice.current
      device.isBatteryMonitoringEnabled = true
      if device.batteryState == UIDevice.BatteryState.unknown {
        result(FlutterError(code: "UNAVAILABLE",
                            message: "Battery level not available.",
                            details: nil))
      } else {
        result(Int(device.batteryLevel * 100))
      }
    }
}

class IrisClassifierWrapper {

    var model = IrisClassifier()

    func predict(features: [Double]) -> String? {
        guard let model = model else { return nil }

        do {
            let inputArray = try MLMultiArray(shape: [4], dataType: .double)
            for (index, value) in features.enumerated() {
                inputArray[index] = NSNumber(value: value)
            }

            let prediction = try model.prediction(input: IrisClassifierInput(input: inputArray))
            return prediction.classLabel
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}