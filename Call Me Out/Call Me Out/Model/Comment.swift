//
//  Comment.swift
//  Call Me Out
//
//  Created by B S on 4/16/18.
//  Copyright © 2018 B S. All rights reserved.
//
import Foundation
class Comment {
//    var id:String
//    var feed_id:String
    var comment:String
    var avatar:String
    var username:String
    var userId: Int
    var commentId: Int
    
    init(comment:String, avatar:String, username:String, userid: Int, commentid: Int) {
        self.comment = comment
        self.avatar = avatar
        self.username = username
        self.userId = userid
        self.commentId = commentid
    }
}
