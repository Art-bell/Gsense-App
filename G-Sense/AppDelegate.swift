
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,SPTSessionManagerDelegate, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate {
  
  let SpotifyClientID = "dad09a8631ca43f192359868aadfecd6"
  let SpotifyRedirectURI = URL(string: "g-sense://returnAfterLogin")!
  
  lazy var configuration: SPTConfiguration = {
      let configuration = SPTConfiguration(clientID: SpotifyClientID, redirectURL: SpotifyRedirectURI)
      // Set the playURI to a non-nil value so that Spotify plays music after authenticating and App Remote can connect
      // otherwise another app switch will be required
      configuration.playURI = ""

      // Set these url's to your backend which contains the secret to exchange for an access token
      // You can use the provided ruby script spotify_token_swap.rb for testing purposes
      configuration.tokenSwapURL = URL(string: "https://g-sense.herokuapp.com/api/token")
      configuration.tokenRefreshURL = URL(string: "https://g-sense.herokuapp.com/api/refresh_token")
      return configuration
  }()

  lazy var sessionManager: SPTSessionManager = {
      let manager = SPTSessionManager(configuration: configuration, delegate: self)
      return manager
  }()

  lazy var appRemote: SPTAppRemote = {
      let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
      appRemote.delegate = self
      return appRemote
  }()

  var appCallback: SPTAppRemoteCallback? = nil
            

   func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
         appRemote.playerAPI?.delegate = self
         appRemote.playerAPI?.subscribe(toPlayerState: { (success, error) in
             if let error = error {
                 print("Error subscribing to player state:" + error.localizedDescription)
             }
         })
    appRemote.playerAPI?.skip(toNext: appCallback)
    
     }
  
  func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
    print("Failed")
  }
  
  func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
    print("Disconnected")
  }
  
  func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
    print("Player state changed")
  }
  

  var window: UIWindow?

  


  func applicationDidBecomeActive(_ application: UIApplication) {
    
    if let _ = self.appRemote.connectionParameters.accessToken {
      self.appRemote.connect()
    }
    else {
      print("No access token")
    }
  }
  
  func applicationDidEnterBackground(_ application: UIApplication) {
    if self.appRemote.isConnected {
      self.appRemote.disconnect()
    }
  }

  func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
    print("Manager failed")
    print(error)
  }
  
  func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
       print("Session renewed")
   }

   func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
    print("Session started")
       appRemote.connectionParameters.accessToken = session.accessToken
       appRemote.connect()
    
   }
  
  func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    print(url)
      sessionManager.application(app, open: url, options: options)
//    print(appRemote.connectionParameters.accessToken)
    
      return true
  }
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

   Thread.sleep(forTimeInterval: 3.0)
    let requestedScopes: SPTScope = [.appRemoteControl]
    self.sessionManager.initiateSession(with: requestedScopes, options: .default)
    
//    let scope: SPTScope = [.appRemoteControl, .playlistReadPrivate]
//
//    if #available(iOS 11, *) {
//        // Use this on iOS 11 and above to take advantage of SFAuthenticationSession
//      print("Going to spotify")
//      sessionManager.initiateSession(with: scope, options: .clientOnly)
//    } else {
//        print("No options")
//    }
    print("Session created")
    return true
  }
  
  func applicationWillResignActive(_ application: UIApplication) {
    print("App is going into background mode")
  }
  //Parameters is nil
  

}
