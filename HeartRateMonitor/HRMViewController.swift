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
class HRMViewController: UIViewController {

  @IBOutlet weak var logButton: UIButton!
  @IBOutlet weak var gestureLabel: UILabel!
  @IBOutlet weak var bodySensorLocationLabel: UILabel!
  
  @IBAction func loginPressed(_ sender: Any) {
  }
  
  var centralManager: CBCentralManager!
  var heartRatePeripheral: CBPeripheral!
  
  
  override func viewDidLoad() {
    gestureLabel.text = "None"
    bodySensorLocationLabel.text = "0"
//    centralManager = CBCentralManager(delegate: self, queue: nil)
    super.viewDidLoad()
    // Make the digits monospaces to avoid shifting when the numbers change
    gestureLabel.font = UIFont.monospacedDigitSystemFont(ofSize: gestureLabel.font!.pointSize, weight: .regular)
  }

  func onHeartRateReceived(_ gesture: Int) {
    gestureLabel.text = String(gesture)
    print("Gesture: \(gesture)")
  }
}

extension HRMViewController: CBCentralManagerDelegate {
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
      centralManager.scanForPeripherals(withServices: [heartRateServiceCBUUID])
      print("central.state is .poweredOn")
    }
  }
  func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
      print(peripheral)
      heartRatePeripheral = peripheral
      heartRatePeripheral.delegate = self
      centralManager.stopScan()
      centralManager.connect(heartRatePeripheral)
  }
  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    print("Connected to device")
    heartRatePeripheral.discoverServices([heartRateServiceCBUUID])
  }
  
  func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
    
     print("Device disconnected, scanning again")
     centralManager.scanForPeripherals(withServices: [heartRateServiceCBUUID])
  }
  
}

extension HRMViewController: CBPeripheralDelegate {
  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    guard let services = peripheral.services else { return }
    
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
