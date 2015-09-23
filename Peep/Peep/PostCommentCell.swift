//
//  PostDetailCell.swift
//  Peep
//
//  Created by Raymond_Dev on 9/20/15.
//  Copyright © 2015 Rayngel. All rights reserved.
//

import UIKit

class PostCommentCell: UITableViewCell {

    @IBOutlet weak var postDetailContent: UILabel!
    @IBOutlet weak var postCommentsContent: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
