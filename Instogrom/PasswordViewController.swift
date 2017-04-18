//
//  PasswordViewController.swift
//  Instogrom
//
//  Created by sabrina.kuo on 2017/4/17.
//  Copyright © 2017年 sabrinaApp. All rights reserved.
//

import UIKit
import Firebase

class PasswordViewController: UITableViewController {

    @IBOutlet weak var currentPW: UITextField!
    @IBOutlet weak var newPW: UITextField!
    @IBOutlet weak var comfirmPW: UITextField!
    
    var email: String!
   
    @IBAction func ChangePWTapped(_ sender: Any) {
    
        let curPW = currentPW.text!
        
        FIRAuth.auth()?.signIn(withEmail: email, password: curPW, completion: { (user, error) in
            guard error == nil else {
                print("Current Password is worng!")
                self.clearTextFields()
                return
            }
           
            let newPassword = self.newPW.text!
            let comfirmPassword = self.comfirmPW.text!
            
            if newPassword != comfirmPassword {
                print("please comfirm new password")
                self.clearTextFields()
                return
            }
            
            user?.updatePassword(newPassword, completion: { (error) in
                if let error = error {
                    print("update password failed : \(error)")
                    self.clearTextFields()
                    return
                }
                
                self.clearTextFields()
                print("update password success")
            })
        })
    }

    func clearTextFields() {
        currentPW.text = ""
        newPW.text = ""
        comfirmPW.text = ""
    }
    
}
