//
//  ViewController.swift
//  BottomKeyboardConstraint
//
//  Created by Stefan Brighiu on 05/06/2019.
//  Copyright (c) 2019 Stefan Brighiu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
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

}

