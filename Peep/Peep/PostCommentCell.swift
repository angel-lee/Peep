//
//  PostDetailCell.swift
//  Peep
//
//  Created by Raymond_Dev on 9/20/15.
//  Copyright © 2015 Rayngel. All rights reserved.
//

import UIKit
import ActiveLabel

class PostCommentCell: UITableViewCell {

    @IBOutlet weak var postDetailContent: UILabel!
    @IBOutlet weak var postCommentsContent: ActiveLabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var numOfLikes: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var likesInt: Int!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        postCommentsContent.numberOfLines = 0
        postCommentsContent.lineBreakMode = .ByWordWrapping
        postCommentsContent.hashtagColor = UIColor(red: 40.0/255, green: 132.0/255, blue: 255.0/255, alpha: 1)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
