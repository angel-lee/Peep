//
//  PostCellTableViewCell.swift
//  Peep
//
//  Created by Raymond_Dev on 9/8/15.
//  Copyright (c) 2015 Rayngel. All rights reserved.
//

import UIKit

class PostCellTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postContent: UILabel!
    @IBOutlet weak var myPostAndCommentContent: UILabel!
    @IBOutlet weak var numOfLikes: UILabel!
    
    @IBOutlet weak var likeButton: UIButton!
    
    var likesInt: Int!
    var isLiked: Bool!
    var likers: NSArray!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
