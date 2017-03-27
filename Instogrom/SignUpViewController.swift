//
//  SignUpViewController.swift
//  Instogrom
//
//  Created by Kuo Sabrina on 2017/3/27.
//  Copyright © 2017年 sabrinaApp. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var comfirmField: UITextField!
    
    @IBAction func signUpTapped(_ sender: Any) {
        
        guard let email = emailField.text, let password = passwordField.text else {
            print("資料輸入錯誤")
            return
        }
        
        if password != passwordField.text {
            print("二次密碼不一樣")
            return
        }
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password) {user, error in
            guard let user = user else {
                print("註冊失敗\(error)")
                return
            }
            
            print("\(user.email)註冊成功")
        }
        
    }
    
    @IBAction func backToSignInTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}
