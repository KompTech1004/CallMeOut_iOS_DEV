//
//  NotificationChallengeObj.swift
//  Call Me Out
//
//  Created by Apple on 10/21/18.
//  Copyright © 2018 B S. All rights reserved.
//

import UIKit
import SwiftyJSON

class NotificationChallengeObj: NSObject {
    var challenge_id: Int
    var post_id: Int
    var challenge_thumb: String
    var challenge_video: String
    var view_count: Int
    var challenger: NotificationPosterObj
    var challenge_date: Double?
    
    init(json: JSON) {
        
        challenge_id    = json["id"].intValue
        post_id         = json["post_id"].intValue
        challenge_thumb = json["challenge_thumb"].stringValue
        challenge_video = json["challenge_video"].stringValue
        view_count      = json["view_count"].intValue
        
        challenger      = NotificationPosterObj(json: json["challenger"])
        challenge_date  = json["challenge_date"].doubleValue
    }
}
