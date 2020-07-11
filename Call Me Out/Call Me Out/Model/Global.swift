//
//  Global.swift
//  Call Me Out
//
//  Created by B S on 4/4/18.
//  Copyright © 2018 B S. All rights reserved.
//

import Foundation
import AVKit
import Alamofire
import AlamofireImage
import Alamofire_SwiftyJSON
import SwiftyJSON
import MediaPlayer

let DEVICE_TOKEN = "device_token"

enum CALL_TYPE{
    case CALLOUT_TYPE_VIDEO
    case CALLOUT_TYPE_LIVE
    case CALLOUT_TYPE_PHOTO
    case CALLOUT_TYPE_AUDIO
}
enum CALLOUT_DURATION{
    case CALLOUT_DURATION_24_HOURS
    case CALLOUT_DURATION_1_WEEK
    case CALLOUT_DURATION_2_WEEKS
    case CALLOUT_DURATION_3_WEEKS
    case CALLOUT_DURATION_4_WEEKS
    case CALLOUT_DURATION_5_WEEKS
    case CALLOUT_DURATION_6_WEEKS
    case CALLOUT_DURATION_7_WEEKS
    case CALLOUT_DURATION_8_WEEKS
    case CALLOUT_DURATION_9_WEEKS
    case CALLOUT_DURATION_10_WEEKS
}

let server    = "http://callmeout.com/call-me-out/"
let serverUrl = "http://callmeout.com/call-me-out/api"

class Global {
    static let shared = Global.init()
    
//    let serverUrl = "http://192.168.1.194/callmeout/call_me_out/"
    var tabbar:TabbarVC?
    var user:User?
    var selected_challenge_id = 0
    
    static let imageCache = AutoPurgingImageCache(memoryCapacity: 100*1024*1024, preferredMemoryUsageAfterPurge: 60*1024*1024)
    
    let AllCategory = ["SPORTS":["Adaptive Sports","Badminton","Barrell Racing","Baseball","Basketball","Bowling","Bull Riding","Calf Roping","Cheerleading / Competitive Spirit Squads","Cross Country","Crossfit","Dance Team","Field Hockey","Flag Football","Football","Golf","Gymnastics","Hockey","Indoor Track & Field","Lacrosse","Nascar Racing","Olympic Weightlifting","Power Lifting","Skiing & Snowboarding","Slow Pitch Softball","Soccer","Softball","Surf","Swimming & Diving","Team Roping","Tennis","Track & Field","Volleyball","Water Polo","Weightlifting","Wrestling"],
                       "ENTERTAINMENT":["Comedy","Dance","Filming","Movie","Photography","Pictures","Poetry","Singing","Theater"],
                       "MUSIC":["Alternative","Country","Dance","Electronic","Gospel","Hip Hop","Instrumental","Jazz","Latin","Metal","Pop","R & B","Reggae","Rap","Rock","Soundtrack","World"],
                       "BEAUTY & FASHION":["Accessories","Clothes","Eye lashes","Hair","Make Up","Make Up","Modeling","Nails","Shoes"],
                       "HOT TOPICS":["In the news","On Social Media","Trending"],
                       "OTHER":[],
                       "VEHICLES":["Boats","Cars","Motorcycles","Planes","Trucks"]]
    
    /* Check if device is iPhoneX */
    static func isIPhoneX() -> Bool {
        if UIDevice().userInterfaceIdiom == .phone {
            if (UIScreen.main.nativeBounds.height == 2436) {
                return true
            }
        }
        
        return false
    }
    
    static func setImage(_ imageView:UIImageView,_ url:String,_ placeholder:UIImage)
    {
        let urlRequest = URLRequest(url: URL(string: url)!)
        if let image = imageCache.image(for:urlRequest,withIdentifier:url)
        {
            imageView.image = image
        }
        else{
            imageView.af_setImage(withURL: URL(string: url)!, placeholderImage: nil, filter: AspectScaledToFillSizeFilter(size: imageView.frame.size), progress: nil, imageTransition: .crossDissolve(0.0), runImageTransitionIfCached: true) { (response) in
                guard let image = response.result.value else {return}
                imageView.image = image
                imageCache.add(image, for: urlRequest, withIdentifier: url)
            }
        }
    }
    
    static func saveUserData(user:User)
    {
        var data = [User]()
        data.append(user)
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: data)
        UserDefaults.standard.set(nil, forKey: "User")
        UserDefaults.standard.set(encodedData, forKey: "User")
        UserDefaults.standard.synchronize()
    }
    
    static func getUserDataFromLocal()->User?
    {
        if let data = UserDefaults.standard.data(forKey: "User")
        {
            if let userList = NSKeyedUnarchiver.unarchiveObject(with: data) as? [User]
            {
                let user = userList[0]
                return user
            }
        }
        return nil
    }
    
    static func export(_ assetURL:URL,handler:@escaping(_ fileURL:URL?, _ error:Error?)->Void){
        let asset = AVURLAsset(url: assetURL)
        guard let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
            handler(nil,nil)
            return
        }
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(NSUUID().uuidString).appendingPathExtension("m4a")
        
        exporter.outputURL = fileURL
        exporter.outputFileType = AVFileType.m4a
        exporter.exportAsynchronously {
            if exporter.status == .completed
            {
                handler(fileURL,nil)
            }
            else{
                handler(nil,nil)
            }
        }
    }
    
    static func getData(_ item:URL?, mediaItem: MPMediaItem?, handler:@escaping(_ data:Data?)->Void)
    {
        
            if let assetURL = item {
                export(assetURL) { (url, error) in
                    guard let url = url,error == nil else{
                        handler(nil)
                        return
                    }
                    do{
                        var result:Data?
                        result = try Data.init(contentsOf: url)
                        handler(result)
                    }
                    catch{
                        
                    }
                }
            } else {
                if let assetURL = mediaItem?.value(forProperty: MPMediaItemPropertyAssetURL) as? URL {
                    export(assetURL) { (url, error) in
                        guard let url = url, error == nil else {
                            handler(nil)
                            return
                        }
                        
                        do {
                            var result: Data?
                            result = try Data(contentsOf: url)
                            handler(result)
                        } catch {
                            
                        }
                    }
                }
        }
    }
    
    static func getThumbImageFromVideoFile(fileURL:URL)->CGImage?
    {
        do{
            let asset = AVURLAsset(url: fileURL)
            let generateImg = AVAssetImageGenerator(asset: asset)
            generateImg.appliesPreferredTrackTransform = true
            let time  = CMTimeMake(1, 30)
            let refImg = try generateImg.copyCGImage(at: time, actualTime: nil)            
            return refImg;
        }
        catch{
            return nil
        }
    }
    
    func updateViewCount(id:String, completionHandler:@escaping ()->Void)
    {
        let requestString = serverUrl
        Alamofire.request(requestString, method: .post, parameters: ["service": "updateviewcount", "id":id]).responseSwiftyJSON { (data) in
            completionHandler()
        }
    }
    
    func login(email:String,password:String,completionHandler:@escaping (_ flag:Bool, _ result :String)->Void)
    {
        let requestString = serverUrl
        
        let deviceToken = UserDefaults.standard.string(forKey: DEVICE_TOKEN) ?? ""
        Alamofire.request(requestString, method: .post, parameters: ["service": "login", "email_id":email,"password":password, "device_type": "I", "device_token": deviceToken]).responseSwiftyJSON { (data) in
            guard let userData = data.value else {
                completionHandler(false,"Network Error")
                return
            }
            print(userData)
            let response = userData["user"]
            let result = userData["status"].stringValue
            if result == "Error"
            {
                completionHandler(false,userData["Error"].stringValue)
            }
            else{
                let user = User(json: response)
                Global.saveUserData(user: user)
                completionHandler(true,"success")
            }
        }
    }
    
    func getAds(completionHandler:@escaping (_ result :[JSON]?)->Void) {
        let requestString = serverUrl
        
        Alamofire.request(requestString, method: .post, parameters: ["service": "getadlist"]).responseSwiftyJSON { (data) in
            guard let userData = data.value else {
                completionHandler(nil)
                return
            }
            
            let response = userData["data"].arrayValue
            completionHandler(response)
        }
    }
    
    func challenge(challengeID:Int,id:String,post_id:String,image:Data?,first:String,video:Data?,type:String, direct: String,completionHandler:@escaping (_ flag:Bool,_ result:String)->Void)
    {
        let requestUrl = serverUrl
        let parameters = ["service": "challenge", "id":String(id),
                          "post_id":String(post_id),
                          "challenge_id":String(challengeID),
                          "dict": direct,
                          "first":first] as [String:Any]
        if type == "photo" {
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                multipartFormData.append(image!, withName: "image", fileName: "swift_file.jpeg", mimeType: "image/png")
                for (key, value) in parameters {
                    multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                }
            }, to:requestUrl)
            { (encodingResult) in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseSwiftyJSON(completionHandler: { (response) in
                        guard let data = response.value else {
                            completionHandler(false,"Upload image Failed please try again later")
                            return
                        }
                        let result = data["status"].stringValue
                        if result == "Error"
                        {
                            completionHandler(false,data["Error"].stringValue)
                        }
                        else{
                            completionHandler(true,"success")
                        }
                    })
                case .failure( _):
                    completionHandler(false,"challenge Failed")
                    return
                }
            }
        }
        else if type == "video"{
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                multipartFormData.append(video!, withName: "video", fileName: "temp.mov", mimeType: "video/mov")
                multipartFormData.append(image!, withName: "image", fileName: "swift_file.jpeg", mimeType: "image/png")
                for (key, value) in parameters {
                    multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                }
            }, to:requestUrl)
            { (encodingResult) in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseSwiftyJSON(completionHandler: { (response) in
                        guard let data = response.value else {
                            completionHandler(false,"Upload video Failed please try again later")
                            return
                        }
                        let result = data["status"].stringValue
                        if result == "Error"
                        {
                            completionHandler(false,data["Error"].stringValue)
                        }
                        else{
                            completionHandler(true,"success")
                        }
                    })
                case .failure( _):
                    completionHandler(false,"challenge Failed")
                    return
                }
            }
        }
        else if type == "audio"
        {
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                multipartFormData.append(video!, withName: "audio", fileName: "temp.m4a", mimeType: "audio/*")
                for (key, value) in parameters {
                    multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                }
            }, to:requestUrl)
            { (encodingResult) in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseSwiftyJSON(completionHandler: { (response) in
                        guard let data = response.value else {
                            completionHandler(false,"Upload audio Failed please try again later")
                            return
                        }
                        let result = data["status"].stringValue
                        if result == "Error"
                        {
                            completionHandler(false,data["Error"].stringValue)
                        }
                        else{
                            completionHandler(true,"success")
                        }
                    })
                case .failure( _):
                    completionHandler(false,"challenge Failed")
                    return
                }
            }
        }
    }
    func post(posterID:Int,title:String,category:String,duration:Int,type:String,video:Data?,image:Data?,group:String,people:String,keyword:String,format:String,completionHandler:@escaping (_ flag:Bool, _ result:String)->Void)
    {
        let time = 24*60*60*7

        var key = ""
        if keyword == ""
        {
            key  = " "
        }
        else
        {
            key = keyword
        }
        let requestUrl = serverUrl
        let parameters = ["service": "createcallout",
                          "poster_id":String(posterID),
                          "title":title,
                          "category":category,
                          "duration":String(time),
                          "type":type,
                          "group":group,
                          "people":people,
                          "keyword":key,
                          "format":format] as [String:Any]
        
        print(parameters)
        if format == "video"{
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                multipartFormData.append(video!, withName: "video", fileName: "temp.mov", mimeType: "video/mov")
                multipartFormData.append(image!, withName: "image", fileName: "swift_file.jpeg", mimeType: "image/png")
                for (key, value) in parameters {
                    multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                }
            }, to:requestUrl)
            { (encodingResult) in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseSwiftyJSON(completionHandler: { (response) in
                        guard let data = response.value else {
                            completionHandler(false,"Upload video Failed please try again later")
                            return
                        }
                        let result = data["status"].stringValue
                        if result == "Error"
                        {
                            completionHandler(false,data["Error"].stringValue)
                        }
                        else{
                            completionHandler(true,"success")
                        }
                    })
                case .failure( _):
                    completionHandler(false,"Register Failed")
                    return
                }
            }
        }
        else if format == "photo"
        {
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                multipartFormData.append(image!, withName: "image", fileName: "swift_file.jpeg", mimeType: "image/png")
                for (key, value) in parameters {
                    multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                }
            }, to:requestUrl)
            { (encodingResult) in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseSwiftyJSON(completionHandler: { (response) in
                        guard let data = response.value else {
                            completionHandler(false,"Upload image Failed please try again later")
                            return
                        }
                        let result = data["status"].stringValue
                        if result == "Error"
                        {
                            completionHandler(false,data["Error"].stringValue)
                        }
                        else{
                            completionHandler(true,"success")
                        }
                    })
                case .failure( _):
                    completionHandler(false,"Register Failed")
                    return
                }
            }
        }
        else if format == "audio"
        {
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                multipartFormData.append(video!, withName: "audio", fileName: "swift_file.m4a", mimeType: "audio/*")
                for (key, value) in parameters {
                    multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                }
            }, to:requestUrl)
            { (encodingResult) in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseSwiftyJSON(completionHandler: { (response) in
                        guard let data = response.value else {
                            completionHandler(false,"Upload audio Failed please try again later")
                            return
                        }
                        let result = data["status"].stringValue
                        if result == "Error"
                        {
                            completionHandler(false,data["Error"].stringValue)
                        }
                        else{
                            completionHandler(true,"success")
                        }
                    })
                case .failure( _):
                    completionHandler(false,"Register Failed")
                    return
                }
            }
        }
    }
    func getArchive(userID:Int,last_id:String,type:String,category:String,duration:String,keyword:String,completionHandler:@escaping(_ flag:Bool,_ result:[CallOut]?)->Void)
    {
        let requestUrl = serverUrl
        Alamofire.request(requestUrl, method: .post, parameters: ["service": "getarchive",  "userid":String(userID),"last_id":last_id,"type":type,"category":category,"duration":duration,"keyword":keyword]).responseSwiftyJSON { (data) in
            guard let userData = data.value else {
                completionHandler(false,nil)
                return
            }
            let result = userData["data"].arrayValue
            var output = [CallOut]()
            for value in result
            {
                let postid = value["id"].intValue
                let post_id = value["post_id"].stringValue
                let title = value["title"].stringValue
                let category = value["category"].stringValue
                let duration = value["duration"].intValue
                
                var video: String
                let videoStr = value["video"].stringValue
                if videoStr.hasPrefix(server) {
                    video = videoStr
                } else {
                    video = "\(server)\(videoStr)"
                }
                
                var thumb: String
                let thumbStr = value["thumb"].stringValue
                if thumbStr.hasPrefix(server) {
                    thumb = thumbStr
                } else {
                    thumb = "\(server)\(thumbStr)"
                }
                
                var thumb1: String
                let thumb1Str1 = value["challenge_thumb"].stringValue
                if videoStr.hasPrefix(server) {
                    thumb1 = thumb1Str1
                } else {
                    thumb1 = "\(server)\(thumb1Str1)"
                }
                
                var video1: String
                let video1Str = value["challenge_video"].stringValue
                if thumbStr.hasPrefix(server) {
                    video1 = video1Str
                } else {
                    video1 = "\(server)\(video1Str)"
                }

                
                let avg_rating_poster = CGFloat(value["avg_rating_poster"].floatValue)
                let avg_rating_chall = CGFloat(value["avg_rating_chall"].floatValue)
                let your_rating_chall = CGFloat(value["your_rating_chall"].floatValue)
                let your_rating_poster = CGFloat(value["your_rating_poster"].floatValue)
                let format = value["format"].stringValue
                let your_vote = value["your_vote"].stringValue
                var cnt_vote_poster = value["cnt_vote_poster"].stringValue
                
                if cnt_vote_poster == "" {
                    cnt_vote_poster = "0"
                }
                
                var cnt_vote_challenger = value["cnt_vote_challenger"].stringValue
                if cnt_vote_challenger == "" {
                    cnt_vote_challenger = "0"
                }
                
                
                let response = value["poster"]
                let id = response["id"].intValue
                let username = response["username"].stringValue
                let password = response["password"].stringValue
                let email = response["email"].stringValue
                let first_name = response["first_name"].stringValue
                let last_name = response["last_name"].stringValue
                let lat = response["lat"].stringValue
                let long = response["long"].stringValue
                let birthday = response["birthday"].stringValue
                let phone = response["phone"].stringValue
                let token = response["token"].stringValue
                
                var avatar: String
                let avatarStr = response["avatar"].stringValue
                if avatarStr.hasPrefix(server) {
                    avatar = avatarStr
                } else {
                    avatar = "\(server)\(avatarStr)"
                }
                
                let isFollow = response["isFollower"].stringValue
                let countFollowers = response["countFollowers"].stringValue
                let countFollowings = response["countFollowings"].stringValue
                let bio = response["bio"].stringValue
                let fb = response["fb"].stringValue
                let tw = response["tw"].stringValue
                let ins = response["in"].stringValue
                let vic_count = response["vic_count"].stringValue
                let poster = User(id: id,username: username,password: password,email: email,first_name: first_name,last_name: last_name,lat: lat,long: long,birthday: birthday,phone: phone,token: token,avatar: avatar,isFollow:isFollow,countFollowers:countFollowers,countFollowings:countFollowings,bio:bio,fb:fb,ins:ins,tw:tw,vic_count:vic_count)
                
                poster.isBlocked = response["is_block"].boolValue
                
                let callout = CallOut(id: postid, poster: poster, post_id: post_id,title: title, category: category, duration: duration, video: video, thumb: thumb, challenge_video: video1, challenge_thumb: thumb1, avg_rating_poster: avg_rating_poster, avg_rating_chall: avg_rating_chall, your_rating_poster: your_rating_poster, your_rating_chall: your_rating_chall, isChallenge: "1", format: format,your_vote: your_vote, cnt_poster: cnt_vote_poster, cnt_challenger: cnt_vote_challenger)
                callout.views = value["views"].stringValue
                callout.isWinner = value["isWinner"].boolValue
                callout.enableVote = value["enableVote"].boolValue
                if value["challenger"].exists() && value["challenger"].count > 0
                {
                    let response = value["challenger"]
                    let id1 = response["id"].intValue
                    let username1 = response["username"].stringValue
                    let password1 = response["password"].stringValue
                    let email1 = response["email"].stringValue
                    let first_name1 = response["first_name"].stringValue
                    let last_name1 = response["last_name"].stringValue
                    let lat1 = response["lat"].stringValue
                    let long1 = response["long"].stringValue
                    let birthday1 = response["birthday"].stringValue
                    let phone1 = response["phone"].stringValue
                    let token1 = response["token"].stringValue
                    
                    var avatar1: String
                    let avatarStr = response["avatar"].stringValue
                    if avatarStr.hasPrefix(server) {
                        avatar1 = avatarStr
                    } else {
                        avatar1 = "\(server)\(avatarStr)"
                    }
                    
                    let isFollow1 = response["isFollower"].stringValue
                    let countFollowers1 = response["countFollowers"].stringValue
                    let countFollowings1 = response["countFollowings"].stringValue
                    let bio1 = response["bio"].stringValue
                    let fb1 = response["fb"].stringValue
                    let tw1 = response["tw"].stringValue
                    let ins1 = response["in"].stringValue
                    let vic_count1 = response["vic_count"].stringValue
                    let challenger = User(id: id1,username: username1,password: password1,email: email1,first_name: first_name1,last_name: last_name1,lat: lat1,long: long1,birthday: birthday1,phone: phone1,token: token1,avatar: avatar1,isFollow:isFollow1,countFollowers:countFollowers1,countFollowings:countFollowings1,bio:bio1,fb:fb1,ins:ins1,tw:tw1,vic_count:vic_count1)
                    challenger.isBlocked = response["is_block"].boolValue
                    callout.challenger = challenger
                }
                
                output.append(callout)
            }
            
            completionHandler(true,output)
        }
    }
    
    func getChallengeItem(userid:String,id:String,handler:@escaping(_ result:CallOut?)->Void) // id : challenge id
    {
        let requestUrl = serverUrl
        Alamofire.request(requestUrl, method: .post, parameters: ["service": "getitem",  "userid":userid,"id":id]).responseSwiftyJSON { (data) in
            
            guard let userData = data.value else {
                handler(nil)
                return
            }
            let result = userData
            print(result)
            let postid = result["id"].intValue
            let post_id = result["post_id"].stringValue
            let title = result["title"].stringValue
            let category = result["category"].stringValue
            let duration = result["duration"].intValue
            var video: String
            let videoStr = result["video"].stringValue
            if videoStr.hasPrefix(server) {
                video = videoStr
            } else {
                video = "\(server)\(videoStr)"
            }
            
            var thumb: String
            let thumbStr = result["thumb"].stringValue
            if thumbStr.hasPrefix(server) {
                thumb = thumbStr
            } else {
                thumb = "\(server)\(thumbStr)"
            }
            
            var thumb1: String
            let thumb1Str1 = result["challenge_thumb"].stringValue
            if videoStr.hasPrefix(server) {
                thumb1 = thumb1Str1
            } else {
                thumb1 = "\(server)\(thumb1Str1)"
            }
            
            var video1: String
            let video1Str = result["challenge_video"].stringValue
            if thumbStr.hasPrefix(server) {
                video1 = video1Str
            } else {
                video1 = "\(server)\(video1Str)"
            }
            let avg_rating_poster = CGFloat(result["avg_rating_poster"].floatValue)
            let avg_rating_chall = CGFloat(result["avg_rating_chall"].floatValue)
            let your_rating_chall = CGFloat(result["your_rating_chall"].floatValue)
            let your_rating_poster = CGFloat(result["your_rating_poster"].floatValue)
            let format = result["format"].stringValue
            let isChallenge = result["isChallenge"].stringValue
            let your_vote = result["your_vote"].stringValue
            var cnt_vote_poster = result["cnt_vote_poster"].stringValue
            
            if cnt_vote_poster == "" {
                cnt_vote_poster = "0"
            }
            
            var cnt_vote_challenger = result["cnt_vote_challenger"].stringValue
            if cnt_vote_challenger == "" {
                cnt_vote_challenger = "0"
            }
            
            let response = result["poster"]
            let id = response["id"].intValue
            let username = response["username"].stringValue
            let password = response["password"].stringValue
            let email = response["email"].stringValue
            let first_name = response["first_name"].stringValue
            let last_name = response["last_name"].stringValue
            let lat = response["lat"].stringValue
            let long = response["long"].stringValue
            let birthday = response["birthday"].stringValue
            let phone = response["phone"].stringValue
            let token = response["token"].stringValue
            var avatar: String
            let avatarStr = response["avatar"].stringValue
            if avatarStr.hasPrefix(server) {
                avatar = avatarStr
            } else {
                avatar = "\(server)\(avatarStr)"
            }
            let isFollow = response["isFollower"].stringValue
            let countFollowers = response["countFollowers"].stringValue
            let countFollowings = response["countFollowings"].stringValue
            let bio = response["bio"].stringValue
            let fb = response["fb"].stringValue
            let tw = response["tw"].stringValue
            let ins = response["in"].stringValue
            let vic_count = response["vic_count"].stringValue
            let poster = User(id: id,username: username,password: password,email: email,first_name: first_name,last_name: last_name,lat: lat,long: long,birthday: birthday,phone: phone,token: token,avatar: avatar,isFollow:isFollow,countFollowers:countFollowers,countFollowings:countFollowings,bio:bio,fb:fb,ins:ins,tw:tw,vic_count:vic_count)
            poster.isBlocked = response["is_block"].boolValue
            let callout = CallOut(id: postid, poster: poster, post_id: post_id,title: title, category: category, duration: duration, video: video, thumb: thumb, challenge_video: video1, challenge_thumb: thumb1, avg_rating_poster: avg_rating_poster, avg_rating_chall: avg_rating_chall, your_rating_poster: your_rating_poster, your_rating_chall: your_rating_chall, isChallenge: isChallenge,format:format,your_vote: your_vote, cnt_poster: cnt_vote_poster, cnt_challenger: cnt_vote_challenger)
            callout.views = result["views"].stringValue
            if result["challenger"].exists() && result["challenger"].count > 0
            {
                let response = result["challenger"]
                let id1 = response["id"].intValue
                let username1 = response["username"].stringValue
                let password1 = response["password"].stringValue
                let email1 = response["email"].stringValue
                let first_name1 = response["first_name"].stringValue
                let last_name1 = response["last_name"].stringValue
                let lat1 = response["lat"].stringValue
                let long1 = response["long"].stringValue
                let birthday1 = response["birthday"].stringValue
                let phone1 = response["phone"].stringValue
                let token1 = response["token"].stringValue
                
                var avatar1: String
                let avatarStr = response["avatar"].stringValue
                if avatarStr.hasPrefix(server) {
                    avatar1 = avatarStr
                } else {
                    avatar1 = "\(server)\(avatarStr)"
                }
                
                let isFollow1 = response["isFollower"].stringValue
                let countFollowers1 = response["countFollowers"].stringValue
                let countFollowings1 = response["countFollowings"].stringValue
                let bio1 = response["bio"].stringValue
                
                let fb1 = response["fb"].stringValue
                let tw1 = response["tw"].stringValue
                let ins1 = response["in"].stringValue
                let vic_count1 = response["vic_count"].stringValue
                let challenger = User(id: id1,username: username1,password: password1,email: email1,first_name: first_name1,last_name: last_name1,lat: lat1,long: long1,birthday: birthday1,phone: phone1,token: token1,avatar: avatar1,isFollow:isFollow1,countFollowers:countFollowers1,countFollowings:countFollowings1,bio:bio1,fb:fb1,ins:ins1,tw:tw1,vic_count:vic_count1)
                challenger.isBlocked = response["is_block"].boolValue
                callout.challenger = challenger
            }
            handler(callout)
        }
    }
    
    
    func getItem(userid:String,id:String,handler:@escaping(_ result:CallOut?)->Void) // id : challenge id
    {
        let requestUrl = serverUrl
        Alamofire.request(requestUrl, method: .post, parameters: ["service": "getposteditem",  "userid":userid,"id":id]).responseSwiftyJSON { (data) in
            
            guard let userData = data.value else {
                handler(nil)
                return
            }
            let result = userData
            print(result)
            let postid = result["id"].intValue
            let post_id = result["post_id"].stringValue
            let title = result["title"].stringValue
            let category = result["category"].stringValue
            let duration = result["duration"].intValue
            var video: String
            let videoStr = result["video"].stringValue
            if videoStr.hasPrefix(server) {
                video = videoStr
            } else {
                video = "\(server)\(videoStr)"
            }
            
            var thumb: String
            let thumbStr = result["thumb"].stringValue
            if thumbStr.hasPrefix(server) {
                thumb = thumbStr
            } else {
                thumb = "\(server)\(thumbStr)"
            }
            
            var thumb1: String
            let thumb1Str1 = result["challenge_thumb"].stringValue
            if videoStr.hasPrefix(server) {
                thumb1 = thumb1Str1
            } else {
                thumb1 = "\(server)\(thumb1Str1)"
            }
            
            var video1: String
            let video1Str = result["challenge_video"].stringValue
            if thumbStr.hasPrefix(server) {
                video1 = video1Str
            } else {
                video1 = "\(server)\(video1Str)"
            }
            let avg_rating_poster = CGFloat(result["avg_rating_poster"].floatValue)
            let avg_rating_chall = CGFloat(result["avg_rating_chall"].floatValue)
            let your_rating_chall = CGFloat(result["your_rating_chall"].floatValue)
            let your_rating_poster = CGFloat(result["your_rating_poster"].floatValue)
            let format = result["format"].stringValue
            let isChallenge = result["isChallenge"].stringValue
            let your_vote = result["your_vote"].stringValue
            var cnt_vote_poster = result["cnt_vote_poster"].stringValue
            
            if cnt_vote_poster == "" {
                cnt_vote_poster = "0"
            }
            
            var cnt_vote_challenger = result["cnt_vote_challenger"].stringValue
            if cnt_vote_challenger == "" {
                cnt_vote_challenger = "0"
            }
            
            let response = result["poster"]
            let id = response["id"].intValue
            let username = response["username"].stringValue
            let password = response["password"].stringValue
            let email = response["email"].stringValue
            let first_name = response["first_name"].stringValue
            let last_name = response["last_name"].stringValue
            let lat = response["lat"].stringValue
            let long = response["long"].stringValue
            let birthday = response["birthday"].stringValue
            let phone = response["phone"].stringValue
            let token = response["token"].stringValue
            var avatar: String
            let avatarStr = response["avatar"].stringValue
            if avatarStr.hasPrefix(server) {
                avatar = avatarStr
            } else {
                avatar = "\(server)\(avatarStr)"
            }
            let isFollow = response["isFollower"].stringValue
            let countFollowers = response["countFollowers"].stringValue
            let countFollowings = response["countFollowings"].stringValue
            let bio = response["bio"].stringValue
            let fb = response["fb"].stringValue
            let tw = response["tw"].stringValue
            let ins = response["in"].stringValue
            let vic_count = response["vic_count"].stringValue
            let poster = User(id: id,username: username,password: password,email: email,first_name: first_name,last_name: last_name,lat: lat,long: long,birthday: birthday,phone: phone,token: token,avatar: avatar,isFollow:isFollow,countFollowers:countFollowers,countFollowings:countFollowings,bio:bio,fb:fb,ins:ins,tw:tw,vic_count:vic_count)
            poster.isBlocked = response["is_block"].boolValue
            let callout = CallOut(id: postid, poster: poster, post_id: post_id,title: title, category: category, duration: duration, video: video, thumb: thumb, challenge_video: video1, challenge_thumb: thumb1, avg_rating_poster: avg_rating_poster, avg_rating_chall: avg_rating_chall, your_rating_poster: your_rating_poster, your_rating_chall: your_rating_chall, isChallenge: isChallenge,format:format,your_vote: your_vote, cnt_poster: cnt_vote_poster, cnt_challenger: cnt_vote_challenger)
            callout.views = result["views"].stringValue
            if result["challenger"].exists() && result["challenger"].count > 0
            {
                let response = result["challenger"]
                let id1 = response["id"].intValue
                let username1 = response["username"].stringValue
                let password1 = response["password"].stringValue
                let email1 = response["email"].stringValue
                let first_name1 = response["first_name"].stringValue
                let last_name1 = response["last_name"].stringValue
                let lat1 = response["lat"].stringValue
                let long1 = response["long"].stringValue
                let birthday1 = response["birthday"].stringValue
                let phone1 = response["phone"].stringValue
                let token1 = response["token"].stringValue
                
                var avatar1: String
                let avatarStr = response["avatar"].stringValue
                if avatarStr.hasPrefix(server) {
                    avatar1 = avatarStr
                } else {
                    avatar1 = "\(server)\(avatarStr)"
                }
                
                let isFollow1 = response["isFollower"].stringValue
                let countFollowers1 = response["countFollowers"].stringValue
                let countFollowings1 = response["countFollowings"].stringValue
                let bio1 = response["bio"].stringValue
                
                let fb1 = response["fb"].stringValue
                let tw1 = response["tw"].stringValue
                let ins1 = response["in"].stringValue
                let vic_count1 = response["vic_count"].stringValue
                let challenger = User(id: id1,username: username1,password: password1,email: email1,first_name: first_name1,last_name: last_name1,lat: lat1,long: long1,birthday: birthday1,phone: phone1,token: token1,avatar: avatar1,isFollow:isFollow1,countFollowers:countFollowers1,countFollowings:countFollowings1,bio:bio1,fb:fb1,ins:ins1,tw:tw1,vic_count:vic_count1)
                challenger.isBlocked = response["is_block"].boolValue
                callout.challenger = challenger
            }
            handler(callout)
        }
    }
    func getTopList(id:String,handler:@escaping(_ result:[[String:String]])->Void)
    {
        let requestUrl = serverUrl
        Alamofire.request(requestUrl, method: .post, parameters: ["service": "gettoplist", "id":id]).responseSwiftyJSON { (data) in
            var output = [[String:String]]()
            guard let userData = data.value else {
                handler(output)
                return
            }
            let result = userData["toplist"].arrayValue
            for value in result
            {
                let id = value["id"].stringValue
                let name = value["name"].stringValue
                
                var thumb1: String
                let thumb1Str = value["thumb1"].stringValue
                if thumb1Str.hasPrefix(server) {
                    thumb1 = thumb1Str
                } else {
                    thumb1 = "\(server)\(thumb1Str)"
                }
                
                var thumb2: String
                let thumb2Str = value["thumb2"].stringValue
                if thumb1Str.hasPrefix(server) {
                    thumb2 = thumb2Str
                } else {
                    thumb2 = "\(server)\(thumb2Str)"
                }
                let format = value["format"].stringValue
                
                output.append(["id":id,"name":name,"thumb1":thumb1,"thumb2":thumb2,"format":format])
            }
            
            handler(output)
        }
    }
    
    func getRanking(userid:String,handler:@escaping(_ result:[CallOut]?)->Void)
    {
        let requestUrl = serverUrl
        Alamofire.request(requestUrl, method: .post, parameters: ["service": "getranking", "id":userid]).responseSwiftyJSON { (data) in
            guard let userData = data.value else {
                handler(nil)
                return
            }
            let result = userData["data"].arrayValue
            var output = [CallOut]()
            for value in result
            {
                let postid = value["id"].intValue
                let post_id = value["post_id"].stringValue
                let title = value["title"].stringValue
                let category = value["category"].stringValue
                let duration = value["duration"].intValue
                var video: String
                let videoStr = value["video"].stringValue
                if videoStr.hasPrefix(server) {
                    video = videoStr
                } else {
                    video = "\(server)\(videoStr)"
                }
                
                var thumb: String
                let thumbStr = value["thumb"].stringValue
                if thumbStr.hasPrefix(server) {
                    thumb = thumbStr
                } else {
                    thumb = "\(server)\(thumbStr)"
                }
                
                var thumb1: String
                let thumb1Str1 = value["challenge_thumb"].stringValue
                if thumb1Str1.hasPrefix(server) {
                    thumb1 = thumb1Str1
                } else {
                    thumb1 = "\(server)\(thumb1Str1)"
                }
                
                var video1: String
                let video1Str = value["challenge_video"].stringValue
                if video1Str.hasPrefix(server) {
                    video1 = video1Str
                } else {
                    video1 = "\(server)\(video1Str)"
                }
                let avg_rating_poster = CGFloat(value["avg_rating_poster"].floatValue)
                let avg_rating_chall = CGFloat(value["avg_rating_chall"].floatValue)
                let your_rating_chall = CGFloat(value["your_rating_chall"].floatValue)
                let your_rating_poster = CGFloat(value["your_rating_poster"].floatValue)
                let format = value["format"].stringValue
                let isChallenge = value["isChallenge"].stringValue
                let your_vote = value["your_vote"].stringValue
                var cnt_vote_poster = value["cnt_vote_poster"].stringValue
                
                if cnt_vote_poster == "" {
                    cnt_vote_poster = "0"
                }
                
                var cnt_vote_challenger = value["cnt_vote_challenger"].stringValue
                if cnt_vote_challenger == "" {
                    cnt_vote_challenger = "0"
                }
                let winner = value["winner"].boolValue
                
                let response = value["poster"]
                let id = response["id"].intValue
                let username = response["username"].stringValue
                let password = response["password"].stringValue
                let email = response["email"].stringValue
                let first_name = response["first_name"].stringValue
                let last_name = response["last_name"].stringValue
                let lat = response["lat"].stringValue
                let long = response["long"].stringValue
                let birthday = response["birthday"].stringValue
                let phone = response["phone"].stringValue
                let token = response["token"].stringValue
                
                var avatar: String
                let avatarStr = response["avatar"].stringValue
                if avatarStr.hasPrefix(server) {
                    avatar = avatarStr
                } else {
                    avatar = "\(server)\(avatarStr)"
                }
                
                let isFollow = response["isFollower"].stringValue
                let countFollowers = response["countFollowers"].stringValue
                let countFollowings = response["countFollowings"].stringValue
                let bio = response["bio"].stringValue
                let fb = response["fb"].stringValue
                let tw = response["tw"].stringValue
                let ins = response["in"].stringValue
                let vic_count = response["vic_count"].stringValue
                let poster = User(id: id,username: username,password: password,email: email,first_name: first_name,last_name: last_name,lat: lat,long: long,birthday: birthday,phone: phone,token: token,avatar: avatar,isFollow:isFollow,countFollowers:countFollowers,countFollowings:countFollowings,bio:bio,fb:fb,ins:ins,tw:tw,vic_count:vic_count)
                poster.isBlocked = response["is_block"].boolValue
                let callout = CallOut(id: postid, poster: poster, post_id: post_id,title: title, category: category, duration: duration, video: video, thumb: thumb, challenge_video: video1, challenge_thumb: thumb1, avg_rating_poster: avg_rating_poster, avg_rating_chall: avg_rating_chall, your_rating_poster: your_rating_poster, your_rating_chall: your_rating_chall, isChallenge: isChallenge,format:format,your_vote: your_vote, cnt_poster: cnt_vote_poster, cnt_challenger: cnt_vote_challenger)
                callout.views = value["views"].stringValue
                callout.participants = value["participants"].stringValue
                callout.isWinnerPoster = winner
                if value["challenger"].exists() && value["challenger"].count > 0
                {
                    let response = value["challenger"]
                    let id1 = response["id"].intValue
                    let username1 = response["username"].stringValue
                    let password1 = response["password"].stringValue
                    let email1 = response["email"].stringValue
                    let first_name1 = response["first_name"].stringValue
                    let last_name1 = response["last_name"].stringValue
                    let lat1 = response["lat"].stringValue
                    let long1 = response["long"].stringValue
                    let birthday1 = response["birthday"].stringValue
                    let phone1 = response["phone"].stringValue
                    let token1 = response["token"].stringValue
                    
                    var avatar1: String
                    let avatarStr = response["avatar"].stringValue
                    if avatarStr.hasPrefix(server) {
                        avatar1 = avatarStr
                    } else {
                        avatar1 = "\(server)\(avatarStr)"
                    }
                    
                    let isFollow1 = response["isFollower"].stringValue
                    let countFollowers1 = response["countFollowers"].stringValue
                    let countFollowings1 = response["countFollowings"].stringValue
                    let bio1 = response["bio"].stringValue
                    
                    let fb1 = response["fb"].stringValue
                    let tw1 = response["tw"].stringValue
                    let ins1 = response["in"].stringValue
                    let vic_count1 = response["vic_count"].stringValue
                    let challenger = User(id: id1,username: username1,password: password1,email: email1,first_name: first_name1,last_name: last_name1,lat: lat1,long: long1,birthday: birthday1,phone: phone1,token: token1,avatar: avatar1,isFollow:isFollow1,countFollowers:countFollowers1,countFollowings:countFollowings1,bio:bio1,fb:fb1,ins:ins1,tw:tw1,vic_count:vic_count1)
                    challenger.isBlocked = response["is_block"].boolValue
                    callout.challenger = challenger
                }
                
                output.append(callout)
            }
            handler(output)
        }
    }
    
    func getUserChallengeItems(userid:String, requestid: String, handler:@escaping(_ result:[CallOut])->Void)
    {
        let requestUrl = serverUrl
        Alamofire.request(requestUrl, method: .post, parameters: ["service": "getchallengeitems",  "userid":userid, "requestid": requestid]).responseSwiftyJSON { (data) in
            var output = [CallOut]()
            guard let userData = data.value else {
                handler(output)
                return
            }
            let result = userData["data"].arrayValue
            for value in result
            {
                let postid = value["id"].intValue
                let post_id = value["post_id"].stringValue
                let title = value["title"].stringValue
                let category = value["category"].stringValue
                let duration = value["duration"].intValue
                
                var video: String
                let videoStr = value["video"].stringValue
                if videoStr.hasPrefix(server) {
                    video = videoStr
                } else {
                    video = "\(server)\(videoStr)"
                }
                
                var thumb: String
                let thumbStr = value["thumb"].stringValue
                if thumbStr.hasPrefix(server) {
                    thumb = thumbStr
                } else {
                    thumb = "\(server)\(thumbStr)"
                }
                
                var thumb1: String
                let thumb1Str = value["challenge_thumb"].stringValue
                if thumb1Str.hasPrefix(server) {
                    thumb1 = thumb1Str
                } else {
                    thumb1 = "\(server)\(thumb1Str)"
                }
                
                var video1: String
                let video1Str = value["challenge_video"].stringValue
                if video1Str.hasPrefix(server) {
                    video1 = video1Str
                } else {
                    video1 = "\(server)\(video1Str)"
                }
                
                let avg_rating_poster = CGFloat(value["avg_rating_poster"].floatValue)
                let avg_rating_chall = CGFloat(value["avg_rating_chall"].floatValue)
                let your_rating_chall = CGFloat(value["your_rating_chall"].floatValue)
                let your_rating_poster = CGFloat(value["your_rating_poster"].floatValue)
                let format = value["format"].stringValue
                let isChallenge = value["isChallenge"].stringValue
                let your_vote = value["your_vote"].stringValue
                var cnt_vote_poster = value["cnt_vote_poster"].stringValue
                
                if cnt_vote_poster == "" {
                    cnt_vote_poster = "0"
                }
                
                var cnt_vote_challenger = value["cnt_vote_challenger"].stringValue
                if cnt_vote_challenger == "" {
                    cnt_vote_challenger = "0"
                }
                
                let response = value["poster"]
                let id = response["id"].intValue
                let username = response["username"].stringValue
                let password = response["password"].stringValue
                let email = response["email"].stringValue
                let first_name = response["first_name"].stringValue
                let last_name = response["last_name"].stringValue
                let lat = response["lat"].stringValue
                let long = response["long"].stringValue
                let birthday = response["birthday"].stringValue
                let phone = response["phone"].stringValue
                let token = response["token"].stringValue
                var avatar: String
                
                let avatarStr = response["avatar"].stringValue
                if avatarStr.hasPrefix(server) {
                    avatar = avatarStr
                } else {
                    avatar = "\(server)\(avatarStr)"
                }
                let isFollow = response["isFollower"].stringValue
                let countFollowers = response["countFollowers"].stringValue
                let countFollowings = response["countFollowings"].stringValue
                let bio = response["bio"].stringValue
                let fb = response["fb"].stringValue
                let tw = response["tw"].stringValue
                let ins = response["in"].stringValue
                let vic_count = response["vic_count"].stringValue
                let poster = User(id: id,username: username,password: password,email: email,first_name: first_name,last_name: last_name,lat: lat,long: long,birthday: birthday,phone: phone,token: token,avatar: avatar,isFollow:isFollow,countFollowers:countFollowers,countFollowings:countFollowings,bio:bio,fb:fb,ins:ins,tw:tw,vic_count:vic_count)
                poster.isBlocked = response["is_block"].boolValue
                let callout = CallOut(id: postid, poster: poster, post_id: post_id,title: title, category: category, duration: duration, video: video, thumb: thumb, challenge_video: video1, challenge_thumb: thumb1, avg_rating_poster: avg_rating_poster, avg_rating_chall: avg_rating_chall, your_rating_poster: your_rating_poster, your_rating_chall: your_rating_chall, isChallenge: isChallenge,format:format,your_vote: your_vote, cnt_poster: cnt_vote_poster, cnt_challenger: cnt_vote_challenger)
                callout.views = value["views"].stringValue
                
                let type = response["type"].intValue
                callout.type = type
                
                if value["challenger"].exists() && value["challenger"].count > 0
                {
                    let response = value["challenger"]
                    let id1 = response["id"].intValue
                    let username1 = response["username"].stringValue
                    let password1 = response["password"].stringValue
                    let email1 = response["email"].stringValue
                    let first_name1 = response["first_name"].stringValue
                    let last_name1 = response["last_name"].stringValue
                    let lat1 = response["lat"].stringValue
                    let long1 = response["long"].stringValue
                    let birthday1 = response["birthday"].stringValue
                    let phone1 = response["phone"].stringValue
                    let token1 = response["token"].stringValue
                    var avatar1: String
                    
                    let avatarStr = response["avatar"].stringValue
                    if avatarStr.hasPrefix(server) {
                        avatar1 = avatarStr
                    } else {
                        avatar1 = "\(server)\(avatarStr)"
                    }
                    let isFollow1 = response["isFollower"].stringValue
                    let countFollowers1 = response["countFollowers"].stringValue
                    let countFollowings1 = response["countFollowings"].stringValue
                    let bio1 = response["bio"].stringValue
                    
                    let fb1 = response["fb"].stringValue
                    let tw1 = response["tw"].stringValue
                    let ins1 = response["in"].stringValue
                    let vic_count1 = response["vic_count"].stringValue
                    let challenger = User(id: id1,username: username1,password: password1,email: email1,first_name: first_name1,last_name: last_name1,lat: lat1,long: long1,birthday: birthday1,phone: phone1,token: token1,avatar: avatar1,isFollow:isFollow1,countFollowers:countFollowers1,countFollowings:countFollowings1,bio:bio1,fb:fb1,ins:ins1,tw:tw1,vic_count:vic_count1)
                    challenger.isBlocked = response["is_block"].boolValue
                    callout.challenger = challenger
                }
                
                output.append(callout)
            }
            
            handler(output)
        }
    }
    
    func getChallengeItems(userid:String,handler:@escaping(_ result:[CallOut])->Void)
    {
        let requestUrl = serverUrl
        Alamofire.request(requestUrl, method: .post, parameters: ["service": "getchallenge",  "userid":userid]).responseSwiftyJSON { (data) in
            var output = [CallOut]()
            guard let userData = data.value else {
                handler(output)
                return
            }
            let result = userData["data"].arrayValue
            for value in result
            {
                let postid = value["id"].intValue
                let post_id = value["post_id"].stringValue
                let title = value["title"].stringValue
                let category = value["category"].stringValue
                let duration = value["duration"].intValue
                
                var video: String
                let videoStr = value["video"].stringValue
                if videoStr.hasPrefix(server) {
                    video = videoStr
                } else {
                    video = "\(server)\(videoStr)"
                }
                
                var thumb: String
                let thumbStr = value["thumb"].stringValue
                if thumbStr.hasPrefix(server) {
                    thumb = thumbStr
                } else {
                    thumb = "\(server)\(thumbStr)"
                }
                
                var thumb1: String
                let thumb1Str = value["challenge_thumb"].stringValue
                if thumb1Str.hasPrefix(server) {
                    thumb1 = thumb1Str
                } else {
                    thumb1 = "\(server)\(thumb1Str)"
                }
                
                var video1: String
                let video1Str = value["challenge_video"].stringValue
                if video1Str.hasPrefix(server) {
                    video1 = video1Str
                } else {
                    video1 = "\(server)\(video1Str)"
                }
                
                let avg_rating_poster = CGFloat(value["avg_rating_poster"].floatValue)
                let avg_rating_chall = CGFloat(value["avg_rating_chall"].floatValue)
                let your_rating_chall = CGFloat(value["your_rating_chall"].floatValue)
                let your_rating_poster = CGFloat(value["your_rating_poster"].floatValue)
                let format = value["format"].stringValue
                let isChallenge = value["isChallenge"].stringValue
                let your_vote = value["your_vote"].stringValue
                var cnt_vote_poster = value["cnt_vote_poster"].stringValue
                
                if cnt_vote_poster == "" {
                    cnt_vote_poster = "0"
                }
                
                var cnt_vote_challenger = value["cnt_vote_challenger"].stringValue
                if cnt_vote_challenger == "" {
                    cnt_vote_challenger = "0"
                }
                
                let response = value["poster"]
                let id = response["id"].intValue
                let username = response["username"].stringValue
                let password = response["password"].stringValue
                let email = response["email"].stringValue
                let first_name = response["first_name"].stringValue
                let last_name = response["last_name"].stringValue
                let lat = response["lat"].stringValue
                let long = response["long"].stringValue
                let birthday = response["birthday"].stringValue
                let phone = response["phone"].stringValue
                let token = response["token"].stringValue
                var avatar: String
                
                let avatarStr = response["avatar"].stringValue
                if avatarStr.hasPrefix(server) {
                    avatar = avatarStr
                } else {
                    avatar = "\(server)\(avatarStr)"
                }
                let isFollow = response["isFollower"].stringValue
                let countFollowers = response["countFollowers"].stringValue
                let countFollowings = response["countFollowings"].stringValue
                let bio = response["bio"].stringValue
                let fb = response["fb"].stringValue
                let tw = response["tw"].stringValue
                let ins = response["in"].stringValue
                let vic_count = response["vic_count"].stringValue
                let poster = User(id: id,username: username,password: password,email: email,first_name: first_name,last_name: last_name,lat: lat,long: long,birthday: birthday,phone: phone,token: token,avatar: avatar,isFollow:isFollow,countFollowers:countFollowers,countFollowings:countFollowings,bio:bio,fb:fb,ins:ins,tw:tw,vic_count:vic_count)
                poster.isBlocked = response["is_block"].boolValue
                let callout = CallOut(id: postid, poster: poster, post_id: post_id,title: title, category: category, duration: duration, video: video, thumb: thumb, challenge_video: video1, challenge_thumb: thumb1, avg_rating_poster: avg_rating_poster, avg_rating_chall: avg_rating_chall, your_rating_poster: your_rating_poster, your_rating_chall: your_rating_chall, isChallenge: isChallenge,format:format,your_vote: your_vote, cnt_poster: cnt_vote_poster, cnt_challenger: cnt_vote_challenger)
                callout.views = value["views"].stringValue
                
                let type = response["type"].intValue
                callout.type = type
                
                if value["challenger"].exists() && value["challenger"].count > 0
                {
                    let response = value["challenger"]
                    let id1 = response["id"].intValue
                    let username1 = response["username"].stringValue
                    let password1 = response["password"].stringValue
                    let email1 = response["email"].stringValue
                    let first_name1 = response["first_name"].stringValue
                    let last_name1 = response["last_name"].stringValue
                    let lat1 = response["lat"].stringValue
                    let long1 = response["long"].stringValue
                    let birthday1 = response["birthday"].stringValue
                    let phone1 = response["phone"].stringValue
                    let token1 = response["token"].stringValue
                    var avatar1: String
                    
                    let avatarStr = response["avatar"].stringValue
                    if avatarStr.hasPrefix(server) {
                        avatar1 = avatarStr
                    } else {
                        avatar1 = "\(server)\(avatarStr)"
                    }
                    let isFollow1 = response["isFollower"].stringValue
                    let countFollowers1 = response["countFollowers"].stringValue
                    let countFollowings1 = response["countFollowings"].stringValue
                    let bio1 = response["bio"].stringValue
                    
                    let fb1 = response["fb"].stringValue
                    let tw1 = response["tw"].stringValue
                    let ins1 = response["in"].stringValue
                    let vic_count1 = response["vic_count"].stringValue
                    let challenger = User(id: id1,username: username1,password: password1,email: email1,first_name: first_name1,last_name: last_name1,lat: lat1,long: long1,birthday: birthday1,phone: phone1,token: token1,avatar: avatar1,isFollow:isFollow1,countFollowers:countFollowers1,countFollowings:countFollowings1,bio:bio1,fb:fb1,ins:ins1,tw:tw1,vic_count:vic_count1)
                    challenger.isBlocked = response["is_block"].boolValue
                    callout.challenger = challenger
                }
                
                output.append(callout)
            }
            
            handler(output)
        }
    }
    
    func getVicCount(userid: String, handler:@escaping(_ vicCount:Int)->Void) {
        Alamofire.request(serverUrl, method: .post, parameters: ["service": "getvictorycount",  "userid":userid]).responseSwiftyJSON { (response) in
            guard let userData = response.value else {
                handler(0)
                return
            }
            
            let result = userData["status"].stringValue
            if result == "Success" {
                let victoryCount = userData["vic_count"].intValue
                handler(victoryCount)
            } else {
                handler(0)
            }
        }
    }
    
    func getUserPostedItems(userid:String,caller:String, requestid: String ,handler:@escaping(_ result:[CallOut])->Void)
    {
        let requestUrl = serverUrl
        Alamofire.request(requestUrl, method: .post, parameters: ["service": "getcallouts",  "userid":userid,"caller":caller, "requestid": requestid]).responseSwiftyJSON { (data) in
            var output = [CallOut]()
            guard let userData = data.value else {
                handler(output)
                return
            }
            let result = userData["data"].arrayValue
            for value in result
            {
                let postid = value["id"].intValue
                let post_id = value["post_id"].stringValue
                let title = value["title"].stringValue
                let category = value["category"].stringValue
                let duration = value["duration"].intValue
                
                var video: String
                let videoStr = value["video"].stringValue
                if videoStr.hasPrefix(server) {
                    video = videoStr
                } else {
                    video = "\(server)\(videoStr)"
                }
                
                var thumb: String
                let thumbStr = value["thumb"].stringValue
                if thumbStr.hasPrefix(server) {
                    thumb = thumbStr
                } else {
                    thumb = "\(server)\(thumbStr)"
                }
                
                var thumb1: String
                let thumb1Str = value["challenge_thumb"].stringValue
                if thumb1Str.hasPrefix(server) {
                    thumb1 = thumb1Str
                } else {
                    thumb1 = "\(server)\(thumb1Str)"
                }
                
                var video1: String
                let video1Str = value["challenge_video"].stringValue
                if video1Str.hasPrefix(server) {
                    video1 = video1Str
                } else {
                    video1 = "\(server)\(video1Str)"
                }
                
                let avg_rating_poster = CGFloat(value["avg_rating_poster"].floatValue)
                let avg_rating_chall = CGFloat(value["avg_rating_chall"].floatValue)
                let your_rating_chall = CGFloat(value["your_rating_chall"].floatValue)
                let your_rating_poster = CGFloat(value["your_rating_poster"].floatValue)
                let format = value["format"].stringValue
                let isChallenge = value["isChallenge"].stringValue
                let your_vote = value["your_vote"].stringValue
                var cnt_vote_poster = value["cnt_vote_poster"].stringValue
                
                if cnt_vote_poster == "" {
                    cnt_vote_poster = "0"
                }
                
                var cnt_vote_challenger = value["cnt_vote_challenger"].stringValue
                if cnt_vote_challenger == "" {
                    cnt_vote_challenger = "0"
                }
                
                let response = value["poster"]
                let id = response["id"].intValue
                let username = response["username"].stringValue
                let password = response["password"].stringValue
                let email = response["email"].stringValue
                let first_name = response["first_name"].stringValue
                let last_name = response["last_name"].stringValue
                let lat = response["lat"].stringValue
                let long = response["long"].stringValue
                let birthday = response["birthday"].stringValue
                let phone = response["phone"].stringValue
                let token = response["token"].stringValue
                
                var avatar: String
                
                let avatarStr = response["avatar"].stringValue
                if avatarStr.hasPrefix(server) {
                    avatar = avatarStr
                } else {
                    avatar = "\(server)\(avatarStr)"
                }
                
                let isFollow = response["isFollower"].stringValue
                let countFollowers = response["countFollowers"].stringValue
                let countFollowings = response["countFollowings"].stringValue
                let bio = response["bio"].stringValue
                let fb = response["fb"].stringValue
                let tw = response["tw"].stringValue
                let ins = response["in"].stringValue
                let vic_count = response["vic_count"].stringValue
                let poster = User(id: id,username: username,password: password,email: email,first_name: first_name,last_name: last_name,lat: lat,long: long,birthday: birthday,phone: phone,token: token,avatar: avatar,isFollow:isFollow,countFollowers:countFollowers,countFollowings:countFollowings,bio:bio,fb:fb,ins:ins,tw:tw,vic_count:vic_count)
                poster.isBlocked = response["is_block"].boolValue
                let keyword = value["keyword"].stringValue
                
                let callout = CallOut(id: postid, poster: poster, post_id: post_id,title: title, category: category, duration: duration, video: video, thumb: thumb, challenge_video: video1, challenge_thumb: thumb1, avg_rating_poster: avg_rating_poster, avg_rating_chall: avg_rating_chall, your_rating_poster: your_rating_poster, your_rating_chall: your_rating_chall, isChallenge: isChallenge,format:format,your_vote: your_vote, cnt_poster: cnt_vote_poster, cnt_challenger: cnt_vote_challenger)
                callout.views = value["views"].stringValue
                callout.keyword = keyword
                let type = response["type"].intValue
                callout.type = type
                if value["challenger"].exists() && value["challenger"].count > 0
                {
                    let response = value["challenger"]
                    let id1 = response["id"].intValue
                    let username1 = response["username"].stringValue
                    let password1 = response["password"].stringValue
                    let email1 = response["email"].stringValue
                    let first_name1 = response["first_name"].stringValue
                    let last_name1 = response["last_name"].stringValue
                    let lat1 = response["lat"].stringValue
                    let long1 = response["long"].stringValue
                    let birthday1 = response["birthday"].stringValue
                    let phone1 = response["phone"].stringValue
                    let token1 = response["token"].stringValue
                    
                    var avatar1: String
                    
                    let avatarStr = response["avatar"].stringValue
                    if avatarStr.hasPrefix(server) {
                        avatar1 = avatarStr
                    } else {
                        avatar1 = "\(server)\(avatarStr)"
                    }
                    
                    let isFollow1 = response["isFollower"].stringValue
                    let countFollowers1 = response["countFollowers"].stringValue
                    let countFollowings1 = response["countFollowings"].stringValue
                    let bio1 = response["bio"].stringValue
                    
                    let fb1 = response["fb"].stringValue
                    let tw1 = response["tw"].stringValue
                    let ins1 = response["in"].stringValue
                    let vic_count1 = response["vic_count"].stringValue
                    let challenger = User(id: id1,username: username1,password: password1,email: email1,first_name: first_name1,last_name: last_name1,lat: lat1,long: long1,birthday: birthday1,phone: phone1,token: token1,avatar: avatar1,isFollow:isFollow1,countFollowers:countFollowers1,countFollowings:countFollowings1,bio:bio1,fb:fb1,ins:ins1,tw:tw1,vic_count:vic_count1)
                    challenger.isBlocked = response["is_block"].boolValue
                    callout.challenger = challenger
                }
                
                output.append(callout)
            }
            
            handler(output)
        }
    }
    
    func getPostItems(userid:String,caller:String,handler:@escaping(_ result:[CallOut])->Void)
    {
        let requestUrl = serverUrl
        Alamofire.request(requestUrl, method: .post, parameters: ["service": "getpostitem",  "userid":userid,"caller":caller]).responseSwiftyJSON { (data) in
            var output = [CallOut]()
            guard let userData = data.value else {
                handler(output)
                return
            }
            let result = userData["data"].arrayValue
            for value in result
            {
                let postid = value["id"].intValue
                let post_id = value["post_id"].stringValue
                let title = value["title"].stringValue
                let category = value["category"].stringValue
                let duration = value["duration"].intValue

                var video: String
                let videoStr = value["video"].stringValue
                if videoStr.hasPrefix(server) {
                    video = videoStr
                } else {
                    video = "\(server)\(videoStr)"
                }
                
                var thumb: String
                let thumbStr = value["thumb"].stringValue
                if thumbStr.hasPrefix(server) {
                    thumb = thumbStr
                } else {
                    thumb = "\(server)\(thumbStr)"
                }
                
                var thumb1: String
                let thumb1Str = value["challenge_thumb"].stringValue
                if thumb1Str.hasPrefix(server) {
                    thumb1 = thumb1Str
                } else {
                    thumb1 = "\(server)\(thumb1Str)"
                }
                
                var video1: String
                let video1Str = value["challenge_video"].stringValue
                if video1Str.hasPrefix(server) {
                    video1 = video1Str
                } else {
                    video1 = "\(server)\(video1Str)"
                }
                
                let avg_rating_poster = CGFloat(value["avg_rating_poster"].floatValue)
                let avg_rating_chall = CGFloat(value["avg_rating_chall"].floatValue)
                let your_rating_chall = CGFloat(value["your_rating_chall"].floatValue)
                let your_rating_poster = CGFloat(value["your_rating_poster"].floatValue)
                let format = value["format"].stringValue
                let isChallenge = value["isChallenge"].stringValue
                let your_vote = value["your_vote"].stringValue
                var cnt_vote_poster = value["cnt_vote_poster"].stringValue
                
                if cnt_vote_poster == "" {
                    cnt_vote_poster = "0"
                }
                
                var cnt_vote_challenger = value["cnt_vote_challenger"].stringValue
                if cnt_vote_challenger == "" {
                    cnt_vote_challenger = "0"
                }
                
                let response = value["poster"]
                let id = response["id"].intValue
                let username = response["username"].stringValue
                let password = response["password"].stringValue
                let email = response["email"].stringValue
                let first_name = response["first_name"].stringValue
                let last_name = response["last_name"].stringValue
                let lat = response["lat"].stringValue
                let long = response["long"].stringValue
                let birthday = response["birthday"].stringValue
                let phone = response["phone"].stringValue
                let token = response["token"].stringValue
                
                var avatar: String
                
                let avatarStr = response["avatar"].stringValue
                if avatarStr.hasPrefix(server) {
                    avatar = avatarStr
                } else {
                    avatar = "\(server)\(avatarStr)"
                }

                let isFollow = response["isFollower"].stringValue
                let countFollowers = response["countFollowers"].stringValue
                let countFollowings = response["countFollowings"].stringValue
                let bio = response["bio"].stringValue
                let fb = response["fb"].stringValue
                let tw = response["tw"].stringValue
                let ins = response["in"].stringValue
                let vic_count = response["vic_count"].stringValue
                let poster = User(id: id,username: username,password: password,email: email,first_name: first_name,last_name: last_name,lat: lat,long: long,birthday: birthday,phone: phone,token: token,avatar: avatar,isFollow:isFollow,countFollowers:countFollowers,countFollowings:countFollowings,bio:bio,fb:fb,ins:ins,tw:tw,vic_count:vic_count)
                poster.isBlocked = response["is_block"].boolValue
                let keyword = value["keyword"].stringValue
                
                let callout = CallOut(id: postid, poster: poster, post_id: post_id,title: title, category: category, duration: duration, video: video, thumb: thumb, challenge_video: video1, challenge_thumb: thumb1, avg_rating_poster: avg_rating_poster, avg_rating_chall: avg_rating_chall, your_rating_poster: your_rating_poster, your_rating_chall: your_rating_chall, isChallenge: isChallenge,format:format,your_vote: your_vote, cnt_poster: cnt_vote_poster, cnt_challenger: cnt_vote_challenger)
                callout.views = value["views"].stringValue
                callout.keyword = keyword
                let type = response["type"].intValue
                callout.type = type
                if value["challenger"].exists() && value["challenger"].count > 0
                {
                    let response = value["challenger"]
                    let id1 = response["id"].intValue
                    let username1 = response["username"].stringValue
                    let password1 = response["password"].stringValue
                    let email1 = response["email"].stringValue
                    let first_name1 = response["first_name"].stringValue
                    let last_name1 = response["last_name"].stringValue
                    let lat1 = response["lat"].stringValue
                    let long1 = response["long"].stringValue
                    let birthday1 = response["birthday"].stringValue
                    let phone1 = response["phone"].stringValue
                    let token1 = response["token"].stringValue
                    
                    var avatar1: String
                    
                    let avatarStr = response["avatar"].stringValue
                    if avatarStr.hasPrefix(server) {
                        avatar1 = avatarStr
                    } else {
                        avatar1 = "\(server)\(avatarStr)"
                    }
                    
                    let isFollow1 = response["isFollower"].stringValue
                    let countFollowers1 = response["countFollowers"].stringValue
                    let countFollowings1 = response["countFollowings"].stringValue
                    let bio1 = response["bio"].stringValue
                    
                    let fb1 = response["fb"].stringValue
                    let tw1 = response["tw"].stringValue
                    let ins1 = response["in"].stringValue
                    let vic_count1 = response["vic_count"].stringValue
                    let challenger = User(id: id1,username: username1,password: password1,email: email1,first_name: first_name1,last_name: last_name1,lat: lat1,long: long1,birthday: birthday1,phone: phone1,token: token1,avatar: avatar1,isFollow:isFollow1,countFollowers:countFollowers1,countFollowings:countFollowings1,bio:bio1,fb:fb1,ins:ins1,tw:tw1,vic_count:vic_count1)
                    challenger.isBlocked = response["is_block"].boolValue
                    callout.challenger = challenger
                }
                
                output.append(callout)
            }
            
            handler(output)
        }
    }
    func getPost(userID:Int,last_id:String,type:String,category:String,duration:String,keyword:String,completionHandler:@escaping(_ flag:Bool,_ result:[CallOut]?)->Void)
    {
        let requestUrl = serverUrl
        Alamofire.request(requestUrl, method: .post, parameters: ["service": "getpost",  "userid":String(userID),"type":type,"category":category,"duration":duration,"keyword":keyword]).responseSwiftyJSON { (data) in
            guard let userData = data.value else {
                completionHandler(false,nil)
                return
            }
            let result = userData["data"].arrayValue
            var output = [CallOut]()
            for value in result
            {
                let postid = value["id"].intValue
                let post_id = value["post_id"].stringValue
                let title = value["title"].stringValue
                let category = value["category"].stringValue
                let duration = value["duration"].intValue
                
                var video: String
                let videoStr = value["video"].stringValue
                if videoStr.hasPrefix(server) {
                    video = videoStr
                } else {
                    video = "\(server)\(videoStr)"
                }
                
                var thumb: String
                let thumbStr = value["thumb"].stringValue
                if thumbStr.hasPrefix(server) {
                    thumb = thumbStr
                } else {
                    thumb = "\(server)\(thumbStr)"
                }
                
                var thumb1: String
                let thumb1Str = value["challenge_thumb"].stringValue
                if thumb1Str.hasPrefix(server) {
                    thumb1 = thumb1Str
                } else {
                    thumb1 = "\(server)\(thumb1Str)"
                }
                
                var video1: String
                let video1Str = value["challenge_video"].stringValue
                if video1Str.hasPrefix(server) {
                    video1 = video1Str
                } else {
                    video1 = "\(server)\(video1Str)"
                }
                
                let avg_rating_poster = CGFloat(value["avg_rating_poster"].floatValue)
                let avg_rating_chall = CGFloat(value["avg_rating_chall"].floatValue)
                let your_rating_chall = CGFloat(value["your_rating_chall"].floatValue)
                let your_rating_poster = CGFloat(value["your_rating_poster"].floatValue)
                let format = value["format"].stringValue
                let isChallenge = value["isChallenge"].stringValue
                let your_vote = value["your_vote"].stringValue
                var cnt_vote_poster = value["cnt_vote_poster"].stringValue
                
                if cnt_vote_poster == "" {
                    cnt_vote_poster = "0"
                }
                
                var cnt_vote_challenger = value["cnt_vote_challenger"].stringValue
                if cnt_vote_challenger == "" {
                    cnt_vote_challenger = "0"
                }
                
                let response = value["poster"]
                let id = response["id"].intValue
                let username = response["username"].stringValue
                let password = response["password"].stringValue
                let email = response["email"].stringValue
                let first_name = response["first_name"].stringValue
                let last_name = response["last_name"].stringValue
                let lat = response["lat"].stringValue
                let long = response["long"].stringValue
                let birthday = response["birthday"].stringValue
                let phone = response["phone"].stringValue
                let token = response["token"].stringValue
                
                var avatar: String
                let avatar1Str = response["avatar"].stringValue
                if avatar1Str.hasPrefix(server) {
                    avatar = avatar1Str
                } else {
                    avatar = "\(server)\(avatar1Str)"
                }
                
                let isFollow = response["isFollower"].stringValue
                let countFollowers = response["countFollowers"].stringValue
                let countFollowings = response["countFollowings"].stringValue
                let bio = response["bio"].stringValue
                let fb = response["fb"].stringValue
                let tw = response["tw"].stringValue
                let ins = response["in"].stringValue
                let vic_count = response["vic_count"].stringValue
                let poster = User(id: id,username: username,password: password,email: email,first_name: first_name,last_name: last_name,lat: lat,long: long,birthday: birthday,phone: phone,token: token,avatar: avatar,isFollow:isFollow,countFollowers:countFollowers,countFollowings:countFollowings,bio:bio,fb:fb,ins:ins,tw:tw,vic_count:vic_count)
                
                poster.isBlocked = response["is_block"].boolValue
                
                let keyword = value["keyword"].stringValue
                
                let callout = CallOut(id: postid, poster: poster, post_id: post_id,title: title, category: category, duration: duration, video: video, thumb: thumb, challenge_video: video1, challenge_thumb: thumb1, avg_rating_poster: avg_rating_poster, avg_rating_chall: avg_rating_chall, your_rating_poster: your_rating_poster, your_rating_chall: your_rating_chall, isChallenge: isChallenge,format:format,your_vote: your_vote, cnt_poster: cnt_vote_poster, cnt_challenger: cnt_vote_challenger)
                callout.views = value["views"].stringValue
                callout.isExpired = value["isExpired"].boolValue
                callout.keyword = keyword
                
                if value["challenger"].exists() && value["challenger"].count > 0
                {
                    let response = value["challenger"]
                    let id1 = response["id"].intValue
                    let username1 = response["username"].stringValue
                    let password1 = response["password"].stringValue
                    let email1 = response["email"].stringValue
                    let first_name1 = response["first_name"].stringValue
                    let last_name1 = response["last_name"].stringValue
                    let lat1 = response["lat"].stringValue
                    let long1 = response["long"].stringValue
                    let birthday1 = response["birthday"].stringValue
                    let phone1 = response["phone"].stringValue
                    let token1 = response["token"].stringValue
                    
                    var avatar1: String
                    let avatar1Str = response["avatar"].stringValue
                    if avatar1Str.hasPrefix(server) {
                        avatar1 = avatar1Str
                    } else {
                        avatar1 = "\(server)\(avatar1Str)"
                    }
                    
                    let isFollow1 = response["isFollower"].stringValue
                    let countFollowers1 = response["countFollowers"].stringValue
                    let countFollowings1 = response["countFollowings"].stringValue
                    let bio1 = response["bio"].stringValue
                    
                    let fb1 = response["fb"].stringValue
                    let tw1 = response["tw"].stringValue
                    let ins1 = response["in"].stringValue
                    let vic_count1 = response["vic_count"].stringValue
                    let challenger = User(id: id1,username: username1,password: password1,email: email1,first_name: first_name1,last_name: last_name1,lat: lat1,long: long1,birthday: birthday1,phone: phone1,token: token1,avatar: avatar1,isFollow:isFollow1,countFollowers:countFollowers1,countFollowings:countFollowings1,bio:bio1,fb:fb1,ins:ins1,tw:tw1,vic_count:vic_count1)
                    print (response["is_block"])
                    challenger.isBlocked = response["is_block"].intValue == 1 ? true : false
                    callout.challenger = challenger
                }
                
                output.append(callout)
            }
            
            completionHandler(true,output)
        }
    }
    
    func updateProfile(id:String,email:String,first_name:String,last_name:String,birthday:String,username:String,phone:String,bio:String,image:Data,fb:String,ins:String,tw:String,completionHandler:@escaping(_ flag:Bool, _ photo: String?)->Void)
    {
        let requestUrl = serverUrl
        let accessToken = Global.getUserDataFromLocal()?.access_token ?? ""
        let parameters = [
                "service": "updateprofile",
                "id":id,
                "email": email,
                "access_token": accessToken,
                "username": username,
                "bio":bio,
                "phone":phone,
                "first_name": first_name,
                "last_name": last_name,
                "birthday": birthday,
                "fb":fb,
                "in":ins,
                "tw":tw] as [String : Any]
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                multipartFormData.append(image, withName: "image", fileName: "swift_file.jpeg", mimeType: "image/png")
                for (key, value) in parameters {
                    multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                }
            }, to:requestUrl)
            { (encodingResult) in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseSwiftyJSON(completionHandler: { (response) in
                        guard let data = response.value else {
                            completionHandler(false, nil)
                            return
                        }
                        print(data)
                        let result = data["status"].stringValue
                        if result == "Error"
                        {
                            completionHandler(false, data["Error"].stringValue)
                        }
                        else{
                            let userData = data["user"]
                            let user = User(json: userData)
                            Global.saveUserData(user: user)
                            completionHandler(true, user.avatar)
                        }
                    })
                case .failure( _):
                    completionHandler(false, nil)
                    return
                }
            }
    }
    func socialRegister(email:String,username:String,password:String,first_name:String,last_name:String,path:String,type:String,completionHandler:@escaping(_ flag:Bool,_ result:String)->Void)
    {

        let deviceToken = UserDefaults.standard.string(forKey: DEVICE_TOKEN) ?? ""
        let requestUrl = serverUrl
        let  parameters = [
            "service": "socialmediasignup",
            "email_id": email,
            "username": username,
            "first_name": first_name,
            "last_name": last_name,
            "device_type": "I",
            "device_token": deviceToken,
            "social_media_profile_url": path,
            "social_media_type":type] as [String : Any]
        Alamofire.request(requestUrl, method: .post, parameters: parameters).responseSwiftyJSON { (data) in
            guard let userData = data.value else {
                completionHandler(false,"Network Error")
                return
            }
            let result = userData["status"].stringValue
            if result == "Error"
            {
                completionHandler(false,userData["Error"].stringValue)
            }
            else{
                let response = userData["user"]
                let user = User(json: response)
                Global.saveUserData(user: user)
                completionHandler(true,"success")
            }
        }
    }
    func register(email:String,password:String,first_name:String,last_name:String,birthday:String,username:String,phone:String?,image:Data?,fb:String,ins:String,tw:String,completionHandler:@escaping(_ flag:Bool, _ result :String)->Void)
    {
        let requestUrl = serverUrl
        
        let device_token = UserDefaults.standard.value(forKey: DEVICE_TOKEN)
        let parameters:[String:Any]
        if let ph = phone{
            parameters = [
                "service": "emailsignup",
                "email_id": email,
                "username": username,
                "password": password,
                "first_name": first_name,
                "last_name": last_name,
                "birthday": birthday,
                "phone":ph,
                "fb_id":fb,
                "instagram_id":ins,
                "device_token": device_token ?? "",
                "device_type": "I",
                "multipart": "Y",
                "twitter_id":tw] as [String : Any]
        }
        else{
            parameters = [
                "service": "emailsignup",
                "email_id": email,
                "username": username,
                "password": password,
                "first_name": first_name,
                "last_name": last_name,
                "birthday": birthday,
                "fb_id":fb,
                "instagram_id":ins,
                "device_token": device_token ?? "",
                "device_type": "I",
                "multipart": "Y",
                "twitter_id":tw] as [String : Any]
        }
        if let img = image {
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                multipartFormData.append(img, withName: "image", fileName: "swift_file.jpeg", mimeType: "image/png")
                for (key, value) in parameters {
                    multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                }
            }, to:requestUrl)
            { (encodingResult) in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseSwiftyJSON(completionHandler: { (response) in
                        guard let data = response.value else {
                            completionHandler(false,"Upload image Failed please try again later")
                            return
                        }
                        let result = data["status"].stringValue
                        if result == "Error"
                        {
                            completionHandler(false,data["Error"].stringValue)
                        }
                        else{
                            let user = User(json: data)
                            Global.saveUserData(user: user)
                            completionHandler(true,"success")
                        }
                    })
                case .failure( _):
                    completionHandler(false,"Register Failed")
                    return
                }
            }
        }
        else{
            print(requestUrl)
            print(parameters)
            Alamofire.request(requestUrl, method: .post, parameters: parameters).responseSwiftyJSON { (data) in
                guard let userData = data.value else {
                    completionHandler(false,"Network Error")
                    return
                }
                let response = userData["response"]
                let result = response["success"].intValue
                if result == 0
                {
                    completionHandler(false,response["error"].stringValue)
                }
                else{
                    let id = response["id"].intValue
                    let username = response["username"].stringValue
                    let password = response["password"].stringValue
                    let email = response["email"].stringValue
                    let first_name = response["first_name"].stringValue
                    let last_name = response["last_name"].stringValue
                    let lat = response["lat"].stringValue
                    let long = response["long"].stringValue
                    let birthday = response["birthday"].stringValue
                    let phone = response["phone"].stringValue
                    let token = response["token"].stringValue
                    var avatar: String
                    let avatar1Str = response["avatar"].stringValue
                    if avatar1Str.hasPrefix(server) {
                        avatar = avatar1Str
                    } else {
                        avatar = "\(server)\(avatar1Str)"
                    }
                    let countFollowers = response["countFollowers"].stringValue
                    let countFollowings = response["countFollowings"].stringValue
                    let bio = response["bio"].stringValue
                    let fb = response["fb"].stringValue
                    let tw = response["tw"].stringValue
                    let ins = response["in"].stringValue
                    let vic_count = response["vic_count"].stringValue
                    let user = User(id: id,username: username,password: password,email: email,first_name: first_name,last_name: last_name,lat: lat,long: long,birthday: birthday,phone: phone,token: token,avatar: avatar,isFollow:"0",countFollowers:countFollowers,countFollowings:countFollowings,bio:bio,fb:fb,ins:ins,tw:tw,vic_count:vic_count)
                    Global.saveUserData(user: user)
                    completionHandler(true,"success")
                }
            }
        }
    }
    
    func postComment(feedid:String,comment:String,userid:String,completionHandler:@escaping (_ flag:Bool, _ comment :String, _ commentId: Int)->Void)
    {
        let requestString = serverUrl
        Alamofire.request(requestString, method: .post, parameters: ["service": "postcomment",  "feedid":feedid,"comment":comment,"userid":userid]).responseSwiftyJSON { (data) in
            guard let userData = data.value else {
                completionHandler(false,"Network Error", 0)
                return
            }
            print(userData)
            let response = userData["status"]
            if response == "Error"
            {
                completionHandler(false,response["Error"].stringValue, 0)
            }
            else{
                completionHandler(true,userData["comment"].stringValue, userData["comment_id"].intValue)
            }
        }
    }
    
    func getComment(feedid:String,completionHandler:@escaping (_ flag:Bool, _ result :[Comment]?)->Void)
    {
        let requestString = serverUrl
        Alamofire.request(requestString, method: .post, parameters: ["service": "getcomment",  "feedid":feedid]).responseSwiftyJSON { (data) in
            guard let userData = data.value else {
                completionHandler(false,nil)
                return
            }
            var result = [Comment]()
            let response = userData["comment"].arrayValue
            for c in response
            {
                let comment = c["comment"].stringValue
                
                let avatarStr = c["avatar"].stringValue
                
                var avatar: String
                if avatarStr.hasPrefix(server) {
                    avatar = avatarStr
                } else {
                    avatar = "\(server)\(avatarStr)"
                }
                
                let userid = c["userid"].intValue
                let commentid = c["comment_id"].intValue
                
                let username = c["username"].stringValue
                
                result.append(Comment(comment: comment, avatar: avatar, username: username, userid: userid, commentid: commentid))
            }
            completionHandler(true,result)
        }
    }
    func vote(postid:String,challenge_id:String,userid:String,voteid:String,toPoster:String,completionHandler:@escaping (_ flag:Bool)->Void)
    {
        let requestString = serverUrl
        let parameters = ["service": "vote", "postid":postid,
                          "challenge_id":challenge_id,
                          "userid":userid,
                          "voteid":voteid,
                          "toPoster":toPoster]
        Alamofire.request(requestString, method: .post, parameters: parameters).responseSwiftyJSON { (data) in
            guard let userData = data.value else {
                completionHandler(false)
                return
            }
            let result = userData["status"].stringValue
            if result == "Error"
            {
                completionHandler(false)
            }
            else{
                completionHandler(true)
            }
        }
    }
    func rating(feedid:String,postid:String,to:String,userid:String,rating:String,completionHandler:@escaping (_ flag:Bool, _ result:String)->Void)
    {
        let requestString = serverUrl
        let parameters = ["service": "rating",
                            "feedid":feedid,
                          "postid":postid,
                          "to":to,
                          "userid":userid,
                          "rating":rating]
        Alamofire.request(requestString, method: .post, parameters: parameters).responseSwiftyJSON { (data) in
            guard let userData = data.value else {
                completionHandler(false,"something wrong")
                return
            }
            let result = userData["status"].stringValue
            if result == "Error"
            {
                completionHandler(false,userData["Error"].stringValue)
            }
            else{
                completionHandler(true,"success")
            }
        }
    }
    
    func follow(follower:String,following:String,value:String,completionHandler:@escaping (_ flag:Bool, _ result:String)->Void)
    {
        let requestString = serverUrl
        let parameters = [ "service": "follow",
                        "follower":follower,
                          "following":following,
                          "value":value]
        Alamofire.request(requestString, method: .post, parameters: parameters).responseSwiftyJSON { (data) in
            guard let userData = data.value else {
                completionHandler(false,"something wrong")
                return
            }
            let result = userData["status"].stringValue
            if result == "Error"
            {
                completionHandler(false,userData["Error"].stringValue)
            }
            else{
                completionHandler(true,"success")
            }
        }
    }
    func blockUser(userid:String,blocked_id:String,value:String,handler:@escaping(_ flag:Bool)->Void){
        let requestString = serverUrl
        let parameters = ["service": "block",
                            "userid":userid,
                          "blocked_id":blocked_id,
                          "value":value]
        Alamofire.request(requestString, method: .post, parameters: parameters).responseSwiftyJSON { (data) in
            guard let userData = data.value else {
                handler(false)
                return
            }
            print(userData)
            let result = userData["status"].stringValue
            if result == "Error"
            {
                handler(false)
            }
            else{
                handler(true)
            }
        }
    }
    func getFollowing(userid:String,callerid:String,completionHandler:@escaping (_ flag:Bool, _ result:[User]?)->Void)
    {
        let requestString = serverUrl
        let parameters = [ "service": "getfollowing",
                        "userid":userid,
                          "callerid":callerid]
        Alamofire.request(requestString, method: .post, parameters: parameters).responseSwiftyJSON { (data) in
            guard let userData = data.value else {
                completionHandler(false,nil)
                return
            }
            var users = [User]()
            let datas = userData["followings"].arrayValue
            for data in datas{
                let id = data["id"].intValue
                let username = data["username"].stringValue
                let password = data["password"].stringValue
                let email = data["email"].stringValue
                let first_name = data["first_name"].stringValue
                let last_name = data["last_name"].stringValue
                let lat = data["lat"].stringValue
                let long = data["long"].stringValue
                let birthday = data["birthday"].stringValue
                let phone = data["phone"].stringValue
                let token = data["token"].stringValue
                var avatar: String
                let avatar1Str = data["avatar"].stringValue
                if avatar1Str.hasPrefix(server) {
                    avatar = avatar1Str
                } else {
                    avatar = "\(server)\(avatar1Str)"
                }
                let isFollower = data["isFollower"].stringValue
                let countFollowers = data["countFollowers"].stringValue
                let countFollowings = data["countFollowings"].stringValue
                let bio = data["bio"].stringValue
                let fb = data["fb"].stringValue
                let tw = data["tw"].stringValue
                let ins = data["in"].stringValue
                let vic_count = data["vic_count"].stringValue
                
                let user = User(id: id,username: username,password: password,email: email,first_name: first_name,last_name: last_name,lat: lat,long: long,birthday: birthday,phone: phone,token: token,avatar: avatar,isFollow:isFollower,countFollowers:countFollowers,countFollowings:countFollowings,bio:bio,fb:fb,ins:ins,tw:tw,vic_count:vic_count)
                
                user.isBlocked = data["is_block"].boolValue
                
                users.append(user)
            }
            completionHandler(true,users)
        }
    }
    
    func getFollower(userid:String,callerid:String,completionHandler:@escaping (_ flag:Bool, _ result:[User]?)->Void)
    {
        let requestString = serverUrl
        let parameters = ["service": "getfollower",
                            "userid":userid,
                          "callerid":callerid]
        Alamofire.request(requestString, method: .post, parameters: parameters).responseSwiftyJSON { (data) in
            guard let userData = data.value else {
                completionHandler(false,nil)
                return
            }
            var users = [User]()
            let datas = userData["followers"].arrayValue
            for data in datas{
                let id = data["id"].intValue
                let username = data["username"].stringValue
                let password = data["password"].stringValue
                let email = data["email"].stringValue
                let first_name = data["first_name"].stringValue
                let last_name = data["last_name"].stringValue
                let lat = data["lat"].stringValue
                let long = data["long"].stringValue
                let birthday = data["birthday"].stringValue
                let phone = data["phone"].stringValue
                let token = data["token"].stringValue
                var avatar: String
                let avatar1Str = data["avatar"].stringValue
                if avatar1Str.hasPrefix(server) {
                    avatar = avatar1Str
                } else {
                    avatar = "\(server)\(avatar1Str)"
                }
                let isFollower = data["isFollower"].stringValue
                let countFollowers = data["countFollowers"].stringValue
                let countFollowings = data["countFollowings"].stringValue
                let bio = data["bio"].stringValue
                let fb = data["fb"].stringValue
                let tw = data["tw"].stringValue
                let ins = data["in"].stringValue
                let vic_count = data["vic_count"].stringValue
                let user = User(id: id,username: username,password: password,email: email,first_name: first_name,last_name: last_name,lat: lat,long: long,birthday: birthday,phone: phone,token: token,avatar: avatar,isFollow:isFollower,countFollowers:countFollowers,countFollowings:countFollowings,bio:bio,fb:fb,ins:ins,tw:tw,vic_count:vic_count)
                
                user.isBlocked = data["is_block"].boolValue
                users.append(user)
            }
            completionHandler(true,users)
        }
    }
    
    func createGroup(creator:String,name:String,member:String,groupid:String,handler:@escaping (_ flag:Bool,_ result:String)->Void)
    {
        let requestString = serverUrl
        let access_token = Global.getUserDataFromLocal()?.access_token ?? ""
        
        Alamofire.request(requestString, method: .post, parameters: ["service": "creategroup", "access_token": access_token, "user_id":creator,"name":name,"member":member]).responseSwiftyJSON { (data) in
            guard let userData = data.value else {
                handler(false,"something wrong")
                return
            }
            let result = userData["status"].stringValue
            if result == "Error"
            {
                handler(false,userData["Error"].stringValue)
            }
            else{
                handler(true,"success")
            }
        }
    }
    
    func updateFcm(userid:String,token:String,handler:@escaping (_ flag:Bool,_ result:String)->Void)
    {
        let requestString = serverUrl
        let accessToken = Global.getUserDataFromLocal()?.access_token ?? ""
        Alamofire.request(requestString, method: .post, parameters: ["service": "updatedevicetoken",  "user_id":userid, "access_token": accessToken, "device_token":token]).responseSwiftyJSON { (data) in
            guard let userData = data.value else {
                handler(false,"something wrong")
                return
            }
            let result = userData["status"].stringValue
            if result == "Error"
            {
                handler(false,userData["Error"].stringValue)
            }
            else{
                handler(true,"success")
            }
        }
    }
    
    func getGroupInfo(groupid:String,handler:@escaping(_ userids:String,_ usernames:String)->Void)
    {
        let requestString = serverUrl
        Alamofire.request(requestString, method: .post, parameters: ["service": "getgroupinfo",  "groupid":groupid]).responseSwiftyJSON { (data) in
            guard let userData = data.value else {
                handler("","")
                return
            }
            let usernames = userData["usernames"].stringValue
            let userids = userData["member"].stringValue
            handler(userids,usernames)
        }
    }
    
    func logout(userId: Int, handler:@escaping ()->Void) {
        let access_token = Global.getUserDataFromLocal()?.access_token ?? ""
        
        Alamofire.request(serverUrl, method: .post, parameters: ["service": "logout",  "user_id":userId, "access_token": access_token]).responseSwiftyJSON { (data) in
            UIApplication.shared.applicationIconBadgeNumber = 0
            handler()
        }
    }
    
    func getGroup(userid:String,handler:@escaping (_ result:[Group])->Void)
    {
        let requestString = serverUrl
        
        let access_token = Global.getUserDataFromLocal()?.access_token ?? ""
        
        Alamofire.request(requestString, method: .post, parameters: ["service": "getgroup",  "user_id":userid, "access_token": access_token]).responseSwiftyJSON { (data) in
            var groups = [Group]()
            guard let userData = data.value else {
                handler(groups)
                return
            }
            let datas = userData["group"].arrayValue
            for data in datas{
                let id = data["id"].stringValue
                let name = data["name"].stringValue
                let creator = data["creator"].stringValue
                let member = data["member"].stringValue
                let group = Group(id: id, name: name, creator: creator, member: member)
                groups.append(group)
            }
            handler(groups)
        }
    }
    
    func deleteComment(commentId: Int, handler:@escaping()-> Void) {
        Alamofire.request(serverUrl, method: .post, parameters: ["service": "deletecomment" ,"comment_id":commentId]).responseSwiftyJSON { (data) in
            handler()
        }
    }
    
    func deleteNotification(notification_id: Int, handler:@escaping()-> Void) {
        Alamofire.request(serverUrl, method: .post, parameters: ["service": "deletenotification" ,"notification_id":notification_id, "userid": (Global.getUserDataFromLocal()?.id)!]).responseSwiftyJSON { (data) in
            handler()
        }
    }
    
    func getNotification(userid:String,handler:@escaping(_ result:[NotificationObj])-> Void)
    {
        let requestString = serverUrl
        Alamofire.request(requestString, method: .post, parameters: ["service": "getnotifications",  "userid":userid]).responseSwiftyJSON { (data) in
            var output = [NotificationObj]()
            guard let userData = data.value else {
                handler(output)
                return
            }
            
            let result = userData["data"].arrayValue
            for value in result
            {
                /*
                let avatar = value["avatar"].stringValue
                let username = value["username"].stringValue
                let thumb = value["thumb"].stringValue
                let id = value["challenge_id"].stringValue
                let expired = value["expired"].boolValue
                let title = value["title"].stringValue
                let type = value["type"].intValue
                let p = value["private"].stringValue
                let member = value["member"].stringValue
                
                let creation_date = value["creation_date"].doubleValue
                let callout = ["avatar":avatar,"username":username,"thumb":thumb,"id":id,"expired":expired,"title":title,"can":value["can"].boolValue,"type":type,"private":p,"member":member, "creation_date": creation_date] as [String : Any]
                output.append(callout)*/
                let obj = NotificationObj(json: value)
                output.append(obj)
            }
            handler(output)
        }
    }
    func changePassword(userid:String,password:String,handler:@escaping (_ flag:Bool)->Void)
    {
        let requestString = serverUrl
        let accessToken = Global.getUserDataFromLocal()?.access_token ?? ""
        Alamofire.request(requestString, method: .post, parameters: ["service": "changepassword",  "userid":userid, "access_token": accessToken, "password":password]).responseSwiftyJSON { (data) in
            guard let userData = data.value else {
                handler(false)
                return
            }
            let result = userData["status"].stringValue
            if result == "Error"
            {
                handler(false)
            }
            else{
                handler(true)
            }
        }
    }
    func getuserBlockList(userid:String,handler:@escaping(_ result:[User])->Void)
    {
        let requestString = serverUrl
        Alamofire.request(requestString, method: .post, parameters: ["service": "getblocklist", "userid":userid]).responseSwiftyJSON { (data) in
            var users = [User]()
            guard let userData = data.value else {
                handler(users)
                return
            }
            let datas = userData["blocklist"].arrayValue
            for data in datas{
                let id = data["id"].intValue
                let username = data["username"].stringValue
                let password = data["password"].stringValue
                let email = data["email"].stringValue
                let first_name = data["first_name"].stringValue
                let last_name = data["last_name"].stringValue
                let lat = data["lat"].stringValue
                let long = data["long"].stringValue
                let birthday = data["birthday"].stringValue
                let phone = data["phone"].stringValue
                let token = data["token"].stringValue
                var avatar: String
                let avatarStr = data["avatar"].stringValue
                if avatarStr.hasPrefix(server) {
                    avatar = avatarStr
                } else {
                    avatar = "\(server)\(avatarStr)"
                }
                let isFollower = data["isFollower"].stringValue
                let countFollowers = data["countFollowers"].stringValue
                let countFollowings = data["countFollowings"].stringValue
                let bio = data["bio"].stringValue
                let fb = data["fb"].stringValue
                let tw = data["tw"].stringValue
                let ins = data["in"].stringValue
                let vic_count = data["vic_count"].stringValue
                let user = User(id: id,username: username,password: password,email: email,first_name: first_name,last_name: last_name,lat: lat,long: long,birthday: birthday,phone: phone,token: token,avatar: avatar,isFollow:isFollower,countFollowers:countFollowers,countFollowings:countFollowings,bio:bio,fb:fb,ins:ins,tw:tw,vic_count:vic_count)
                user.isBlocked = data["is_block"].boolValue
                users.append(user)
            }
            handler(users)
        }
    }
    func search(userid:String,type:String,key:String,handler:@escaping (_ flag:Bool,_ result:[Any]?)->Void)
    {
        let requestString = serverUrl
        Alamofire.request(requestString, method: .post, parameters: ["service": "search",  "userid":userid,"key":key,"type":type]).responseSwiftyJSON { (data) in
            guard let userData = data.value else {
                handler(false,nil)
                return
            }
            if type == "user"
            {
                var users = [User]()
                let datas = userData["data"].arrayValue
                for data in datas{
                    let id = data["id"].intValue
                    let username = data["username"].stringValue
                    let password = data["password"].stringValue
                    let email = data["email"].stringValue
                    let first_name = data["first_name"].stringValue
                    let last_name = data["last_name"].stringValue
                    let lat = data["lat"].stringValue
                    let long = data["long"].stringValue
                    let birthday = data["birthday"].stringValue
                    let phone = data["phone"].stringValue
                    let token = data["token"].stringValue
                    var avatar: String
                    let avatar1Str = data["avatar"].stringValue
                    if avatar1Str.hasPrefix(server) {
                        avatar = avatar1Str
                    } else {
                        avatar = "\(server)\(avatar1Str)"
                    }
                    let isFollower = data["isFollower"].stringValue
                    let countFollowers = data["countFollowers"].stringValue
                    let countFollowings = data["countFollowings"].stringValue
                    let bio = data["bio"].stringValue
                    let fb = data["fb"].stringValue
                    let tw = data["tw"].stringValue
                    let ins = data["in"].stringValue
                    let vic_count = data["vic_count"].stringValue
                    let user = User(id: id,username: username,password: password,email: email,first_name: first_name,last_name: last_name,lat: lat,long: long,birthday: birthday,phone: phone,token: token,avatar: avatar,isFollow:isFollower,countFollowers:countFollowers,countFollowings:countFollowings,bio:bio,fb:fb,ins:ins,tw:tw,vic_count:vic_count)
                    user.isBlocked = data["is_block"].boolValue
                    users.append(user)
                }
                handler(true,users)
            }
            else{
                let result = userData["data"].arrayValue
                var output = [CallOut]()
                for value in result
                {
                    print(value)
                    let postid = value["id"].intValue
                    let post_id = value["post_id"].stringValue
                    let title = value["title"].stringValue
                    let category = value["category"].stringValue
                    let duration = value["duration"].intValue
                    var video: String
                    let videoStr = value["video"].stringValue
                    if videoStr.hasPrefix(server) {
                        video = videoStr
                    } else {
                        video = "\(server)\(videoStr)"
                    }
                    
                    var thumb: String
                    let thumbStr = value["thumb"].stringValue
                    if thumbStr.hasPrefix(server) {
                        thumb = thumbStr
                    } else {
                        thumb = "\(server)\(thumbStr)"
                    }
                    
                    var thumb1: String
                    let thumb1Str1 = value["challenge_thumb"].stringValue
                    if videoStr.hasPrefix(server) {
                        thumb1 = thumb1Str1
                    } else {
                        thumb1 = "\(server)\(thumb1Str1)"
                    }
                    
                    var video1: String
                    let video1Str = value["challenge_video"].stringValue
                    if thumbStr.hasPrefix(server) {
                        video1 = video1Str
                    } else {
                        video1 = "\(server)\(video1Str)"
                    }
                    let avg_rating_poster = CGFloat(value["avg_rating_poster"].floatValue)
                    let avg_rating_chall = CGFloat(value["avg_rating_chall"].floatValue)
                    let your_rating_chall = CGFloat(value["your_rating_chall"].floatValue)
                    let your_rating_poster = CGFloat(value["your_rating_poster"].floatValue)
                    let isChallenge = value["isChallenge"].stringValue
                    let format = value["format"].stringValue
                    let your_vote = value["your_vote"].stringValue
                    var cnt_vote_poster = value["cnt_vote_poster"].stringValue
                    
                    if cnt_vote_poster == "" {
                        cnt_vote_poster = "0"
                    }
                    
                    var cnt_vote_challenger = value["cnt_vote_challenger"].stringValue
                    if cnt_vote_challenger == "" {
                        cnt_vote_challenger = "0"
                    }
                    
                    let response = value["poster"]
                    let id = response["id"].intValue
                    let username = response["username"].stringValue
                    let password = response["password"].stringValue
                    let email = response["email"].stringValue
                    let first_name = response["first_name"].stringValue
                    let last_name = response["last_name"].stringValue
                    let lat = response["lat"].stringValue
                    let long = response["long"].stringValue
                    let birthday = response["birthday"].stringValue
                    let phone = response["phone"].stringValue
                    let token = response["token"].stringValue
                    var avatar: String
                    let avatar1Str = response["avatar"].stringValue
                    if avatar1Str.hasPrefix(server) {
                        avatar = avatar1Str
                    } else {
                        avatar = "\(server)\(avatar1Str)"
                    }
                    let isFollow = response["isFollower"].stringValue
                    let countFollowers = response["countFollowers"].stringValue
                    let countFollowings = response["countFollowings"].stringValue
                    let bio = response["bio"].stringValue
                    
                    let fb = response["fb"].stringValue
                    let tw = response["tw"].stringValue
                    let ins = response["in"].stringValue
                    let vic_count = response["vic_count"].stringValue
                    let poster = User(id: id,username: username,password: password,email: email,first_name: first_name,last_name: last_name,lat: lat,long: long,birthday: birthday,phone: phone,token: token,avatar: avatar,isFollow:isFollow,countFollowers:countFollowers,countFollowings:countFollowings,bio:bio,fb:fb,ins:ins,tw:tw,vic_count:vic_count)
                    poster.isBlocked = response["is_block"].boolValue
                    
                    let callout = CallOut(id: postid, poster: poster, post_id: post_id,title: title, category: category, duration: duration, video: video, thumb: thumb, challenge_video: video1, challenge_thumb: thumb1, avg_rating_poster: avg_rating_poster, avg_rating_chall: avg_rating_chall, your_rating_poster: your_rating_poster, your_rating_chall: your_rating_chall, isChallenge: isChallenge,format:format, your_vote: your_vote, cnt_poster: cnt_vote_poster, cnt_challenger: cnt_vote_challenger)
                    callout.views = value["views"].stringValue
                    callout.isExpired = value["isExpired"].boolValue
                    callout.keyword = value["keyword"].stringValue
                    if type == "content"
                    {
                        callout.isActive = value["isActive"].boolValue
                    }
                    if value["challenger"].exists() && value["challenger"].count > 0
                    {
                        let response = value["challenger"]
                        let id1 = response["id"].intValue
                        let username1 = response["username"].stringValue
                        let password1 = response["password"].stringValue
                        let email1 = response["email"].stringValue
                        let first_name1 = response["first_name"].stringValue
                        let last_name1 = response["last_name"].stringValue
                        let lat1 = response["lat"].stringValue
                        let long1 = response["long"].stringValue
                        let birthday1 = response["birthday"].stringValue
                        let phone1 = response["phone"].stringValue
                        let token1 = response["token"].stringValue
                        var avatar1: String
                        let avatar1Str = response["avatar"].stringValue
                        if avatar1Str.hasPrefix(server) {
                            avatar1 = avatar1Str
                        } else {
                            avatar1 = "\(server)\(avatar1Str)"
                        }
                        let isFollow1 = response["isFollower"].stringValue
                        let countFollowers1 = response["countFollowers"].stringValue
                        let countFollowings1 = response["countFollowings"].stringValue
                        let bio1 = response["bio"].stringValue
                        let fb1 = response["fb"].stringValue
                        let tw1 = response["tw"].stringValue
                        let ins1 = response["in"].stringValue
                        let vic_count1 = response["vic_count"].stringValue
                        let challenger = User(id: id1,username: username1,password: password1,email: email1,first_name: first_name1,last_name: last_name1,lat: lat1,long: long1,birthday: birthday1,phone: phone1,token: token1,avatar: avatar1,isFollow:isFollow1,countFollowers:countFollowers1,countFollowings:countFollowings1,bio:bio1,fb:fb1,ins:ins1,tw:tw1,vic_count:vic_count1)
                        
                        challenger.isBlocked = response["is_block"].boolValue
                        
                        callout.challenger = challenger
                    }
                    
                    output.append(callout)
                }
                
                handler(true,output)
            }
        }
    }
    func verifyEmail(email:String,handler:@escaping(_ flag:Bool,_ code:String)->Void)
    {
        let requestString = serverUrl
        Alamofire.request(requestString, method: .post, parameters: ["service": "emailverify", "email":email]).responseSwiftyJSON { (data) in
            guard let userData = data.value else {
                handler(false,"")
                return
            }
            let result = userData["status"].stringValue
            if result == "Error"
            {
                handler(false,"")
            }
            else{
                handler(true,userData["code"].stringValue)
            }
        }
    }
    
    func resetPassword(email:String,password:String,handler:@escaping(_ flag:Bool)->Void)
    {
        let requestString = serverUrl
        Alamofire.request(requestString, method: .post, parameters: ["service": "resetpassword",  "email":email,"password":password]).responseSwiftyJSON { (data) in
            guard let userData = data.value else {
                handler(false)
                return
            }
            let result = userData["status"].stringValue
            if result == "Error"
            {
                handler(false)
            }
            else{
                handler(true)
            }
        }
    }
    
    func changeEmail(userid:String,email:String,handler:@escaping(_ flag:Bool)->Void)
    {
        let requestString = serverUrl
        Alamofire.request(requestString, method: .post, parameters: ["service": "changeemail",  "userid":userid,"email":email]).responseSwiftyJSON { (data) in
            guard let userData = data.value else {
                handler(false)
                return
            }
            let response = userData["status"].stringValue
            if response == "Error"
            {
                handler(false)
            }
            else{
                handler(true)
            }
        }
    }
    
    func declineCallout(userId: String, post_id: String, handler:@escaping(_ flag:Bool)->Void) {
        let requestString = serverUrl
        Alamofire.request(requestString, method: .post, parameters: ["service": "declinecallouts",  "userid":userId,"post_id":post_id]).responseSwiftyJSON { (data) in
            guard let userData = data.value else {
                handler(false)
                return
            }
            let response = userData["status"].stringValue
            if response == "Error"
            {
                handler(false)
            }
            else{
                handler(true)
            }
        }
    }
    
    func reportContent(userid:String,type:String,postid:String,content:String,handler:@escaping(_ result:Bool)->Void)
    {
        if type == "1"
        {
            Alamofire.request(serverUrl, method: .post, parameters: ["service": "report",  "userid":userid,"challenge_id":postid,"report":content]).responseSwiftyJSON { (data) in
                guard let userData = data.value else {
                    handler(false)
                    return
                }
                print (userData)
                let response = userData["status"].stringValue
                if response == "Error"
                {
                    handler(false)
                }
                else{
                    handler(true)
                }
            }
        }
        else if type == "0"
        {
            Alamofire.request(serverUrl, method: .post, parameters: ["service": "report","userid":userid,"post_id":postid,"report":content]).responseSwiftyJSON { (data) in
                guard let userData = data.value else {
                    handler(false)
                    return
                }
                print (userData)
                let response = userData["status"].string
                if response == "Error"
                {
                    handler(false)
                }
                else{
                    handler(true)
                }
            }
        }
    }
    
    func resetNotification(userid: Int, handler:@escaping(_ result:Bool)->Void) {
        Alamofire.request(serverUrl, method: .post, parameters: ["service": "resetbadge", "userid": userid]).responseSwiftyJSON { (data) in
            guard let userData = data.value else {
                handler(false)
                return
            }
            
            let response = userData["status"].stringValue
            
            if response == "Success" {
                handler(true)
            } else {
                handler(false)
            }
        }
    }
    
    func getUnreadNotificationCount(userid: Int, handler:@escaping(_ result:Int)->Void) {
        Alamofire.request(serverUrl, method: .post, parameters: ["service": "gettbadge", "userid": userid]).responseSwiftyJSON { (data) in
            guard let userData = data.value else {
                handler(0)
                return
            }
            
            let response = userData["status"].stringValue
            
            if response == "Success" {
                handler(userData["badge"].intValue)
            } else {
                handler(0)
            }
        }
    }
}
