
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    Thread.sleep(forTimeInterval: 3.0)
    return true
  }
  
  func applicationWillResignActive(_ application: UIApplication) {
    print("App is going into background mode")
  }
}
