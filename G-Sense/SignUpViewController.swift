
import UIKit
import Firebase

class SignUpViewController: UIViewController {

  @IBOutlet var emailTextField: UITextField!
  
  @IBOutlet var numberTextField: UITextField!
  
  @IBOutlet var passwordTextField: UITextField!
  
  @IBOutlet var confPasswordTextField: UITextField!
  
  @IBOutlet var signupButton: UIButton!
  
  @IBOutlet var errorLabel: UILabel!
  override func viewDidLoad() {
        super.viewDidLoad()
    
        // Do any additional setup after loading the view.
        setUpElements()
    }
    
  func setUpElements(){
    errorLabel.alpha = 0
  }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
  
  func validateFields() -> String? {
    //Check if all fields are full
    if emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
      numberTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
      passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
      confPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
    {
      return "Please fill in all fields"
    }
    
    let emailRegEx = "(?:[a-zA-Z0-9!#$%\\&‘*+/=?\\^_`{|}~-]+(?:\\.[a-zA-Z0-9!#$%\\&'*+/=?\\^_`{|}"
    + "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    + "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    + "z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    + "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    + "9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    + "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
    
    //Check if email is valid
    if (!(NSPredicate(format: "SELF MATCHES %@", emailRegEx)).evaluate(with: emailTextField.text!))
    {
      return "Please make sure password is at least 8 characters, contains a special character and a number"
    }
    
    //Check if password is secure
    if (!(NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")).evaluate(with: passwordTextField.text!))
    {
      return "Please make sure password is at least 8 characters, contains a special character and a number"
    }
    
    if (passwordTextField.text! != confPasswordTextField.text!)
    {
      return "Passwords must match"
    }
    return nil
  }
  
  func showErrorMessage(message: String)
  {
    errorLabel.text = message
    errorLabel.alpha = 1
  }
  
  @IBAction func signUpTapped(_ sender: Any) {
    //Validate fields
    let error = validateFields()
    
    if error != nil {
      showErrorMessage(message: error!)
    }
    else {
      //Create user
      let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
      let number = numberTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
      
      let password =
        passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
      
      
      
      Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
        if err != nil{
          self.showErrorMessage(message: "Error creating account. Please try again later")
        }
        else {
          let db = Firestore.firestore()
          db.collection("users").addDocument(data: ["number": number, "uid" : result!.user.uid]) { (error) in
            self.showErrorMessage(message: "Unable to store user phone number")
          }
          self.transitionToGestureSetup()
        }
      }
      //Transition to peripheral pair screen
      
    }
    
  }
  
  func transitionToGestureSetup() {
    if #available(iOS 13.0, *) {
      let gestureSetupViewController = storyboard?.instantiateViewController(identifier: "GestureSetupVC") as? 
          GestureSetupViewController
        
      view.window?.rootViewController = gestureSetupViewController
      view.window?.makeKeyAndVisible()
    }
//    else {
//      // Fallback on earlier versions
//    }
    
    
  }
  
  

  
  
}
