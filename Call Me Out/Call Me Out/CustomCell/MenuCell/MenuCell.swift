//
//  MenuCell.swift
//  Call Me Out
//
//  Created by B S on 4/4/18.
//  Copyright © 2018 B S. All rights reserved.
//

import UIKit

class MenuCell: UITableViewCell {
    @IBOutlet weak var lblMenuTitle: UILabel!
    @IBOutlet weak var imgViThumb: UIImageView!
    @IBOutlet weak var lblCounts: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
