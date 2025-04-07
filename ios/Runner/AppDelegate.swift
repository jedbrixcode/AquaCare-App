import Flutter
import UIKit

import flutter_local_notifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // Register Flutter Local Notifications Plugin
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
      GeneratedPluginRegistrant.register(with: registry)
    }

    // Initialize Flutter plugin
    GeneratedPluginRegistrant.register(with: self)

    // Set notification delegate to handle background/foreground notifications
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Handle notifications when the app is in the foreground or background
  @available(iOS 10, *)
  func userNotificationCenter(_ center: UNUserNotificationCenter, 
                               willPresent notification: UNNotification, 
                               withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    // You can customize this as needed (like showing the notification in the foreground)
    completionHandler([.alert, .badge, .sound])
  }
  
  // Handle notification tap action
  @available(iOS 10, *)
  func userNotificationCenter(_ center: UNUserNotificationCenter, 
                               didReceive response: UNNotificationResponse, 
                               withCompletionHandler completionHandler: @escaping () -> Void) {
    // Handle the notification response (like navigating to a specific screen)
    completionHandler()
  }
}
