//
//  PostCell.swift
//  Instogrom
//
//  Created by Kuo Sabrina on 2017/4/6.
//  Copyright © 2017年 sabrinaApp. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var likesView: UIView!
    @IBOutlet weak var sharedButton: UIButton!
    
    @IBOutlet weak var msgName: UILabel!
    @IBOutlet weak var msgLabel: UILabel!
    
    var delegate: myTableDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(PostCell.longPress(sender:)))
        
        self.addGestureRecognizer(longPress)
        
        avatarImageView.layer.borderWidth = 0.1
        avatarImageView.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    func longPress(sender: UILongPressGestureRecognizer) {
        delegate?.myTableDelegate(sender: sender)
    }
    
}

protocol myTableDelegate {
    func myTableDelegate(sender: UILongPressGestureRecognizer)
}
