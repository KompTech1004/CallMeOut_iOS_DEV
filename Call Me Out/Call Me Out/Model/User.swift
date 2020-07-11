//
//  User.swift
//  Call Me Out
//
//  Created by B S on 4/8/18.
//  Copyright © 2018 B S. All rights reserved.
//

import Foundation
import SwiftyJSON

class User:NSObject,NSCoding{
    var access_token: String?
    var notification_count: Int = 0
    var id:Int
    var username:String
    var password:String
    var email:String
    var first_name:String
    var last_name:String
    var birthday:String
    var phone:String
    var token:String
    var avatar:String
    var isFollow:String
    var countFollowers:String
    var countFollowings:String
    var bio:String
    
    var fb_username:String
    var in_username:String
    var tw_username:String
    var vic_count:String
    var isBlocked:Bool = false
    var socialType: String?
    
    init(id:Int, username:String, password:String,email:String,first_name:String,last_name:String,
         lat:String,long:String,birthday:String,phone:String,token:String,avatar:String,isFollow:String,countFollowers:String,countFollowings:String,bio:String,fb:String,ins:String,tw:String,vic_count:String) {
        self.id = id
        self.username = username
        self.password = password
        self.email = email
        self.first_name = first_name
        self.last_name = last_name
        self.birthday = birthday
        self.phone = phone
        self.token = token
        self.avatar = avatar
        self.isFollow = isFollow
        self.countFollowers = countFollowings
        self.countFollowings = countFollowers
        self.bio = bio
        self.fb_username = fb
        self.in_username = ins
        self.tw_username = tw
        self.vic_count = vic_count
    }
    
    init(json: JSON) {
        print (json)
        self.access_token   = json["access_token"].stringValue
        self.birthday       = json["birthday"].stringValue
        self.email          = json["email"].stringValue
        self.fb_username    = json["fb_id"].stringValue
        self.first_name     = json["first_name"].stringValue
        self.last_name      = json["last_name"].stringValue
        self.notification_count = json["notification_count"].intValue
        self.phone          = json["phone"].stringValue
        
        self.socialType     = json["social_media_type"].stringValue
        
        let profilePhoto    = json["profile_photo"].stringValue
        
        if profilePhoto.hasPrefix("images/upload") {
            self.avatar     = "\(server)\(profilePhoto)"
        } else {
            self.avatar     = profilePhoto
        }
        
//        if socialType != "email" {
//            self.avatar     = profilePhoto
//        } else {
//            if profilePhoto.hasPrefix(server) {
//                self.avatar     = profilePhoto
//            } else {
//                self.avatar     = "\(server)\(profilePhoto)"
//            }
//        }
        
        self.tw_username    = json["twitter_id"].stringValue
        self.id             = json["user_id"].intValue
        self.username       = json["username"].stringValue
        self.vic_count      = json["victory_count"].stringValue
        self.password       = ""
        self.token          = UserDefaults.standard.string(forKey: DEVICE_TOKEN) ?? ""
        self.isFollow       = "0"
        self.countFollowings  = json["countFollowers"].stringValue
        self.countFollowers = json["countFollowings"].stringValue
        self.bio            = json["bio"].stringValue
        self.in_username    = json["instagram_id"].stringValue
    }
    
    required init(coder decoder:NSCoder){
        self.id = decoder.decodeInteger(forKey: "id")
        self.access_token = decoder.decodeObject(forKey: "access_token") as? String
        self.notification_count = decoder.decodeInteger(forKey: "notification_count")
        self.username = decoder.decodeObject(forKey: "username") as! String
        self.password = decoder.decodeObject(forKey: "password") as! String
        self.email = decoder.decodeObject(forKey: "email") as! String
        self.first_name = decoder.decodeObject(forKey: "first_name") as! String
        self.last_name = decoder.decodeObject(forKey: "last_name") as! String
        self.birthday = decoder.decodeObject(forKey: "birthday") as! String
        self.phone = decoder.decodeObject(forKey: "phone") as! String
        self.token = decoder.decodeObject(forKey: "token") as! String
        self.avatar = decoder.decodeObject(forKey: "avatar") as! String
        self.isFollow = decoder.decodeObject(forKey: "isFollow") as! String
        self.countFollowers = decoder.decodeObject(forKey: "countFollowers") as! String
        self.countFollowings = decoder.decodeObject(forKey: "countFollowings") as! String
        self.bio = decoder.decodeObject(forKey: "bio") as! String
        self.fb_username = decoder.decodeObject(forKey: "fb_username") as! String
        self.in_username = decoder.decodeObject(forKey: "in_username") as! String
        self.tw_username = decoder.decodeObject(forKey: "tw_username") as! String
        self.vic_count = decoder.decodeObject(forKey: "vic_count") as! String
    }
    func encode(with coder:NSCoder){
        coder.encode(id,forKey:"id")
        coder.encode(access_token, forKey: "access_token")
        coder.encode(notification_count, forKey: "notification_count")
        coder.encode(username,forKey:"username")
        coder.encode(password,forKey:"password")
        coder.encode(email,forKey:"email")
        coder.encode(first_name,forKey:"first_name")
        coder.encode(last_name,forKey:"last_name")
        coder.encode(birthday,forKey:"birthday")
        coder.encode(phone,forKey:"phone")
        coder.encode(token,forKey:"token")
        coder.encode(avatar,forKey:"avatar")
        coder.encode(isFollow,forKey:"isFollow")
        coder.encode(countFollowers,forKey:"countFollowers")
        coder.encode(countFollowings,forKey:"countFollowings")
        coder.encode(bio,forKey:"bio")
        coder.encode(fb_username,forKey:"fb_username")
        coder.encode(in_username,forKey:"in_username")
        coder.encode(tw_username,forKey:"tw_username")
        coder.encode(vic_count,forKey:"vic_count")
    }
}
