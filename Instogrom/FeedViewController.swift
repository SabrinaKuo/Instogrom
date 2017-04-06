//
//  FeedViewController.swift
//  Instogrom
//
//  Created by sabrina.kuo on 2017/4/6.
//  Copyright © 2017年 sabrinaApp. All rights reserved.
//

import UIKit
import Firebase

class FeedViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var ref: FIRDatabaseReference!
    
    override func viewDidLoad() {
        ref = FIRDatabase.database().reference()
        
        ref.observe(.value, with: { snapshot in
            if let value = snapshot.value as? [String: Any] {
                debugPrint(value)
            }
        })
        
        ref.observe(.childAdded, with: { (snapshot) in
            if let value = snapshot.value as? [String: Any] {
                debugPrint(snapshot)
            }
        })
    }

    @IBAction func signOut(_ sender: Any) {
        try!FIRAuth.auth()?.signOut()
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
        
        if let data = UIImageJPEGRepresentation(image, 0.7) {
            let metaData = FIRStorageMetadata()
            metaData.contentType = "image/jpeg"
            
            let imageRef = FIRStorage.storage().reference().child("photos/photo.jpg")
            
            imageRef.put(data, metadata: metaData) { metadata, error in
                guard let metadata = metadata else {
                    print("檔案上傳失敗")
                    return
                }
                
                print("檔案上傳完成了")
                debugPrint(metadata)
                debugPrint(metadata.downloadURL()!)
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    
}
