//
//  MainViewController.swift
//  Instogrom
//
//  Created by Kuo Sabrina on 2017/3/27.
//  Copyright © 2017年 sabrinaApp. All rights reserved.
//

import UIKit
import Firebase

class MainViewController: UIViewController {

    
    @IBAction func signOutTapped(_ sender: Any) {
        try!FIRAuth.auth()?.signOut()
    }
}
