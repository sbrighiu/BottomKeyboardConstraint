//
//  Copyright © 2019 Stefan Brighiu. All rights reserved.
//
import UIKit
import BottomKeyboardConstraint

class ViewController: UIViewController, KeyboardDelegate {
    
    @IBOutlet weak var titleLabel: UILabel?
    
    @IBOutlet weak var bottomKeyboardConstraint: NSLayoutConstraint?
    
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bottomKeyboardConstraint?.registerAsBottomKeyboardConstraint(in: self)
    }

    @IBAction func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func closeKeyboard() {
        self.view.endEditing(false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (self.navigationController?.viewControllers.count ?? 1) >= 2 {
            segue.destination.hidesBottomBarWhenPushed = true
        }
    }
    
    func keyboardUpdated(withState state: KeyboardState) {
        print(state)
    }
    
    func keyboardShouldDismissAtTap() -> Bool {
        if titleLabel?.text == "No Tap To Dismiss" {
            return false
        }
        return true
    }

}
