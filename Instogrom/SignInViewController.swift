//
//  SignInViewController.swift
//  Instogrom
//
//  Created by Kuo Sabrina on 2017/3/27.
//  Copyright © 2017年 sabrinaApp. All rights reserved.
//

import UIKit
import Firebase

class SignInViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBAction func signInTapped(_ sender: Any) {
        print("start sign in")
        
        guard let email = emailField.text, let password = passwordField.text else {
            print("account or email wrong")
            return
        }
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password) { user, error in
            guard let user = user else {
                print("Login failed \(error)")
                return
            }
            
            print("user \(user.email) Login success")
        }
    }
    
}
