//
//  ProfileCallout.swift
//  Call Me Out
//
//  Created by B S on 4/30/18.
//  Copyright © 2018 B S. All rights reserved.
//

import UIKit

class ProfileCallout: UICollectionViewCell {

    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var imgType: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imgType.image = nil
        img.image = nil
    }
}
