
import UIKit

class HomeViewController: UIViewController {

    @IBOutlet var loginOutlet: UIButton!
    @IBOutlet var signUpOutlet: UIButton!
    
  @IBAction func backPressed(_ sender: Any) {
  }
  override func viewDidLoad() {
        super.viewDidLoad()
      Utilities.styleButton(button: loginOutlet)
      Utilities.styleButtonNoColor(button: signUpOutlet)
        // Do any additional setup after loading the view.
    }
    
  

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
