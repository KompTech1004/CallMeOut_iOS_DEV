//
//  TopListCell.swift
//  Call Me Out
//
//  Created by gstream on 9/2/18.
//  Copyright © 2018 B S. All rights reserved.
//

import UIKit

class TopListCell: UICollectionViewCell {
    
    @IBOutlet weak var imgThumb1: UIImageView!
    @IBOutlet weak var imgThumb2: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    
    override func awakeFromNib() {
        lblName.layer.cornerRadius = 15
        lblName.clipsToBounds = true
    }
}
