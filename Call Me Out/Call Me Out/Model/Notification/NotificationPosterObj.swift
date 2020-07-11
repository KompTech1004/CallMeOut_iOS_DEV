//
//  NotificationPosterObj.swift
//  Call Me Out
//
//  Created by Apple on 10/21/18.
//  Copyright © 2018 B S. All rights reserved.
//

import UIKit
import SwiftyJSON

class NotificationPosterObj: NSObject {
    var id: Int
    var username: String
    var email: String
    var last_name: String
    var birthday: String
    var phone: String
    var first_name: String
    var avatar: String = ""
    var countFollowers: Int
    var countFollowings: Int
    var bio: String
    var fb: String
    var instagram: String
    var tw: String
    var vic_count: Int
    
    init(json: JSON) {
        id          = json["id"].intValue
        username    = json["username"].stringValue
        email       = json["email"].stringValue
        first_name  = json["first_name"].stringValue
        last_name   = json["last_name"].stringValue
        birthday    = json["birthday"].stringValue
        phone       = json["phone"].stringValue
        
        let profile = json["avatar"].stringValue
        
        if profile.hasPrefix(server) {
            avatar = profile
        } else {
            avatar = "\(server)\(profile)"
        }
        
        countFollowers  = json["countFollowers"].intValue
        countFollowings = json["countFollowings"].intValue
        bio         = json["bio"].stringValue
        fb          = json["fb"].stringValue
        instagram   = json["in"].stringValue
        tw          = json["tw"].stringValue
        vic_count   = json["vic_count"].intValue
    }
}
