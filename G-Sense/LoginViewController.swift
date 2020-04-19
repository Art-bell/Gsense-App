
import UIKit
import Firebase

class LoginViewController: UIViewController {
  @IBOutlet var emailTextField: UITextField!
  
  @IBOutlet var passwordTextField: UITextField!
  
  @IBOutlet var loginButton: UIButton!
  
  @IBOutlet var errorLabel: UILabel!
  
  override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    setUpElements()
    }
    
    func setUpElements()
    {
      errorLabel.alpha = 0
    }

    
  @IBAction func loginTapped(_ sender: Any) {
    //Validate text fields
    let error = validateFields()
    
    if error != nil {
      showErrorMessage(message: error!)
    }
    else
    {
      //Create cleaned versions of text fields
      let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
      let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
      //signing in user
      Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
        if error != nil {
          self.showErrorMessage(message: "Incorrect username or password")
        }
        else {
          self.transitionToPeripheralSelector()
        }
      }
    }
  }
  
  func showErrorMessage(message: String)
  {
    errorLabel.text = message
    errorLabel.alpha = 1
  }
  
  func validateFields() -> String? {
  //Check if all fields are full
  if emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
  {
    return "Please fill in all fields"
  }
    return nil
  }
  
  func transitionToPeripheralSelector() {
    performSegue(withIdentifier: "GoToPeriphSelect", sender: self)
//  if #available(iOS 13.0, *) {
//    let peripheralNav = storyboard?.instantiateViewController(identifier: "PNVC") as?
//        PeripheralNav
//
//    self.view.window?.rootViewController = peripheralNav
//    self.view.window?.makeKeyAndVisible()
//  }
  }
  
}
