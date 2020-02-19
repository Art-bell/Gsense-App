import UIKit
import CoreBluetooth

let heartRateServiceCBUUID = CBUUID(string: "0x180D")
let gesture = CBUUID(string: "0x2A37")
let serviceNumber = CBUUID(string: "0x2A38")

class PeripheralSelector: UIViewController {
  var centralManager: CBCentralManager!
  var heartRatePeripheral: CBPeripheral!

  override func viewDidLoad() {
    print("Reached")
    centralManager = CBCentralManager(delegate: self, queue: nil)
    super.viewDidLoad()
  }

}

extension PeripheralSelector: CBCentralManagerDelegate {
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
//      heartRatePeripheral.delegate = self
//      centralManager.stopScan()
//      centralManager.connect(heartRatePeripheral)
  }

}
