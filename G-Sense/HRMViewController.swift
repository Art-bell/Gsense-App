import UIKit
import CoreBluetooth

//let heartRateServiceCBUUID = CBUUID(string: "0x180D")
//let gesture = CBUUID(string: "0x2A37")
//let serviceNumber = CBUUID(string: "0x2A38")
let url = URL(string: "https://maker.ifttt.com/trigger/SeniorDesignTest/with/key/bTjX4EmGRVKd66ZZp_n5tF")!
let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
    if let error = error {
        print("error: \(error)")
    } else {
        if let response = response as? HTTPURLResponse {
            print("statusCode: \(response.statusCode)")
        }
        if let data = data, let dataString = String(data: data, encoding: .utf8) {
            print("data: \(dataString)")
        }
    }
}


var arrChar = [Int: CBCharacteristic]()

class HRMViewController: UIViewController ,SPTSessionManagerDelegate, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate  {

  @IBOutlet var strLogPressed: UIButton!
  @IBOutlet weak var logPressed: UIButton!
  @IBOutlet weak var gestureLabel: UILabel!
  @IBOutlet weak var bodySensorLocationLabel: UILabel!
  let requestedScopes: SPTScope = [.appRemoteControl]
  
  @IBAction func loginPressed(_ sender: Any)
  {
  self.sessionManager.initiateSession(with: requestedScopes, options: .default)
    Thread.sleep(forTimeInterval: 0.5)
    self.strLogPressed.setTitle("Connected to Spotify", for: .normal)
    self.strLogPressed.backgroundColor = UIColor.systemGreen
     
  }
  
  var centralManager: CBCentralManager!
  var sensorPeripheral: CBPeripheral!
  
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
          
  
  override func viewDidLoad() {
    gestureLabel.text = "None"
    bodySensorLocationLabel.text = "5"
//    centralManager = CBCentralManager(delegate: self, queue: nil)
    super.viewDidLoad()
    // Make the digits monospaces to avoid shifting when the numbers change
    gestureLabel.font = UIFont.monospacedDigitSystemFont(ofSize: gestureLabel.font!.pointSize, weight: .regular)
    centralManager.delegate = self
    centralManager.stopScan()
    print("Stopped scanning")
    
     centralManager.connect(sensorPeripheral)
     print("Proceeding to find services in new view")
    if let _ = self.appRemote.connectionParameters.accessToken {
      self.appRemote.connect()
    }
    else {
      print("No access token")
    }
//    self.strLogPressed.setTitle("Connected to Spotify", for: .normal)
//    self.strLogPressed.backgroundColor = UIColor.green
  }

  func onHeartRateReceived(_ gesture: Int) {
    gestureLabel.text = String(gesture)
    print("Gesture: \(gesture)")
  }
  
  func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
    print("Established connect")
    self.appRemote = appRemote
//          appRemote.playerAPI?.delegate = self
//          appRemote.playerAPI?.subscribe(toPlayerState: { (success, error) in
//              if let error = error {
//                  print("Error subscribing to player state:" + error.localizedDescription)
//              }
//          })
//    appRemote.playerAPI?.skip(toNext: appCallback)

     
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
  
}

extension HRMViewController: CBCentralManagerDelegate {
  
  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
      print("Connected to device in HRM")
      sensorPeripheral.delegate = self
    sensorPeripheral.discoverServices([heartRateServiceCBUUID])
    
    
  }
  
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    
    switch central.state {
      
    case .unknown:
      print("central.state is .unknown")
    case .resetting:
      print("central.state is .resetting")
    case .unsupported:
      print("central.state is .unsupported")
    case .unauthorized:
      print("central.state is .unauthorized")
    case .poweredOff:
      print("central.state is .poweredOff")
    case .poweredOn:
      print("central.state is .poweredOn")
      
      
    }
  }
//  func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
//      print(peripheral)
//      heartRatePeripheral = peripheral
//      heartRatePeripheral.delegate = self
//      centralManager.stopScan()
//      centralManager.connect(heartRatePeripheral)
//  }
//  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
//    print("Connected to device")
//    heartRatePeripheral.discoverServices([heartRateServiceCBUUID])
//  }
  
  func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
    _ = navigationController?.popViewController(animated: true)
    
     print("Device disconnected, scanning again")
     
  }
  
  func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
    print("Unable to connect to device")
     _ = navigationController?.popViewController(animated: true)
   }
  
}

extension HRMViewController: CBPeripheralDelegate {
  
  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    guard let services = peripheral.services else { return }
    print("Services found in HRM")
    for service in services {
      print(service)
      peripheral.discoverCharacteristics(nil, for: service)
    }
  }
  
  func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
    guard let characteristics = service.characteristics else {return}

    for characteristic in characteristics {
      
      if characteristic.properties.contains(.read)
      {
        print("\(characteristic.uuid): properties contains .read")
        peripheral.readValue(for: characteristic)
       // arrChar[0] = characteristic
      }
      if characteristic.properties.contains(.notify)
      {
        print("\(characteristic.uuid): properties contains .notify")
        peripheral.setNotifyValue(true, for: characteristic)
        arrChar[1] = characteristic
      }
    }
  }
   
  func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
    
    guard let data = characteristic.value else {return }
    switch characteristic.uuid {
    case serviceNumber:
      if (data.first == 0){
        bodySensorLocationLabel.text = "0"
      }
      else if (data.first == 1){
        bodySensorLocationLabel.text = "1"
      }
      else if (data.first == 2){
        bodySensorLocationLabel.text = "2"
      }
    case gesture:
      let gestureVal = getGesture(from: characteristic)
      switch gestureVal {
      case 1:
        task.resume()
      case 2:
        print("Skip song")
        self.appRemote.playerAPI?.delegate = self
        self.appRemote.playerAPI?.subscribe(toPlayerState: { (success, error) in
                  if let error = error {
                      print("Error subscribing to player state:" + error.localizedDescription)
                  }
                  else {
                    print("worked")
      }
              })
        self.appRemote.playerAPI?.skip(toNext: appCallback)
//        appRemote.playerAPI?.skip(toNext: appCallback)
      default:
        print("None occured")
        
      }
      onHeartRateReceived(gestureVal)
      //peripheral.readValue(for: arrChar[0]!)
    default:
      print("Unhandled UUID: \(characteristic.uuid)")
    }
  }
  
  private func getGesture(from characteristic: CBCharacteristic) -> Int {
    guard let characteristicData = characteristic.value else { return -1 }
    let byteArray = [UInt8](characteristicData)

    let firstBitValue = byteArray[0] & 0x01
    if firstBitValue == 0 {
      // Heart Rate Value Format is in the 2nd byte
      return Int(byteArray[1])
    } else {
      // Heart Rate Value Format is in the 2nd and 3rd bytes
      return (Int(byteArray[1]) << 8) + Int(byteArray[2])
    }
  }
}
