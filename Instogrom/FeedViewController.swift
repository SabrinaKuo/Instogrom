//
//  FeedViewController.swift
//  Instogrom
//
//  Created by sabrina.kuo on 2017/4/6.
//  Copyright © 2017年 sabrinaApp. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabaseUI
import SDWebImage
import SVProgressHUD

class FeedViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var ref: FIRDatabaseReference!
    var postsRef: FIRDatabaseReference!
    var messageRef: FIRDatabaseReference!
    var likeRef: FIRDatabaseReference!
    var dataSource: FUITableViewDataSource!
    
    override func viewDidLoad() {
        ref = FIRDatabase.database().reference()
        postsRef = ref.child("posts")
        messageRef = ref.child("messages")
        likeRef = ref.child("likes")
        
//        ref.updateChildValues(["123": "abc"])
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 410
        
        let query = postsRef.queryOrdered(byChild: "postDateReversed")
        dataSource = tableView.bind(to: query) { (tableView, indexPath, snapshot) -> UITableViewCell in
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
            
            if let postData = snapshot.value as? [String: Any] {
                
                cell.likeButton.tag = postData["postDate"] as! Int
                cell.likeButton.addTarget(self, action:#selector(FeedViewController.likeTapped(_:)), for: UIControlEvents.touchUpInside)

                
                cell.emailLabel.text = postData["email"] as? String
                
                let imageURLString = postData["imageURL"] as! String
                let imageURL = URL(string: imageURLString)!
                
                cell.photoImageView.sd_setImage(with: imageURL)
            }
            return cell
        }
    }
    
    
    @IBAction func signOut(_ sender: Any) {
        try!FIRAuth.auth()?.signOut()
    }
    
    @IBAction func likeTapped(_ sender: UIButton) {
        debugPrint(sender.tag)
        
        if FIRAuth.auth()?.currentUser == nil {
            print("no one login, can't upload")
            return
        }
        
//        let likeKey = sender.tag as! String
//        likeRef.child(likeKey)
//        let currentUser = (FIRAuth.auth()?.currentUser)!
//        
//        let post : [String: Any] = [
//            "uid" : currentUser
//        ]
//        
//        likeRef.updateChildValues(post)
        
    }
    
    @IBAction func addPhotoTapped(_ sender: Any) {
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
        
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        let postRef = postsRef.childByAutoId()
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
        
        
        if let data = UIImageJPEGRepresentation(image, 0.7) {
            let metaData = FIRStorageMetadata()
            metaData.contentType = "image/jpeg"
            
            let imageRef = FIRStorage.storage().reference().child("photos/\(postKey).jpg")
            
            SVProgressHUD.setDefaultMaskType(.black)
            SVProgressHUD.showProgress(0)
            
            let uploadTask = imageRef.put(data, metadata: metaData) { metadata, error in
                
                SVProgressHUD.dismiss()
                guard let metadata = metadata else {
                    print("檔案上傳失敗")
                    return
                }
                
                print("檔案上傳完成了")
                
                postData["imagePath"] = imageRef.fullPath
                postData["imageURL"] = metadata.downloadURL()!.absoluteString
                
                let now = Date()
                postData["postDate"] = Int(round(now.timeIntervalSince1970 * 1000))
                postData["postDateReversed"] = Int(round(now.timeIntervalSince1970 * 1000)) * -1
                
                postRef.updateChildValues(postData)
            }
            
            uploadTask.observe(.progress, handler: { (snapshot) in
                guard let progress = snapshot.progress else {
                    return
                }
                
                SVProgressHUD.showProgress(Float(progress.fractionCompleted))
            })
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    
}
