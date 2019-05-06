//
//  Copyright © 2019 Stefan Brighiu. All rights reserved.
//

import UIKit

class BaseKeyboardVC: UIViewController, KeyboardHandlerDelegate {

    @IBOutlet weak var bottomConstraint: NSLayoutConstraint?
    var keyboardHandler: KeyboardHandler?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let _ = bottomConstraint {
            keyboardHandler = KeyboardHandler(withVC: self)
        }
    }
    
}
