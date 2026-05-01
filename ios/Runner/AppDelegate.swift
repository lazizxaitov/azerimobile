import Flutter
import UIKit
#if canImport(YandexMapsMobile)
import YandexMapsMobile
#endif

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    #if canImport(YandexMapsMobile)
    if let key = Bundle.main.object(forInfoDictionaryKey: "YandexMapsApiKey") as? String,
       key.isEmpty == false {
      YMKMapKit.setApiKey(key)
    } else {
      NSLog("YandexMapsApiKey is missing/empty. Set it in Info.plist before using Yandex MapKit.")
    }
    #endif
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
