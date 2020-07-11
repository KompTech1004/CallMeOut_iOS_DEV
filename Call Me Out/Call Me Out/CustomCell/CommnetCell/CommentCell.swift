//
//  CommentCell.swift
//  Call Me Out
//
//  Created by B S on 4/16/18.
//  Copyright © 2018 B S. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {

    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblComment: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
