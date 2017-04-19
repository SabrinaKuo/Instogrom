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
    @IBOutlet weak var signUPButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    var frameView: UIView!
    
    override func viewDidLoad() {
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.keyboardWillHide))
        view.addGestureRecognizer(tap)
        
        signUPButton.layer.borderWidth = 1
        signUPButton.layer.borderColor = UIColor.white.cgColor
        
        checkAvaliable()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.scrollView.contentInset = UIEdgeInsets.zero
        self.scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
        
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func didTextfieldChanged() {
        checkAvaliable()
    }
    
    func keyboardWillShow(notification: NSNotification) {
        DispatchQueue.main.async(execute: {
            let info:NSDictionary = notification.userInfo! as NSDictionary
            let kbSize = (info.object(forKey: UIKeyboardFrameBeginUserInfoKey) as AnyObject).cgRectValue.size
            let contentInsets = UIEdgeInsetsMake(0.0, 0.0, (kbSize.height), 0.0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
        })
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        DispatchQueue.main.async(execute: {
            self.scrollView.contentInset = UIEdgeInsets.zero
            self.scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
            self.view.endEditing(true)
        })
        
    }
    
    func checkAvaliable() {
        if (emailField.text?.isEmpty)! || (passwordField.text?.isEmpty)! || (comfirmField.text?.isEmpty)! {
            signUPButton.isEnabled = false
            signUPButton.alpha = 0.5
        } else {
            signUPButton.isEnabled = true
            signUPButton.alpha = 1
        }
    }
    
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
