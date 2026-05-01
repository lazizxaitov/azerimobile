import Flutter
import UIKit
import YandexMapsMobile

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let key = Bundle.main.object(forInfoDictionaryKey: "YandexMapsApiKey") as? String,
       key.isEmpty == false {
      YMKMapKit.setApiKey(key)
    } else {
      NSLog("YandexMapsApiKey is missing/empty. Set it in Info.plist before using Yandex MapKit.")
    }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
