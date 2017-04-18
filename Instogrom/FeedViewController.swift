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
    var profileRef: FIRDatabaseReference!
    var dataSource: FUITableViewDataSource!
    
    var userName: String!
    var avatarImageURL: URL!
    var selectedPostID: String!
    
    
    override func viewDidLoad() {
        ref = FIRDatabase.database().reference()
        postsRef = ref.child("posts")
        profileRef = ref.child("profile")
        messageRef = ref.child("messages")
        likeRef = ref.child("likes")
        
//        ref.updateChildValues(["123": "abc"])
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 410
        
        let currentUserID = (FIRAuth.auth()?.currentUser?.uid)!
        
        let query = postsRef.queryOrdered(byChild: "postDateReversed")
        dataSource = tableView.bind(to: query) { (tableView, indexPath, snapshot) -> UITableViewCell in
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
            
            if let postData = snapshot.value as? [String: Any] {
                
                cell.likeButton.tag = indexPath.row
                cell.likeButton.addTarget(self, action:#selector(FeedViewController.likeTapped(_:)), for: UIControlEvents.touchUpInside)
                
                if let userID = postData["authorUID"] as? String {
                    self.profileRef.child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
                        if let value = snapshot.value as? NSDictionary {
                            self.userName = value["username"] as! String
                            let avatarURLString = value["photoURL"] as! String
                            self.avatarImageURL = URL(string: avatarURLString)!
                            
                            cell.userNameLabel.text = self.userName
                            cell.avatarImageView.sd_setImage(with: self.avatarImageURL)
                        }
                    })
                }
                
                if let likeID = postData["postID"] as? String {
                    self.likeRef.child(likeID).observeSingleEvent(of: .value, with: { snapshot in
                        if let value = snapshot.value as? NSDictionary {
                            if value[currentUserID] != nil {
                                cell.likeButton.setImage(UIImage(named: "like"), for: .normal)
                            }
                        }
                        
                    })
                }
                
                if (cell.userNameLabel.text?.isEmpty)! {
                    cell.userNameLabel.text = postData["email"] as? String
                }
                
                let imageURLString = postData["imageURL"] as! String
                let imageURL = URL(string: imageURLString)!
                
                cell.photoImageView.sd_setImage(with: imageURL)
            }
            return cell
        }

    }
    
    @IBAction func likeTapped(_ sender: UIButton) {
        debugPrint(sender.tag)
        
        let userID = (FIRAuth.auth()?.currentUser?.uid)!
        let snapshot = dataSource.snapshot(at: sender.tag)
        
        var likeData: [String: Any] = [
             userID : true
        ]
        
        
        if let value = snapshot.value as? NSDictionary {
            let likeID = value["postID"] as? String
            
            let selectedLikeRef = likeRef.child(likeID!)
            
            if (sender.imageView?.image == UIImage(named:"like")) {
                sender.setImage(UIImage(named: "unlike"), for: .normal)
                selectedLikeRef.child(userID).removeValue()
            } else {
                sender.setImage(UIImage(named: "like"), for: .normal)
                selectedLikeRef.updateChildValues(likeData)
            }
            
        }
        
        
        
    }
    
}
