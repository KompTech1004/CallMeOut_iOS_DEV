//
//  ContactCell.swift
//  Call Me Out
//
//  Created by B S on 5/22/18.
//  Copyright © 2018 B S. All rights reserved.
//

import UIKit

class ContactCell: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblPhonenumber: UILabel!
    @IBOutlet weak var btnAdd: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
