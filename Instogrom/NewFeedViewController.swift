//
//  NewFeedViewController.swift
//  Instogrom
//
//  Created by sabrina.kuo on 2017/4/17.
//  Copyright © 2017年 sabrinaApp. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class NewFeedViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addButton: UIButton!
    
    var image: UIImage?
    var ref: FIRDatabaseReference!
    var postsRef: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        postsRef = ref.child("posts")
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        addButton.layer.borderWidth = 2
        addButton.layer.borderColor = UIColor.gray.cgColor
        startImagePicker()
    }
    
    @IBAction func addTapped(_ sender: Any) {
        let postRef = self.postsRef.childByAutoId()
        let postKey = postRef.key
        
        if FIRAuth.auth()?.currentUser == nil {
            print("no one login, can't upload")
            return
        }
        
        let currentUser = (FIRAuth.auth()?.currentUser)!
        
        var postData: [String: Any] = [
            "authorUID" : currentUser.uid,
            "email" : currentUser.email!,
            "imagePath" : "",
            "imageURL": "",
            "postDate": 0,
            "postDateReversed": 0
        ]
        
        if let data = UIImageJPEGRepresentation(self.image!, 0.7) {
            let mataData = FIRStorageMetadata()
            mataData.contentType = "image/jpeg"
            
            let imageRef = FIRStorage.storage().reference().child("photos\(postKey).jpg")
            
            SVProgressHUD.setDefaultMaskType(.black)
            SVProgressHUD.showProgress(0)
            
            let uploadTask = imageRef.put(data, metadata: mataData) { metadata, error in
                
                SVProgressHUD.dismiss()
                
                guard let metadata = metadata else {
                    print("Upload file failed")
                    return
                }
                
                print("Upload Finish!")
                
                postData["imagePath"] = imageRef.fullPath
                postData["imageURL"] = metadata.downloadURL()!.absoluteString
                
                let now = Date()
                postData["postDate"] = Int(round(now.timeIntervalSince1970 * 1000))
                postData["postDateReversed"] = Int(round(now.timeIntervalSince1970 * 1000)) * -1
                postRef.updateChildValues(postData)
                
                self.imageView.image = nil
            }
            
            uploadTask.observe(.progress){ snapshot in
                guard let progress = snapshot.progress else {
                    return
                }
                
                SVProgressHUD.showProgress(Float(progress.fractionCompleted))
            }
            
        }

        self.tabBarController?.selectedIndex = 0
        
    }
    
    func startImagePicker() {
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
        
        imageView.image = image
        
        dismiss(animated: true, completion: nil)
    }
}
