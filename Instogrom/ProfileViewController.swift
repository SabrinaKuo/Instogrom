//
//  ProfileViewController.swift
//  Instogrom
//
//  Created by sabrina.kuo on 2017/4/17.
//  Copyright © 2017年 sabrinaApp. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class ProfileViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var image: UIImage!
    var ref: FIRDatabaseReference!
    var profileRef: FIRDatabaseReference!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        profileRef = ref.child("profile")
    }

    @IBAction func completeEdit(_ sender: Any) {
//        let postRef = self.profileRef.childByAutoId()
//        let postKey = postRef.key
        
        if FIRAuth.auth()?.currentUser == nil {
            print("no one login, can't upload")
            return
        }
        
        let currentUser = (FIRAuth.auth()?.currentUser)!
        
        var profileData: [String: Any] = [
            "authorUID" : currentUser.uid,
            "email" : currentUser.email!,
            "name" : nameTextField.text,
            "photoPath" : "",
            "photoURL" : "",
            
        ]

        if let data = UIImageJPEGRepresentation(self.image!, 0.7) {
            let mataData = FIRStorageMetadata()
            mataData.contentType = "image/jpeg"
            
            let imageRef = FIRStorage.storage().reference().child("photos\(currentUser.uid).jpg")
            
            SVProgressHUD.setDefaultMaskType(.black)
            SVProgressHUD.showProgress(0)
            
            let uploadTask = imageRef.put(data, metadata: mataData) { metadata, error in
                
                SVProgressHUD.dismiss()
                
                guard let metadata = metadata else {
                    print("Upload file failed")
                    return
                }
                
                print("Upload Finish!")
                
                profileData["photoPath"] = imageRef.fullPath
                profileData["photoURL"] = metadata.downloadURL()!.absoluteString
                
                self.profileRef.updateChildValues(profileData)
                
            }
            
            uploadTask.observe(.progress){ snapshot in
                guard let progress = snapshot.progress else {
                    return
                }
                
                SVProgressHUD.showProgress(Float(progress.fractionCompleted))
            }
            
        }
        
//        self.tabBarController?.selectedIndex = 0

    }
    
    @IBAction func editAvatar(_ sender: Any) {
    
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let picker = UIImagePickerController()
        picker.delegate = self
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "拍照", style: .default) { action in
                picker.sourceType = .camera
                self.present(picker, animated: true, completion: nil)
            }
            actionSheet.addAction(cameraAction)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let photoAction = UIAlertAction(title: "選取照片", style: .default) { action in
                picker.sourceType = .photoLibrary
                self.present(picker, animated: true, completion: nil)
            }
            actionSheet.addAction(photoAction)
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { action in
        }
        actionSheet.addAction(cancelAction)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        image = info[UIImagePickerControllerOriginalImage] as! UIImage
        avatarImageView.image = image
        
        dismiss(animated: true, completion: nil)
    }
}
