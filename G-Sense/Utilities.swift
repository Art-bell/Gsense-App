

import Foundation
import UIKit

class Utilities {
  static func styleButton(button: UIButton)
  {
    button.backgroundColor = UIColor.init(red: 245/255, green: 170/255, blue:66/255, alpha:1)
    button.layer.cornerRadius = 25.0
    button.tintColor = UIColor.white
  }
  
  static func styleButtonNoColor(button: UIButton)
  {
    button.layer.cornerRadius = 25.0
    button.layer.borderWidth = 2
    button.layer.borderColor = UIColor.systemOrange.cgColor
    button.tintColor = UIColor.systemOrange
  }
}
