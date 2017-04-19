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

class FeedViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, myTableDelegate {
    
    var ref: FIRDatabaseReference!
    var postsRef: FIRDatabaseReference!
    var messageRef: FIRDatabaseReference!
    var likeRef: FIRDatabaseReference!
    var profileRef: FIRDatabaseReference!
    var dataSource: FUITableViewDataSource!
    
    var avatarImageURL: URL!
    var selectedPostID: String!
    
    
    override func viewDidLoad() {
        ref = FIRDatabase.database().reference()
        postsRef = ref.child("posts")
        profileRef = ref.child("profile")
        messageRef = ref.child("messages")
        likeRef = ref.child("likes")
        
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 410
        
        let currentUserID = (FIRAuth.auth()?.currentUser?.uid)!
        
        let query = postsRef.queryOrdered(byChild: "postDateReversed")
        dataSource = tableView.bind(to: query) { (tableView, indexPath, snapshot) -> UITableViewCell in
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
            
            if let postData = snapshot.value as? [String: Any] {
                
                cell.likeButton.tag = indexPath.row
                cell.likeButton.addTarget(self, action:#selector(FeedViewController.likeTapped(_:)), for: UIControlEvents.touchUpInside)
                cell.sharedButton.tag = indexPath.row
                cell.sharedButton.addTarget(self, action: #selector(FeedViewController.sharedTapped(_:)), for: UIControlEvents.touchUpInside)
                
                cell.delegate = self
                
                if let userID = postData["authorUID"] as? String {
                    self.profileRef.child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
                        if let value = snapshot.value as? NSDictionary {
                            let avatarURLString = value["photoURL"] as! String
                            self.avatarImageURL = URL(string: avatarURLString)!
                            
                            cell.userNameLabel.text = value["username"] as? String
                            cell.avatarImageView.sd_setImage(with: self.avatarImageURL)
                        } else {
                            let email = postData["email"] as! String
                            let name = email.components(separatedBy: "@")
                            cell.userNameLabel.text = name.first!
                            
                        }
                    })
                }
                
                if let postID = postData["postID"] as? String {
                    self.likeRef.child(postID).observeSingleEvent(of: .value, with: { snapshot in
                        if let value = snapshot.value as? NSDictionary {
                            cell.likesView.isHidden = false
                            
                            cell.likesLabel.text = "\(value.count)個讚"
                            if value[currentUserID] != nil {
                                cell.likeButton.setImage(UIImage(named: "like"), for: .normal)
                            }
                        } else {
                            cell.likeButton.setImage(UIImage(named: "unlike"), for: .normal)
                            cell.likesLabel.text = ""
                        }
                    })
                    
                    self.messageRef.child(postID).observeSingleEvent(of: .value, with: { snapshot in
                        if let value = snapshot.value as? NSDictionary {
                            cell.msgName.text = value["name"] as? String
                            cell.msgLabel.text = value["Message"] as? String
                        } else {
                            cell.msgName.text = ""
                            cell.msgLabel.text = ""
                        }
                        
                    })
                }
                
                let imageURLString = postData["imageURL"] as! String
                let imageURL = URL(string: imageURLString)!
                
                cell.photoImageView.sd_setImage(with: imageURL)
            }
            return cell
        }

    }
    
    @IBAction func sharedTapped(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let snapshot = dataSource.snapshot(at: sender.tag)
        
        if let value = snapshot.value as? NSDictionary, let imageURLString = value["imageURL"] as? String {
            
            if let imageURL = URL(string: imageURLString) {
                let copyAction = UIAlertAction(title: "複製圖片連結", style: .default) { action in
                    UIPasteboard.general.url = imageURL
                }
                
                let lineAction = UIAlertAction(title: "在LINE分享照片", style: .default) { action in
                    if let appUrl = URL(string: "line://msg/text/" + "\(imageURL)") {
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(appUrl, options: [:], completionHandler: nil)
                        }
                    } else {
                        let itunesURL = URL(string: "itms-apps://itunes.apple.com/app/id443904275")!
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(itunesURL, options: [:], completionHandler: nil)
                        } else {
                            // Fallback on earlier versions
                        }
                    }
                    
                }
                
                let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (action) in
                }
                
                actionSheet.addAction(copyAction)
                actionSheet.addAction(lineAction)
                actionSheet.addAction(cancelAction)
                
                self.present(actionSheet, animated: true, completion: nil)

            }
        }
        
    }
    
    @IBAction func likeTapped(_ sender: UIButton) {
        debugPrint(sender.tag)
        
        let userID = (FIRAuth.auth()?.currentUser?.uid)!
        let snapshot = dataSource.snapshot(at: sender.tag)
        
        let likeData: [String: Any] = [
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
        
        self.tableView.reloadData()
        
    }

    func myTableDelegate(sender: UILongPressGestureRecognizer){
        
        if sender.state == UIGestureRecognizerState.began {
            let location = sender.location(in: self.tableView)
            if let indexPath = self.tableView.indexPathForRow(at: location) {
                
                let snapshot = dataSource.snapshot(at: indexPath.row)
                if let value = snapshot.value as? NSDictionary {
                    
                    let alerConroller = UIAlertController(title: nil, message: "刪除這則貼文", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: { action in
                        let postID = value["postID"] as? String
                        self.postsRef.child(postID!).removeValue()
                    })
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    
                    alerConroller.addAction(okAction)
                    alerConroller.addAction(cancelAction)
                    
                    self.present(alerConroller, animated: true, completion: nil)
                }
                
            }
            
        }
    }
    
}
