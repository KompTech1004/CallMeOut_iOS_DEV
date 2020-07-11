//
//  CallCell.swift
//  Call Me Out
//
//  Created by B S on 4/5/18.
//  Copyright © 2018 B S. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Player

class CallCell: UICollectionViewCell {

    @IBOutlet weak var imgViThumb1: UIImageView!
    @IBOutlet weak var imgViThumb2: UIImageView!
    @IBOutlet weak var lblCallOutName: UILabel!
    @IBOutlet weak var imgViAvatar1: UIImageView!
    @IBOutlet weak var lblUser1: UILabel!
    @IBOutlet weak var lblUser2: UILabel!
    @IBOutlet weak var imgViAvatar2: UIImageView!
    @IBOutlet weak var iconCallOutType: UIImageView!
    @IBOutlet weak var lblWinner: UILabel!
    @IBOutlet weak var lblInitator: UILabel!
    @IBOutlet weak var lblWinnerRight: UILabel!
    @IBOutlet weak var lblViewCnt: UILabel!
    @IBOutlet weak var lblVote: UILabel!
    
    var leftViewController:AVPlayerViewController?
    var rightViewController:AVPlayerViewController?
    
    var leftPlayer:Player?
    var rightPlayer:Player?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
