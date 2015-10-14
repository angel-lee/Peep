//
//  PostCellTableViewCell.swift
//  Peep
//
//  Created by Raymond_Dev on 9/8/15.
//  Copyright (c) 2015 Rayngel. All rights reserved.
//

import UIKit
import ActiveLabel

class PostCellTableViewCell: UITableViewCell {
    
    @IBOutlet weak var myPostAndCommentContent: UILabel!
    @IBOutlet weak var numOfLikes: UILabel!
    
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var postContent : ActiveLabel!
    
    var likesInt: Int!
    var isLiked: Bool!
    var likers: NSArray!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        postContent.numberOfLines = 0
        postContent.hashtagColor = UIColor(red: 85.0/255, green: 172.0/255, blue: 238.0/255, alpha: 1)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
