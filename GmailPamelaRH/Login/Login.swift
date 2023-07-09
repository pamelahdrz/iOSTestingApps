//
//  Login.swift
//  GmailPamelaRH
//
//  Created by Razo Hernandez Pamela on 07/07/23.
//

import Foundation
import UIKit

public class Login: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        email.delegate = self
        password.delegate = self
        password.isSecureTextEntry = true
        password.autocorrectionType = .no
        password.keyboardType = .asciiCapable
    }
    
    @IBAction func navToGmailDashboard(sender: UIButton!) {
        DispatchQueue.main.async {
            let vc = GmailDashboard()
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .coverVertical
            self.present(vc, animated: true, completion: nil)
        }
    }

}

