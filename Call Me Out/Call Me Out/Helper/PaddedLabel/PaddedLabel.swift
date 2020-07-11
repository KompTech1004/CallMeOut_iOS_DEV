//
//  PaddedLabel.swift
//  Call Me Out
//
//  Created by gstream on 9/9/18.
//  Copyright © 2018 B S. All rights reserved.
//

import UIKit

class PaddedLabel: UILabel {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets.init(top: 0, left: 25, bottom: 0, right: 10)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
    
}
