import UIKit
import CoreBluetooth

let heartRateServiceCBUUID = CBUUID(string: "0x180D")
let gesture = CBUUID(string: "0x2A37")
let serviceNumber = CBUUID(string: "0x2A38")
let stackView = UIStackView()
var buttonPeripheral = [UIButton: CBPeripheral]()
class PeripheralSelector: UIViewController {
  @IBOutlet weak var SensorStack: UIStackView!
  @IBOutlet weak var sensorLabel: UILabel!
//  @IBAction func unwindToSelection(_ unwindSegue: UIStoryboardSegue) {
//
//  }
  var centralManager: CBCentralManager!
  var sensorPeripheral: CBPeripheral!

  override func viewDidLoad() {
    print("Reached")
    centralManager = CBCentralManager(delegate: self, queue: nil)
    stackView.axis = .vertical
    stackView.alignment = .fill // .Leading .FirstBaseline .Center .Trailing .LastBaseline
    stackView.distribution = .fill // .FillEqually .FillProportionally .EqualSpacing .EqualCentering
    
    
    super.viewDidLoad()
    
  }
  override func viewDidAppear(_ animated: Bool) {
    sensorLabel.text = "No Sensors Found"
    SensorStack.subviews.forEach({ $0.removeFromSuperview() })
    centralManager.delegate = self
    if (centralManager.state.rawValue == 5)
    {
      if (sensorPeripheral != nil){
      centralManager.cancelPeripheralConnection(sensorPeripheral)
      centralManager.scanForPeripherals(withServices: [heartRateServiceCBUUID])
        print("Peripheral scan from view load")
      }
    }
    
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
  @objc func AttemptConnection(_ sender: UIButton)
   {
    
    sensorPeripheral = buttonPeripheral[sender]
    
    
    performSegue(withIdentifier: "GoToGestureView", sender: sender)
   }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?)
  {
    
      if segue.destination is HRMViewController
      {
          let vc = segue.destination as? HRMViewController
        vc?.centralManager = centralManager
        vc?.sensorPeripheral = sensorPeripheral
        
        
      }
  }
  
  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
      print("Connected to device Periph")
    sensorPeripheral.discoverServices([heartRateServiceCBUUID])
    
    
  }
  
  func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
      let label = UILabel()
      let button = UIButton()
      let horizontalStack = UIStackView()
    horizontalStack.axis = .horizontal
    horizontalStack.alignment = .top
    horizontalStack.distribution = .fillEqually
    button.setTitle("Connect", for: .normal)
    button.setTitleColor(UIColor.blue, for: .normal)
    button.frame = CGRect(x: 15, y: -50, width: 100, height: 20)
    button.addTarget(self, action: #selector(AttemptConnection(_:)), for: .touchUpInside)
    print(type(of: button))
    label.text = peripheral.name
    label.sizeToFit()
    label.font = label.font.withSize(20)
    label.frame = CGRect(x: 0, y: 0, width: label.frame.width+30, height:20)
    sensorLabel.text = "Found Sensors"
    horizontalStack.addArrangedSubview(label)


  horizontalStack.addArrangedSubview(button)
    buttonPeripheral[button] = peripheral

    SensorStack.addArrangedSubview(horizontalStack)
//      sensorPeripheral = peripheral
//      heartRatePeripheral.delegate = self
//      centralManager.stopScan()
//      centralManager.connect(heartRatePeripheral)
  }
  
 
}

extension PeripheralSelector: CBPeripheralDelegate {
  
  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    
    guard let services = peripheral.services else { return }
    print("Services found in Periph")
    for service in services {
      print(service)
//      peripheral.discoverCharacteristics(nil, for: service)
    }
  }
  
 
}
