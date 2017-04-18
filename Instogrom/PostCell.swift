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
    
    var delegate: myTableDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(PostCell.longPress(sender:)))
        
        self.addGestureRecognizer(longPress)
    }
    
    func longPress(sender: UILongPressGestureRecognizer) {
        delegate?.myTableDelegate(sender: sender)
    }
    
}

protocol myTableDelegate {
    func myTableDelegate(sender: UILongPressGestureRecognizer)
}
