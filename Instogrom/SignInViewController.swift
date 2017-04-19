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
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignInViewController.keyboardWillClose))
        view.addGestureRecognizer(tap)
        
        signInButton.layer.borderWidth = 1
        signInButton.layer.borderColor = UIColor.white.cgColor
        checkAvaliable()
    }
    
    func checkAvaliable(){
        if emailField.text == "" || passwordField.text == "" {
            signInButton.isEnabled = false
            signInButton.alpha = 0.5
        } else {
            signInButton.isEnabled = true
            signInButton.alpha = 1
        }
    }
    
    @IBAction func didTextFieldChange() {
        checkAvaliable()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.scrollView.contentInset = UIEdgeInsets.zero
        self.scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
        
        NotificationCenter.default.addObserver(self, selector: #selector(SignInViewController.keyboardWillShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func keyboardWillShown(notification:NSNotification) {
        DispatchQueue.main.async(execute: {
            let info:NSDictionary = notification.userInfo! as NSDictionary
            let kbSize = (info.object(forKey: UIKeyboardFrameBeginUserInfoKey) as AnyObject).cgRectValue.size
            let contentInsets = UIEdgeInsetsMake(0.0, 0.0, (kbSize.height), 0.0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
        })
    }
    
    func keyboardWillClose(){
        DispatchQueue.main.async(execute: {
            self.scrollView.contentInset = UIEdgeInsets.zero
            self.scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
            self.view.endEditing(true)
        })
    }
    
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
