//
//  NotificationVC.swift
//  Call Me Out
//
//  Created by B S on 4/4/18.
//  Copyright © 2018 B S. All rights reserved.
//

import UIKit
import ProgressHUD

class NotificationVC: UIViewController {
    
    @IBOutlet weak var tblViNotifications: UITableView!
    @IBOutlet weak var viLoading: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var lblLoading: UILabel!
    
    var results = [NotificationObj]()
    override func viewDidLoad() {
        super.viewDidLoad()

        tblViNotifications.tableFooterView = UIView()
        
        tblViNotifications.register(UINib(nibName: "NotificationCell", bundle: nil), forCellReuseIdentifier: "NotificationCell")        
    }

    @objc func updateNotificaion()
    {
        Global.shared.getNotification(userid: String((Global.getUserDataFromLocal()?.id)!), handler: { (result) in
            
            self.results = result
            
            self.results.sort(by: { (notiObj1, notiObj2) -> Bool in
                return notiObj1.time > notiObj2.time
            })
            
            self.tblViNotifications.reloadData()
        })
        
        Global.shared.resetNotification(userid: (Global.getUserDataFromLocal()?.id)!) { (bool) in
            if bool {
                UIApplication.shared.applicationIconBadgeNumber = 0
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "receive_notification1"), object: nil)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateNotificaion), name: NSNotification.Name(rawValue: "receive_notification"), object: nil)
        
        SlideNavigationController.sharedInstance().enableSwipeGesture = false
        
        ProgressHUD.show("Loading...", interaction: false)
        Global.shared.getNotification(userid: String((Global.getUserDataFromLocal()?.id)!), handler: { (result) in
            ProgressHUD.dismiss()
            
            self.results = result
            
            self.results.sort(by: { (notiObj1, notiObj2) -> Bool in
                return notiObj1.time > notiObj2.time
            })
            
            self.tblViNotifications.reloadData()
        })

        Global.shared.resetNotification(userid: (Global.getUserDataFromLocal()?.id)!) { (bool) in
            if bool {
                UIApplication.shared.applicationIconBadgeNumber = 0
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "receive_notification"), object: nil)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        SlideNavigationController.sharedInstance().enableSwipeGesture = true
        
        NotificationCenter.default.removeObserver(self)
    }
    
//
//    func filter()
//    {
//        for result in results
//        {
//            let type = result["type"] as! Int
//            if type == 2
//            {
//
//            }
//        }
//    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onShowLeftMenu(_ sender: Any) {
        SlideNavigationController.sharedInstance().open(MenuLeft, withCompletion: nil)
    }
}

extension NotificationVC:UITableViewDelegate,UITableViewDataSource
{
    //Action
    @objc func tapDetected(gesture: UITapGestureRecognizer ) {
        let index = (gesture.view?.tag)! - 10
        
        
        if index > -1 {
            let data = results[index]

            if data.action == "Following" || data.action == "createGroup" {
                return
            }

            if Date().timeIntervalSince1970 - (data.post?.creation_date)! > 24*60*60*7 {
                if data.action == "Accept" || data.action == "FollowerAccept" || data.action == "DirectChallenge"{
                    ProgressHUD.show()
                    Global.shared.getArchive(userID: (Global.getUserDataFromLocal()?.id)!, last_id: "0",type: "0", category: "All", duration: "0",keyword:"") { (flag, result) in
                        ProgressHUD.dismiss()
                        if flag && result != nil{
                            var tapChallenge: CallOut?
                            
                            if let callouts = result {
                                for callout in callouts {
                                    if "\(data.challenge?.challenge_id ?? 0)" == callout.id {
                                        tapChallenge = callout
                                        break
                                    }
                                }
                            }
                            
                            if tapChallenge != nil {
                                ProgressHUD.show()
                                Global.shared.updateViewCount(id: tapChallenge!.id, completionHandler: {
                                    Global.shared.getChallengeItem(userid: String((Global.getUserDataFromLocal()?.id)!), id: tapChallenge!.id, handler: { (callout) in
                                        ProgressHUD.dismiss()
                                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "VoteVC") as! VoteVC
                                        vc.callout = callout!
                                        self.present(vc, animated: true, completion: nil)
                                    })
                                })
                                
                            }
                        }
                    }
                } else if data.action == "SingleCalledOut" || data.action == "Private" || data.action == "CalledOut" || data.action == "FollowCalledOut" || data.action == "Decline" {
                    self.view.makeToast("Sorry, it’s too late to Challenge this Call Out!")
                } else {
                    Global.shared.getItem(userid: "\((Global.getUserDataFromLocal()?.id)!)", id: "\(data.post?.id ?? 0)") { (callout) in
                        ProgressHUD.dismiss()
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "VoteVC") as! VoteVC
                        vc.callout = callout
                        self.present(vc, animated: true, completion: nil)
                        
                    }
                }
                return
            }
            
            if data.action == "Accept" || data.action == "FollowerAccept" || data.action == "DirectChallenge" {
                ProgressHUD.show()
                
                Global.shared.getChallengeItems(userid: "\((data.challenge?.challenger.id)!)") { (challenges) in
                    ProgressHUD.dismiss()
                    var tapChallenge: CallOut?
                    
                    for callout in challenges {
                        if "\(data.challenge?.challenge_id ?? 0)" == callout.id {
                            tapChallenge = callout
                            break
                        }
                    }
                    
                    if tapChallenge != nil {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "VoteVC") as! VoteVC
                        vc.callout = tapChallenge
                        self.present(vc, animated: true, completion: nil)
                    }
                }

                /*
                Global.shared.getPost(userID: (Global.getUserDataFromLocal()?.id)!, last_id: "0", type: "0", category: "All", duration: "0",keyword: "") { (flag, result) in
                    
                    ProgressHUD.dismiss()
                    var tapChallenge: CallOut?
                    
                    if let callouts = result {
                        for callout in callouts {
                            if "\(data.challenge?.challenge_id ?? 0)" == callout.id {
                                tapChallenge = callout
                                break
                            }
                        }
                    }
                    
                    if tapChallenge != nil {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "VoteVC") as! VoteVC
                        vc.callout = tapChallenge
                        self.present(vc, animated: true, completion: nil)
                    }
                }*/
                
            } else if data.action == "SingleCalledOut" || data.action == "Private" || data.action == "CalledOut" || data.action == "FollowCalledOut" || data.action == "Decline" {
                ProgressHUD.show()

                if data.isChallenged {
                    Global.shared.getChallengeItems(userid: "\((Global.getUserDataFromLocal()?.id)!)") { (challenges) in
                        ProgressHUD.dismiss()
                        var tapChallenge: CallOut?
                        
                        for challenge in challenges {
                            if challenge.post_id == "\(data.post?.id ?? 0)" {
                                tapChallenge = challenge
                                break
                            }
                        }
                        
                        if tapChallenge != nil {
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "VoteVC") as! VoteVC
                            vc.callout = tapChallenge
                            self.present(vc, animated: true, completion: nil)
                        }
                    }
                } else {
                    Global.shared.getItem(userid: "\((Global.getUserDataFromLocal()?.id)!)", id: "\(data.post?.id ?? 0)") { (callout) in
                        ProgressHUD.dismiss()
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "VoteVC") as! VoteVC
                        vc.callout = callout
                        self.present(vc, animated: true, completion: nil)

                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
        let data = results[indexPath.row]
        
        cell.imgViInitator.sd_setImage(with: URL(string: data.sender?.avatar ?? ""), completed: nil)
        
        cell.imgViCalloutThumb.sd_setImage(with: URL(string: (data.post?.thumb ?? "")), completed: nil)
        
        if data.post?.format == "audio" {
            cell.imgViCalloutThumb.image = #imageLiteral(resourceName: "iconAudioGray.png")
        }
        
        let viewCalloutTap = UITapGestureRecognizer(target: self, action: #selector(tapDetected(gesture:)))
        cell.imgViCalloutThumb.isUserInteractionEnabled = true
        cell.imgViCalloutThumb.addGestureRecognizer(viewCalloutTap)
        cell.imgViCalloutThumb.tag = indexPath.row + 10
        
        cell.lblUserName.text = data.sender?.username
        
        let action = data.action
        let username = data.sender?.username ?? ""
        
        if action == "SingleCalledOut"
        {
//            let message = "It is on! You have been called out by \(username) on CallMeOut.com. Tap to accept or decline. Tap image to view Call Out. You have 48 hours to accept the challenge. Your followers and friends know you have been \"Called Out\", show them you are up for the challenge."
            
            let formattedString = NSMutableAttributedString()
            formattedString
                        .normal("It is on! You have been called out by \(username) on CallMeOut.com. Tap ")
                        .bold("here ")
                        .normal("to accept or decline. Tap image to view Call Out. You have 48 hours to accept the challenge. Your followers and friends know you have been \"Called Out\", show them you are up for the challenge.")
            
            cell.lblMessage.attributedText = formattedString
        } else if action == "CalledOut" || action == "Private" {
            let formattedString = NSMutableAttributedString()
            formattedString
                        .normal("It is on! You and a few other users have been called out by \(username) on CallMeOut.com. Tap ")
                        .bold("here ")
                        .normal("to accept or decline. Tap image to view Call Out. You have 48 hours to accept the challenge. Your followers and friends know you have been \"Called Out\", show them you are up for the challenge.")
            
//            let message = "It is on! You and a few other users have been called out by \(username) on CallMeOut.com. Tap to accept or decline. Tap image to view Call Out. You have 48 hours to accept the challenge. Your followers and friends know you have been \"Called Out\", show them you are up for the challenge."
            
//            cell.lblMessage.text = message
            cell.lblMessage.attributedText = formattedString
        } else if action == "Accept" {
            let message = "It just got real! \(username) has accepted your \(data.post?.title ?? "") call out."
            
            cell.lblMessage.text = message
        } else if action == "createGroup" {
            let message = "You have been added to a private group. \(username) has inclouded you in a private group on the CallMeOut.com app. Members of the group are the only ones who can vote view and comment on private group challenges. If you are not already a user, then join in on the fun and download the app for Apple app Store. (Android coming soon!)"
            
            cell.imgViCalloutThumb.image = nil
            cell.imgViCalloutThumb.isHidden = true
            
            cell.lblMessage.text = message
        } else if action == "FollowerAccept" {
            let message = "Oh Snap! \(data.challenge?.challenger.username ?? "") has been called out by \(data.post?.poster_name ?? "Someone"), and the challenge has been accepted! Make sure you vote to decide the winner. To vote go to the their profile or search for \(data.post?.title ?? "") on the home page."
            
            cell.lblMessage.text = message
        } else if action == "FollowCalledOut" {
            let message = "\(username) has called out someone on CallMeOut.com."
            
            cell.lblMessage.text = message
        } else if action == "Decline"{
            let message = "They're just not feeling it! \(username) has declined your \(data.post?.title ?? "") Call out!"
            cell.lblMessage.text = message
        } else if action == "Following" {
            let message = "Nice! \(username) is now following you!"
            cell.lblMessage.text = message
            
            cell.imgViCalloutThumb.image = nil
            cell.imgViCalloutThumb.isHidden = true
        } else if action == "DirectChallenge" {
            let message = "\(username) has challenged you! Check out what they did and be sure to vote!"
            cell.lblMessage.text = message
        } else {
            cell.imgViCalloutThumb.image = nil
            cell.imgViCalloutThumb.isHidden = true
            print (action)
        }
        
        var creationDate: Date

        creationDate = Date(timeIntervalSince1970: data.time)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone.local
        
        let timeStamp = dateFormatter.string(from: creationDate)
        
        let localTime = dateFormatter.date(from: timeStamp)
        
        cell.lblTime.text = dateTimeAgo(date: localTime ?? Date())
        cell.lblMessage.sizeToFit()
        
        cell.imgViInitator.layer.masksToBounds = true
        cell.imgViInitator.layer.cornerRadius = cell.imgViInitator.frame.size.height / 2.0;
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let result = results[indexPath.row]
        let type = result.action
        let username = (result.sender?.username)!
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.width - 140, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.systemFont(ofSize: 12)
        
        if type == "SingleCalledOut"
        {
            let message = "It is on! You have been called out by \(username) on CallMeOut.com. Tap Here to accept or decline. Tap image to view Call Out. You have 48 hours to accept the challenge. Your followers and friends know you have been \"Called Out\", show them you are up for the challenge. "
            
            label.text = message
            label.sizeToFit()
            return label.frame.height + 40 > 60 ? label.frame.height + 50:80
        } else if type == "CalledOut" || type == "Private" {
            let message = "It is on! You and a few other users have been called out by \(username) on CallMeOut.com. Tap Here to accept or decline. Tap image to view Call Out. You have 48 hours to accept the challenge. Your followers and friends know you have been \"Called Out\", show them you are up for the challenge. "
            label.text = message
            label.sizeToFit()
            return label.frame.height + 40 > 60 ? label.frame.height + 50:80
        } else if type == "Accept" {
            let message = "It just got real! \(username) has accepted your \(result.post?.title ?? "") call out."
            
            label.text = message
            label.sizeToFit()
            
            return label.frame.height + 40 > 60 ? label.frame.height + 50:80
        } else if type == "createGroup" {
            let message = "You have been added to a private group. \(username) has inclouded you in a private group on the CallMeOut.com app. Members of the group are the only ones who can vote view and comment on private group challenges. If you are not already a user, then join in on the fun and download the app for Apple app Store. (Android coming soon!)"
            
            label.text = message
            label.sizeToFit()
            
            return label.frame.height + 40 > 60 ? label.frame.height + 50:80
        } else if type == "FollowerAccept" {
            let message = "Oh Snap! \(result.challenge?.challenger.username ?? "") has been called out by \(username), and the challenge has been accepted! Make sure you vote to decide the winner. To vote go to the their profile or search for \(result.post?.title ?? "") on the home page."
            
            label.text = message
            label.sizeToFit()
            
            return label.frame.height + 40 > 60 ? label.frame.height + 50:80
        } else if type == "FollowCalledOut" {
            let message = "\(username) has called out someone on CallMeOut.com."
            
            label.text = message
            label.sizeToFit()
            
            return label.frame.height + 40 > 60 ? label.frame.height + 50:80
        } else if type == "Decline"{
            let message = "They're just not feeling it! \(username) has declined your \(result.post?.title ?? "") Call out!"
            label.text = message
            label.sizeToFit()
            
            return label.frame.height + 40 > 60 ? label.frame.height + 50:80
        }  else if type == "Following" {
            let message = "Nice! \(username) is now following you!"
            label.text = message
            label.sizeToFit()
            
            return label.frame.height + 40 > 60 ? label.frame.height + 50:80
        } else if type == "DirectChallenge" {
            let message = "\(username) has challenged you! Check out what they did and be sure to vote!"
            label.text = message
            label.sizeToFit()
            
            return label.frame.height + 40 > 60 ? label.frame.height + 50:80
        }
        else
        {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let result = results[indexPath.row]
//        if result["type"] as! Int == 3 || result["type"] as! Int == 2{
//            return
//        }
        
        if result.action == "Following" || result.action == "createGroup" {
            return
        }
        
        if Date().timeIntervalSince1970 - (result.post?.creation_date)! > 24*60*60*7 {
            self.view.makeToast("Sorry, it’s too late to Challenge this Call Out!")
            return
        }
        
        if result.action == "CalledOut" || result.action == "SingleCalledOut" || result.action == "Private" {
            
//            if result.isChallenged {
//                self.view.makeToast("You have already challenged this call out")
//                return
//            }
            
            ProgressHUD.show("")
            Global.shared.getItem(userid: String((Global.getUserDataFromLocal()?.id)!), id: "\((result.post?.id)!)") { (r) in
                ProgressHUD.dismiss()
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "AcceptCallVC") as! AcceptCallVC
                vc.isChallenged = result.isChallenged
                vc.callout = r
                self.present(vc, animated: true, completion: nil)
            }
        }
/*
        if result["can"] as! Bool
        {
            if result["expired"] as! Bool
            {
                self.view.makeToast("This Call Out has already expired")
                return
            }
            ProgressHUD.show("")
            Global.shared.getItem(userid: String((Global.getUserDataFromLocal()?.id)!), id: result["id"] as! String) { (r) in
                ProgressHUD.dismiss()
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "AcceptCallVC") as! AcceptCallVC
                vc.callout = r
//                vc.isNotification = true
                self.present(vc, animated: true, completion: nil)
            }
        }
        else
        {
            ProgressHUD.show("")
            Global.shared.getItem(userid: String((Global.getUserDataFromLocal()?.id)!), id: result["id"] as! String) { (r) in
                ProgressHUD.dismiss()
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "VoteVC") as! VoteVC
                vc.callout = r
                self.present(vc,animated:true,completion:nil)
            }
        }*/
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let result = results[indexPath.row]
            Global.shared.deleteNotification(notification_id: result.notificationId) {
                self.results.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
}
