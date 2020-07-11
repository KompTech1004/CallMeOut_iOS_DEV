//
//  NotificationPostObj.swift
//  Call Me Out
//
//  Created by Apple on 10/21/18.
//  Copyright © 2018 B S. All rights reserved.
//

import UIKit
import SwiftyJSON

class NotificationPostObj: NSObject {
    var id: Int
    var title: String?
    var keyword: String?
    var category: String?
    var duration: Double?
    var video: String?
    var thumb: String?
    var type: Int
    var format: String?
    var creation_date: Double?
    
    var poster_name: String?
    
    init(json: JSON) {
        id          = json["id"].intValue
        title       = json["title"].stringValue
        keyword     = json["keyword"].stringValue
        category    = json["category"].stringValue
        duration    = json["duration"].doubleValue
        
        let videoUrl = json["video"].stringValue
        if videoUrl.hasPrefix(server) {
            video = videoUrl
        } else {
            video = "\(server)\(videoUrl)"
        }

        let thumbUrl = json["thumb"].stringValue
        if thumbUrl.hasPrefix(server) {
            thumb = thumbUrl
        } else {
            thumb = "\(server)\(thumbUrl)"
        }

        type        = json["type"].intValue
        format      = json["format"].stringValue
        creation_date   = json["creation_date"].doubleValue
        poster_name = json["poster_name"].stringValue
    }
}
