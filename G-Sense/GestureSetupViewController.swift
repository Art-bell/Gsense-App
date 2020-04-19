import UIKit
import Firebase
import Eureka

class GestureSetupViewController: FormViewController {
    @objc func AlertCheck()
    {
      let valuesDictionary = form.values()
      
      let alertController = UIAlertController(title: "Setup Error", message:
          "Please use different gestures for each operation", preferredStyle: .alert)
      
        //Check spotify section
        if valuesDictionary["Skip Forward Gesture"]! as! String == valuesDictionary["Skip Backward Gesture"]! as! String || valuesDictionary["Skip Backward Gesture"]! as! String == valuesDictionary["Pause/Play"]! as! String ||
            valuesDictionary["Pause/Play"]! as! String == valuesDictionary["Skip Forward Gesture"]! as! String
        {
         alertController.message = "Please use different gestures for Spotify operations"
          alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))

          self.present(alertController, animated: true, completion: nil)
        }
        else if valuesDictionary["Dim Lights Gesture"]! as! String == valuesDictionary["Brighten Lights Gesture"]! as! String
        {
         alertController.message = "Please use different gestures for Smart Light operations"
          alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))

          self.present(alertController, animated: true, completion: nil)
        }
        else {
          if Auth.auth().currentUser != nil {
            let user = Auth.auth().currentUser
            if let user = user {
              let uid = user.uid
              
              let db = Firestore.firestore()
                db.collection("users").document(uid).setData([
                    "skip_forward_gesture": valuesDictionary["Skip Forward Gesture"]!,
                    "skip_backward_gesture": valuesDictionary["Skip Backward Gesture"]!,
                  "dim_lights_gesture":valuesDictionary["Dim Lights Gesture"]!,
                  "brighten_lights_gesture":valuesDictionary["Brighten Lights Gesture"]!,
                  "pause_play":valuesDictionary["Pause/Play"]!
                ]){ err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                    }
                }
            }
//              db.collection("users").addDocument(data: ["skip_forward_gesture": valuesDictionary["Skip Forward Gesture"]!,
//                                                          "skip_backward_gesture": valuesDictionary["Skip Backward Gesture"]!,
//                                                          "dim_lights_gesture": valuesDictionary["Dim Lights Gesture"]!,
//                                                          "brighten_lights_gesture": valuesDictionary["Brighten Lights Gesture"]!,
//                                                          "pause_play": valuesDictionary["Pause/Play"]!,
//                  "uid" : uid])
//
//            }
            transitionToPeripheralSelector()
          } else {
            print("User not signed in")
          }
          
          
        }
      for (field,val) in valuesDictionary{
        if (val! as! String).elementsEqual("Select An Option"){
          alertController.message = "Please select an option for all fields"
          alertController.title = "Missing fields"
        }
      }
        
      
      
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
      let spotifyOptions = ["Clockwise Twist", "Outward Punch", "Vertical Pan", "Forward Punch"]
      
      let spotifyOptionsLessA = ["Clockwise Twist", "Outward Punch", "Vertical Pan"]
      
      let spotifyOptionsLessB = ["Clockwise Twist", "Outward Punch"]
      
      let spotifyOptionsLessC = ["Clockwise Twist"]
      
      let section1 = Section(){ section in
          var header = HeaderFooterView<UIView>(.class)
          header.height = {120}
          header.onSetupView = { view, _ in
              view.backgroundColor = UIColor.init(red: 242/255, green: 242/255, blue:247/255, alpha:1)
            let label = UILabel()
            let label2 = UILabel()
            label.sizeToFit()
            label.font = label.font.withSize(30)
            label.frame = CGRect(x: 0, y: 20, width: label.frame.width+420, height:30)
            label.text = "Gesture Setup"
            label.textAlignment = .center
            
            label2.sizeToFit()
            label2.font = label2.font.withSize(15)
            label2.frame = CGRect(x: 20, y: 50, width: label2.frame.width+380, height:80)
            label2.text = "Please select gestures for corresponding service operations. The same gesture cannot be used for different operations within a service"
            label2.numberOfLines = 0
            label2.textAlignment = .center
            if #available(iOS 13.0, *) {
              label.textColor = .systemGray2
              label2.textColor = .systemGray2
            } else {
              label.textColor = .orange
              label2.textColor = .orange
            }
            
            view.addSubview(label)
            view.addSubview(label2)
          }
          section.header = header
      }
      
      let sectionZ = Section(){ section in
          var header = HeaderFooterView<UIView>(.class)
          header.height = {100}
          header.onSetupView = { view, _ in
              view.backgroundColor = UIColor.init(red: 242/255, green: 242/255, blue:247/255, alpha:1)
            let submitButton = UIButton()
            submitButton.setTitle("Submit", for: .normal)
            submitButton.setTitleColor(UIColor.white, for: .normal)
            submitButton.frame = CGRect(x: 90, y: 25, width: 240, height: 50)
            submitButton.layer.cornerRadius = 20.0
            submitButton.backgroundColor = UIColor.init(red: 240/255, green: 128/255, blue:10/255, alpha:1)
            submitButton.addTarget(self, action: Selector(("AlertCheck")), for: .touchUpInside)
            
            view.addSubview(submitButton)
          }
          section.header = header
      }
         
      form +++ section1
          
//          <<< LabelRow(){
//
//                $0.title = "GSense Gesture Setup"
//          $0.cellStyle = .default
//        }.cellUpdate({ (cell, row) in
//            cell.textLabel?.textAlignment = .center
//          cell.textLabel?.textColor = .systemOrange
//          cell.textLabel?.backgroundColor = .systemBlue
//          cell.textLabel?.font = UIFont.systemFont(ofSize: 30.0)
//        })
      
        form +++ Section("Spotify")
            <<< PickerInlineRow<String>("Skip Forward Gesture") {
              $0.title = "Skip Forward Gesture"
              $0.options = spotifyOptions
              
              $0.value = "Select An Option"
      }
        <<< PickerInlineRow<String>("Skip Backward Gesture") {
                    $0.title = "Skip Backward Gesture"
                    $0.options = spotifyOptions
          $0.value = "Select An Option"
        }
      
      <<< PickerInlineRow<String>("Pause/Play") {
              $0.title = "Pause/Play"
              $0.options = spotifyOptions
        $0.value = "Select An Option"
              
      }
      
      form +++ Section("Dominos")
                 <<< PickerInlineRow<String>("Place Favorite Order Gesture") {
                   $0.title = "Place Favorite Order Gesture"
                   $0.options = spotifyOptions
                  $0.value = "Select An Option"
           }

      form +++ Section("Smart Lights")
            <<< PickerInlineRow<String>("Dim Lights Gesture") {
              $0.title = "Dim Lights Gesture"
              $0.options = spotifyOptions
              $0.value = "Select An Option"
      }
          <<< PickerInlineRow<String>("Brighten Lights Gesture") {
                  $0.title = "Brighten Lights Gesture"
                  $0.options = spotifyOptions
            $0.value = "Select An Option"
          }
//        }
      form +++ Section("Find My Phone")
            <<< PickerInlineRow<String>("Call Phone Gesture") {
              $0.title = "Call Phone Gesture"
              $0.options = spotifyOptions
              $0.value = "Select An Option"
      }
      
      form +++ sectionZ
      
//      form +++ Section("Apple Music")
//            <<< PickerInlineRow<String>("Skip Forward Gesture") {
//              $0.title = "Skip Forward Gesture"
//              $0.options = spotifyOptions
//      }
//        <<< PickerInlineRow<String>("Skip Backward Gesture") {
//                    $0.title = "Skip Backward Gesture"
//                    $0.options = spotifyOptions
//        }
//
//      <<< PickerInlineRow<String>("Pause/Play") {
//              $0.title = "Pause/Play"
//              $0.options = spotifyOptions
//
//      }
      
    }
  
  func transitionToPeripheralSelector() {
      
    performSegue(withIdentifier: "GoToPeriphSelect", sender: nil)
    
//  if #available(iOS 13.0, *) {
//    let peripheralNav = storyboard?.instantiateViewController(identifier: "PNVC") as?
//        PeripheralNav
//
//    self.view.window?.rootViewController = peripheralNav
//    self.view.window?.makeKeyAndVisible()
//  }
  }
  
  
}
