//
//  Notification.swift
//  Call Me Out
//
//  Created by Apple on 10/20/18.
//  Copyright © 2018 B S. All rights reserved.
//

import UIKit
import SwiftyJSON

class NotificationObj: NSObject {

    var notificationId: Int
    var action: String
    var senderId: Int
    var time: Double
    var sender: NotificationPosterObj?
    var post: NotificationPostObj?
    var groupName: String?
    var challenge: NotificationChallengeObj?
    
    var isChallenged: Bool = false
        
    init(json: JSON) {
        notificationId  = json["notification_id"].intValue
        action          = json["action"].stringValue
        senderId        = json["sender"].intValue
        time            = json["time"].doubleValue + 25200
        sender          = NotificationPosterObj(json: json["senderinfo"])
        
        post            = NotificationPostObj(json: json["post"])
        
        groupName       = json["group_name"].stringValue
        
        challenge       = NotificationChallengeObj(json: json["challenge"])
        
        isChallenged    = json["isChallenge"].boolValue
        
    }
}
