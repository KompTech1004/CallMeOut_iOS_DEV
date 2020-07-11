//
//  RankingCell.swift
//  Call Me Out
//
//  Created by B S on 4/5/18.
//  Copyright © 2018 B S. All rights reserved.
//

import UIKit

class RankingCell: UITableViewCell {

    @IBOutlet weak var imgViThumb1: UIImageView!
    @IBOutlet weak var imgViThumb2: UIImageView!
    @IBOutlet weak var imgViTrophy: UIImageView!
    @IBOutlet weak var lblRank: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblCategories: UILabel!
    @IBOutlet weak var lblParticipants: UILabel!
    @IBOutlet weak var imgViWinner: UIImageView!
    @IBOutlet weak var lblWinnerName: UILabel!
    @IBOutlet weak var imgViInitator: UIImageView!
    @IBOutlet weak var lblInitatorName: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
