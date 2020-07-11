//
//  CallOut.swift
//  Call Me Out
//
//  Created by B S on 4/9/18.
//  Copyright © 2018 B S. All rights reserved.
//

import Foundation
class CallOut {
    var id:String
    var post_id:String
    var poster:User
    var challenger:User?
    var title:String
    var category:String
    var duration:Int
    var video:String
    var thumb:String
    var challenge_thumb:String
    var challenge_video:String
    var avg_rating_poster:CGFloat
    var your_rating_poster:CGFloat
    var avg_rating_chall:CGFloat
    var your_rating_chall:CGFloat
    var isChallenge:String
    var format:String
    var type: Int = 0
    var views:String?
    var isWinner:Bool?
    var participants:String?
    var enableVote:Bool?
    var isExpired:Bool?
    var isWinnerPoster:Bool?
    var isActive:Bool?
    
    var your_vote:String
    var cnt_vote_poster:String
    var cnt_vote_challneger:String
    var keyword: String?
        
    init(id:Int,poster:User,post_id:String,title:String,category:String,duration:Int,video:String,thumb:String,
         challenge_video:String,challenge_thumb:String,avg_rating_poster:CGFloat,avg_rating_chall:CGFloat,your_rating_poster:CGFloat,your_rating_chall:CGFloat,isChallenge:String,format:String,your_vote:String,cnt_poster:String,cnt_challenger:String) {
        self.id = String(id)
        self.poster = poster
        self.title = title
        self.category = category
        self.duration = duration
        self.video = video
        self.thumb = thumb
        self.challenge_thumb = challenge_thumb
        self.challenge_video = challenge_video
        self.post_id = post_id
        self.avg_rating_poster = avg_rating_poster
        self.avg_rating_chall = avg_rating_chall
        self.your_rating_chall = your_rating_chall
        self.your_rating_poster = your_rating_poster
        self.isChallenge = isChallenge
        self.format = format
        self.your_vote = your_vote
        self.cnt_vote_poster = cnt_poster
        if cnt_challenger.count == 0 {
            self.cnt_vote_challneger = "0"
        } else {
            self.cnt_vote_challneger = cnt_challenger
        }
    }
}
