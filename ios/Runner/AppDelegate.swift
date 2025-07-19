import Flutter
import UIKit
import "GoogleMaps/GoogleMaps.h"

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    [GMSServices provideAPIKey:@"AIzaSyDm69BfFMh-PuIyZPQ1gmaCzN90sAnOiJQ"];
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
